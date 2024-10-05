extends MovementState
class_name CrouchState

@export var max_crouch_speed: float = 3
@export var crouch_acceleration: float = 10
@export var crouch_friction: float = 12

@export var max_slide_speed: float = 3
@export var slide_acceleration: float = 10
@export var slide_friction: float = 3
@export var slide_velocity_cutoff: float = 5
@export var slide_minimum_angle: float = 15

@export var stand_collider: CollisionShape3D
@export var crouch_collider: CollisionShape3D
@export var shape_cast: ShapeCast3D
@export var head_bob: HeadBob

@export var y_offset: float = 0.5
@export var y_offset_change_speed: float = 10

var active: bool = false

var camera_offset: Vector3

var _initial_snap_length: float

@onready var label = $Label

# Sliding off small ramps is easier with high speed?
# TODO: when leaving air state, if colliding with slope, add that vel to movement

# TODO: redirect y vel when entering slope

func _init():
	input = {"left": 0, "right": 0, "up": 0, "down": 0, "crouch": 0}

func _ready():
	super()
	
	shape_cast.add_exception(_cb)
	_toggle_colliders()

func _toggle_colliders() -> void:
	stand_collider.disabled = active
	crouch_collider.disabled = not active

func enter():
	_initial_snap_length = _cb.floor_snap_length
	active = true
	_toggle_colliders()

func exit():
	if shape_cast and shape_cast.is_colliding():
		return false
	active = false
	_toggle_colliders()
	head_bob.enable()
	_cb.floor_snap_length = _initial_snap_length
	_cb.apply_floor_snap()
	return true

func is_active():
	return input["crouch"]

func _check_snap_ray(target: Vector3) -> bool:
	var exclude = _cb.get_rid()
	var space_state = _cb.get_world_3d().get_direct_space_state()
	
	var from = _cb.global_position
	var to = from + target
	
	DebugDraw3D.draw_line(from, to, Color(0, 0, 1))
	var ray_params = PhysicsRayQueryParameters3D.create(from, to)
	var rid_array: Array[RID]
	rid_array.append(exclude)
	ray_params.exclude = rid_array
	
	var ray = space_state.intersect_ray(ray_params)
	var result = ray.has("collider")
	label.text = str(result)
	return result

func handle(delta: float):
	var floor_normal = _cb.get_floor_normal()
	var floor_angle = _cb.get_floor_angle()
	var down_slope_vector = (Vector3.DOWN - floor_normal * Vector3.DOWN.dot(floor_normal)).normalized()
	
	if floor_angle and floor_angle > deg_to_rad(slide_minimum_angle):
		if _cb.velocity.dot(down_slope_vector) > 0:
			_cb.floor_snap_length = max(_cb.velocity.length() / 20, _initial_snap_length)
		else:
			_cb.velocity.y = _cb.get_real_velocity().y
			_cb.floor_snap_length = _initial_snap_length
		_cb.velocity += down_slope_vector * delta * 20
		# Slide down slope
		head_bob.disable()
		#DebugDraw3D.draw_line(_cb.global_position, _cb.global_position + _cb.velocity, Color(1, 0, 0))
		#DebugDraw3D.draw_line(_cb.global_position, _cb.global_position + down_slope_vector, Color(0, 1, 0))
		_apply_acceleration(max_slide_speed, slide_acceleration, delta)
		_apply_friction(slide_friction, delta)
		
	elif _cb.velocity.length_squared() > pow(slide_velocity_cutoff, 2):
		# Slide
		_cb.floor_snap_length = _initial_snap_length
		#_cb.apply_floor_snap()
		head_bob.disable()
		_apply_friction(slide_friction, delta)
		
	else:
		# Move
		_cb.floor_snap_length = _initial_snap_length
		head_bob.enable()
		_apply_acceleration(max_crouch_speed, crouch_acceleration, delta)
		_apply_friction(crouch_friction, delta)
	
	_cb.move_and_slide()
	
	if _cb.get_real_velocity().y > 0 and floor_angle and _check_snap_ray(Vector3(-down_slope_vector.x, 0, -down_slope_vector.z)):
		_cb.apply_floor_snap()


func handle2(delta: float):
	var floor_normal = _cb.get_floor_normal()
	var floor_angle = _cb.get_floor_angle()
	var down_slope_vector = (Vector3.DOWN - floor_normal * Vector3.DOWN.dot(floor_normal)).normalized()
	
	if _cb.velocity.dot(down_slope_vector) > 0.25 and floor_angle > deg_to_rad(slide_minimum_angle):
		# Slide down slope
		head_bob.disable()
		_cb.velocity += down_slope_vector * delta * 10
		#DebugDraw3D.draw_line(_cb.global_position, _cb.global_position + _cb.velocity, Color(1, 0, 0))
		#DebugDraw3D.draw_line(_cb.global_position, _cb.global_position + down_slope_vector, Color(0, 1, 0))
		_apply_friction(slide_friction, delta)
		_cb.floor_snap_length = max(_cb.velocity.length() / 20, _initial_snap_length)
		
	elif _cb.velocity.length_squared() > pow(slide_velocity_cutoff, 2):
		# Slide
		_cb.floor_snap_length = _initial_snap_length
		#_cb.apply_floor_snap()
		head_bob.disable()
		_apply_friction(slide_friction, delta)
		_cb.velocity.y = _cb.get_real_velocity().y
		
	else:
		# Move
		_cb.floor_snap_length = _initial_snap_length
		head_bob.enable()
		_apply_acceleration(max_crouch_speed, crouch_acceleration, delta)
		_apply_friction(crouch_friction, delta)
		#var input_vector = _cb.global_transform.basis * _get_input_vector().normalized()
	
	_cb.move_and_slide()
	#if _cb.velocity.y > 0 and _check_snap_ray():
		#_cb.apply_floor_snap()

func _process(delta):
	if active:
		camera_offset.y = lerp(camera_offset.y, -y_offset, y_offset_change_speed * delta)
	else:
		camera_offset.y = lerp(camera_offset.y, 0.0, y_offset_change_speed * delta)
	#label.text = str(_cb.velocity.round())
