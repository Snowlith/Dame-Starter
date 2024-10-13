extends Interactable
class_name Switch

@export var is_on: bool = false

@export var entities_to_interact_with: Array[Entity]
@export var nodes_to_show_when_on: Array[Node3D]
@export var nodes_to_hide_when_on: Array[Node3D]

func _ready():
	_toggle_nodes()
	
func _toggle_nodes():
	for node in nodes_to_show_when_on:
		node.visible = is_on
	for node in nodes_to_hide_when_on:
		node.visible = not is_on

func interact(interactor: Interactor):
	is_on = not is_on
	for entity in entities_to_interact_with:
		var interactables = entity.get_components_of_type("Interactable")
		for interactable: Interactable in interactables:
			interactable.interact(interactor)
	_toggle_nodes()
