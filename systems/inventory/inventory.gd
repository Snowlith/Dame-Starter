extends Component
class_name Inventory

@export var size: int
@export var slots: Array[Slot]

signal inventory_loaded
signal external_inventory_loaded(inventory: Inventory, close_callable: Callable)

func _ready():
	slots.resize(max(size, slots.size()))
	for i in slots.size():
		if not slots[i]:
			slots[i] = Slot.new()
	inventory_loaded.emit()
			
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

func open_external(inventory: Inventory, close_callable: Callable):
	external_inventory_loaded.emit(inventory, close_callable)


# TODO: write similarly to insert
func remove(item: Item, amount: int = 1) -> int:
	if amount <= 0 or not item:
		return 0
	return _remove_from_existing_slots(item, amount)

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
