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
		'0861', '0835', '02C4', '095E', '0962', '086A', '0929', '0930', '0893', '0281', 
		'095A', '0965', '0947', '0891', '087A', '0877', '08AA', '0802', '0967', '093B', 
		'0956', '089C', '091B', '091C', '0864', '08A7', '0963', '07EC', '0868', '0924', 
		'091A', '0961', '0938', '0951', '0937', '0946', '0811', '0872', '089B', '094C', 
		'0838', '0890', '0860', '0865', '0873', '0949', '0950', '088C', '0925', '0928', 
		'0892', '095B', '0202', '0878', '088D', '0866', '0880', '093C', '0884', '0863', 
		'0436', '087F', '0957', '0867', '0875', '0927', '0945', '092B', '0871', '085C', 
		'0886', '08A1', '08AD', '0364', '092E', '0940', '0369', '0958', '092D', '0362', 
		'092C', '093E', '0964', '0955', '0920', '0815', '083C', '0895', '0876', '08A8', 
		'087C', '095F', '0869', '0889', '08A6', '089F', '092A', '087B', '08AB', '0363', 
		'035F', '0819', '08A0', '089A', '08A4', '0882', '094A', '086E', '08AC', '088B', 
		'0361', '0874', '0437', '089D', '088A', '0941', '085E', '088F', '0968', '0943', 
		'0932', '0934', '087D', '0894', '08A9', '0936', '094B', '085A', '094F', '0966', 
		'0899', '0944', '0959', '091D', '023B', '088E', '091F', '0935', '0954', '0953', 
		'0368', '0817', '086B', '0919', '0948', '092F', '0888', '08A3', '0897', '0360', 
		'093A', '0887', '0952', '094E', '085F', '0960', '091E', '022D', '085D', '0969', 
		'0939', '0881', '0885', '095D', '0918', '0883', '086D', '086F'
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