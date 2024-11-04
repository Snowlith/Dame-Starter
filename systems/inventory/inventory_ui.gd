extends MenuUI
class_name InventoryUI

@export var inventory: Inventory

@export var context_menu: ContextMenu
@export var hotbar_ui: HotbarUI
@export var hotbar_target_container: Control

func _ready():
	super()
	if not inventory.is_node_ready():
		await inventory.ready
	_populate_slots()
		
# TODO: this
func open_external(external_inventory: Inventory):
	pass
	
# NOTE: currently does not take into account drop slot
# drop slot initializes by itself, does not have actions

func _populate_slots():
	var standard_uis = find_children("", "StandardSlotUI")
	
	for i in standard_uis.size():
		var slot_ui = standard_uis[i] as StandardSlotUI
		if i >= inventory.slots.size():
			slot_ui.get_parent().remove_child(slot_ui)
			slot_ui.queue_free()
			continue
		slot_ui.slot = inventory.slots[i]
		if context_menu:
			slot_ui.context_action_registered.connect(context_menu.register_action.bind(slot_ui))
			slot_ui.context_menu_requested.connect(context_menu.open.bind(slot_ui))
			slot_ui.register_context_actions()
	
	if hotbar_ui:
		hotbar_ui.assign_slots(hotbar_target_container)
