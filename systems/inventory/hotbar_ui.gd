extends Control
class_name HotbarUI

@export var item_user: Entity
@export var hand: Node3D

var previous_slot_index: int = -1
var selected_slot_index: int = 0

var hotbar: Array[HotbarSlotUI] = []

func _unhandled_input(event):
	if event.is_echo():
		return
	var change = Input.get_axis("hotbar_left", "hotbar_right")
	if change != 0:
		previous_slot_index = selected_slot_index
		selected_slot_index = wrap(selected_slot_index + change, 0, hotbar.size())
		_selected_slot_changed()
		
func _selected_slot_changed():
	if previous_slot_index != -1:
		hotbar[previous_slot_index].slot.item_changed.disconnect(_update_hand)
	hotbar[selected_slot_index].slot.item_changed.connect(_update_hand)
	_update_hand()

func _update_hand():
	var selected_slot_ui = hotbar[selected_slot_index]
	%SelectionPanel.reparent(selected_slot_ui)
	for child in hand.get_children():
		hand.remove_child(child)
		child.queue_free()
	if not selected_slot_ui.slot.item:
		return
	var view_model = selected_slot_ui.slot.item.view_model.instantiate()
	hand.add_child(view_model)
	if view_model is ItemBehavior:
		view_model.user = item_user

func assign_slots(slot_container):
	var hotbar_slot_uis = find_children("", "HotbarSlotUI")
	var target_standard_uis = slot_container.find_children("", "StandardSlotUI")
	
	for i in hotbar_slot_uis.size():
		var hotbar_slot_ui = hotbar_slot_uis[i] as HotbarSlotUI
		if not i < target_standard_uis.size():
			return
		hotbar.append(hotbar_slot_ui)
		hotbar_slot_ui.slot = target_standard_uis[i].slot
	
	_selected_slot_changed()
		
