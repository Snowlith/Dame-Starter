extends State
class_name MovementState

func _get_input_vector():
	return Vector3(input["right"] - input["left"], 0, input["down"] - input["up"])

func _apply_acceleration(max_speed: float, acceleration: float, delta: float) -> void:
	var input_vector = _cb.global_basis * _get_input_vector().normalized()
	
	var speed_remaining = max_speed * input_vector.length() - _cb.velocity.dot(input_vector)
	
	if speed_remaining <= 0:
		return

	var final_acceleration = clampf(acceleration * delta * max_speed, 0, speed_remaining)
	_cb.velocity += final_acceleration * input_vector

# Should this really affect y axis??
func _apply_friction(friction: float, delta: float) -> void:
	var current_speed = _cb.velocity.length()
	
	if current_speed < 0.1:
		_cb.velocity = Vector3.ZERO
		return
	
	var speed_scalar = max(current_speed - friction * delta, 0) / current_speed
	_cb.velocity *= speed_scalar

# seems difficult because the initial snap length must always be restored after leaving the state
func _adjust_snap_length():
	pass
