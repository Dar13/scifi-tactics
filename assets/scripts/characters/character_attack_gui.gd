extends Control

signal confirmed
signal cancelled

onready var target_confirm_dlg = get_node("target_confirm_dlg")
onready var cancel_attack_btn = get_node("cancel_attack_btn")

onready var attack_selection_btn = get_node("target_confirm_dlg/VSplitContainer/attack_btn")
onready var cancel_selection_btn = get_node("target_confirm_dlg/VSplitContainer/cancel_btn")

func _ready():
	attack_selection_btn.connect("pressed", self, "handle_attack_selection")
	cancel_selection_btn.connect("pressed", self, "handle_cancel_selection")

	cancel_attack_btn.connect("pressed", self, "handle_cancel_button")
	pass

func selection_mode():
	target_confirm_dlg.hide()
	cancel_attack_btn.show()

func confirmation_mode(screen_coord):
	cancel_attack_btn.hide()

	target_confirm_dlg.rect_global_position = screen_coord
	target_confirm_dlg.show()

func handle_attack_selection():
	emit_signal("confirmed")

func handle_cancel_selection():
	emit_signal("cancelled")

func handle_cancel_button():
	emit_signal("cancelled")
