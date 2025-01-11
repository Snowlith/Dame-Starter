extends Interactable
class_name Toggleable

@export var enable_prompt: String
@export var disable_prompt: String

# refactor to toggled
@export var toggled: bool = false

func _get_prompt(default_prompt: String):
	if toggled and disable_prompt:
		return disable_prompt
	if not toggled and enable_prompt:
		return enable_prompt
	return default_prompt
	
func interact(interactor: Interactor):
	toggled = not toggled
	prompt_changed.emit(prompt)
