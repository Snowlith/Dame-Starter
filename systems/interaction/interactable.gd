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
# TODO: call this deferred so that multiple updates are stacked

func _get_prompt(default_value):
	return default_value

func interact(interactor: Interactor):
	print("Interacted with by " + str(interactor.get_parent_entity()))

# TODO: allow interactables to have multiple "actions"'
# All these actions can have different input mappings

# Also, the relationship between Interactable and Interactor needs to be more flexible.
# There should be a method Interactable can invoke on Interactor to end all interactions with
# other interactables.

# Rules:
# Player can only interact with one entity at a time.
# Interactables can have multiple actions.
# Interactables can make the Interactor be in different "modes"
# 	These modes include:
# 		Wait for confimation, do not switch entity

# TODO: instead of input actions to prompts, return a callable which will be utilized
