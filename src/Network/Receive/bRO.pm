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
		'08A9', '0960', '093C', '0887', '0869', '0863', '0942', '0893', '0949', '08AA', 
		'023B', '0935', '0929', '0870', '0957', '0896', '087E', '089F', '086B', '0367', 
		'089E', '0817', '0436', '0875', '0879', '085E', '0920', '0364', '022D', '094B', 
		'0369', '085F', '091D', '0838', '094D', '08A2', '0872', '0895', '087C', '0918', 
		'089D', '07EC', '0281', '0861', '0899', '0802', '0877', '095D', '0934', '094F', 
		'0951', '08AD', '092B', '0931', '089B', '0898', '0922', '08A7', '0862', '0866', 
		'0945', '088D', '091A', '096A', '0882', '08A1', '0933', '0438', '086E', '092F', 
		'0958', '0365', '0363', '0883', '087A', '0928', '0811', '0943', '08A8', '087F', 
		'0948', '092A', '0889', '0819', '0885', '0924', '085D', '086C', '0361', '086D', 
		'085C', '088B', '0937', '0886', '088F', '0815', '0880', '0956', '08A5', '089A', 
		'0961', '0946', '0923', '0968', '0366', '0867', '02C4', '08AC', '08A4', '0925', 
		'085B', '0963', '08A6', '095B', '088E', '086A', '0938', '08A0', '091E', '093F', 
		'0954', '095A', '0950', '0944', '0967', '089C', '0936', '0437', '0360', '093A', 
		'0940', '087D', '0930', '091F', '0202', '092E', '0897', '088C', '093E', '083C', 
		'0871', '0947', '0835', '0865', '091B', '0878', '095F', '0927', '0874', '0921', 
		'0969', '0892', '0939', '0965', '0888', '0955', '0959', '091C', '0891', '0966', 
		'0890', '08A3', '0876', '095C', '0926', '0881', '0917', '095E'
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