extends MovementState
class_name WalkState

@export var max_speed: float = 10
@export var acceleration: float = 12
@export var friction: float = 40

@export var rigid_body_push_force: float = 2

func _init():
	input = {"left": 0, "right": 0, "up": 0, "down": 0}
	
func update_status(_delta: float) -> Status:
	if _cb.is_on_floor():
		return Status.ACTIVE
	return Status.INACTIVE

# BUG: walk state does not have snap length adjustment

func handle(delta: float):
	_apply_acceleration(max_speed, acceleration, delta)
	_apply_friction(friction, delta)
	_push_rigid_bodies(rigid_body_push_force)
	_cb.move_and_slide()
	#if _cb.velocity.y > 0:
		#_cb.apply_floor_snap()
