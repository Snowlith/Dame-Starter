extends Interactable
class_name Toggleable

@export var toggle_On_prompt: String
@export var toggle_off_prompt: String

@export var is_on: bool = false

func interact(_interactor: Interactor):
	is_on = not is_on

func get_prompt() -> String:
	if not is_on and toggle_On_prompt:
		return toggle_On_prompt
	if is_on and toggle_off_prompt:
		return toggle_off_prompt
	return interact_prompt
