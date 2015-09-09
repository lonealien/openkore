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
	'0927', '088F',	'094C', '086E',	'0880', '088A',	'092B', '0948',	'022D', '08A0',	'091F', '085A',	'092A', '0895',	'091D', '094A',	'0879', '0866',	'0815', '092F',	'0956', '091E',	'0938', '0886',	'0364', '095E',	'0876', '0819',	'087F', '089F',	'086B', '0957',	'0865', '0881',	'0961', '0365',	'085D', '089B',	'087C', '088D',	'0917', '0921',	'093D', '0952',	'0202', '0869',	'08AD', '0936',	'088C', '07E4',	'0943', '0877',	'0949', '07EC',	'093C', '093A',	'0897', '095B',	'0937', '0963',	'0361', '0964',	'0953', '08AA',	'0878', '086C',	'0437', '0369',	'0868', '0931',	'091B', '0894',	'0883', '095C',	'08A9', '08A1',	'0898', '08A7',	'0960', '0941',	'08A4', '085C',	'0861', '085B',	'0368', '0959',	'0968', '08A5',	'035F', '091C',	'0893', '0967',	'085E', '0899',	'0363', '08A3',	'0366', '0875',	'087A', '087D',	'088B', '0934',	'0802', '0920',	'0950', '08AC',	'0860', '023B',	'087B', '0891',	'088E', '091A',	'089D', '0926',	'0940', '02C4',	'0924', '093F',	'092E', '08A6',	'094F', '0885',	'0874', '0438',	'0929', '0892',	'094B', '0889',	'086F', '0923',	'0811', '08A2',	'0969', '0362',	'0922', '0882',	'0887', '08A8',	'0867', '0870',	'08AB', '086D',	'0935', '0872',	'093E', '0962',	'0918', '092C',	'096A', '083C',	'0360', '095A',	'089C', '0945',	'085F', '0942',	'095F', '0436',	'094D', '093B',	'0862', '0946',	'0932', '087E',	'0864', '0939',	'0965', '0896',
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
