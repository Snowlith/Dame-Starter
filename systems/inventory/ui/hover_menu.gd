extends Control

@onready var label = $Label

var current_slot: Slot

func _input(event):
	if event is InputEventMouseMotion:
		close()

# Called when the node enters the scene tree for the first time.
func _ready():
	for slot: Slot in get_tree().get_nodes_in_group("inventory slot"):
		slot.hovered.connect(open)

func open(slot: Slot):
	set_process_input(true)
	position = get_viewport().get_mouse_position()
	label.text = slot.item.view_name
	visible = true
	current_slot = slot

func close():
	set_process_input(false)
	visible = false
	current_slot = null
