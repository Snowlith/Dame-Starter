extends MovementState
class_name AirState

@export var gravity: float = -30
#@export var speed: float = 12
#@export var acceleration: float = 2

@export var max_speed: float = 2
@export var acceleration: float = 40
@export var surf_acceleration: float = 80
@export var surf_max_angle: float = 60

# TODO: don't allow building up speed in the air
# rather, make the jump add some horizontal speed
# allow changing direction in the air but not adding speed

# When turning mouse and moving in that direction, turn vel instead of lerping

func _apply_acceleration(max_speed: float, acceleration: float, delta: float, use_wall_normal: bool = false):
	var input_vector = _cb.global_transform.basis * _get_input_vector().normalized()
	
	var speed_remaining = max_speed * input_vector.length() - _cb.velocity.dot(input_vector)
	
	if speed_remaining <= 0:
		return

	var wall_normal = _cb.get_wall_normal()
	var angle = 90 - rad_to_deg(atan2(wall_normal.y, sqrt(wall_normal.x * wall_normal.x + wall_normal.z * wall_normal.z)))
	print(angle)
	if use_wall_normal and wall_normal and angle < surf_max_angle:
		var final_acceleration = clampf(surf_acceleration * delta * max_speed, 0, speed_remaining)
		var projected_input = (input_vector - wall_normal * input_vector.dot(wall_normal)).normalized()
		_cb.velocity += final_acceleration * 2 * projected_input
	else:
		var final_acceleration = clampf(acceleration * delta * max_speed, 0, speed_remaining)
		_cb.velocity += final_acceleration * input_vector

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
