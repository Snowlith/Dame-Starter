extends Control

@onready var box_container = $BoxContainer
@onready var panel = $Panel


var hovered
var current_slot: Slot

# TODO: consume input properly
# NOTE ideas for buttons:
# take one
# take half
# drop (IDK)


func _input(event):
	var mouse_event = event as InputEventMouseButton
	if not mouse_event:
		return
	if mouse_event.is_pressed() and not hovered:
		close()

# Called when the node enters the scene tree for the first time.
func _ready():
	var buttons = box_container.get_children()
	for i in buttons.size():
		var b = buttons[i] as Button
		if not b:
			continue
		var action: Callable = close
		match i:
			0:
				action = split
			1:
				action = foo
		b.pressed.connect(action)
		b.mouse_exited.connect(func(): hovered = false)
		b.mouse_entered.connect(func(): hovered = true)
		
	for slot: Slot in get_tree().get_nodes_in_group(Inventory.SLOT):
		slot.hovered.connect(open)

func open(slot: Slot = null):
	set_process_input(true)
	position = get_viewport().get_mouse_position()
	visible = true
	if slot:
		current_slot = slot

func close():
	set_process_input(false)
	visible = false
	current_slot = null

func split():
	current_slot.drag_half()
	close()

func foo():
	print("hello")

func wow():
	close()
