extends Control
class_name ExternalInventoryUI

@onready var grid_container: Control = $PanelContainer/MarginContainer/VBoxContainer/GridContainer

const STANDARD_SLOT_UI = preload("res://systems/inventory/slot/standard_slot_ui.tscn")

var _inventory: Inventory

func open(inventory: Inventory):
	_inventory = inventory
	_populate_slots()

func close():
	_inventory = null
	
func _populate_slots():
	for i in _inventory.slots.size():
		var slot_ui = STANDARD_SLOT_UI.instantiate()
		grid_container.add_child(slot_ui)
		slot_ui.slot = _inventory.slots[i]
		#slot_ui.hover_started.connect(func(): hovered_standard_slot_ui = slot_ui)
		#slot_ui.hover_ended.connect(func(): hovered_standard_slot_ui = null)
		#if context_menu:
			#slot_ui.context_action_registered.connect(context_menu.register_action.bind(slot_ui))
			#slot_ui.context_menu_requested.connect(context_menu.open.bind(slot_ui))
			#slot_ui.register_context_actions()
	#are_slots_populated = true
	#slots_populated.emit()
