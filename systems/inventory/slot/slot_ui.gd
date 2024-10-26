extends Control
class_name SlotUI

var slot: Slot:
	set = _set_slot

func _set_slot(new_slot):
	if slot == new_slot:
		return
	slot = new_slot

signal context_action_registered(action, callable)
signal context_menu_requested

func register_context_actions():
	pass
