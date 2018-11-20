extends Node

enum WinConditions {
	KILL_ALL = 0,
	KILL_LEADER,
	SURVIVE_TURNS,
	NUM_WIN_CONDITIONS
}

enum LossConditions {
	LEADER_DEAD = 0,
	ANY_DEAD,
	TOO_SLOW,
	NUM_LOSS_CONDITIONS
}

onready var win_condition = WinConditions.KILL_ALL
onready var loss_condition = LossConditions.LEADER_DEAD

# Information for "Kill Leader"
onready var enemy_leader = null

# Information for "Survive Turns"
onready var min_num_turns = 1

# Information for "Leader Dead"
onready var player_leader = null

# Information for "Too Slow"
onready var max_num_turns = 1

func _init(win_type, win_info, loss_type, loss_info):
	win_condition = win_type
	match win_type:
		WinConditions.KILL_LEADER:
			enemy_leader = win_info

		WinConditions.SURVIVE_TURNS:
			min_num_turns = win_info

		# Default win condition, very simple
		_, WinConditions.KILL_ALL:
			pass

	loss_condition = loss_type
	match loss_type:
		LossConditions.LEADER_DEAD:
			player_leader = loss_info

		LossConditions.TOO_SLOW:
			max_num_turns = loss_info

		# Straight-forward enough
		_, LossConditions.ANY_DEAD:
			pass

func _ready():
	pass

func evaluate_win(enemy_team, num_turns):
	match win_condition:
		WinConditions.KILL_LEADER:
			if enemy_leader.state.health == 0:
				return true

		WinConditions.KILL_ALL:
			for c in enemy_team.values():
				if c.state.health != 0:
					return false

		WinConditions.SURVIVE_TURNS:
			if num_turns > min_num_turns:
				return true

	return false

func evaluate_loss(player_team, num_turns):
	match loss_condition:
		LossConditions.LEADER_DEAD:
			if player_leader.state.health == 0:
				return true

		LossConditions.ANY_DEAD:
			for c in player_team.values():
				if c.state.health == 0:
					return true

		LossConditions.TOO_SLOW:
			if num_turns > max_num_turns:
				return true

	return false
