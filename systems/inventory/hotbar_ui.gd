extends Control
class_name HotbarUI

# TODO: equip fists when nothing else in use

@export var item_user: Entity
@export var hand: Node3D

@export var slot_amount: int = 6

@onready var hotbar_container = $MarginContainer/HBoxContainer

const HOTBAR_SLOT_UI = preload("res://systems/inventory/slot/hotbar_slot_ui.tscn")

var row_start_index: int = 0

var previous_slot_ui: SlotUI
var selected_slot_ui: SlotUI

var selected_slot_index: int = 0

# maybe instead of this, use get_child() for hotbar container
var hotbar: Array[HotbarSlotUI] = []

var _inventory: Inventory

var _loaded_viewmodel: Node3D
var _is_use_persistent: bool = false

func _unhandled_input(event):
	if event.is_echo():
		return
	if event.is_action_pressed("hotbar_cycle_row"):
		cycle_row_index(1)
		
	cycle_hotbar_index(Input.get_axis("hotbar_left", "hotbar_right"))
	
	for i in range(0, 6, 1):
		if Input.is_action_just_pressed("hotbar_"+str(i+1)):
			set_hotbar_index(i)
			return

func cycle_row_index(amount):
	row_start_index += amount * slot_amount
	if row_start_index >= _inventory.size:
		row_start_index = 0
	_row_changed()

func set_row_index(index):
	row_start_index = index * slot_amount
	if row_start_index >= _inventory.size:
		row_start_index = 0
	_row_changed()

func cycle_hotbar_index(amount: int):
	# TEST THIS
	if amount == 0 or amount % hotbar.size() == 0:
		return
	previous_slot_ui = hotbar[selected_slot_index]
	selected_slot_index = wrap(selected_slot_index + amount, 0, hotbar.size())
	selected_slot_ui = hotbar[selected_slot_index]
	_selected_slot_changed()

func set_hotbar_index(index):
	var clamped = clamp(index, 0, hotbar.size())
	if clamped == selected_slot_index:
		return
	previous_slot_ui = hotbar[selected_slot_index]
	selected_slot_index = clamped
	selected_slot_ui = hotbar[selected_slot_index]
	_selected_slot_changed()
	
func _selected_slot_changed():
	if previous_slot_ui:
		previous_slot_ui.slot.item_changed.disconnect(_update_hand)
	selected_slot_ui.slot.item_changed.connect(_update_hand)
	_update_hand()

func _update_hand():
	if _loaded_viewmodel:
		if _loaded_viewmodel is ItemBehavior:
			_loaded_viewmodel.unholster()
		hand.remove_child(_loaded_viewmodel)
		if not _is_use_persistent:
			_loaded_viewmodel.queue_free()
		_loaded_viewmodel = null
	
	%SelectionPanel.reparent(selected_slot_ui)
	
	var selected_slot = selected_slot_ui.slot
	if not selected_slot.item:
		return
	
	if selected_slot.cached_viewmodel:
		_loaded_viewmodel = selected_slot.cached_viewmodel
		_is_use_persistent = true
	else:
		_loaded_viewmodel = selected_slot.item.viewmodel.instantiate()
		if selected_slot.item.is_use_persistent:
			selected_slot.cached_viewmodel = _loaded_viewmodel
			_is_use_persistent = true
		else:
			_is_use_persistent = false
	
	hand.add_child(_loaded_viewmodel)
	if _loaded_viewmodel is ItemBehavior:
		_loaded_viewmodel.holster(item_user)

func get_target_slots():
	var slots = _inventory.slots

	return slots.slice(row_start_index, row_start_index + slot_amount)

func create_slots(inventory: Inventory):
	_inventory = inventory
	var target_slots = get_target_slots()
	for slot: Slot in target_slots:
		var slot_ui: HotbarSlotUI = HOTBAR_SLOT_UI.instantiate()
		hotbar_container.add_child(slot_ui)
		slot_ui.slot = slot
		hotbar.append(slot_ui)
		
		var action = "hotbar_"+str(hotbar.size())
		slot_ui.set_input_icon_action(action)
	
	selected_slot_ui = hotbar[0]
	_selected_slot_changed()
	
func _row_changed():
	var target_slots = get_target_slots()
	
	for i in target_slots.size():
		var slot_ui: HotbarSlotUI = hotbar_container.get_child(i)
		slot_ui.slot = target_slots[i]
		hotbar.append(slot_ui)
