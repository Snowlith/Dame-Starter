extends CanvasLayer
class_name Transition

var disabled_actions: Array[String] = ["jump", "crouch", "sprint", "left", "right", "up", "down", "inspect"]

func _input(event: InputEvent):
	for action in disabled_actions:
		if event.is_action_pressed(action):
			get_viewport().set_input_as_handled()
			return

# Called when the node enters the scene tree for the first time.
func fade_out() -> void:
	pass

func fade_in() -> void:
	pass
