#########################################################################
#  OpenKore - Default error handler
#
#  Copyright (c) 2006 OpenKore Development Team
#
#  This software is open source, licensed under the GNU General Public
#  License, version 2.
#  Basically, this means that you're allowed to modify and distribute
#  this software. However, if you distribute modified versions, you MUST
#  also distribute the source code.
#  See http://www.gnu.org/licenses/gpl.html for the full license.
#########################################################################
##
# MODULE DESCRIPTION: Default error handler.
#
# This module displays a nice error dialog to the user if the program crashes
# unexpectedly.
#
# To use this feature, simply type 'use ErrorHandler'.
package ErrorHandler;

use strict;
use Carp;
use Scalar::Util;
use Globals;
use encoding 'utf8';
use Translation;

sub showError {
	$net->serverDisconnect() if ($net);

	if (!$Globals::interface || UNIVERSAL::isa($Globals::interface, "Interface::Startup") || UNIVERSAL::isa($Globals::interface, "Interface::Socket")) {
		print TF("%s\nPress ENTER to exit this program.\n", $_[0]);
		<STDIN>;
	} else {
		$Globals::interface->errorDialog($_[0]);
	}
}

sub errorHandler {
	return unless (defined $^S && $^S == 0);
	my $e = $_[0];

	# Get the error message, and extract file and line number.
	my ($file, $line, $errorMessage);
	if (UNIVERSAL::isa($e, 'Exception::Class::Base')) {
		$file = $e->file;
		$line = $e->line;
		$errorMessage = $e->message;
	} else {
		($file, $line) = $e =~ / at (.+?) line (\d+)\.$/;
		# Get rid of the annoying "@INC contains:"
		$errorMessage = $e;
		$errorMessage =~ s/ \(\@INC contains: .*\)//;
	}
	$errorMessage =~ s/[\r\n]+$//s;

	# Create the message to be displayed to the user.
	my $display = TF("This program has encountered an unexpected problem. This is expected to happen\n" .
					 "while using BetaKore. Please, report this at the following address:\n" .
					 "https://code.google.com/p/betakore/issues/list\n".
					 "Please check for logs inside errors.txt and post them too.\n".
	                 "The error message is:\n" .
	                 "%s",
	                 $errorMessage);

	# Create the errors.txt error log.
	my $log = '';
	$log .= "$Settings::NAME version ${Settings::VERSION}${Settings::SVN}\n" if (defined $Settings::VERSION);
	$log .= "\@ai_seq = @Globals::ai_seq\n" if (defined @Globals::ai_seq);
	$log .= "Network state = $Globals::conState\n" if (defined $Globals::conState);
	$log .= "Network handler = " . Scalar::Util::blessed($Globals::net) . "\n" if ($Globals::net);
	my $revision = defined(&Settings::getSVNRevision) ? Settings::getSVNRevision() : undef;
	if (defined $revision) {
		$log .= "SVN revision: $revision\n";
	} else {
		$log .= "SVN revision: unknown\n";
	}
	if (defined @Plugins::plugins) {
		$log .= "Loaded plugins:\n";
		foreach my $plugin (@Plugins::plugins) {
			next if (!defined $plugin);
			$log .= "  $plugin->{filename} ($plugin->{name}; description: $plugin->{description})\n";
		}
	} else {
		$log .= "No loaded plugins.\n";
	}
	$log .= "\nError message:\n$errorMessage\n\n";

	# Add stack trace to errors.txt.
	if (UNIVERSAL::isa($e, 'Exception::Class::Base')) {
		$log .= "Stack trace:\n";
		$log .= $e->trace();
	} elsif (defined &Carp::longmess) {
		$log .= "Stack trace:\n";
		my $e = $errorMessage;
		$log .= Carp::longmess("$e\n");
	}
	$log =~ s/\n+$//s;

	# Find out which line died.
	if (defined $file && defined $line && -f $file && open(F, "<", $file)) {
		my @lines = <F>;
		close F;

		my $msg;
		$msg .= "  $lines[$line-2]" if ($line - 2 >= 0);
		$msg .= "* $lines[$line-1]";
		$msg .= "  $lines[$line]" if (@lines > $line);
		$msg .= "\n" unless $msg =~ /\n$/s;
		$log .= TF("\n\nDied at this line:\n%s\n", $msg);
	}

	if (open(F, ">:utf8", "errors.txt")) {
		print F $log;
		close F;
	}
	showError($display);
}

$SIG{__DIE__} = \&errorHandler;

1;
