extends Area3D
class_name Inventory

@export var held_item: Hand

@onready var hand_slot: Slot = $NinePatchRect/HandSlot
@onready var nine_patch_rect: Control = $NinePatchRect
@onready var color_rect: Control = $ColorRect
@onready var context_menu: Control = $Control

var disabled_actions: Array[String] = ["jump", "crouch", "sprint", "left", "right", "up", "down", "inspect"]
var items: Array[Item]
var slots: Array[Slot]
var size: int

# TODO TODO TODO: remove items array, only use slots

# TODO: get rid of group constant variables, increases load times and clutters
# NOTE: potential memory leak since items are not being queue freed always? needs testing
# NOTE: account for item currently being consumed when designing shops and locked doors
# TODO: rework item renaming
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
			context_menu.close()

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
		slot.swapped.connect(_on_slot_swapped)
		slot.combined.connect(_on_slot_combined)
		slot.replaced.connect(_on_slot_replaced)
		
	hand_slot.item_changed.connect(_update_hand)
	color_rect.item_dropped.connect(drop)
	area_entered.connect(_on_area_entered)
	
	
	
	is_open = false

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
	var index = slots.find(slot)
	items[index] = null

func drop(slot: Slot):
	var item = slot.item
	item.stack_size = slot.amount
	remove_from(slot, slot.amount)
	var existing_items = get_tree().current_scene.get_children().filter(func(child):
		return child is Item and item.is_same(child))
	
	var spawn_location = global_position + Vector3.FORWARD.rotated(Vector3.UP, global_rotation.y) * 2
	
	for existing_item in existing_items:
		if spawn_location.distance_to(existing_item.global_transform.origin) < 1.0:
			# If nearby, combine the stacks
			existing_item.stack_size += item.stack_size
			
			# Cannot queue free since they can be the same but split
			item.queue_free()
			return
	
	# failed combine
	while get_tree().current_scene.has_node(str(item.name)):
		item.name = _generate_name("abcdefghijklmnopqrstuvwxyz", 10)
		print(item.name)
		
	get_tree().current_scene.add_child(item)
	item.user = null
	item.transform.origin = spawn_location

func has(item: Item):
	if not item:
		return false
	for new_item in items:
		if item.is_same(new_item):
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

func can_insert(item: Item, amount: int) -> bool:
	var total_capacity = 0
	if item.is_stackable:
		for i in items.size():
			if not items[i] or not item.is_same(items[i]):
				continue
			total_capacity += SLOT_CAPACITY - slots[i].amount
		total_capacity += count(null) * SLOT_CAPACITY
	else:
		total_capacity = count(null)
	return total_capacity >= amount

func _on_slot_swapped(target_slot: Slot, source_slot: Slot, desired_amount: int):
	if target_slot.is_empty():
		# Move the item completely
		target_slot.item = source_slot.item
		target_slot.amount = desired_amount
		source_slot.item = null
	else:
		# Swap items between the two slots
		var temp_item = target_slot.item
		var temp_amount = target_slot.amount
		target_slot.item = source_slot.item
		target_slot.amount = desired_amount
		source_slot.item = temp_item
		source_slot.amount = temp_amount
	
	items[slots.find(target_slot)] = target_slot.item
	items[slots.find(source_slot)] = source_slot.item

func _on_slot_combined(target_slot: Slot, source_slot: Slot, desired_amount: int):
	var total_amount = target_slot.amount + desired_amount
	if total_amount <= SLOT_CAPACITY:
		   # Merge completely
		target_slot.amount = total_amount
		source_slot.amount = 0
		
		items[slots.find(source_slot)] = null
	else:
			# Fill this slot and leave the rest in the source slot
		var remaining_amount = total_amount - SLOT_CAPACITY
		target_slot.amount = SLOT_CAPACITY
		source_slot.amount = remaining_amount

func _on_slot_replaced(target_slot: Slot, source_slot: Slot, desired_amount: int):
	# Move the item completely
	target_slot.item = source_slot.item
	target_slot.amount = desired_amount
	source_slot.amount -= desired_amount
		
func _update_hand():
	if not held_item:
		return
	held_item.item = hand_slot.item

func _generate_name(chars, length):
	var word: String = ""
	for i in range(length):
		word += chars[randi() % len(chars)]
	return word

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
		if not items[i] or not item.is_same(items[i]):
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
			# Queue free item?
	return remaining_amount

func _insert_into_empty_slots(item: Item, remaining_amount: int) -> int:
	for i in items.size():
		# Only consider empty slots
		if items[i]:
			continue
		items[i] = item.duplicate()
		var amount_to_add = min(remaining_amount, SLOT_CAPACITY)
		slots[i].item = items[i]
		slots[i].amount = amount_to_add
		remaining_amount -= amount_to_add
		if remaining_amount <= 0:
			return 0
	return remaining_amount

func _remove_from_existing_slots(item: Item, remaining_amount: int) -> int:
	for i in items.size():
		# Skip if null or items don't match
		if not items[i] or not item.is_same(items[i]):
			continue
		# Partly deplete slot
		if slots[i].amount > remaining_amount:
			slots[i].amount -= remaining_amount
			return 0
		else:
			# Completely deplete slot
			remaining_amount -= slots[i].amount
			slots[i].amount = 0
			items[i].queue_free()
			items[i] = null
	return remaining_amount
