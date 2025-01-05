extends Control
class_name HotbarUI

# TODO: equip fists when nothing else in use

@export var item_user: Entity
@export var hand: Node3D
@export var inventory_ui: InventoryUI
@export var target_slot_container: Control

var previous_slot_ui: SlotUI
var selected_slot_ui: SlotUI

var selected_slot_index: int = 0

var hotbar: Array[HotbarSlotUI] = []

var _loaded_viewmodel: Node3D
var _is_use_persistent: bool = false

func _ready():
	if not inventory_ui.are_slots_populated:
		await inventory_ui.slots_populated
	_assign_slots(target_slot_container)

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

func _assign_slots(slot_container: Control):
	var hotbar_slot_uis = find_children("", "HotbarSlotUI")
	var target_standard_uis = slot_container.find_children("", "StandardSlotUI")
	
	for i in hotbar_slot_uis.size():
		var hotbar_slot_ui = hotbar_slot_uis[i] as HotbarSlotUI
		if not i < target_standard_uis.size():
			return
		hotbar.append(hotbar_slot_ui)
		hotbar_slot_ui.slot = target_standard_uis[i].slot
	
	selected_slot_ui = hotbar[selected_slot_index]
	_selected_slot_changed()
		
