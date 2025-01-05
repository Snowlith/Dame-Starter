extends Component
class_name Interactable

@export var is_active: bool = true

#@export var registered_input_actions: Array[String] = ["interact"]
#@export var registered_input_actions_dict: Dictionary = {"Interact": "interact"}
@export var required_input_action: String = "interact"
@export var interact_prompt: String

signal prompt_changed(prompt: String)

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
# 		

func interact(interactor: Interactor):
	print("Interacted with by " + str(interactor))

func start_interaction(interactor: Interactor, input_action: String):
	print(interactor, input_action)

func end_interaction():
	pass

func get_prompt() -> String:
	return interact_prompt
