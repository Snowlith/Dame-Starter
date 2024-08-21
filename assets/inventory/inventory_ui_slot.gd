extends Panel

@onready var item_visual: Sprite2D = $CenterContainer/Panel/item_display

func update(item: Item):
	if !item:
		item_visual.visible = false
	else:
		item_visual.visible = true
		item_visual.texture = item.texture
