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
	'0952', '093B',	'0967', '0360',	'0942', '0878',	'094D', '0955',	'091C', '0872',	'0876', '0864',	'093C', '0868',	'0937', '087F',	'094E', '0922',	'0929', '094C',	'0921', '0891',	'0895', '0963',	'08A1', '0889',	'0960', '0965',	'0874', '092C',	'07E4', '07EC',	'095F', '0890',	'093D', '091B',	'091E', '0879',	'0944', '0887',	'08A8', '087E',	'0438', '0898',	'087C', '0896',	'08A3', '0941',	'0815', '092F',	'08A0', '0893',	'0918', '088D',	'095C', '0367',	'089B', '0835',	'086E', '0945',	'0883', '087A',	'0968', '02C4',	'092A', '0951',	'0869', '0953',	'0926', '089C',	'0865', '0958',	'08A7', '0954',	'08AC', '093E',	'0964', '0948',	'093A', '0436',	'08A6', '0946',	'0933', '0363',	'0894', '095B',	'08A9', '0897',	'0860', '08AB',	'0886', '095D',	'088C', '0882',	'092B', '0202',	'0936', '0938',	'093F', '086D',	'083C', '085F',	'0871', '095E',	'0962', '0892',	'086C', '0861',	'0966', '085B',	'08AD', '0957',	'0361', '096A',	'0866', '0947',	'085C', '08A5',	'094B', '094A',	'022D', '0870',	'0932', '0362',	'0364', '0924',	'091A', '0920',	'0884', '095A',	'0437', '094F',	'092D', '088F',	'0881', '086A',	'0930', '088B',	'0281', '0931',	'0899', '0925',	'0862', '085E',	'0959', '0368',	'088A', '0885',	'0875', '092E',	'0940', '085A',	'0969', '0917',	'0863', '0923',	'087D', '089A',	'0950', '091D',	'0867', '0949',	'0802', '0819',	'0817', '088E',	'0877', '0888',
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
