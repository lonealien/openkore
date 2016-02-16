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
	'088B', '0861',	'094C', '087B',	'086C', '0866',	'086F', '092B',	'0875', '0955',	'0966', '0964',	'093D', '0950',	'0960', '08A3',	'0945', '07EC',	'08A0', '0943',	'086D', '0867',	'0935', '091D',	'092F', '0882',	'0923', '0872',	'092C', '089E',	'0889', '0961',	'0869', '087C',	'0936', '0369',	'0938', '094A',	'08A9', '0874',	'0870', '095A',	'0815', '0884',	'0365', '088C',	'0202', '0921',	'0962', '089B',	'0941', '0946',	'08A1', '0963',	'0933', '091C',	'091A', '089A',	'085F', '094B',	'0438', '0954',	'093C', '086B',	'092D', '0965',	'0897', '0928',	'0952', '095B',	'0360', '02C4',	'08AB', '094E',	'0894', '093A',	'0944', '0864',	'0926', '0871',	'0929', '0967',	'085E', '087F',	'0862', '0881',	'0368', '0956',	'0880', '08A6',	'095E', '0811',	'0890', '095F',	'087A', '0436',	'023B', '08A4',	'0949', '0958',	'0891', '085D',	'086A', '0937',	'092A', '0940',	'0883', '085C',	'0957', '0888',	'086E', '091F',	'0930', '092E',	'0931', '0364',	'08A5', '0367',	'0893', '0887',	'094F', '08A8',	'0885', '0920',	'0969', '0898',	'0281', '089C',	'088F', '0860',	'0939', '0924',	'091E', '0819',	'08A2', '0925',	'0895', '0918',	'08AC', '0947',	'093E', '0896',	'091B', '0948',	'088E', '0942',	'0934', '0868',	'0366', '0361',	'0362', '0437',	'094D', '0865',	'0835', '0927',	'0932', '085A',	'0959', '095C',	'0876', '096A',	'085B', '0863',	'083C', '0873',	'0953', '0951',
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
