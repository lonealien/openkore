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
		'0945', '0969', '0967', '089A', '094E', '0885', '08AB', '0363', '0886', '0879', 
		'0870', '0953', '092A', '093C', '0934', '0436', '087D', '094C', '094F', '086E', 
		'0920', '092D', '085F', '0959', '0917', '0882', '088A', '0940', '0956', '0884', 
		'0948', '08A0', '0951', '08A9', '088E', '093F', '0819', '096A', '0918', '0942', 
		'0894', '0864', '0880', '0955', '0868', '088D', '02C4', '091A', '086A', '083C', 
		'08A8', '035F', '095D', '0939', '0366', '0873', '0957', '086D', '0946', '0878', 
		'091B', '08A2', '0965', '094A', '0938', '0952', '0947', '07E4', '0924', '0874', 
		'08AA', '0941', '091E', '0897', '08AD', '086F', '085B', '086B', '08A1', '0811', 
		'095F', '091F', '093A', '0438', '0968', '0202', '095B', '0892', '0835', '0931', 
		'0815', '088F', '092F', '0937', '0362', '0361', '087F', '0930', '0929', '0954', 
		'0872', '0921', '0926', '0871', '0925', '0365', '0932', '0890', '0367', '087C', 
		'0888', '095C', '0861', '0966', '0364', '0962', '0936', '0876', '0883', '094D', 
		'0950', '094B', '092E', '093B', '0881', '095E', '0862', '0928', '022D', '0877', 
		'0899', '0960', '093D', '089B', '0866', '092B', '0927', '023B', '087E', '0838', 
		'089E', '0961', '0817', '0943', '085A', '0933', '0860', '087A', '0944', '0867', 
		'0281', '0437', '08A3', '0898', '0875', '0964', '0893', '092C', '0923', '0865', 
		'08A6', '095A', '088B', '086C', '0958', '0891', '089D', '0887'
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