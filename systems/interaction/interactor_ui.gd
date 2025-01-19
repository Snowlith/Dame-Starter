extends Control

@export var interactor: Interactor

@onready var list_container: Control = $MarginContainer/VBoxContainer

const INTERACTION_LIST_ELEMENT = preload("res://systems/interaction/interaction_list_element.tscn")

# TODO: delete interaction list label from files
# TODO: interactor already handles is_active, don't need to do that here

var ui_elements: Dictionary = {}

func _ready():
	hide()
	interactor.hovered_interactables_updated.connect(_on_hovered_interactables_updated)

func _on_hovered_interactables_updated(hovered_interactables):
	for input_action in ui_elements.keys():
		if not hovered_interactables.has(input_action):
			_remove_ui_element(input_action)
	
	for input_action in hovered_interactables.keys():
		if not ui_elements.has(input_action):
			_add_ui_element(input_action)
		
		var interactables = hovered_interactables[input_action]
		_update_ui_element(input_action, interactables)
	
	visible = not hovered_interactables.is_empty()

func _add_ui_element(input_action: String):
	var list_element = INTERACTION_LIST_ELEMENT.instantiate()
	list_element.name = input_action
	list_container.add_child(list_element)
	list_element.set_input_action(input_action)
	ui_elements[input_action] = {
		"element": list_element,
		"labels": []
	}

func _remove_ui_element(input_action: String):
	var data = ui_elements[input_action]
	var list_element = data["element"]
	
	for label_data in data["labels"]:
		var interactable = label_data["interactable"]
		interactable.prompt_changed.disconnect(_on_prompt_changed)
		interactable.is_active_changed.disconnect(_on_is_active_changed)
	
	list_container.remove_child(list_element)
	list_element.queue_free()
	ui_elements.erase(input_action)

func _update_ui_element(input_action: String, interactables: Array):
	var data = ui_elements[input_action]
	var list_element = data["element"]
	
	for label_data in data["labels"]:
		var label = label_data["label"]
		list_element.prompt_container.remove_child(label)
		label.queue_free()
		var interactable = label_data["interactable"]
		interactable.prompt_changed.disconnect(_on_prompt_changed)
		interactable.is_active_changed.disconnect(_on_is_active_changed)
	
	data["labels"].clear()
	
	for interactable: Interactable in interactables:
		var prompt_label = Label.new()
		list_element.prompt_container.add_child(prompt_label)
		prompt_label.text = interactable.prompt
		data["labels"].append({"label": prompt_label, "interactable": interactable})
		interactable.prompt_changed.connect(_on_prompt_changed.bind(input_action, prompt_label))
		interactable.is_active_changed.connect(_on_is_active_changed.bind(input_action, prompt_label))

func _on_prompt_changed(new_prompt: String, input_action: String, label: Label):
	label.text = new_prompt

func _on_is_active_changed(is_active: bool, input_action: String, label: Label):
	label.visible = is_active
