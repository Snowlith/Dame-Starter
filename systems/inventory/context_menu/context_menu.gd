extends Control
class_name ContextMenu

@onready var box_container = $MarginContainer/BoxContainer
@onready var button = $MarginContainer/BoxContainer/Button

var actions: Dictionary

var _is_hovered: bool
var _previous_node: Node

func _ready():
	mouse_exited.connect(func(): _is_hovered = false)
	mouse_entered.connect(func(): _is_hovered = true)
	close()

func _input(event):
	if not _is_hovered and event is InputEventMouseButton and event.is_pressed():
		close()

func open(node):
	set_process_input(true)
	if _previous_node:
		for b in actions[_previous_node]:
			b.hide()
	global_position = get_viewport().get_mouse_position() - box_container.position
	for b in actions[node]:
		b.show()
	show()
	_previous_node = node
	
func close():
	set_process_input(false)
	hide()

func register_action(action: String, callable: Callable, node: Node):
	var b: Button = button.duplicate()
	b.text = action
	b.pressed.connect(callable)
	b.pressed.connect(close)
	b.hide()
	box_container.add_child(b)
	if actions.has(node):
		actions[node].append(b)
	else:
		actions[node] = [b]
