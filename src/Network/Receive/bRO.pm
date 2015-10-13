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
	'0365', '0862',	'088C', '0930',	'0891', '0437',	'0966', '0835',	'0883', '0888',	'092D', '095D',	'08A3', '088F',	'092A', '0919',	'0926', '089D',	'0965', '094B',	'0893', '0954',	'086B', '0921',	'0939', '0918',	'0958', '0946',	'086A', '0892',	'08A7', '0928',	'0955', '0364',	'0865', '095B',	'092F', '0962',	'091D', '089E',	'085B', '0899',	'0436', '0815',	'02C4', '0884',	'0920', '0879',	'0917', '086F',	'08AD', '083C',	'094A', '089A',	'092E', '0957',	'095A', '093C',	'0931', '0929',	'07EC', '0935',	'0886', '0363',	'0942', '08AA',	'0361', '0873',	'085E', '0944',	'0880', '0963',	'0948', '08A6',	'0866', '0960',	'0360', '0941',	'0882', '089C',	'07E4', '089B',	'091A', '087D',	'0876', '0953',	'0366', '0894',	'093A', '0885',	'092B', '0959',	'0362', '08A4',	'093F', '0964',	'08A1', '095C',	'0281', '0838',	'0802', '0934',	'088B', '0875',	'087C', '0968',	'0878', '0869',	'0945', '08A2',	'08A5', '0369',	'0936', '0933',	'0874', '087A',	'085C', '022D',	'0870', '089F',	'086D', '0923',	'094D', '091E',	'0817', '0924',	'0867', '091C',	'0951', '0947',	'0811', '0861',	'0898', '086C',	'0895', '0961',	'08A8', '08AB',	'0202', '095F',	'0890', '0819',	'0871', '023B',	'095E', '0872',	'088A', '0940',	'088E', '0881',	'0897', '093D',	'0868', '087F',	'0949', '085F',	'085A', '0969',	'0438', '092C',	'0932', '0863',	'0950', '091F',	'0877', '094C',	'087E', '0937',
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
