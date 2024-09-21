extends Component
class_name Inventory

@export var open_sound: AudioStream
@export var close_sound: AudioStream

@onready var collect_area: Area3D = $Area3D
@onready var nine_patch_rect: Control = $NinePatchRect
@onready var hand_slot: Slot = $NinePatchRect/HandSlot
@onready var drop_slot: Slot = $ColorRect
@onready var context_menu: Control = $ContextMenu

var disabled_actions: Array[String] = ["jump", "crouch", "sprint", "left", "right", "up", "down", "inspect"]
var slots: Array[Slot]
var size: int

# TODO: instead of can_insert, return amount that can be inserted, or just see how many were inserted
# TODO: add collect notification
# TODO: adding items through editor -> make slots export item

var is_open = true:
	set(value):
		if is_open == value:
			return
		
		is_open = value
		nine_patch_rect.visible = is_open
		drop_slot.visible = is_open
		
		if is_open:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Audio.play_sound(open_sound)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			Audio.play_sound(close_sound)
			context_menu.close()

func _ready() -> void:
	for slot: Slot in get_tree().get_nodes_in_group("inventory slot"):
		if not slot:
			continue
		slots.append(slot)
	size = slots.size()
	
	collect_area.area_entered.connect(_on_area_entered)
	
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
