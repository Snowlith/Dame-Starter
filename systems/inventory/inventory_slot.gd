extends Control
class_name Slot

@onready var item_visual: TextureRect = $TextureRect
@onready var rarity_text: Label = $RarityText
@onready var amount_text: Label = $AmountText

var current_item: Item
var texture

signal item_dropped(slot, previous_owner)
signal item_changed

# TODO: Remove the ability to move nulls around

func _ready():
	add_to_group(Inventory.SLOT)

func _get_drag_data(_pos):
	if not current_item:
		return
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
	return true

func _drop_data(_pos, prev_owner):
	item_dropped.emit(self, prev_owner)

func update(item: Item):
	if current_item == item:
		return
	current_item = item
	item_changed.emit()
	
	if current_item:
		texture = load(current_item.get_icon_path())
		item_visual.texture = texture
		rarity_text.visible = true
		rarity_text.text = item.rarity
	else:
		texture = null
		item_visual.texture = texture
		rarity_text.visible = false
		rarity_text.text = ""
