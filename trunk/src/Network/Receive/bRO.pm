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
		'08AC', '0875', '0368', '093B', '087B', '02C4', '091F', '0964', '0878', '0940', 
		'091E', '0922', '0918', '088C', '0874', '085C', '0891', '085A', '092D', '094D', 
		'0869', '0894', '07E4', '0969', '088D', '0895', '0817', '095A', '08A7', '0920', 
		'0838', '093A', '0933', '0896', '0948', '086D', '0868', '0942', '0802', '0892', 
		'088B', '0943', '0967', '08A8', '089E', '0935', '0860', '08A9', '0897', '08A6', 
		'094B', '086A', '08A3', '0893', '096A', '08AA', '088E', '0863', '092E', '089D', 
		'08AD', '0929', '0931', '0962', '092A', '023B', '0921', '089A', '0923', '0876', 
		'0864', '0950', '0883', '0952', '0882', '0966', '095E', '0899', '0965', '087D', 
		'089B', '0926', '093D', '0963', '08A0', '0898', '0930', '035F', '08A1', '0934', 
		'093F', '0369', '095B', '086F', '091A', '0939', '0438', '0951', '087C', '092F', 
		'0888', '0873', '0887', '088F', '0937', '083C', '0811', '091C', '08AB', '0960', 
		'0365', '0877', '0919', '0364', '0946', '0872', '0957', '0886', '0366', '0958', 
		'0961', '091B', '0360', '086E', '092B', '0956', '0281', '0955', '0884', '0436', 
		'092C', '094C', '095D', '086B', '022D', '094A', '0953', '0941', '08A4', '0881', 
		'08A5', '085E', '089C', '089F', '08A2', '0835', '0870', '07EC', '0819', '091D', 
		'0947', '0815', '088A', '087A', '0867', '085F', '0924', '0925', '0367', '0202', 
		'087E', '0944', '095F', '087F', '0880', '093E', '0945', '0890'
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