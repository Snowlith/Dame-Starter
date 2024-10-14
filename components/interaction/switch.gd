extends Toggleable
class_name Switch

@export var entities_to_interact_with: Array[Entity]
@export var nodes_to_show_when_on: Array[Node3D]
@export var nodes_to_hide_when_on: Array[Node3D]

@export var stagger_time: float = 0

func _ready():
	_toggle_visible(nodes_to_show_when_on, is_on, 0)
	_toggle_visible(nodes_to_hide_when_on, not is_on, 0)

func _toggle_visible(nodes: Array, on: bool, stagger: float):
	for node in nodes:
		node.visible = on
		if stagger:
			await get_tree().create_timer(stagger).timeout

func _interact_nodes(nodes: Array, interactor: Interactor, stagger: float):
	for entity in nodes:
		var interactables = entity.get_components_of_type("Interactable")
		for interactable: Interactable in interactables:
			interactable.interact(interactor)
		if stagger:
			await get_tree().create_timer(stagger).timeout

func interact(interactor: Interactor):
	super(interactor)
	_toggle_visible(nodes_to_show_when_on, is_on, stagger_time)
	_toggle_visible(nodes_to_hide_when_on, not is_on, stagger_time)
	_interact_nodes(entities_to_interact_with, interactor, stagger_time)
