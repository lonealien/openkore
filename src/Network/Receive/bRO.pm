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
		'0943', '07EC', '0882', '08AB', '089F', '092D', '0884', '089A', '0866', '091D', 
		'094E', '0930', '08AD', '095A', '087C', '094B', '0281', '0928', '0949', '0886', 
		'089E', '089C', '07E4', '0890', '0948', '0872', '0874', '0938', '0922', '0932', 
		'0871', '0436', '0940', '08AA', '023B', '0868', '0883', '0968', '0817', '0838', 
		'0875', '0363', '08AC', '0965', '0953', '08A6', '0920', '0885', '0919', '092A', 
		'0202', '0437', '087E', '08A5', '094A', '085A', '088C', '092C', '083C', '093B', 
		'0889', '085E', '0923', '0945', '0951', '022D', '0362', '0939', '0950', '089D', 
		'0366', '091A', '0944', '0811', '0864', '0959', '0888', '086D', '0873', '0894', 
		'0963', '0368', '0862', '0364', '0929', '0879', '0860', '0876', '092E', '093C', 
		'0935', '0365', '08A1', '0942', '088E', '0962', '0958', '085C', '0936', '093E', 
		'0865', '0878', '0926', '0946', '093F', '0952', '0947', '035F', '086C', '087D', 
		'085B', '0955', '0870', '085D', '0802', '0934', '086A', '08A2', '0361', '089B', 
		'0924', '0933', '087A', '08A8', '0819', '02C4', '093D', '0927', '0891', '087B', 
		'0835', '0895', '0967', '094C', '0917', '0880', '0898', '0892', '091B', '0960', 
		'0869', '0887', '0815', '095F', '086B', '0867', '092F', '088B', '091E', '0861', 
		'0863', '0438', '0969', '0957', '0941', '0966', '0931', '093A', '095B', '0893', 
		'088A', '0360', '08A3', '0897', '0899', '0925', '095C', '0896'
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