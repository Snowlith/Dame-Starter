extends MovementState
class_name CrouchState

@export var max_speed: float = 3
@export var acceleration: float = 10
@export var friction: float = 12

@export var cam_crouch: CameraCrouchManager

var camera_offset: Vector3

func enter():
	super()
	cam_crouch.enable()

func exit():
	super()
	cam_crouch.disable()
	_cb.apply_floor_snap()

func update_status(delta: float) -> Status:
	if not _cb.is_on_floor():
		return Status.INACTIVE
	if cam_crouch.is_hitting_head():
		return Status.ACTIVE_FORCED
	elif Input.is_action_pressed("crouch"):
		return Status.ACTIVE
	return Status.INACTIVE

func handle(delta: float):
	_apply_acceleration(max_speed, acceleration, delta)
	_apply_friction(friction, delta)
	_adjust_snap_length()
	_cb.move_and_slide()
	_snap_up_slope()
