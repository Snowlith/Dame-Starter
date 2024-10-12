extends Component
class_name State

@export var disabled: bool = false

enum Status {INACTIVE, ACTIVE, FORCED, ACTIVE_FORCED}

signal input_changed(action: String, value: int)

var input: Dictionary

var _cb: CharacterBody3D

func initialize(cb: CharacterBody3D) -> void:
	_cb = cb

func enter() -> void:
	pass

func exit() -> void:
	pass

func update_status(_delta: float) -> Status:
	return Status.INACTIVE

func handle(delta: float) -> void:
	pass
