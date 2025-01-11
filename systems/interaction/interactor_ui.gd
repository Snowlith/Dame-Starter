extends Control

@export var interactor: Interactor

@onready var list_container: Control = $MarginContainer/VBoxContainer

const INTERACTION_LIST_ELEMENT = preload("res://systems/interaction/interaction_list_element.tscn")
const INTERACTION_LIST_LABEL = preload("res://systems/interaction/interaction_list_label.tscn")

func _ready():
	hide()
	interactor.entity_changed.connect(_on_entity_changed)
	interactor.interactable_added.connect(_on_interactable_added)
	
func _on_entity_changed(entity: Entity):
	if entity:
		show()
	else:
		for child in list_container.get_children():
			list_container.remove_child(child)
			child.queue_free()
		hide()
		
func _on_interactable_added(interactable: Interactable):
	var input_action = interactable.input_action

	if list_container.get_child_count() != 0:
		list_container.add_child(HSeparator.new())
	var list_element = list_container.get_node_or_null(input_action)
	if not list_element:
		list_element = INTERACTION_LIST_ELEMENT.instantiate()
		list_element.set_input_action.call_deferred(interactable.input_action)
		list_element.name = input_action
		list_container.add_child(list_element)
		
	var prompt_label = INTERACTION_LIST_LABEL.instantiate()
	prompt_label.connect_interactable_signals(interactable)
	list_element.prompt_container.add_child.call_deferred(prompt_label)
