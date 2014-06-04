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
		'0871', '0935', '0899', '0969', '092D', '0891', '087F', '0960', '087B', '08A9', 
		'095B', '088B', '086A', '086B', '0923', '0959', '092F', '0866', '0860', '0874', 
		'086D', '0956', '092C', '085F', '0887', '0897', '0952', '0963', '093B', '0929', 
		'0926', '0890', '093C', '0815', '089D', '094D', '0202', '083C', '096A', '0864', 
		'0955', '08A8', '092A', '087C', '0876', '07EC', '0878', '0869', '0880', '088C', 
		'0865', '0967', '035F', '089A', '094C', '0958', '087E', '0362', '0918', '0363', 
		'095C', '08A0', '087A', '0964', '0928', '089F', '07E4', '092E', '08A7', '0366', 
		'0936', '092B', '095A', '091A', '085A', '0938', '08AC', '0940', '0863', '0966', 
		'0893', '0948', '087D', '094B', '0369', '0437', '08A6', '0951', '0944', '0931', 
		'0436', '0873', '0438', '0961', '0927', '0949', '0881', '0884', '0925', '091C', 
		'0867', '0861', '088D', '089C', '0947', '08A4', '0360', '089E', '0862', '0933', 
		'095F', '085C', '0802', '0942', '0364', '0883', '0819', '0895', '0920', '0886', 
		'0281', '0835', '08AD', '0965', '0932', '0953', '08A2', '0937', '0930', '0939', 
		'0898', '0968', '088F', '0957', '0922', '0868', '0365', '0921', '0870', '0361', 
		'093D', '08AB', '093A', '0872', '088A', '0368', '095D', '093E', '0950', '094F', 
		'088E', '091D', '093F', '086C', '0917', '0945', '08A1', '0811', '095E', '0882', 
		'091E', '0962', '08A5', '094A', '0954', '023B', '0894', '094E'
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