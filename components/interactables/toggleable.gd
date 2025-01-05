extends Interactable
class_name Toggleable

@export var enable_prompt: String
@export var disable_prompt: String

# refactor to toggled
@export var enabled: bool = false

func interact(interactor: Interactor):
	enabled = not enabled
	prompt_changed.emit(get_prompt())

func get_prompt() -> String:
	if enabled and disable_prompt:
		return disable_prompt
	if not enabled and enable_prompt:
		return enable_prompt
	return interact_prompt
