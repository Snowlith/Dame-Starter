extends Area3D
class_name Inventory

@export var held_item: Hand

@onready var hand_slot: Slot = $NinePatchRect/HandSlot
@onready var nine_patch_rect: Control = $NinePatchRect
@onready var color_rect: Control = $ColorRect
@onready var context_menu: Control = $Control

var disabled_actions: Array[String] = ["jump", "crouch", "sprint", "left", "right", "up", "down", "inspect"]
var slots: Array[Slot]
var size: int

# TODO: add collect notification
# TODO: move stack size to slot as int var
# TODO: get rid of group constant variables, increases load times and clutters
# NOTE: potential memory leak since items are not being queue freed always? needs testing
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
	
	for i in size:
		var slot: Slot = slots[i]
		
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

func collect(item: Item):
	if can_insert(item, item.stack_size):
		await item.collect()
		item.get_parent().remove_child(item)
		insert(item, item.stack_size)
		item.queue_free()
	else:
		# make partly taken animation
		# Only take as many items as possible
		var items_taken = insert(item, item.stack_size)
		item.stack_size -= items_taken

func drop(slot: Slot, desired_amount: int):
	var item = slot.item.duplicate()
	remove_from(slot, desired_amount)
	item.user = null
	item.stack_size = desired_amount
	var existing_items = get_tree().current_scene.get_children().filter(func(child):
		# make partly added animation
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
	item.transform.origin = spawn_location
	item.drop()

func has(item: Item):
	if not item:
		return false
	for slot in slots:
		if slot.item and slot.item.is_same(item):
			return true
	return false

func count(item: Item) -> int:
	var tally = 0
	for slot in slots:
		if slot.item == item:
			if item:
				tally += slot.amount
			else:
				tally += 1
	return tally

func can_insert(item: Item, amount: int) -> bool:
	var total_capacity = 0
	if item.is_stackable:
		for slot in slots:
			if not slot.item or not item.is_same(slot.item):
				continue
			total_capacity += SLOT_CAPACITY - slot.amount
		total_capacity += count(null) * SLOT_CAPACITY
	else:
		total_capacity = count(null)
	return total_capacity >= amount
		
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
	collect(item)

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
	for slot in slots:
		# Skip when null or items don't match
		if not slot.item or not item.is_same(slot.item):
			continue
		# Skip full slots
		if slot.amount >= SLOT_CAPACITY:
			continue
		var available_space = SLOT_CAPACITY - slot.amount
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
		var amount_to_add = min(remaining_amount, SLOT_CAPACITY)
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
