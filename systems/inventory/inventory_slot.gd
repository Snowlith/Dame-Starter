extends Control

@onready var item_visual: TextureRect = $TextureRect
@onready var amount_text: Label = $Label

var current_inventory: Inventory
var current_item: Item

var texture

func _get_drag_data(_pos):
	if not current_item:
		return
	var texture_rect = TextureRect.new()
	texture_rect.texture = texture
	texture_rect.expand = true
	var rect_size = Vector2(80.0, 50.0)
	texture_rect.size = rect_size
	
	var preview = Control.new()
	texture_rect.position -= rect_size / 2
	preview.add_child(texture_rect)
	
	set_drag_preview(preview)
	
	return self

func _can_drop_data(_pos, data):
	return true

func _drop_data(_pos, prev_owner):
	current_inventory.switch_slots(self, prev_owner)

func update(item: Item):
	if current_item == item:
		return
	current_item = item
	
	if current_item:
		texture = load(current_item.get_icon_path())
		item_visual.texture = texture
		amount_text.visible = true
		amount_text.text = item.rarity
	else:
		texture = null
		item_visual.texture = texture
		amount_text.visible = false
		amount_text.text = ""
