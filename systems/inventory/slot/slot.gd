extends Resource
class_name Slot

@export var item: Item:
	set(new_item):
		if item == new_item:
			return
		item = new_item
		# NOTE: call deferred fixes swap bugs
		item_changed.emit.call_deferred()

@export_range(0, 1000) var amount: int = 0:
	set(new_amount):
		new_amount = max(0, new_amount)
		if amount == new_amount:
			return
		amount = new_amount
		if item:
			if amount == 0:
				item = null
			elif amount > item.stack_size:
				push_error("Amount (", new_amount, ") is greater than stack size (", item.stack_size, ") on ", self)
		amount_changed.emit.call_deferred()

var cached_viewmodel: Node3D

signal item_changed
signal amount_changed

func is_empty():
	return not is_instance_valid(item)
	
func exchange_with(source_slot: Slot, desired_amount: int):
	if source_slot.is_empty():
		return

	if is_empty() or (item == source_slot.item and item.stack_size > 1):
		combine_with(source_slot, desired_amount)
	else:
		swap_with(source_slot)

func swap_with(source_slot: Slot):
	var temp_item = source_slot.item
	var temp_amount = source_slot.amount
	var temp_cached_viewmodel = source_slot.cached_viewmodel
	
	source_slot.item = item
	source_slot.amount = amount
	source_slot.cached_viewmodel = cached_viewmodel
	
	item = temp_item
	amount = temp_amount
	cached_viewmodel = temp_cached_viewmodel

func combine_with(source_slot: Slot, desired_amount: int):
	if is_empty():
		item = source_slot.item
		cached_viewmodel = source_slot.cached_viewmodel
	
	var transferable_amount = min(desired_amount, source_slot.amount)
	var total_amount = amount + transferable_amount
	
	if total_amount <= item.stack_size:
		amount = total_amount
		source_slot.amount -= transferable_amount
	else:
		var remaining_capacity = item.stack_size - amount
		amount = item.stack_size
		source_slot.amount -= remaining_capacity
