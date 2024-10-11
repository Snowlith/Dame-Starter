extends MovementState
class_name AirState

@export var gravity: float = 25
@export var max_speed: float = 2
@export var acceleration: float = 40

func _init():
	input = {"left": 0, "right": 0, "up": 0, "down": 0}

func update_status(delta: float):
	if not _cb.is_on_floor():
		return Status.ACTIVE
	return Status.INACTIVE
	
func handle(delta: float):
	_apply_acceleration(max_speed, acceleration, delta)
	_cb.velocity.y -= gravity * delta
	_cb.move_and_slide()
