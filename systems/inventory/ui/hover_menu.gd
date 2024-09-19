extends Control

@onready var item_name = $MarginContainer/VBoxContainer/ItemName
@onready var item_description = $MarginContainer/VBoxContainer/ItemDescription


var current_slot: Slot

func _input(event):
	if event is InputEventMouseMotion:
		_update_pos()
	elif event is InputEventMouseButton and event.is_pressed():
		close()

# Called when the node enters the scene tree for the first time.
func _ready():
	for slot: Slot in get_tree().get_nodes_in_group("inventory slot"):
		if not slot is StandardSlot:
			continue
		slot.hovered.connect(open)
		slot.unhovered.connect(close)
	close()

func open(slot: Slot):
	set_process_input(true)
	_update_pos()
	item_name.text = slot.item.view_name
	item_description.text = slot.item.view_description
	visible = true
	current_slot = slot

func close(slot: Slot = null):
	if visible == false:
		return
	if slot != null and slot != current_slot:
		return
	set_process_input(false)
	visible = false
	current_slot = null

func _update_pos():
	global_position = get_viewport().get_mouse_position() + Vector2(5, 5)
