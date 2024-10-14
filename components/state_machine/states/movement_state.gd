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

func _push_rigid_bodies(push_force: float):
	for i in _cb.get_slide_collision_count():
		var collision = _cb.get_slide_collision(i)
		var collider := collision.get_collider() as RigidBody3D
		if not collider:
			return
		var push_dir = -collision.get_normal()
		
		var velocity_diff = _cb.velocity.dot(push_dir) - collider.linear_velocity.dot(push_dir)
		velocity_diff = max(0.0, velocity_diff)
		
		var mass_ratio = min(1.0, 80.0 / collider.mass)
		if mass_ratio < 0.25:
			continue
		push_dir.y = 0
		var position_diff = collision.get_position() - collider.global_position
		collider.apply_impulse(push_dir * velocity_diff * mass_ratio * push_force, position_diff)

# seems difficult because the initial snap length must always be restored after leaving the state
func _adjust_snap_length():
	pass
