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
	'0930', '0926',	'08AD', '0928',	'093C', '0863',	'0861', '087D',	'0436', '0959',	'091A', '092C',	'093E', '0882',	'0935', '0868',	'0922', '08A8',	'08A4', '089A',	'085E', '089E',	'0817', '0945',	'0879', '089C',	'022D', '094B',	'095A', '0364',	'08AA', '095C',	'0880', '0921',	'087C', '094E',	'095F', '0871',	'08A3', '08A9',	'07EC', '094A',	'093B', '0944',	'0942', '0866',	'0937', '085F',	'0875', '0878',	'0365', '0362',	'0876', '0881',	'08AB', '0952',	'0940', '0888',	'092F', '0865',	'091C', '0949',	'096A', '0811',	'0898', '0953',	'088D', '089F',	'0897', '0947',	'0963', '0950',	'0366', '095D',	'0931', '0929',	'0939', '02C4',	'0899', '094D',	'092B', '0956',	'0835', '0957',	'023B', '0802',	'093D', '0961',	'0867', '0883',	'08A1', '0936',	'089B', '08A7',	'0932', '0964',	'092E', '0202',	'0368', '0948',	'085C', '0862',	'0864', '0360',	'0884', '0938',	'091E', '0966',	'0877', '0920',	'095E', '0869',	'0933', '0886',	'0917', '0965',	'086F', '0887',	'0946', '083C',	'092D', '0943',	'087A', '0924',	'094F', '0363',	'088F', '0890',	'0951', '085B',	'087E', '088A',	'0281', '0860',	'0927', '08AC',	'088C', '0969',	'085D', '07E4',	'093A', '091B',	'0367', '0893',	'0889', '0960',	'086E', '0873',	'091D', '0438',	'0361', '08A6',	'0918', '086A',	'035F', '0369',	'087B', '085A',	'093F', '087F',	'0894', '0968',	'086C', '086D',	'0892', '0955',	'0925', '0923',
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
