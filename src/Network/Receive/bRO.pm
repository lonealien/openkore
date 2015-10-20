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
	'0919', '0949',	'088F', '089E',	'0865', '095B',	'08AD', '0888',	'092B', '0962',	'0862', '0956',	'088B', '087D',	'088C', '093D',	'08A3', '085A',	'0364', '0967',	'0894', '0875',	'089F', '087B',	'089A', '095E',	'08A8', '08AB',	'02C4', '0943',	'0934', '07EC',	'0882', '0360',	'0436', '093C',	'087F', '08A0',	'0932', '094E',	'0890', '0963',	'0863', '0899',	'088A', '0889',	'0965', '08AC',	'087C', '0966',	'0895', '0969',	'0365', '0887',	'0361', '0881',	'0930', '093A',	'095C', '096A',	'091C', '023B',	'0936', '0950',	'086D', '092E',	'0892', '0953',	'0838', '094C',	'0369', '085E',	'0957', '0955',	'0878', '0866',	'0281', '0917',	'0948', '0363',	'088E', '0942',	'035F', '0869',	'0961', '0368',	'0877', '0879',	'08A5', '0437',	'0926', '0946',	'0940', '0952',	'0366', '092D',	'0959', '0923',	'0860', '093E',	'0886', '0944',	'0884', '0883',	'0867', '0937',	'0874', '0938',	'0897', '089C',	'0968', '0438',	'0880', '0367',	'0872', '08A7',	'0817', '0871',	'0933', '086E',	'089B', '086A',	'0958', '0815',	'0918', '0861',	'08A2', '0925',	'095D', '08A1',	'08A6', '0945',	'085F', '0811',	'0868', '087A',	'086C', '085D',	'091B', '083C',	'095A', '093B',	'0362', '092A',	'0873', '0864',	'094F', '0202',	'0870', '0924',	'091E', '088D',	'0891', '085B',	'0898', '086F',	'0935', '092C',	'094D', '0876',	'0835', '087E',	'091F', '0947',	'091A', '0929',	'091D', '0802',
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
