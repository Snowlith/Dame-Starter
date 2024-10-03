extends State
class_name MovementState

func _get_input_vector():
	return Vector3(input["right"] - input["left"], 0, input["down"] - input["up"])

func _apply_acceleration(max_speed: float, acceleration: float, delta: float, use_floor_normal: bool = false):
	var input_vector = _cb.global_transform.basis * _get_input_vector().normalized()
	
	var speed_remaining = max_speed * input_vector.length() - _cb.velocity.dot(input_vector)
	
	if speed_remaining <= 0:
		return

	var final_acceleration = clampf(acceleration * delta * max_speed, 0, speed_remaining)
	
	var floor_normal = _cb.get_floor_normal()
	if use_floor_normal and floor_normal:
		var projected_input = (input_vector - floor_normal * input_vector.dot(floor_normal)).normalized()
		_cb.velocity += final_acceleration * projected_input
	else:
		_cb.velocity += final_acceleration * input_vector

func _apply_friction(friction: float, delta: float):
	var current_speed = _cb.velocity.length()
	
	if current_speed < 0.1:
		_cb.velocity.x = 0
		_cb.velocity.y = 0
		return
	
	var speed_scalar = max(current_speed - friction * delta, 0) / current_speed
	
	_cb.velocity *= speed_scalar
