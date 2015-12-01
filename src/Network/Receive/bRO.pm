#############################################################################
#  OpenKore - Network subsystem												#
#  This module contains functions for sending messages to the server.		#
#																			#
#  This software is open source, licensed under the GNU General Public		#
#  License, version 2.														#
#  Basically, this means that you're allowed to modify and distribute		#
#  this software. However, if you distribute modified versions, you MUST	#
#  also distribute the source code.											#
#  See http://www.gnu.org/licenses/gpl.html for the full license.			#
#############################################################################
# bRO (Brazil)
package Network::Receive::bRO;
use strict;
use Log qw(warning);
use base 'Network::Receive::ServerType0';


# Sync_Ex algorithm developed by Fr3DBr

sub new {
	my ($class) = @_;
	my $self = $class->SUPER::new(@_);
	
	my %packets = (
		'0097' => ['private_message', 'v Z24 V Z*', [qw(len privMsgUser flag privMsg)]], # -1
);
# Sync Ex Reply Array 
	$self->{sync_ex_reply} = {
	'0942', '0950',	'088E', '0965',	'0898', '088F',	'0899', '08AC',	'08AB', '0889',	'08A0', '0946',	'0861', '0894',	'0363', '0838',	'0936', '0930',	'091D', '0202',	'08A6', '0928',	'0886', '086A',	'0953', '0897',	'0881', '0932',	'0802', '093B',	'0811', '0937',	'0966', '085C',	'0941', '0884',	'092D', '094E',	'0962', '0938',	'0867', '091A',	'0896', '08A1',	'0281', '083C',	'091B', '093E',	'0949', '0860',	'085D', '0872',	'0964', '091C',	'087D', '08A3',	'0925', '0866',	'0929', '094A',	'0865', '08AA',	'0879', '08AD',	'0919', '07EC',	'0365', '0864',	'0922', '085B',	'0926', '0871',	'0874', '0883',	'0947', '0870',	'087B', '092A',	'0967', '093F',	'0862', '087A',	'0931', '0968',	'0875', '092E',	'095E', '08A9',	'0360', '08A8',	'08A7', '095C',	'087E', '0362',	'0923', '0939',	'093A', '087F',	'0895', '095D',	'0920', '092B',	'0366', '0361',	'023B', '092F',	'0969', '0817',	'086F', '0869',	'092C', '0891',	'0924', '0438',	'0892', '0888',	'0945', '0887',	'08A5', '088B',	'0952', '0873',	'0436', '0893',	'088C', '085E',	'0368', '0367',	'0934', '091E',	'0954', '0863',	'0877', '087C',	'089C', '089A',	'0943', '0437',	'0921', '086B',	'0951', '0815',	'095B', '094C',	'095A', '0918',	'094F', '0835',	'088D', '02C4',	'0364', '0819',	'0927', '08A4',	'0880', '085F',	'0878', '094D',	'0961', '022D',	'089D', '0882',	'0940', '0960',	'088A', '08A2',	'094B', '0957',
	};
	
	foreach my $key (keys %{$self->{sync_ex_reply}}) { $packets{$key} = ['sync_request_ex']; }
	foreach my $switch (keys %packets) { $self->{packet_list}{$switch} = $packets{$switch}; }
	return $self;
}

sub items_nonstackable {
	my ($self, $args) = @_;

	my $items = $self->{nested}->{items_nonstackable};

	if($args->{switch} eq '00A4' || $args->{switch} eq '00A6' || $args->{switch} eq '0122') {
		return $items->{type4};
	} elsif ($args->{switch} eq '0295' || $args->{switch} eq '0296' || $args->{switch} eq '0297') {
		return $items->{type4};
	} elsif ($args->{switch} eq '02D0' || $args->{switch} eq '02D1' || $args->{switch} eq '02D2') {
		return  $items->{type4};
	} else {
		warning("items_nonstackable: unsupported packet ($args->{switch})!\n");
	}
}

*parse_quest_update_mission_hunt = *Network::Receive::ServerType0::parse_quest_update_mission_hunt_v2;
*reconstruct_quest_update_mission_hunt = *Network::Receive::ServerType0::reconstruct_quest_update_mission_hunt_v2;

1;
