extends MovementState
class_name AirState

@export var gravity: float = -30

#@export var speed: float = 12
#@export var acceleration: float = 2

@export var max_speed: float = 2
@export var acceleration: float = 40

# TODO: don't allow building up speed in the air
# rather, make the jump add some horizontal speed
# allow changing direction in the air but not adding speed

# When turning mouse and moving in that direction, turn vel instead of lerping

func _init():
	input = {"left": 0, "right": 0, "up": 0, "down": 0}

func is_active():
	return not _cb.is_on_floor()

func clip_velocity(normal: Vector3, overbounce: float, delta: float) -> void:
	var correction_amount = _cb.velocity.normalized().dot(normal) * overbounce
	_cb.velocity -= correction_amount * normal

func handle(delta: float):
	_apply_acceleration(max_speed, acceleration, delta, true)
	_cb.velocity.y += gravity * delta
	var collided := _cb.move_and_slide()
	if collided:
		var slide_direction := _cb.get_last_slide_collision().get_normal()
		_cb.velocity = _cb.velocity.slide(slide_direction)
	#if _cb.is_on_floor():
		#clip_velocity(_cb.get_floor_normal(), 1, delta)
	#if _cb.is_on_wall():
		#clip_velocity(_cb.get_wall_normal(), 1, delta)
