extends HBoxContainer

func _ready():
	pass

func display(show_ability):
	if show_ability:
		$ability.show()
	else:
		$ability.hide()
	
	self.show()

func get_attack_btn():
	return get_node("attack")

func get_ability_btn():
	return get_node("ability")

func get_item_btn():
	return get_node("item")

func get_standby_btn():
	return get_node("standby")

func get_cancel_btn():
	return get_node("cancel")
