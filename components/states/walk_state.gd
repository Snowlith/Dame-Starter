extends MovementState
class_name WalkState

@export var max_speed: float = 10
@export var acceleration: float = 12
@export var friction: float = 40

func _init():
	input = {"left": 0, "right": 0, "up": 0, "down": 0}

func is_active():
	# or velocity.y > 0
	return _cb.is_on_floor()

#func clip_velocity(normal: Vector3, overbounce: float, delta: float) -> void:
	#var correction_amount = _cb.velocity.normalized().dot(normal) * overbounce
	#_cb.velocity -= correction_amount * normal

func handle(delta: float):
	_apply_acceleration(max_speed, acceleration, delta)
	_apply_friction(friction, delta)
	_cb.move_and_slide()
	if _cb.velocity.y > 0:
		_cb.apply_floor_snap()
	#if _cb.is_on_wall():
		#clip_velocity(_cb.get_wall_normal(), 1, delta)
