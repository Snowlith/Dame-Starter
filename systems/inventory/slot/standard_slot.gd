extends Slot
class_name StandardSlot

@onready var item_visual: TextureRect = $TextureRect
@onready var amount_text: Label = $AmountText

# NOTE: position in drag could do some interesting stuff

# TODO: move logic from determining which method to use to slot.gd
# TODO: write can_drop and drop in a way that visual indicator of blocked is there

var texture

func _ready():
	super()
	amount_changed.connect(_on_amount_changed)
	item_changed.connect(_on_item_changed)

func _on_amount_changed():
	amount_text.text = str(amount)

func _on_item_changed():
	if item:
		# stagger this
		texture = load(get_icon_path())
		amount_text.text = str(amount)
		amount_text.visible = item.is_stackable
	else:
		texture = null
		amount_text.visible = false
			
	item_visual.texture = texture
	
## Mouse hover

func _input(event):
	if not item:
		return
	var mouse_event = event as InputEventMouseButton
	if not mouse_event:
		return
	if mouse_event.is_pressed() and mouse_event.button_index == MOUSE_BUTTON_RIGHT:
		clicked.emit(self)

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
	# TEMP
	data['operation'] = str(desired_amount) + "fard"
	
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
		if desired_amount > capacity or amount > source_slot.capacity:
			return
		_swap_from_slot(source_slot)
