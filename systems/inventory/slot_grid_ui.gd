extends GridContainer
class_name SlotGridUI

# TODO instantiate slots automatically instead of populating them

@export var context_menu: ContextMenu

const STANDARD_SLOT_UI = preload("res://systems/inventory/slot/standard_slot_ui.tscn")

var _hovered_standard_slot_ui: StandardSlotUI

func get_hovered_slot_ui():
	return _hovered_standard_slot_ui

func create_slots(inventory: Inventory):
	for i in inventory.size:
		var slot_ui: StandardSlotUI = STANDARD_SLOT_UI.instantiate()
		add_child(slot_ui)
		slot_ui.slot = inventory.slots[i]
		slot_ui.hover_started.connect(func(): _hovered_standard_slot_ui = slot_ui)
		slot_ui.hover_ended.connect(func(): _hovered_standard_slot_ui = null)
		if context_menu:
			slot_ui.context_action_registered.connect(context_menu.register_action.bind(slot_ui))
			slot_ui.context_menu_requested.connect(context_menu.open.bind(slot_ui))
			slot_ui.register_context_actions()

# TODO: unregister context actions when clearing
func clear_slots():
	for child in get_children():
		remove_child(child)
		child.queue_free()
