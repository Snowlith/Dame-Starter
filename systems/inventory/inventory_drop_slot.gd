extends Control

# TODO: this

signal item_dropped(prev_owner)

func _can_drop_data(_pos, data):
	return true

func _drop_data(_pos, data):
	var source_slot = data["slot"] as Slot
	var desired_amount = data['amount'] as int
	item_dropped.emit(source_slot, desired_amount)
