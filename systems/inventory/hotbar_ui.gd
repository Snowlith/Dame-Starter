extends Control
class_name HotbarUI

@export var item_user: Entity
@export var hand: Node3D
@onready var selected_panel = $MarginContainer/HBoxContainer/HotbarSlotUI/SelectedPanel

var selected_index: int
var hotbar: Array[HotbarSlotUI] = []

# TODO: improve hotbar updating with signals
# TODO: START TRANSFERRING TO DAME STARTER

func _unhandled_input(event):
	if event.is_echo():
		return
	if event.is_action_pressed("hotbar_left"):
		selected_index = wrap(selected_index-1, 0, hotbar.size())
		_update_hand()
	elif event.is_action_pressed("hotbar_right"):
		selected_index = wrap(selected_index+1, 0, hotbar.size())
		_update_hand()

func _update_hand():
	var hand_slot_ui = hotbar[selected_index]
	selected_panel.reparent(hand_slot_ui)
	for child in hand.get_children():
		hand.remove_child(child)
		child.queue_free()
	if not hand_slot_ui.slot.item:
		return
	var item_node = hand_slot_ui.slot.item.view_model.instantiate() as Node3D
	hand.add_child(item_node)
	if item_node is ItemBehavior:
		item_node.user = item_user

func assign_slots(slot_container):
	var hotbar_uis = find_children("", "HotbarSlotUI")
	var target_standard_uis = slot_container.find_children("", "StandardSlotUI")
	
	for i in hotbar_uis.size():
		var hotbar_ui = hotbar_uis[i] as HotbarSlotUI
		if not i < target_standard_uis.size():
			return
		hotbar.append(hotbar_ui)
		hotbar_ui.slot = target_standard_uis[i].slot
		
