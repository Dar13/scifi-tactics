extends Control

onready var dialog = AcceptDialog.new()

var error = OK
var stack = null

# Called when the node enters the scene tree for the first time.
func _ready():
	self.pause_mode = Node.PAUSE_MODE_PROCESS

	add_child(dialog)
	dialog.dialog_hide_on_ok = true
	dialog.get_label().valign = Label.VALIGN_CENTER
	dialog.connect("confirmed", self, "on_confirm")
	
	var error_text = "Error: {0}".format([error])
	if stack:
		error_text += "\n\nStack:\n"
		for frame in stack:
			error_text += "{source},{line}: {function}\n".format(frame)
			
	dialog.dialog_text = error_text
	dialog.popup_centered_minsize(Vector2(300, 300))

func _init(err, call_stack: Array):
	error = err
	stack = call_stack

func on_confirm():
	get_tree().quit()