extends Camera3D
class_name FPSCamera

@export var sensitivity: float = 1.5
@export var nodes_with_camera_offset: Array[Node]

@export_subgroup("Dynamic FOV")
@export var fov_speed_change: float = 0.5
@export var fov_settle_speed: float = 10

var player: CharacterBody3D

var default_fov: float

var start_pos: Vector3

var old_transform: Transform3D
var new_transform: Transform3D

var use_interp: bool = true

func _ready():
	assert(get_parent() is CharacterBody3D)
	player = get_parent()
		
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	rotation_order = EULER_ORDER_XYZ # Fixes camera turning problems
	process_priority = 100 # Updates after other nodes

	default_fov = fov
	start_pos = position
	
	# Copy the target transform
	new_transform = player.global_transform
	old_transform = player.global_transform

func _unhandled_input(event: InputEvent):
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	var mouse_event := event as InputEventMouseMotion
	if mouse_event:
		# Camera rotation
		var look_dir: Vector2 = mouse_event.relative * 0.001
		
		player.rotate_y(-look_dir.x * sensitivity)
		rotate_x(-look_dir.y * sensitivity)
		rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
func _physics_process(_delta):
	# Update the transform, lagging old_transform one physics frame behind
	old_transform = new_transform
	new_transform = player.transform

func _process(delta):
	var f = Engine.get_physics_interpolation_fraction()
	if use_interp:
		global_transform.origin = old_transform.interpolate_with(new_transform, f).origin
	else:
		global_transform.origin = new_transform.origin # Disable interpolation for debugging
		
	_update_fov_offset(delta)
	
	var cumulative_offset := Vector3.ZERO
	for node in nodes_with_camera_offset:
		if not is_instance_valid(node):
			continue
		if "camera_offset" in node:
			var offset = node.camera_offset as Vector3
			cumulative_offset += offset
	
	position += start_pos + cumulative_offset

func get_look_dir() -> Vector3:
	return -global_transform.basis.z

func set_look_dir(dir: Vector3) -> void:
	var yaw = atan2(dir.x, dir.z)
	var pitch = asin(dir.y)

	player.rotation.y = yaw
	rotation.x = clamp(pitch, deg_to_rad(-89), deg_to_rad(89))

## Visual effects

func _update_fov_offset(delta: float) -> void:
	# Horizontal look direction and player velocity
	var look_dir_xz = Vector2(get_look_dir().x, get_look_dir().z).normalized()
	var velocity_xz = Vector2(player.velocity.x, player.velocity.z)
	var vel_length = velocity_xz.length()

	# Default target FOV
	var target_fov = default_fov

	# Adjust FOV based on the velocity's alignment with the look direction
	if vel_length > 0.0:
		var velocity_normalized = velocity_xz.normalized()
		var vel_dot = look_dir_xz.dot(velocity_normalized) * vel_length
		target_fov += fov_speed_change * vel_dot

	# Smoothly interpolate the FOV and clamp it
	fov = clamp(lerp(fov, target_fov, fov_settle_speed * delta), default_fov - 15, default_fov + 15)
