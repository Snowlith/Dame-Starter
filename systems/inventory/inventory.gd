extends Area3D
class_name Inventory

@export var held_item: HeldItem

@onready var hand_slot: Slot = $NinePatchRect/HandSlot
@onready var nine_patch_rect: Control = $NinePatchRect

var items: Array[Item]
var slots: Array[Slot] = []
var size: int

# TODO: add ability to add items through editor
# exposing items does not allow for stacks
# needs custom class

var is_open = true:
	set(value):
		if is_open == value:
			return
		is_open = value
		SceneManager.in_menu = is_open
		nine_patch_rect.visible = is_open

const SLOT = "inv_slot"
const SLOT_CAPACITY: int = 16

func _ready() -> void:
	for slot: Slot in get_tree().get_nodes_in_group(SLOT):
		if not slot:
			continue
		slots.append(slot)
	size = slots.size()
	items.resize(size)
	
	for i in size:
		var slot: Slot = slots[i]
		slot.item = items[i]
		slot.item_dropped.connect(swap_slots)
	hand_slot.item_changed.connect(update_hand)
	area_entered.connect(_on_area_entered)
	
	close()

func has(item: Item):
	return item and item in items

func count(item: Item) -> int:
	if not item:
		return items.count(null)

	var tally = 0
	for slot in slots:
		var slot_item = slot.item
		if slot_item and slot_item == item:
			tally += slot.amount
	return tally

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

func can_insert(item: Item, amount: int) -> bool:
	var total_capacity = 0
	if item.is_stackable:
		for i in items.size():
			if not items[i] or items[i] != item:
				continue
			total_capacity += SLOT_CAPACITY - slots[i].amount
		total_capacity += count(null) * SLOT_CAPACITY
	else:
		total_capacity = count(null)
	return total_capacity >= amount
	
func _on_area_entered(area: Area3D):
	var dropped_item := area as DroppedItem
	if not dropped_item:
		return
	
	# Check if there is enough space for all items
	if can_insert(dropped_item.item, dropped_item.amount):
		insert(dropped_item.item, dropped_item.amount)
		dropped_item.despawn()
	else:
		# Only take as many items as possible
		var items_taken = insert(dropped_item.item, dropped_item.amount)
		dropped_item.amount -= items_taken
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		is_open = not is_open

func update_hand():
	if not held_item:
		return
	held_item.item = hand_slot.item

func open():
	is_open = true

func close():
	is_open = false

func swap_slots(slot_1, slot_2):
	var index_1 = slots.find(slot_1)
	var index_2 = slots.find(slot_2)
	
	# Swap items and amounts
	var temp_item = slot_1.item
	var temp_amount = slot_1.amount
	
	slot_1.item = slot_2.item
	slot_1.amount = slot_2.amount
	
	slot_2.item = temp_item
	slot_2.amount = temp_amount
	
	items[index_1] = slot_1.item
	items[index_2] = slot_2.item
	
## Stacking helper methods

func _insert_into_existing_slots(item: Item, remaining_amount: int) -> int:
	for i in items.size():
		# Skip when null or items don't match
		if not items[i] or items[i] != item:
			continue
		# Skip full slots
		if slots[i].amount >= SLOT_CAPACITY:
			continue
		var available_space = SLOT_CAPACITY - slots[i].amount
		var amount_to_add = min(remaining_amount, available_space)
		slots[i].amount += amount_to_add
		remaining_amount -= amount_to_add
		if remaining_amount <= 0:
			return 0
	return remaining_amount

func _insert_into_empty_slots(item: Item, remaining_amount: int) -> int:
	for i in items.size():
		# Only consider empty slots
		if items[i]:
			continue
		items[i] = item
		var amount_to_add = min(remaining_amount, SLOT_CAPACITY)
		slots[i].item = item
		slots[i].amount = amount_to_add
		remaining_amount -= amount_to_add
		if remaining_amount <= 0:
			return 0
	return remaining_amount

func _remove_from_existing_slots(item: Item, remaining_amount: int) -> int:
	for i in items.size():
		# Skip if null or items don't match
		if not items[i] or items[i] != item:
			continue
		var slot = slots[i]
		# Partly deplete slot
		if slot.amount > remaining_amount:
			slot.amount -= remaining_amount
			return 0
		else:
			# Completely deplete slot
			remaining_amount -= slot.amount
			slot.amount = 0
			items[i] = null
	return remaining_amount
