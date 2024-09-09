extends Control
class_name Slot

var icon_dir = "res://items/icons/"

@onready var item_visual: TextureRect = $TextureRect
@onready var rarity_text: Label = $RarityText
@onready var amount_text: Label = $AmountText

# NOTE: Don't add right click to split stack, do it with a context menu

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

signal item_switched(slot, previous_owner)
signal item_changed

# Before ready
func _init():
	add_to_group(Inventory.SLOT)

func get_icon_path():
	if not item:
		return ""
	return icon_dir + item.scene_file_path.split('/')[-1] + '.png'

## Dragging

func _get_drag_data(_pos):
	if not item or not item.allow_unequip:
		return
	
	# Make drag preview
	var texture_rect = TextureRect.new()
	texture_rect.texture = texture
	texture_rect.expand = true
	
	var rect_size = Vector2(80.0, 80.0)
	texture_rect.size = rect_size
	
	var preview = Control.new()
	texture_rect.position -= rect_size / 2
	preview.add_child(texture_rect)
	
	set_drag_preview(preview)
	
	return self

func _can_drop_data(_pos, data):
	if item:
		return item.allow_unequip
	return true

func _drop_data(_pos, prev_owner):
	if item and not item.allow_unequip:
		return
	item_switched.emit(self, prev_owner)
