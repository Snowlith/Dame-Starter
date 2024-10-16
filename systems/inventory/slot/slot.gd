extends Control
class_name Slot

#var hovering = false

# NOTE: position in drag could do some interesting stuff
# TODO: write can_drop and drop in a way that visual indicator of blocked is there

@export var capacity: int = 16

var amount: int:
	set(value):
		if amount == value:
			return
		amount = value
		if amount <= 0:
			amount = 0
			item = null
		amount_changed.emit()
		
var item: Item:
	set(value):
		if item == value:
			return
		item = value
		item_changed.emit()
		
signal item_changed
signal amount_changed

func _ready():
	set_process_input(false)
	
func get_icon_path():
	if not item:
		return ""
	return "res://items/icons/" + item.scene_file_path.split('/')[-1] + '.png'

# unused?
func can_add(amount_to_add: int):
	return amount_to_add + amount <= capacity

func is_empty():
	return item == null

func get_item_copy():
	if not item:
		return null
	return item.duplicate()
	
## Mouse hover

func _take_from_slot(source_slot: Slot, desired_amount: int):
	item = source_slot.get_item_copy()
	var min_amount = min(desired_amount, capacity)
	amount = min_amount
	source_slot.amount -= min_amount

func _swap_from_slot(source_slot: Slot):
	var temp_item = source_slot.item
	var temp_amount = source_slot.amount
	source_slot.item = item
	source_slot.amount = amount
	item = temp_item
	amount = temp_amount

func _combine_from_slot(source_slot: Slot, desired_amount: int):
	var total_amount = amount + desired_amount
	if total_amount <= capacity:
		   # Merge completely
		amount = total_amount
		source_slot.amount -= desired_amount
	else:
		var amount_to_add = capacity - amount
		amount = capacity
		source_slot.amount -= amount_to_add
	
## Dragging
