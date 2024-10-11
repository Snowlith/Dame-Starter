extends MovementState
class_name CrouchState

@export var max_speed: float = 3
@export var acceleration: float = 10
@export var friction: float = 12

@export var head_duck: HeadDuckManager

var camera_offset: Vector3

func _init():
	input = {"left": 0, "right": 0, "up": 0, "down": 0, "crouch": 0}

func enter():
	head_duck.enable()

func exit():
	head_duck.disable()
	_cb.apply_floor_snap()

func update_status(delta: float) -> Status:
	if not _cb.is_on_floor():
		return Status.INACTIVE
	if head_duck.is_hitting_head():
		return Status.ACTIVE_FORCED
	elif input["crouch"]:
		return Status.ACTIVE
	return Status.INACTIVE

func handle(delta: float):
	_apply_acceleration(max_speed, acceleration, delta)
	_apply_friction(friction, delta)
	_cb.move_and_slide()
	if _cb.velocity.y > 0:
		_cb.apply_floor_snap()
