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
	'0929', '086E',	'0893', '0362',	'0281', '0437',	'0365', '087A',	'0819', '092B',	'087B', '0367',	'0867', '091C',	'0957', '0368',	'094A', '0885',	'0923', '0937',	'0947', '022D',	'091E', '0871',	'095D', '0956',	'085D', '0361',	'087D', '0438',	'08A8', '096A',	'0921', '088F',	'086D', '0949',	'08A3', '0926',	'0958', '094C',	'088D', '088C',	'0948', '0894',	'08A9', '0363',	'0811', '035F',	'023B', '0938',	'0943', '0942',	'087C', '0917',	'085A', '0865',	'02C4', '0936',	'092F', '0918',	'0922', '0968',	'0925', '0864',	'0967', '089B',	'0919', '093F',	'085C', '0965',	'0861', '0962',	'0889', '091A',	'0966', '0928',	'08A7', '0890',	'0886', '089C',	'0436', '0817',	'0963', '0873',	'08AC', '0933',	'0955', '0364',	'086C', '0897',	'0881', '07E4',	'08A6', '0887',	'0888', '085F',	'08A5', '0953',	'0952', '0802',	'0891', '095A',	'0927', '0884',	'0879', '086F',	'0868', '0946',	'08A1', '0882',	'085E', '0951',	'0941', '086A',	'0360', '0870',	'093B', '089E',	'0862', '0878',	'0896', '0874',	'091F', '08A0',	'093C', '092D',	'0935', '0945',	'093A', '091B',	'0866', '0863',	'0892', '0815',	'087F', '092C',	'0932', '0835',	'094D', '092E',	'089A', '0366',	'08AB', '0931',	'0964', '086B',	'0899', '0954',	'07EC', '094F',	'0959', '087E',	'0961', '08AA',	'0875', '0939',	'0838', '0924',	'0898', '095E',	'095B', '088A',	'094B', '0934',	'0877', '0860',	'08A2', '089D',
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
