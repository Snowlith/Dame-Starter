extends Component
class_name Inventory

@export var size: int
@export var slots: Array[Slot]

func _ready():
	slots.resize(max(size, slots.size()))
	for i in slots.size():
		if not slots[i]:
			slots[i] = Slot.new()

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
	return remaining_amount

func remove(item: Item, amount: int = 1) -> int:
	if amount <= 0 or not item:
		return 0
	return _remove_from_existing_slots(item, amount)

func remove_from(slot: Slot, amount: int = 1):
	slot.amount = clamp(slot.amount - amount, 0, slot.amount)

func has(item: Item):
	if not item:
		return false
	for slot in slots:
		if slot.item and slot.item.is_same(item):
			return true
	return false

# TODO: write this better, what even is this
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
		
		# DUPLICATE IS BAD
		slot.item = item #.duplicate()
		#slot.item.take_over_path(item.resource_path) # Duplicate erases the resource path
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
			slot.amount = 0
	return remaining_amount
