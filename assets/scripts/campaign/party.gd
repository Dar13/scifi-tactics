extends Node

var character_state_class = load("res://assets/scripts/characters/character_state.gd")

# A party is a group of character states that can be used for battles, GUIs, or
# any other necessary context.
#
# For example, a campaign will be made up of a 'player party' that contains many
# characters (20-30) while a battle will have a 'player party' and an 'enemy party'
# that only have 8 or less characters in it.

var characters = []

func _notification(what):
	# Put any explicit destructor-like clean-up here
	pass

func add_character(state):
	characters.append(state)

func remove_character(state):
	characters.remove(state)

func size():
	return characters.size()

func get(i):
	return characters[i]

func initialize_from(something):
	print("TODO: Initialize the party from something...")

func suspend_to(file):
	# TODO: Iterate over the characters array, and make
	# 	a 'character.get_save_data()' that will generate a
	#	dictionary of character state variables.
	#	Bleh.
	# TODO: Caller passes in active file object (party.dat)
	for c in characters:
		var d = c.get_save_data()
		var j = to_json(d)
		# TODO: Write 'j' to 'file' via file.store_line(j)
