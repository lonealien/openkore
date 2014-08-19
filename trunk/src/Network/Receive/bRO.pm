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
		'0950', '0934', '08AA', '0887', '094A', '023B', '0838', '0969', '085B', '0866', 
		'092C', '0869', '0865', '093D', '088C', '0925', '0928', '08AB', '0364', '085E', 
		'0811', '08A5', '0888', '0860', '0932', '0873', '0943', '0871', '0895', '0935', 
		'0946', '095C', '094B', '091F', '086B', '0927', '0944', '0880', '085A', '089A', 
		'091C', '0930', '092E', '0361', '0966', '085D', '091E', '088E', '0367', '0886', 
		'0897', '0936', '085F', '095E', '0956', '087A', '0921', '0864', '093E', '0954', 
		'0933', '089F', '0947', '0953', '0889', '0436', '022D', '0952', '0872', '0875', 
		'0959', '0937', '087F', '0898', '095D', '0919', '0360', '0437', '0877', '086C', 
		'083C', '0948', '089C', '08A0', '086F', '07E4', '0938', '0438', '0924', '093C', 
		'07EC', '0967', '0368', '0960', '092A', '0940', '08A7', '08A3', '091B', '087D', 
		'0892', '095B', '086D', '02C4', '0363', '08AD', '094F', '0883', '088D', '0893', 
		'085C', '0815', '0939', '0878', '088B', '093F', '092B', '0884', '094D', '095A', 
		'095F', '0965', '0920', '0874', '092F', '0802', '0949', '0961', '0926', '092D', 
		'0964', '0923', '0951', '096A', '093A', '08A8', '087B', '0862', '0863', '0968', 
		'08A6', '0963', '0899', '0881', '094E', '0945', '0202', '0867', '091D', '088F', 
		'0922', '0365', '088A', '08A1', '0868', '089B', '089E', '08A4', '0362', '0894', 
		'035F', '089D', '0962', '0958', '091A', '0835', '086A', '0819'
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