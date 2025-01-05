extends Component
class_name Inventory

# TODO: make this into a vector2
@export var size: int
@export var slots: Array[Slot]

func _ready():
	slots.resize(max(size, slots.size()))
	for i in slots.size():
		if not slots[i]:
			slots[i] = Slot.new()

func insert(source_slot: Slot, amount: int = 1) -> int:
	if source_slot.is_empty():
		return 0
		
	var partially_filled_slots: Array[Slot]
	var empty_slots: Array[Slot]
	
	for slot in slots:
		if slot.is_empty():
			empty_slots.append(slot)
		elif slot.item == source_slot.item:
			partially_filled_slots.append(slot)
	
	for slot in partially_filled_slots + empty_slots:
		slot.exchange_with(source_slot, amount)
		if source_slot.is_empty():
			return 0
	return source_slot.amount

#func insert(item: Item, amount: int = 1) -> int:
	#if amount <= 0 or not item:
		#return 0
		#
	#var remaining_amount = amount
	#if item.stack_size > 1:
		#remaining_amount = _insert_into_existing_slots(item, remaining_amount)
	#if remaining_amount > 0:
		#remaining_amount = _insert_into_empty_slots(item, remaining_amount)
	#return remaining_amount

# TODO: write similarly to insert
func remove(item: Item, amount: int = 1) -> int:
	if amount <= 0 or not item:
		return 0
	return _remove_from_existing_slots(item, amount)

#func remove_from(slot: Slot, amount: int = 1):
	#slot.amount = clamp(slot.amount - amount, 0, slot.amount)

func has(item: Item):
	for slot in slots:
		if item == slot.item:
			return true
	return false

func count(item: Item) -> int:
	var tally = 0
	if item:
		for slot in slots:
			if slot.item == item:
				tally += slot.amount
	else:
		for slot in slots:
			if not slot.item:
				tally += 1
	return tally

func can_insert(item: Item, amount: int) -> bool:
	if not item:
		return false
	var capacity = 0
	if item.stack_size > 1:
		for slot in slots:
			if slot.item == item:
				capacity += item.stack_size - slot.amount
		capacity += count(null) * item.stack_size
	else:
		capacity = count(null)
	return capacity >= amount

## Stacking helper methods

#func _insert_into_existing_slots(item: Item, remaining_amount: int) -> int:
	#for slot in slots:
		## Skip when items don't match
		#if slot.item != item:
			#continue
		## Skip full slots
		#if slot.amount >= item.stack_size:
			#continue
		#var available_space = item.stack_size - slot.amount
		#var amount_to_add = min(remaining_amount, available_space)
		#slot.amount += amount_to_add
		#remaining_amount -= amount_to_add
		#if remaining_amount <= 0:
			#return 0
	#return remaining_amount
#
#func _insert_into_empty_slots(item: Item, remaining_amount: int) -> int:
	#for slot in slots:
		## Only consider empty slots
		#if slot.item:
			#continue
		#
		#slot.item = item
		#var amount_to_add = min(remaining_amount, item.stack_size)
		#slot.amount = amount_to_add
		#remaining_amount -= amount_to_add
		#if remaining_amount <= 0:
			#return 0
	#return remaining_amount

func _remove_from_existing_slots(item: Item, remaining_amount: int) -> int:
	for slot in slots:
		if slot.item != item:
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
