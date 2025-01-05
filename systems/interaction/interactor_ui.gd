extends Control

@export var interactor: Interactor

@onready var list_container: Control = $MarginContainer/VBoxContainer

const INTERACTION_LIST_ELEMENT = preload("res://systems/interaction/interaction_list_element.tscn")

func _ready():
	hide()
	interactor.entity_changed.connect(_on_entity_changed)
	interactor.input_action_added.connect(_on_input_action_added)
	interactor.interactable_added.connect(_on_interactable_added)

func _on_entity_changed(entity: Entity):
	if entity:
		show()
	else:
		for child in list_container.get_children():
			list_container.remove_child(child)
			child.queue_free()
		hide()
		
func _on_input_action_added(input_action: String):
	if list_container.get_child_count() != 0:
		list_container.add_child(HSeparator.new())
	var list_element = INTERACTION_LIST_ELEMENT.instantiate()
	list_element.set_input_action.call_deferred(input_action)
	list_element.name = input_action
	list_container.add_child(list_element)

func _on_interactable_added(input_action: String, interactable: Interactable):
	var list_element = list_container.get_node_or_null(input_action)
	if not list_element:
		push_error("Invalid interactor list element: " + input_action)
	list_element.add_interactable.call_deferred(interactable)
