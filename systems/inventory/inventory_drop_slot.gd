extends Control

# TODO: this

signal item_dropped(prev_owner)

func _can_drop_data(_pos, data):
	return true

func _drop_data(_pos, prev_owner):
	item_dropped.emit(prev_owner)
