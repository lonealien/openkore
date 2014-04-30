#########################################################################
#  OpenKore - Teleport task
#  Copyright (c) 2007 OpenKore Team
#
#  This software is open source, licensed under the GNU General Public
#  License, version 2.
#  Basically, this means that you're allowed to modify and distribute
#  this software. However, if you distribute modified versions, you MUST
#  also distribute the source code.
#  See http://www.gnu.org/licenses/gpl.html for the full license.
#########################################################################
##
# MODULE DESCRIPTION: Teleport base task
package Task::Teleport;

use strict;
use Modules 'register';
use Time::HiRes qw(time);
use Scalar::Util;
use Carp::Assert;

use Task::WithSubtask;
use base qw(Task::WithSubtask);
use Globals qw($net %config $char $messageSender $taskManager $accountID %timeout %items_lut);
use Utils qw(timeOut);
use Utils::Exceptions;

use AI;
use Task::UseSkill;
use Task::ErrorReport;

use Log qw(debug error message);

use Translation qw(T TF);

use enum qw(
	STARTING
	USE_TELEPORT
	WAITING_FOR_WARPLIST
	GOT_WARP_LIST
	WAITING_FOR_MAPCHANGE
);

use enum qw(
	SKILL
	ITEM
	CHAT
);

use enum qw(
	RANDOM
	RESPAWN
);

use enum qw(
	ERROR_ITEM
	ERROR_SKILL
	ERROR_TASK
);

sub new {
	my $class = shift;
	my %args = @_;
	my $self = $class->SUPER::new(@_, autostop => 1, autofail => 0, mutexes => ['teleport']);
	$self->{emergency} = $args{emergency};
	# $self->{retry}{timeout} = $timeout{ai_teleport_retry}{timeout} || 0.5; unused atm
	$self->{giveup}{timeout} = $args{giveup_time} || 4;
	$self->{giveup}{time} = time;
	$self->{type} = $args{type};
	if ($self->{type} == RANDOM) {
		if (defined $args{useSkill}) {
			$self->{useSkill} = $args{useSkill};
		} elsif (defined $config{teleportAuto_useSkill}) {
			$self->{useSkill} = $config{teleportAuto_useSkill};
		} else {
			$self->{useSkill} = 1;
		}
		@{$self->{teleport_items}} = (601, 12323); # TODO: add alternative items for private servers?
		$self->{destMap} = 'Random';
	} elsif ($self->{type} == RESPAWN) {
		$self->{useSkill} = $args{useSkill} || !$config{teleportAuto_useItemForRespawn} || 1;
		@{$self->{teleport_items}} = (602, 12324);
		$self->{destMap} = $args{destMap} || $config{saveMap} || 'prontera';
		$self->{destMap} = $self->{destMap}.'.gat';
	} else {
		ArgumentException->throw(sprintf("Unknown teleport type value %s.", $self->{type}));
	}
	
	$self->{startTime} = time;
	$timeout{'ai_send_warp_tele_retry'}{'timeout'} = 0.3;
	
	my @holder = ($self);
	Scalar::Util::weaken($holder[0]);
	$self->{hooks} = Plugins::addHooks(
		['Network::Receive::map_changed', \&mapChange, \@holder], 
		['packet/warp_portal_list', \&warpPortalList, \@holder]
	);
	debug "Starting Teleport Task \n", 'teleport';
	return $self;
}

sub warpPortalList {
	my (undef, undef, $holder) = @_;
	my $self = $holder->[0];
	$timeout{'ai_teleport_delay'}{'time'} = time;
	$self->{state} = GOT_WARP_LIST;
	$self->{warpListOpen} = 1;
}

sub DESTROY {
	my ($self) = @_;
	Plugins::delHooks($self->{hooks}) if $self->{hooks};
	$self->SUPER::DESTROY();
}

sub activate {
	my ($self) = @_;
	$self->{state} = STARTING;
	$self->SUPER::activate();
}

sub interrupt {
	my ($self) = @_;
	$self->SUPER::interrupt();
} 

sub resume {
	my ($self) = @_;
	$self->SUPER::resume();
}

