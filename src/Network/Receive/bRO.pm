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
	'093B', '0925',	'094A', '0436',	'087F', '0957',	'092D', '0949',	'0864', '0868',	'0942', '0965',	'087B', '089A',	'0919', '0887',	'0934', '07E4',	'0899', '0969',	'083C', '087E',	'0931', '0880',	'0811', '0959',	'0815', '0883',	'0945', '0889',	'086F', '094B',	'093D', '0867',	'0917', '085F',	'091A', '0898',	'0891', '0870',	'08AD', '0875',	'085D', '0438',	'0869', '023B',	'0929', '0873',	'08A8', '0361',	'0943', '0966',	'091E', '0953',	'0935', '0872',	'092A', '0363',	'088C', '0938',	'0921', '08A7',	'0871', '0365',	'0863', '0962',	'08A9', '0802',	'0838', '0932',	'0924', '095B',	'093A', '089B',	'0886', '091C',	'086C', '0950',	'0963', '08A2',	'0861', '022D',	'089E', '087C',	'0882', '0895',	'08A5', '086D',	'095D', '0952',	'0922', '086B',	'0936', '092F',	'094E', '08A4',	'0930', '08AC',	'0362', '0202',	'0835', '096A',	'094C', '08A0',	'088E', '085E',	'0876', '0437',	'089D', '085C',	'07EC', '0926',	'0928', '0369',	'0920', '0865',	'091D', '0881',	'0923', '0967',	'0933', '0368',	'0939', '0360',	'0958', '091B',	'086A', '095A',	'02C4', '088D',	'088A', '094D',	'088F', '088B',	'0927', '0866',	'095F', '0961',	'0941', '08A1',	'0960', '0947',	'0964', '087D',	'0366', '0877',	'0892', '0968',	'085B', '095C',	'092E', '085A',	'092B', '0946',	'0817', '0862',	'0940', '095E',	'0954', '0860',	'0885', '091F',	'08AA', '0951',	'0890', '0948',	'087A', '0819',
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
