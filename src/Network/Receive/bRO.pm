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
		'0936', '0898', '0802', '0943', '0885', '0931', '088D', '0952', '0937', '0899', 
		'095A', '08A4', '08A6', '0949', '0879', '0877', '0933', '0953', '0960', '0871', 
		'0961', '088B', '093A', '0934', '0864', '085D', '089E', '0892', '0838', '088E', 
		'0862', '0969', '0368', '0888', '0202', '0866', '0928', '0436', '08A1', '0959', 
		'0362', '0811', '0874', '091D', '0364', '0819', '0889', '08A7', '093F', '0946', 
		'0360', '0835', '0940', '095F', '0897', '0941', '087B', '0891', '087F', '0942', 
		'089A', '087D', '07EC', '0938', '0881', '0437', '0932', '0919', '089B', '0956', 
		'083C', '0873', '0860', '089D', '0939', '08A9', '08A0', '0865', '0868', '0967', 
		'0958', '0947', '0966', '087E', '0365', '089C', '0929', '0363', '0863', '093C', 
		'0922', '087A', '07E4', '0917', '085F', '086A', '092D', '0438', '0964', '086C', 
		'085E', '0920', '0281', '0870', '092A', '0887', '092F', '08AC', '0894', '022D', 
		'0963', '0921', '023B', '087C', '092E', '0955', '0878', '085A', '094C', '0950', 
		'0962', '0935', '08A2', '0896', '0880', '0872', '086E', '094B', '094F', '0882', 
		'093D', '0869', '086D', '0883', '096A', '0965', '0884', '0890', '088A', '091C', 
		'0954', '0924', '0867', '0944', '095B', '095D', '0925', '0817', '0861', '0876', 
		'095C', '089F', '092C', '094A', '0366', '08AA', '0893', '08A3', '0815', '0361', 
		'095E', '093B', '0926', '092B', '094E', '0886', '0948', '0369'
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