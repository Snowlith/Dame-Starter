extends Area3D
class_name Inventory

@export var held_item: Hand

@onready var hand_slot: Slot = $NinePatchRect/HandSlot
@onready var nine_patch_rect: Control = $NinePatchRect
@onready var color_rect: Control = $ColorRect

var disabled_actions: Array[String] = ["jump", "crouch", "sprint", "left", "right", "up", "down", "inspect"]
var items: Array[Item]
var slots: Array[Slot]
var size: int

# TODO: add method that priority removes from hand slot for depleting consumables
# TODO: add ability to add items through editor
# exposing items does not allow for stacks
# needs custom class

var is_open = true:
	set(value):
		if is_open == value:
			return
			
		is_open = value
		color_rect.visible = is_open
		nine_patch_rect.visible = is_open
		
		if is_open:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
		#slot.item = items[i]
		slot.item_dropped.connect(swap_slots)
	hand_slot.item_changed.connect(update_hand)
	area_entered.connect(_on_area_entered)
	
	close()

func has(item: Item):
	if not item:
		return false
	for new_item in items:
		if are_same(new_item, item):
			return true
	return false

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
			if not items[i] or not are_same(item, items[i]):
				continue
			total_capacity += SLOT_CAPACITY - slots[i].amount
		total_capacity += count(null) * SLOT_CAPACITY
	else:
		total_capacity = count(null)
	return total_capacity >= amount
	
func _on_area_entered(area: Area3D):
	var item := area.get_parent_node_3d() as Item
	if not item:
		return
	# Check if there is enough space for all items
	if can_insert(item, item.stack_size):
		item.get_parent().remove_child(item)
		insert(item, item.stack_size)
	else:
		# Only take as many items as possible
		var items_taken = insert(item, item.stack_size)
		item.stack_size -= items_taken
		
func are_same(item_1: Item, item_2: Item):
	if not item_1 or not item_2:
		return false
	return item_1.scene_file_path == item_2.scene_file_path

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
	
	var temp_item = slot_1.item
	var temp_amount = slot_1.amount
	
	slot_1.item = slot_2.item
	slot_1.amount = slot_2.amount
	
	slot_2.item = temp_item
	slot_2.amount = temp_amount
	
	items[index_1] = slot_1.item
	items[index_2] = slot_2.item

func _input(event: InputEvent):
	if event.is_action_pressed("inventory") and not event.is_echo():
		is_open = not is_open
	if is_open:
		for action in disabled_actions:
			if event.is_action_pressed(action):
				get_viewport().set_input_as_handled()
				return
	
## Stacking helper methods

func _insert_into_existing_slots(item: Item, remaining_amount: int) -> int:
	for i in items.size():
		# Skip when null or items don't match
		if not items[i] or not are_same(item, items[i]):
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
		if not items[i] or not are_same(item, items[i]):
			continue
		# Partly deplete slot
		if slots[i].amount > remaining_amount:
			slots[i].amount -= remaining_amount
			return 0
		else:
			# Completely deplete slot
			remaining_amount -= slots[i].amount
			slots[i].amount = 0
			# redundant
			items[i] = null
	return remaining_amount
