extends Control
class_name Slot

const SLOT_CAPACITY: int = 16

var icon_dir = "res://items/icons/"

@onready var item_visual: TextureRect = $TextureRect
@onready var rarity_text: Label = $RarityText
@onready var amount_text: Label = $AmountText

var hovering = false
var hover_timer = null

# TODO: write signal methods here instead of in inventory.gd
# TODO: move capacity here, maybe allow varying capacity

var item: Item:
	set(value):
		if item == value:
			return
		
		item = value
		
		if item:
			texture = load(get_icon_path())
			amount_text.text = str(amount)
			amount_text.visible = item.is_stackable
		else:
			texture = null
			amount_text.visible = false
			
		item_visual.texture = texture
		item_changed.emit()

var amount: int:
	set(value):
		if amount == value:
			return
		amount = value
		if amount <= 0:
			item = null
		amount_text.text = str(amount)
		
		
		
var texture

signal item_changed
signal hovered(slot)

# Before ready
func _init():
	add_to_group(Inventory.SLOT)

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	set_process_input(false)
	
func get_icon_path():
	if not item:
		return ""
	return icon_dir + item.scene_file_path.split('/')[-1] + '.png'
	
## Mouse hover

func _input(event):
	if not item:
		return
	var mouse_event = event as InputEventMouseButton
	if not mouse_event:
		return
	if mouse_event.is_pressed() and mouse_event.button_index == MOUSE_BUTTON_RIGHT:
		hovered.emit(self)

func _on_mouse_entered():
	set_process_input(true)
	hover_timer = get_tree().create_timer(0.5)
	hover_timer.timeout.connect(hovered_success)

func _on_mouse_exited():
	set_process_input(false)
	if hover_timer:
		hover_timer.timeout.disconnect(hovered_success)
		hover_timer = null

# TEST THIS
func hovered_success():
	hover_timer = null
	print("hovered")
	#hovered.emit(self)
	
func is_empty():
	return item == null

func _take_from_slot(source_slot: Slot, desired_amount: int):
	item = source_slot.item
	var min_amount = min(desired_amount, source_slot.amount)
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
	if total_amount <= SLOT_CAPACITY:
		   # Merge completely
		amount = total_amount
		source_slot.amount -= desired_amount
	else:
		var amount_to_add = SLOT_CAPACITY - amount
		amount = SLOT_CAPACITY
		source_slot.amount -= amount_to_add
	
## Dragging

func _create_preview():
	var texture_rect = TextureRect.new()
	texture_rect.texture = texture
	texture_rect.expand = true
	
	var rect_size = Vector2(80.0, 80.0)
	texture_rect.size = rect_size
	
	var preview = Control.new()
	texture_rect.position -= rect_size / 2
	preview.add_child(texture_rect)
	return preview

func drag_one():
	if not item or not item.allow_unequip:
		return
	# This will simulate the drag of the new split stack
	var preview = _create_preview()
	
	var desired_amount = 1
	var drag_data = {
		"slot": self,
		"amount": desired_amount
	}
	
	# Trigger drag event manually with the new split slot as data
	force_drag(drag_data, preview)

func drag_half():
	if not item or not item.allow_unequip:
		return
	# This will simulate the drag of the new split stack
	var preview = _create_preview()
	
	var desired_amount = ceil(float(amount) / 2)
	var drag_data = {
		"slot": self,
		"amount": desired_amount
	}
	
	# Trigger drag event manually with the new split slot as data
	force_drag(drag_data, preview)

func _get_drag_data(_pos):
	if not item or not item.allow_unequip:
		return
		
	var drag_data = {
		"slot": self,
		"amount": amount
	}
	
	var preview = _create_preview()
	set_drag_preview(preview)
	
	return drag_data
	
func _can_drop_data(_pos, data):
	var source_slot = data["slot"] as Slot
	var desired_amount = data['amount'] as int
	
	if not source_slot or not desired_amount:
		return false
		
	if is_empty() or (item.is_same(source_slot.item) and item.is_stackable):
		# attempting to drop partial
		return true
	return item.allow_unequip
	
func _drop_data(_pos, data):
	var source_slot = data["slot"] as Slot
	var desired_amount = data['amount'] as int
	if is_empty():
		_take_from_slot(source_slot, desired_amount)
	elif item.is_same(source_slot.item) and item.is_stackable:
		_combine_from_slot(source_slot, desired_amount)
	else:
		_swap_from_slot(source_slot)
