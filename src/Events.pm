#########################################################################
#  BetaKore - Events
#  Copyright (c) 2014 BetaKore Developers
#
#  This software is open source, licensed under the GNU General Public
#  License, version 2.
#  Basically, this means that you're allowed to modify and distribute
#  this software. However, if you distribute modified versions, you MUST
#  also distribute the source code.
#  See http://www.gnu.org/licenses/gpl.html for the full license.
#
#########################################################################
##
# MODULE DESCRIPTION: identify, centalize and manage game events
#

package Events;

use strict;
use warnings;
use FindBin qw($RealBin);
use lib "$RealBin";
use lib "$RealBin/src";
use lib "$RealBin/src/deps";
use Modules 'register';

use Log qw(debug error message warning);

use Globals;
use Plugins;

sub new {
	my $class = shift;
	my %args = @_;
	my %self;
	
	$self{hooks} = Plugins::addHooks(
		['packet/inventory_item_added', \&inventory_bigger], 
		['packet/inventory_item_removed', \&inventory_smaller], 
		['packet/item_used', \&inventory_smaller], 
		['packet/inventory_items_stackable', \&inventory_changed], 
		['packet/inventory_items_nonstackable', \&inventory_changed], 
	);
	
	return bless \%self, $class;
}

sub inventory_bigger {
	debug "inventory got bigger! \n", 'events';
}

sub inventory_smaller {
	debug "inventory got smaller :( \n", 'events';
}

sub inventory_changed {
	debug "inventory changed, dunno if bigger or smaller \n", 'events';
}

sub DESTROY {
	my ($self) = @_;
	Plugins::delHooks($self->{hooks}) if $self->{hooks};
}

1;