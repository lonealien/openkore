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
	'093C', '0892',	'0367', '091D',	'0957', '0934',	'0922', '0919',	'0926', '0863',	'0811', '087F',	'088A', '0952',	'093D', '08A6',	'087E', '089B',	'0885', '0953',	'085A', '0815',	'08A3', '0868',	'0202', '086D',	'088B', '0938',	'0881', '0887',	'0880', '0937',	'0877', '0954',	'08A7', '089D',	'0891', '0943',	'088E', '0925',	'08A8', '0436',	'089F', '091E',	'085B', '091A',	'0360', '0955',	'0930', '0945',	'0918', '0965',	'087D', '089A',	'0281', '08A4',	'0870', '095D',	'0875', '0944',	'08AA', '095E',	'0802', '0889',	'0817', '0861',	'023B', '0819',	'0924', '0941',	'0865', '0876',	'0931', '07EC',	'0929', '087C',	'0946', '0958',	'0884', '092C',	'0950', '0869',	'0896', '0968',	'0942', '0366',	'091B', '08AD',	'095C', '0898',	'0438', '091C',	'035F', '094F',	'0927', '0967',	'07E4', '091F',	'0966', '08A1',	'0838', '022D',	'0867', '0949',	'092D', '0923',	'089E', '0368',	'0835', '0921',	'092A', '094C',	'095A', '0920',	'092F', '08A9',	'0890', '0947',	'092E', '0959',	'0928', '08A2',	'0951', '0369',	'086A', '085C',	'0886', '095B',	'08AC', '093F',	'0866', '086C',	'089C', '094B',	'0969', '08AB',	'0961', '0939',	'0935', '0936',	'08A5', '0893',	'0940', '096A',	'0362', '086F',	'0894', '0874',	'093A', '0932',	'0962', '0882',	'094A', '086E',	'094E', '0873',	'083C', '093E',	'085D', '0364',	'08A0', '087A',	'092B', '0964',	'0956', '094D',	'0864', '0963',
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
