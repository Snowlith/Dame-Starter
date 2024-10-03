extends MovementState
class_name CrouchState

@export var max_crouch_speed: float = 3
@export var crouch_acceleration: float = 10
@export var crouch_friction: float = 12

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

# TODO: redirect y vel when entering slope
# BUG: jumping when going up slope causes headbob issue

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
	active = true
	_toggle_colliders()

func exit():
	if shape_cast and shape_cast.is_colliding():
		return false
	active = false
	_toggle_colliders()
	head_bob.enable()
	return true

func is_active():
	return input["crouch"]

func handle(delta: float):
	var snap: bool = false
	#var force_slide: bool = false
	
	var floor_normal = _cb.get_floor_normal()
	var floor_angle = _cb.get_floor_angle()
	var down_slope_vector = (Vector3.DOWN - floor_normal * Vector3.DOWN.dot(floor_normal)).normalized()
	
	# TODO: Modify snap length based on speed!!!
	
	var exclude = _cb.get_rid()
	var space_state = _cb.get_world_3d().get_direct_space_state()
	
	var from = _cb.global_position
	var to = from + Vector3(_cb.velocity.x, 0, _cb.velocity.z).normalized() * 1
	
	DebugDraw3D.draw_line(from, to, Color(0, 0, 1))
	var ray_params = PhysicsRayQueryParameters3D.create(from, to)
	var rid_array: Array[RID]
	rid_array.append(exclude)
	ray_params.exclude = rid_array
	
	var ray = space_state.intersect_ray(ray_params)
	
	
	if ray.has("collider"):
		print(ray["collider"])
	
	if _cb.velocity.dot(down_slope_vector) > 0.25 and floor_angle > deg_to_rad(slide_minimum_angle):
		# Slide down slope
		head_bob.disable()
		var slope_angle = acos(-floor_normal.y)
		_cb.velocity += down_slope_vector * delta * 10
		#DebugDraw3D.draw_line(_cb.global_position, _cb.global_position + _cb.velocity, Color(1, 0, 0))
		#DebugDraw3D.draw_line(_cb.global_position, _cb.global_position + down_slope_vector, Color(0, 1, 0))
		_apply_friction(slide_friction, delta)
		#force_slide = true
		# TEMPORARY
		#_cb.floor_snap_length = _cb.velocity.length() / 10
		#print(_cb.floor_snap_length)
		
	elif _cb.velocity.length_squared() > pow(slide_velocity_cutoff, 2):
		# Slide
		head_bob.disable()
		_apply_friction(slide_friction, delta)
		#if ray.has("collider"):
			#snap = true
		snap = true
	else:
		# Move
		head_bob.enable()
		_apply_acceleration(max_crouch_speed, crouch_acceleration, delta)
		_apply_friction(crouch_friction, delta)
	
	#var temp = Vector3.ZERO
	#if force_slide:
		#temp = _cb.velocity.y
	_cb.move_and_slide()
	#if force_slide:
		#_cb.velocity.y = temp
	if snap:
		_cb.apply_floor_snap()

func _process(delta):
	if active:
		camera_offset.y = lerp(camera_offset.y, -y_offset, y_offset_change_speed * delta)
	else:
		camera_offset.y = lerp(camera_offset.y, 0.0, y_offset_change_speed * delta)
