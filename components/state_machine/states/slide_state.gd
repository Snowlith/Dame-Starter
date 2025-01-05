extends MovementState
class_name SlideState

@export var max_speed: float = 4
@export var acceleration: float = 5
@export var friction: float = 3

@export var velocity_cutoff: float = 5

@export var slope_downward_acceleration: float = 60
@export var slope_minimum_angle: float = 15

@export var cam_bob: CameraBobManager
@export var cam_crouch: CameraCrouchManager

var camera_offset: Vector3

var _current_velocity: Vector3
var _previous_velocity: Vector3

var _current_grounded: bool
var _previous_grounded: bool

func enter():
	super()
	if not _previous_grounded:
		_enter_slope(_previous_velocity)
	cam_bob.disable()
	cam_crouch.enable()

func exit():
	super()
	cam_bob.enable()
	cam_crouch.disable()

func _enter_slope(velocity):
	if velocity.y > 0:
		return
	if not _cb.get_floor_angle() > deg_to_rad(slope_minimum_angle):
		#print("too shallow")
		return

	var projected_velocity = velocity.slide(_cb.get_floor_normal())
	
	# Redirect the player's velocity along the slope
	_cb.velocity.x = _cb.velocity.x if abs(_cb.velocity.x) > abs(projected_velocity.x) else projected_velocity.x
	_cb.velocity.z = _cb.velocity.z if abs(_cb.velocity.z) > abs(projected_velocity.z) else projected_velocity.z
	# Ensure the player retains any downward momentum, but don't allow upward velocity
	_cb.velocity.y = min(_cb.velocity.y, projected_velocity.y)

func update_status(delta: float) -> Status:
	_previous_velocity = _current_velocity
	_current_velocity = _cb.velocity
	_previous_grounded = _current_grounded
	_current_grounded = _cb.is_on_floor()
	
	if not _cb.is_on_floor():
		return Status.INACTIVE
	
	var is_slope_steep = _cb.get_floor_angle() >= deg_to_rad(slope_minimum_angle)
	var is_velocity_sufficient = _cb.velocity.length_squared() >= pow(velocity_cutoff, 2)
	
	# TODO: only check for hitting head when crouching
	
	if Input.is_action_pressed("crouch") and (is_slope_steep or is_velocity_sufficient):
		if cam_crouch.is_hitting_head():
			return Status.ACTIVE_FORCED
		else:
			return Status.ACTIVE
	else:
		if cam_crouch.is_hitting_head():
			return Status.FORCED
		else:
			return Status.INACTIVE
	
	

func _check_snap_ray(target: Vector3) -> bool:
	var exclude = _cb.get_rid()
	var space_state = _cb.get_world_3d().get_direct_space_state()
	
	var from = _cb.global_position
	var to = from + target
	
	#DebugDraw3D.draw_line(from, to, Color(0, 0, 1))
	var ray_params = PhysicsRayQueryParameters3D.create(from, to)
	var rid_array: Array[RID]
	rid_array.append(exclude)
	ray_params.exclude = rid_array
	
	var ray = space_state.intersect_ray(ray_params)
	var result = ray.has("collider")
	#if ray.has("normal"):
		#print(ray["normal"])
	return result

func handle(delta: float):
	var floor_normal = _cb.get_floor_normal()
	var floor_angle = _cb.get_floor_angle()
	var slope_vector = (Vector3.DOWN - floor_normal * Vector3.DOWN.dot(floor_normal)).normalized()
	
	if floor_angle:
		if _cb.velocity.dot(slope_vector) <= 0:
			_cb.velocity.y = _cb.get_real_velocity().y
		var steepness_scalar = floor_angle / (PI / 2)
		_cb.velocity += slope_vector * slope_downward_acceleration * steepness_scalar * delta
		
	_apply_acceleration(max_speed, acceleration, delta)
	_apply_friction(friction, delta)
	_adjust_snap_length()
	cam_bob.disable()
		
	_cb.move_and_slide()
	
	# TODO: move this to own function
	if _cb.get_real_velocity().y > 0 and floor_angle and _check_snap_ray(Vector3(-slope_vector.x, 0, -slope_vector.z)):
		_cb.apply_floor_snap()
