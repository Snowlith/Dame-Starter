extends Camera3D
class_name FPSCamera

@export_group("Camera")
@export var sensitivity: float = 1.5

@export_subgroup("Dynamic FOV")
@export var fov_speed_change: float = 0.5
@export var fov_settle_speed: float = 10

@export_subgroup("Headbob")
@export var bob_frequency: float = 2.4
@export var bob_amplitude: float = 0.08

var player: CharacterBody3D

var default_fov: float

var start_pos: Vector3

var old_transform: Transform3D
var new_transform: Transform3D

var bob_offset_pos: Vector3
var bob_time: float = 0

var use_interp: bool = true

func _ready():
	player = get_parent() as CharacterBody3D
	if not player:
		queue_free()
	rotation_order = EULER_ORDER_XYZ # fixes camera turning problems

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

func update_camera(delta: float, offset: Vector3):
	var f = Engine.get_physics_interpolation_fraction()
	if use_interp:
		global_transform.origin = old_transform.interpolate_with(new_transform, f).origin
	else:
		global_transform.origin = new_transform.origin # Disable interpolation for debugging
		
	_update_fov_offset(delta)
	_update_headbob_offset(delta)
	
	position += start_pos + offset + bob_offset_pos

func get_look_dir() -> Vector3:
	return -global_transform.basis.z

func set_look_dir(dir: Vector3) -> void:
	var yaw = atan2(dir.x, dir.z)
	var pitch = asin(dir.y)

	player.rotation.y = yaw
	rotation.x = clamp(pitch, deg_to_rad(-89), deg_to_rad(89))

## Visual effects
	
func _update_headbob_offset(delta: float) -> void:
	bob_time += delta * player.velocity.length() * int(player.is_on_floor())
	
	bob_offset_pos.x = cos(bob_time * bob_frequency / 2) * bob_amplitude
	bob_offset_pos.y = sin(bob_time * bob_frequency) * bob_amplitude

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
