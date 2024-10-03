extends Component
class_name State

@export var priority: int
var _cb: CharacterBody3D

signal input_changed(action: String, value: int)

var input: Dictionary

func _ready():
	var cbs = get_parent_entity().find_children("", "CharacterBody3D")
	assert(not cbs.is_empty())
	_cb = cbs[0]

func is_active():
	return true

func enter():
	pass

func exit() -> bool:
	return true

func handle(delta: float):
	pass
