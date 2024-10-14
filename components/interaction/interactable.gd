extends Component
class_name Interactable

@export var interact_prompt: String

func interact(interactor: Interactor):
	print("Interacted with by " + str(interactor))

func get_prompt() -> String:
	return interact_prompt
