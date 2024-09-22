extends Component
class_name Inventory

var slots: Array[Slot]
var size: int

var shit = load("res://items/box.tscn")

@onready var initial_items = $InitialItems

# current problem:
# since the item dropped by a broken box is the box itself, there is a cyclic dependency

func _ready():
	initial_items.add_child(shit.instantiate())
	slots.append(Slot.new())
	for child in initial_items.get_children():
		if child is Item:
			collect(child)

func drop_all():
	var temp_drop_slot = DropSlot.new()
	add_child(temp_drop_slot)
	slots.append(temp_drop_slot)
	for slot in slots:
		if slot == temp_drop_slot:
			return
		temp_drop_slot._take_from_slot(slot, slot.amount)
		temp_drop_slot.drop()
	remove_child(temp_drop_slot)
	temp_drop_slot.queue_free()
		

func insert(item: Item, amount: int = 1) -> int:
	if amount <= 0 or not item:
		return 0
	var remaining_amount = amount

	# Try inserting into existing slots
	if item.is_stackable:
		remaining_amount = _insert_into_existing_slots(item, remaining_amount)

	# Try inserting into empty slots
	if remaining_amount > 0:
		remaining_amount = _insert_into_empty_slots(item, remaining_amount)
	return amount - remaining_amount

func remove(item: Item, amount: int = 1) -> int:
	if amount <= 0 or not item:
		return 0
	var remaining_amount = amount
	remaining_amount = _remove_from_existing_slots(item, remaining_amount)
	return amount - remaining_amount

func remove_from(slot: Slot, amount: int = 1):
	slot.amount = clamp(slot.amount - amount, 0, slot.amount)

func collect(item: Item):
	if can_insert(item, item.stack_size):
		await item.play_collect()
		# some kind of bug here
		item.get_parent().remove_child(item)
		insert(item, item.stack_size)
		item.queue_free()
	else:
		# make partly taken animation
		# Only take as many items as possible
		var items_taken = insert(item, item.stack_size)
		item.stack_size -= items_taken

func has(item: Item):
	if not item:
		return false
	for slot in slots:
		if slot.item and slot.item.is_same(item):
			return true
	return false

func count(item: Item, stackable: bool) -> int:
	var tally = 0
	if item == null:
		for slot in slots:
			if slot.item != null:
				continue
			if stackable:
				tally += slot.capacity
			else:
				tally += 1
	else:
		for slot in slots:
			if not item.is_same(slot.item):
				continue
			tally += slot.amount
	return tally

func can_insert(item: Item, amount: int) -> bool:
	var total_capacity = 0
	if item.is_stackable:
		for slot in slots:
			if not slot.item or not item.is_same(slot.item):
				continue
			total_capacity += slot.capacity - slot.amount
		total_capacity += count(null, true)
	else:
		total_capacity = count(null, false)
	return total_capacity >= amount

## Stacking helper methods

func _insert_into_existing_slots(item: Item, remaining_amount: int) -> int:
	for slot in slots:
		# Skip when null or items don't match
		if not slot.item or not item.is_same(slot.item):
			continue
		# Skip full slots
		if slot.amount >= slot.capacity:
			continue
		var available_space = slot.capacity - slot.amount
		var amount_to_add = min(remaining_amount, available_space)
		slot.amount += amount_to_add
		remaining_amount -= amount_to_add
		if remaining_amount <= 0:
			return 0
			# Queue free item?
	return remaining_amount

func _insert_into_empty_slots(item: Item, remaining_amount: int) -> int:
	for slot in slots:
		# Only consider empty slots
		if slot.item:
			continue
		slot.item = item.duplicate()
		var amount_to_add = min(remaining_amount, slot.capacity)
		if not item.is_stackable:
			amount_to_add = 1
		slot.amount = amount_to_add
		remaining_amount -= amount_to_add
		if remaining_amount <= 0:
			return 0
	return remaining_amount

func _remove_from_existing_slots(item: Item, remaining_amount: int) -> int:
	for slot in slots:
		# Skip if null or items don't match
		if not slot.item or not item.is_same(slot.item):
			continue
		# Partly deplete slot
		if slot.amount > remaining_amount:
			slot.amount -= remaining_amount
			return 0
		else:
			# Completely deplete slot
			remaining_amount -= slot.amount
			slot.item.queue_free()
			slot.amount = 0
	return remaining_amount
