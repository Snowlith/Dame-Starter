extends Control
class_name Slot

var hovering = false
var hover_timer = null

# NOTE: position in drag could do some interesting stuff
# TODO: write can_drop and drop in a way that visual indicator of blocked is there

@export var capacity: int = 16

var amount: int:
	set(value):
		if amount == value:
			return
		amount = value
		if amount <= 0:
			amount = 0
			item = null
		amount_changed.emit()
		
var item: Item:
	set(value):
		if item == value:
			return
		item = value
		item_changed.emit()
		
signal item_changed
signal amount_changed
signal hovered(slot)

func _ready():
	set_process_input(false)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
func get_icon_path():
	if not item:
		return ""
	return "res://items/icons/" + item.scene_file_path.split('/')[-1] + '.png'

func can_add(amount_to_add: int):
	return amount_to_add + amount <= capacity
	
## Mouse hover

func _on_mouse_entered():
	set_process_input(true)
	hover_timer = get_tree().create_timer(0.5)
	# HERE
	hover_timer.timeout.connect(func(): pass)

func _on_mouse_exited():
	set_process_input(false)
	if hover_timer:
		#hover_timer.timeout.disconnect(hovered_success)
		hover_timer = null
	
func is_empty():
	return item == null

func get_item_copy():
	if not item:
		return null
	return item.duplicate()

func _take_from_slot(source_slot: Slot, desired_amount: int):
	item = source_slot.get_item_copy()
	var min_amount = min(desired_amount, capacity)
	amount = min_amount
	source_slot.amount -= min_amount

func _swap_from_slot(source_slot: Slot):
	var temp_item = source_slot.item
	var temp_amount = source_slot.amount
	source_slot.item = item
	source_slot.amount = amount
	item = temp_item
	amount = temp_amount

func _combine_from_slot(source_slot: Slot, desired_amount: int):
	var total_amount = amount + desired_amount
	if total_amount <= capacity:
		   # Merge completely
		amount = total_amount
		source_slot.amount -= desired_amount
	else:
		var amount_to_add = capacity - amount
		amount = capacity
		source_slot.amount -= amount_to_add
	
## Dragging
