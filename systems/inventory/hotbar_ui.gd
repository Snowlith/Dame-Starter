extends Control
class_name HotbarUI

# TODO: equip fists when nothing else in use

@export var item_user: Entity
@export var hand: Node3D
@export var inventory_ui: InventoryUI

@export var hotbar_container: HBoxContainer

const HOTBAR_SLOT_UI = preload("res://systems/inventory/slot/hotbar_slot_ui.tscn")

var previous_slot_ui: SlotUI
var selected_slot_ui: SlotUI

var selected_slot_index: int = 0

# maybe instead of this, use get_child() for hotbar container
var hotbar: Array[HotbarSlotUI] = []

var _loaded_viewmodel: Node3D
var _is_use_persistent: bool = false

func _unhandled_input(event):
	if event.is_echo():
		return
	var change = Input.get_axis("hotbar_left", "hotbar_right")
	if change != 0:
		previous_slot_ui = hotbar[selected_slot_index]
		selected_slot_index = wrap(selected_slot_index + change, 0, hotbar.size())
		selected_slot_ui = hotbar[selected_slot_index]
		_selected_slot_changed()
		return
	
	# This is bad
	for i in range(0, 6, 1):
		if Input.is_action_just_pressed("hotbar_"+str(i+1)):
			if inventory_ui.hovered_standard_slot_ui:
				var target = hotbar[i].slot
				target.swap_with(inventory_ui.hovered_standard_slot_ui.slot)
				return
			previous_slot_ui = hotbar[selected_slot_index]
			selected_slot_index = i
			selected_slot_ui = hotbar[selected_slot_index]
			_selected_slot_changed()
			return
		
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

func _assign_slots():
	var target_slot_uis = inventory_ui.hotbar_container.get_children()
	
	for target_slot_ui: StandardSlotUI in target_slot_uis:
		var slot_ui: HotbarSlotUI = HOTBAR_SLOT_UI.instantiate()
		hotbar_container.add_child(slot_ui)
		slot_ui.slot = target_slot_ui.slot
		hotbar.append(slot_ui)
		
	selected_slot_ui = hotbar[selected_slot_index]
	_selected_slot_changed()

func _on_backpack_ui_slots_created():
	_assign_slots()
