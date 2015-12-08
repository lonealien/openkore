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
	'022D', '089F',	'0874', '094A',	'085F', '0281',	'0899', '089C',	'0368', '085D',	'0835', '0364',	'0838', '0885',	'0896', '095F',	'089E', '088F',	'0883', '0877',	'095C', '0811',	'086D', '0438',	'088B', '0897',	'0918', '0802',	'087F', '092C',	'0868', '0437',	'0893', '092B',	'0949', '08A0',	'0924', '095B',	'087D', '093A',	'0928', '093D',	'0881', '0819',	'0867', '0875',	'091C', '087C',	'0880', '08AC',	'0878', '094C',	'0965', '0952',	'095E', '023B',	'0937', '085C',	'0894', '0879',	'0944', '092F',	'0922', '0960',	'0367', '0934',	'0890', '0954',	'0862', '0362',	'087A', '0968',	'092E', '094F',	'0369', '0950',	'086E', '0964',	'0963', '0951',	'0895', '0925',	'093E', '086F',	'0955', '0920',	'0864', '0365',	'0962', '035F',	'0957', '0865',	'0967', '0940',	'0932', '094D',	'0942', '0961',	'0870', '094B',	'0436', '091B',	'091E', '0969',	'091F', '083C',	'0966', '094E',	'0941', '0936',	'085A', '093B',	'092A', '08AA',	'0927', '0860',	'0917', '0888',	'0891', '086A',	'093C', '089A',	'08A4', '0876',	'0882', '0931',	'0953', '0863',	'0919', '086B',	'0363', '0959',	'0939', '0933',	'0938', '0869',	'0935', '08A8',	'088D', '086C',	'08A9', '08A1',	'091A', '0871',	'0815', '0930',	'0817', '08A7',	'07EC', '088C',	'089D', '08A6',	'0202', '0889',	'095A', '08A2',	'08AD', '0887',	'0366', '093F',	'0892', '088E',	'095D', '0926',	'088A', '0958',	'0945', '0943',
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
