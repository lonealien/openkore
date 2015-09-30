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
	'0962', '086C',	'08A7', '087A',	'0363', '096A',	'0878', '0869',	'0867', '0944',	'088B', '089B',	'094D', '0872',	'0959', '0369',	'0918', '08AA',	'0885', '0865',	'0957', '091C',	'089F', '023B',	'0861', '0945',	'088D', '092B',	'0953', '088F',	'095F', '094C',	'0919', '0921',	'0896', '089A',	'087D', '08AB',	'0960', '0943',	'0815', '07E4',	'0929', '085C',	'0879', '0898',	'093E', '0860',	'091F', '0948',	'0920', '035F',	'0946', '0949',	'087F', '083C',	'0862', '091A',	'094E', '0917',	'0952', '0360',	'0937', '091E',	'0893', '08A1',	'092F', '088A',	'093D', '0866',	'0897', '0926',	'091B', '08A8',	'0968', '0922',	'095A', '093B',	'095B', '0947',	'0969', '095D',	'0950', '092C',	'088C', '0884',	'094A', '08A0',	'0928', '086E',	'0880', '0934',	'08A9', '0366',	'0438', '08A6',	'0874', '085D',	'0364', '0942',	'0930', '0967',	'0964', '0923',	'0940', '0965',	'0870', '0938',	'0963', '0876',	'0802', '085F',	'0939', '093F',	'095E', '094B',	'0935', '089D',	'0362', '0936',	'07EC', '0281',	'02C4', '0835',	'086A', '0882',	'0941', '0895',	'0361', '0875',	'0367', '0954',	'0956', '0889',	'087C', '08A2',	'085A', '0933',	'0927', '08AC',	'0838', '0863',	'0899', '0202',	'0894', '087B',	'086B', '0955',	'093A', '0811',	'085E', '0871',	'0931', '093C',	'089C', '0817',	'0951', '092A',	'0864', '0886',	'0436', '0365',	'086F', '0868',	'086D', '0887',	'0819', '0873',
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
