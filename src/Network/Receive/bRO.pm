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
	'094A', '0882',	'0368', '0819',	'08A1', '094D',	'0872', '087D',	'0958', '094B',	'0953', '0959',	'0871', '083C',	'091C', '0921',	'088F', '08A9',	'0924', '089E',	'08AA', '0369',	'091B', '0920',	'085B', '0867',	'0815', '091E',	'086F', '0917',	'08AD', '0940',	'0966', '095E',	'08AB', '093B',	'0938', '0941',	'085D', '088E',	'0281', '094E',	'0860', '0898',	'0363', '0943',	'0367', '0947',	'086D', '0944',	'095A', '0956',	'0932', '0811',	'0918', '0893',	'0964', '0961',	'0935', '0954',	'0802', '0894',	'0965', '095F',	'0889', '0950',	'0892', '0838',	'087E', '0870',	'0888', '0942',	'0951', '0878',	'0365', '08A0',	'08A3', '0881',	'0931', '0366',	'0895', '0919',	'093A', '094C',	'0960', '0885',	'0362', '0866',	'093E', '0969',	'0869', '088C',	'087C', '087B',	'087A', '091D',	'0926', '0967',	'08A2', '0884',	'0361', '0955',	'0962', '0438',	'095C', '0923',	'086C', '092E',	'0360', '0864',	'088B', '095B',	'0930', '0865',	'035F', '0896',	'022D', '0897',	'093F', '091F',	'089A', '0949',	'0886', '0927',	'0890', '092A',	'0880', '096A',	'0877', '0934',	'0863', '0936',	'086B', '02C4',	'08A7', '092D',	'093D', '088A',	'0963', '0928',	'0876', '0957',	'089C', '0946',	'085F', '0937',	'08A8', '0437',	'0952', '07EC',	'0202', '085E',	'08A6', '089B',	'0817', '086A',	'0891', '091A',	'023B', '0929',	'0874', '08A5',	'087F', '0968',	'0436', '0899',	'0922', '0364',
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
