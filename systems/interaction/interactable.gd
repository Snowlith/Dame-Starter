extends Component
class_name Interactable

@export var input_action: String = "interact"
@export var prompt: String = "":
	get: return _get_prompt(prompt)

@export var is_active: bool = true:
	set(value):
		if is_active == value:
			return
		is_active = value
		is_active_changed.emit(is_active)

signal input_action_changed(new_input_action: String)
signal prompt_changed(new_prompt: String)
signal is_active_changed(new_active: bool)

func _get_prompt(default_value):
	return default_value

func interact(interactor: Interactor):
	print("Interacted with by " + str(interactor.get_parent_entity()))
