extends Resource
class_name Slot

@export var item: Item:
	set(new_item):
		if item and item.is_same(new_item):
			return
		if not new_item and amount != 0:
			amount = 0
		item = new_item
		item_changed.emit()

@export_range(0, 10000) var amount: int = 0:
	set(new_amount):
		if _is_ready and new_amount > capacity:
			push_error("Amount is greater than capacity")
			return
		amount = max(0, new_amount)
		if amount == 0:
			item = null
		amount_changed.emit()
		
@export var capacity: int = 16

signal item_changed
signal amount_changed

# HACK: exporting sucks on resources so gotta do this
var _is_ready = false
func _init():
	call_deferred("_ready")
func _ready():
	_is_ready = true

func is_empty():
	return not is_instance_valid(item)

func exchange_with(source_slot: Slot, desired_amount: int):
	if source_slot.is_empty():
		return
	
	if is_empty() or (item.is_same(source_slot.item) and item.is_stackable):
		combine_with(source_slot, desired_amount)
	else:
		swap_with(source_slot)

func swap_with(source_slot: Slot):
	var temp_item = source_slot.item
	var temp_amount = source_slot.amount
	source_slot.item = item
	source_slot.amount = amount
	item = temp_item
	amount = temp_amount

func combine_with(source_slot: Slot, desired_amount: int):
	if not item:
		item = source_slot.item
	
	var transferable_amount = min(desired_amount, source_slot.amount)
	var total_amount = amount + desired_amount
	
	if total_amount <= capacity:
		amount = total_amount
		source_slot.amount -= transferable_amount
	else:
		var remaining_capacity = capacity - amount
		amount = capacity
		source_slot.amount -= remaining_capacity
