extends Control
class_name InventoryUI

# TODO instantiate slots automatically instead of populating them

@export var inventory: Inventory

@export var context_menu: ContextMenu

var hovered_standard_slot_ui: StandardSlotUI

var are_slots_populated: bool = false
signal slots_populated

# TODO: when pressing q on a hovered item, drop it

func _ready():
	if not inventory.is_node_ready():
		await inventory.ready
	_populate_slots()
		
# TODO
func open_external(external_inventory: Inventory):
	pass

func drop(slot: Slot, amount: int):
	pass

func _populate_slots():
	var standard_uis = find_children("", "StandardSlotUI")
	
	for i in standard_uis.size():
		var slot_ui = standard_uis[i] as StandardSlotUI
		if i >= inventory.slots.size():
			slot_ui.get_parent().remove_child(slot_ui)
			slot_ui.queue_free()
			continue
		slot_ui.slot = inventory.slots[i]
		slot_ui.hover_started.connect(func(): hovered_standard_slot_ui = slot_ui)
		slot_ui.hover_ended.connect(func(): hovered_standard_slot_ui = null)
		if context_menu:
			slot_ui.context_action_registered.connect(context_menu.register_action.bind(slot_ui))
			slot_ui.context_menu_requested.connect(context_menu.open.bind(slot_ui))
			slot_ui.register_context_actions()
	are_slots_populated = true
	slots_populated.emit()
