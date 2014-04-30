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
		'08A3', '0861', '0368', '08AA', '0920', '0969', '087A', '0362', '092A', '08AD', 
		'0960', '094D', '0944', '0880', '0948', '088E', '086D', '085A', '08A0', '0873', 
		'083C', '086B', '0889', '0865', '0868', '0862', '093C', '087B', '093B', '089D', 
		'0940', '0838', '0923', '0896', '0924', '0951', '085B', '086E', '0890', '0884', 
		'0888', '08A5', '0869', '086C', '0871', '08A8', '0281', '089B', '092E', '094A', 
		'0899', '089F', '093F', '02C4', '0898', '08A2', '0965', '088A', '0872', '093A', 
		'07EC', '0939', '0895', '0964', '0934', '0870', '0935', '088B', '0894', '0946', 
		'0365', '095E', '0860', '08A1', '0930', '0921', '08AB', '0863', '0949', '0366', 
		'089C', '0938', '093E', '089A', '0936', '0369', '088D', '08A7', '0968', '0864', 
		'0815', '0363', '0922', '091B', '0367', '0866', '0928', '095B', '0802', '089E', 
		'095D', '0931', '094B', '0437', '085D', '091D', '07E4', '022D', '0929', '0877', 
		'0957', '08A6', '095A', '086A', '093D', '0958', '0879', '094E', '0819', '0875', 
		'035F', '0962', '0943', '0361', '0952', '0881', '0364', '0926', '0927', '087D', 
		'094F', '0950', '094C', '091C', '0942', '0918', '088F', '0961', '0925', '0933', 
		'0886', '0954', '0937', '0876', '0811', '092C', '08A4', '091E', '08AC', '0202', 
		'0867', '085C', '085F', '091A', '088C', '0874', '0817', '092B', '0882', '0438', 
		'0945', '0887', '091F', '0953', '087F', '0941', '095F', '0966'
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