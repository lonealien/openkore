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
package Network::Send::bRO;
use strict;
use base 'Network::Send::ServerType0';

sub new {
	my ($class) = @_;
	my $self = $class->SUPER::new(@_);
	
	my %packets = (
		'0944' => ['actor_action', 'a4 C', [qw(targetID type)]],
		'091D' => ['skill_use', 'v2 a4', [qw(lv skillID targetID)]],
		'0369' => ['character_move','a3', [qw(coords)]],
		'0940' => ['sync', 'V', [qw(time)]],
		'095F' => ['actor_look_at', 'v C', [qw(head body)]],
		'088E' => ['item_take', 'a4', [qw(ID)]],
		'08AD' => ['item_drop', 'v2', [qw(index amount)]],
		'092A' => ['storage_item_add', 'v V', [qw(index amount)]],
		'0950' => ['storage_item_remove', 'v V', [qw(index amount)]],
		'0883' => ['skill_use_location', 'v4', [qw(lv skillID x y)]],
		'085B' => ['actor_info_request', 'a4', [qw(ID)]],
		'094E' => ['actor_name_request', 'a4', [qw(ID)]],
		'089F' => ['item_list_res', 'v V2 a*', [qw(len type action itemInfo)]],
		'0969' => ['map_login', 'a4 a4 a4 V C', [qw(accountID charID sessionID tick sex)]],
		'088B' => ['party_join_request_by_name', 'Z24', [qw(partyName)]], #f
		'0960' => ['homunculus_command', 'v C', [qw(commandType, commandID)]], #f
		'0920' => ['storage_password'],
	);
	
	$self->{packet_list}{$_} = $packets{$_} for keys %packets;
	
	my %handlers = qw(
		master_login 02B0
		buy_bulk_vender 0801
		party_setting 07D7
	);
	
	while (my ($k, $v) = each %packets) { $handlers{$v->[0]} = $k}
	$self->{packet_lut}{$_} = $handlers{$_} for keys %handlers;
	$self->cryptKeys(1646358305, 1401582652, 1087465864);

	return $self;
}

1;