extends Component
class_name State

@export var disabled: bool = false

enum Status {INACTIVE, ACTIVE, FORCED, ACTIVE_FORCED}

@onready var _cb: CharacterBody3D = get_parent_entity().get_physics_body()

func input_int(action: String) -> int:
	return int(Input.is_action_pressed(action))
	
func enter() -> void:
	pass

func exit() -> void:
	pass

func update_status(_delta: float) -> Status:
	return Status.INACTIVE

func handle(_delta: float) -> void:
	pass
