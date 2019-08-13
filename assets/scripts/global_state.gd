extends Node

var debug_mode = 1
var quit_requested = 0

var next_scene = ""
var battle_map = "res://assets/scenes/maps/generic_hill.tscn"

var error_popup = load("res://assets/scripts/utils/error_popup.gd")
