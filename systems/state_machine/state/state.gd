extends Component
class_name State

@export var disabled: bool = false

@onready var _cb: CharacterBody3D = get_parent_entity().physics_body

enum Status {INACTIVE, ACTIVE, FORCED, ACTIVE_FORCED}

signal input_changed(action: String, value: int)

var input: Dictionary

func enter() -> void:
	pass

func exit() -> void:
	pass

func update_status(delta: float) -> Status:
	return Status.INACTIVE

func handle(delta: float) -> void:
	pass