sub iterate {
	my ($self) = @_;
	return if (!$self->SUPER::iterate());
	if ($self->{mapChange} || $net->getState() != Network::IN_GAME) {
		$self->setDone();
		$self->{warpListOpen} = 0;
		debug sprintf("Took %s seconds to teleport \n", (time - $self->{startTime})), "Task::Teleport";
	} elsif (timeOut($self->{giveup}) && $self->{state} != STARTING) {
		$messageSender->sendWarpTele(27, 'cancel');
		$self->setError(ERROR_TASK, "Task::Teleport timeout");
	} elsif ($self->{warpListOpen} && timeOut($timeout{ai_send_warp_tele_retry}) && (timeOut($timeout{ai_teleport_delay}) || $self->{emergency})) {
		$self->{debugRetry}++;
		debug sprintf("Trying to confirm teleport: attempt %s\n", $self->{debugRetry}), "Task::Teleport";
		$timeout{ai_send_warp_tele_retry}{time} = time;
		$messageSender->sendWarpTele(26, $self->{destMap});
		$self->{warpListOpen} = 0;
		#$self->{state} = WAITING_FOR_MAPCHANGE;
	} elsif ($self->{state} == STARTING) {
		$self->{giveup}{time} = time;
		if ($self->{useSkill} && !$char->{muted}) {
			if ($char->{skills}{AL_TELEPORT}) {
				$self->{method} = SKILL;
				$self->{state} = USE_TELEPORT;
			} elsif (!$self->{fallback}) {
				# TODO: check if something needs to be equipped
				# fallback to ITEM method
				error TF("You don't have the Teleport skill, trying to use %s\n", $items_lut{$self->{teleport_items}->[0]}), "teleport";
				$self->{fallback} = 1;
				$self->{useSkill} = 0;
				$self->{state} = STARTING;
			} else {
				# tried item then skill
				my $msg = TF("Unable to use %s and Teleport skill\n", $items_lut{$self->{teleport_items}->[0]});
				error $msg;
				$self->setError(ERROR_ITEM, $msg);
				# what can we do now? deactivate teleport?
			}
		} else {
			foreach my $itemID (@{$self->{teleport_items}}) {
				$self->{item} = $char->inventory->getByNameID($itemID);
				last if $self->{item};
			}
			if ($self->{item}) {
				$self->{method} = ITEM;
				$self->{state} = USE_TELEPORT;
			} elsif (!$self->{fallback}) {
				$self->{fallback} = 1;
				$self->{useSkill} = 1;
				$self->{state} = STARTING;
				error TF("You don't have %ss, trying to use the Teleport Skill\n", $items_lut{$self->{teleport_items}->[0]}), "teleport";
			} else {
				# tried skill then item
				my $msg = TF("Unable to use Teleport skill and %s \n", $items_lut{$self->{teleport_items}->[0]});
				error $msg;
				$self->setError(ERROR_SKILL, $msg);
			}
		}
	} elsif ($self->{state} == USE_TELEPORT) {
		if ($self->{method} == SKILL) {
			if (!$self->getSubtask()) {
				message "Creating skill task \n";
				my $skill = new Skill(handle => 'AL_TELEPORT', level => ($self->{type} == RESPAWN)?$char->{skills}{AL_TELEPORT}{lv}:1); # always use tp level 1 for random dest.
				message (T("Using Teleport Skill Level 2 though we not have it!\n"), "teleport") if ($char->{skills}{AL_TELEPORT}{lv} == 1 && $self->{type} == RESPAWN);
				my $task = new Task::UseSkill (
					actor => $skill->getOwner,
					skill => $skill,
				);
				$self->setSubtask($task);
				$self->{skillTask} = $task;
			}
			
			$self->SUPER::iterate(); # Iterate preparation subtask
			
			if (!$self->getSubtask() && !$self->{skillTask}->getError()) {
				message "Skill task sucess \n";
				# success
				Plugins::callHook('teleport_sent',
					{
						level => ($self->{type}+1), # older plugins compatibility
						type => $self->{type},
						emergency => $self->{emergency},
						method => $self->{method}
					}
				);
				$self->{state} = WAITING_FOR_WARPLIST;
			} elsif (!$self->getSubtask() && $self->{skillTask}->getError()) {
				
				if ($self->{skillTask}->getError()->{code} == Task::UseSkill::ERROR_CASTING_FAILED && $self->{skillTask}->{castingError}->{type} == 1) {
					if (!$self->{fallback}) {
						$self->{fallback} = 1;
						$self->{useSkill} = 0;
						$self->{state} = STARTING;
						undef $self->{skillTask};
						error TF("You don't have enough SP to use the Teleport skill, trying to use %s\n", $items_lut{$self->{teleport_items}->[0]}), "teleport";
					} else {
						my $msg = T("No enough SP to teleport and no teleport items \n");
						error $msg;
						$self->setError(ERROR_TASK, $msg);
					}
				} elsif ($self->{skillTask}->getError()->{code} == Task::UseSkill::ERROR_CASTING_FAILED && ($self->{skillTask}->{castingError}->{type} == 512 || $self->{skillTask}->{castingError}->{type} == 513)) {
					my $msg = T("Can't teleport in this area \n");
					error $msg;
					$self->setError(ERROR_TASK, $msg);
				} elsif ($self->{skillTask}->getError()->{code} == Task::UseSkill::ERROR_MAX_TRIES) {
					my $msg = $self->{skillTask}->getError()->{message}."\n";
					error $msg;
					$self->setError(ERROR_TASK, $msg);
				} elsif ($self->{skillTask}->getError()->{code} == Task::UseSkill::ERROR_NO_SKILL) {
					my $msg = T("We had Teleport skill earlier but now we don't\n");
					error $msg;
					$self->setError(ERROR_TASK, $msg);
				} elsif ($self->{skillTask}->getError()) {
					my $msg = "Untreated error: ".$self->{skillTask}->getError()->{message}."\n";
					error $msg;
					$self->setError(ERROR_TASK, $msg);
					die;
					# TODO: more
				}
			}
		} elsif ($self->{method} == ITEM) {
			$messageSender->sendItemUse($self->{item}->{index}, $accountID);
			Plugins::callHook('teleport_sent',
				{
					level => ($self->{type}+1), # older plugins compatibility
					type => $self->{type},
					emergency => $self->{emergency},
					method => $self->{method}
				}
			);
			$self->{state} = WAITING_FOR_MAPCHANGE;
		}
	}
}


sub mapChange {
	my (undef, undef, $holder) = @_;
	my $self = $holder->[0];
	$self->{mapChange} = 1;
}

1;