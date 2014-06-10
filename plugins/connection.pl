############################################################
# connection for bRO
# unknown author
############################################################
package connection;

use strict;
use Plugins;
use lib $Plugins::current_plugin_folder;
use Log qw(message);
use Globals;
use Globals qw(%rpackets);

Plugins::register('connection', 'connection', \&onUnload);

my $hooks = Plugins::addHooks(['start3', \&load]);

my $pluginDir = $Plugins::current_plugin_folder;

my (@bro_data, $fh, @s_data);

sub load {
	unless ($fh) {
		message "Getting connection data...", 'connection';
		if (open (my $file, $pluginDir.'/'.pack("H*", '646174612e72766b'))) {
			message "success!\n", 'success';
			@bro_data = split "\x58\x58", join '', map { chr(ord($_)-5) } split //, <$file>;
			$bro_data[1] = reverse $bro_data[1] if ($bro_data[1] =~ s/^\x3B\x3B\x3B//);
			while (length($bro_data[1]) > 0) {
				if ($bro_data[1] =~ s/^(...)(\d+)[G-Z]//) {
					push (@s_data, {id => $1, len => $2});
				} 
			}
			message sprintf("Version: %s \n", $bro_data[0]), 'connection';
		} else {
			die("Error while obtaining update data. Please report this at http://forums.openkore.com.br/ \n")
		};
	};
	undef %rpackets;
	foreach my $p (@s_data) {$rpackets{sprintf('%04s', $p->{id})}{length} = $p->{len}} 
};

use Network::Send::bRO;
use Network::Receive::bRO;
*Network::Receive::bRO::new = sub {
	my ($class) = @_;
	my $self = $class->Network::Receive::ServerType0::new(@_);
	for (my $i = 29; $i < 112; $i++) {
		$self->{sync_ex_reply}->{sprintf('%04s', $s_data[$i]->{id})} = sprintf('%04s', $s_data[$i+84]->{id});
	}
	my %recv_packets = ( '0097' => ['private_message', 'v Z24 V Z*', [qw(len privMsgUser flag privMsg)]]);
	foreach my $key (keys %{$self->{sync_ex_reply}}) {
		$recv_packets{$key} => ['sync_request_ex'];
	};
	$self->{packet_list}{$_} = $recv_packets{$_} for keys %recv_packets;
	return $self;
};

*Network::Send::bRO::new = sub {
	my ($class) = @_;
	my $self = $class->Network::Send::ServerType0::new(@_);
	my %send_packets = (
		sprintf('%04s', $s_data[0]->{id}) => ['actor_action', 'a4 C', [qw(targetID type)]],
		sprintf('%04s', $s_data[1]->{id}) => ['skill_use', 'v2 a4', [qw(lv skillID targetID)]],
		sprintf('%04s', $s_data[2]->{id}) => ['character_move','a3', [qw(coords)]],
		sprintf('%04s', $s_data[3]->{id}) => ['sync', 'V', [qw(time)]],
		sprintf('%04s', $s_data[4]->{id}) => ['actor_look_at', 'v C', [qw(head body)]],
		sprintf('%04s', $s_data[5]->{id}) => ['item_take', 'a4', [qw(ID)]],
		sprintf('%04s', $s_data[6]->{id}) => ['item_drop', 'v2', [qw(index amount)]],
		sprintf('%04s', $s_data[28]->{id}) => ['storage_password'],
		sprintf('%04s', $s_data[7]->{id}) => ['storage_item_add', 'v V', [qw(index amount)]],
		sprintf('%04s', $s_data[8]->{id}) => ['storage_item_remove', 'v V', [qw(index amount)]],
		sprintf('%04s', $s_data[9]->{id}) => ['skill_use_location', 'v4', [qw(lv skillID x y)]],
		sprintf('%04s', $s_data[11]->{id}) => ['actor_info_request', 'a4', [qw(ID)]],
		sprintf('%04s', $s_data[23]->{id}) => ['map_login', 'a4 a4 a4 V C', [qw(accountID charID sessionID tick sex)]],
		sprintf('%04s', $s_data[24]->{id}) => ['party_join_request_by_name', 'Z24', [qw(partyName)]],
		sprintf('%04s', $s_data[27]->{id}) => ['homunculus_command', 'v C', [qw(commandType, commandID)]],
	);
	$self->{packet_list}{$_} = $send_packets{$_} for keys %send_packets;
	my %send_handlers = ("\x6D\x61\x73\x74\x65\x72\x5F\x6C\x6F\x67\x69\x6E","\x30\x32\x42\x30","\x62\x75\x79\x5F\x62\x75\x6C\x6B\x5F\x76\x65\x6E\x64\x65\x72","\x30\x38\x30\x31","\x70\x61\x72\x74\x79\x5F\x73\x65\x74\x74\x69\x6E\x67","\x30\x37\x44\x37");
	while (my ($k, $v) = each %send_packets) {
		$send_handlers{$v->[0]} = $k
	};
	$self->{packet_lut}{$_} = $send_handlers{$_} for keys %send_handlers;
	my @ek = split "\x78", $bro_data[2];
	$self->cryptKeys($ek[0], $ek[1], $ek[2]);
	return $self;
};

sub onUnload { message("Unloading connection... \n");
	Plugins::delHooks($hooks);
}
1;

