extends Control
class_name InventoryUI

# TODO instantiate slots automatically instead of populating them

@export var inventory: Inventory

@export var backpack_container: GridContainer
@export var backpack_width: int = 6

@export var hotbar_container: GridContainer
@export var hotbar_width: int = 6

@export var context_menu: ContextMenu

const STANDARD_SLOT_UI = preload("res://systems/inventory/slot/standard_slot_ui.tscn")

var _hovered_standard_slot_ui: StandardSlotUI

signal slots_created

func _ready():
	# do this differently
	if not inventory.is_node_ready():
		await inventory.ready
	backpack_container.columns = backpack_width
	hotbar_container.columns = hotbar_width
	_create_slots()

# TODO
func get_slot(index: int):
	pass
		
# TODO
func open_external(external_inventory: Inventory):
	pass

func drop(slot: Slot, amount: int):
	pass

func _create_slots():
	for i in inventory.size:
		var slot_ui: StandardSlotUI = STANDARD_SLOT_UI.instantiate()
		if i < hotbar_width:
			hotbar_container.add_child(slot_ui)
		else:
			backpack_container.add_child(slot_ui)
		slot_ui.slot = inventory.slots[i]
		slot_ui.hover_started.connect(func(): _hovered_standard_slot_ui = slot_ui)
		slot_ui.hover_ended.connect(func(): _hovered_standard_slot_ui = null)
		if context_menu:
			slot_ui.context_action_registered.connect(context_menu.register_action.bind(slot_ui))
			slot_ui.context_menu_requested.connect(context_menu.open.bind(slot_ui))
			slot_ui.register_context_actions()
	slots_created.emit()
