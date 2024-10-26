extends Control
class_name InventoryUI

@export var inventory: Inventory

@export var context_menu: ContextMenu
@export var hotbar_ui: HotbarUI
@export var hotbar_target_container: Control

@export var disabled_actions_when_open: Array[String] = ["jump", "crouch", "sprint", "left", "right", "up", "down", "hotbar_left", "hotbar_right"]

var _last_mouse_pos: Vector2

# TODO: disregard last mouse pos if outside window

func _ready():
	close()
	if not inventory.is_node_ready():
		await inventory.ready
	_populate_slots()

func _input(event):
	if event is InputEventMouseMotion:
		return
	if not event.is_echo() and event.is_action_pressed("toggle_inventory"):
		toggle()
	if visible and event.is_pressed():
		for action in disabled_actions_when_open:
			if event.is_action_pressed(action):
				get_viewport().set_input_as_handled()

func toggle():
	if visible:
		close()
	else:
		open()
		
func open():
	set_process_unhandled_key_input(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if _last_mouse_pos:
		warp_mouse(_last_mouse_pos)
	show()

# TODO: this
func open_external(Inventory):
	pass

func close():
	hide()
	set_process_unhandled_key_input(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_last_mouse_pos = get_local_mouse_position()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
		
