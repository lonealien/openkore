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
		'0930', '088E', '089D', '0860', '093C', '0838', '0875', '0892', '0948', '094A', 
		'0931', '0817', '0369', '0966', '085F', '0865', '0874', '0957', '091F', '086E', 
		'0894', '089F', '0891', '094D', '0863', '0861', '0960', '0929', '0964', '086B', 
		'0368', '08A8', '087C', '08A2', '0926', '085C', '0898', '08A0', '092A', '0922', 
		'0917', '0879', '0934', '096A', '089B', '0881', '0877', '0363', '0968', '08AC', 
		'085B', '0951', '0811', '0962', '0869', '0950', '0890', '094B', '0361', '085A', 
		'07EC', '0927', '0932', '0364', '0939', '095C', '0366', '0885', '02C4', '0887', 
		'091E', '0886', '0867', '0815', '0802', '07E4', '0958', '0945', '0883', '086C', 
		'0955', '0943', '0899', '0437', '091C', '0872', '086A', '095D', '089E', '0360', 
		'092B', '095F', '0896', '094F', '091D', '0862', '0961', '0937', '091A', '0918', 
		'095E', '086D', '0933', '085E', '08A9', '0884', '092C', '0882', '08A1', '087E', 
		'0954', '0949', '0924', '087F', '088F', '0876', '0938', '095A', '08AD', '0947', 
		'0925', '092E', '0897', '08AA', '0923', '0941', '08A5', '0888', '085D', '0920', 
		'0952', '087D', '0880', '0965', '087B', '08A3', '0835', '08AB', '0868', '0928', 
		'0959', '092F', '089C', '0878', '0362', '094E', '0919', '091B', '093E', '0365', 
		'0921', '0969', '0944', '0953', '093F', '0864', '088B', '022D', '0942', '0871', 
		'0946', '0936', '0967', '0866', '088A', '0202', '0436', '093B'
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