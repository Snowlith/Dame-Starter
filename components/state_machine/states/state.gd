extends Component
class_name State

@export var disabled: bool = false

enum Status {INACTIVE, ACTIVE, FORCED, ACTIVE_FORCED}

var _cb: CharacterBody3D

func input_int(action: String) -> int:
	return int(Input.is_action_pressed(action))

func initialize(cb: CharacterBody3D) -> void:
	_cb = cb

func enter() -> void:
	pass

func exit() -> void:
	pass

func update_status(_delta: float) -> Status:
	return Status.INACTIVE

func handle(_delta: float) -> void:
	pass
