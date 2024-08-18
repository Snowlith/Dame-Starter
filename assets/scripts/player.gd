extends CharacterBody3D

@export_group("Physics")
@export var speed: float = 10.0
@export var acceleration: float = 10.0
@export var friction: float = 18.0

@export var gravity: float = 50.0
@export var jump_strength: float = 15.0

@export_subgroup("Sprinting")
@export var max_sprint_time: float = 4.0
@export var sprint_speed_multiplier: float = 1.4
@export var walk_recharge_rate: float = 1.0
@export var stand_recharge_rate: float = 2.5

@export_subgroup("Crouching")
@export var crouch_speed_multiplier: float = 0.3
@export var crouch_offset_y: float = 0.5
@export var crouch_speed: float = 10

@export_group("Camera")
@export var sensitivity: float = 0.002
@export var fov: float = 80
@export var fov_speed_change: float = 0.5

@export_subgroup("Headbob")
@export var bob_frequency: float = 2.4
@export var bob_amplitude: float = 0.08

@onready var cam := $Camera3D

@onready var stand_col := $StandCollider
@onready var crouch_col := $CrouchCollider
@onready var shape_cast := $CrouchCollider/ShapeCast3D

var current_sprint_time := max_sprint_time

var is_sprinting := false
var is_crouching := false

var cam_start_pos: Vector3
var crouch_offset_pos: Vector3
var bob_offset_pos: Vector3

var bob_time: float = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	shape_cast.add_exception(self)
	
	cam.fov = fov
	cam_start_pos = cam.position
	_reset_crouch()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		cam.rotate_x(-event.relative.y * sensitivity)
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _process(delta: float):
	crouch_offset_pos = _get_crouch_offset(delta)
	bob_offset_pos = _get_headbob_offset(delta)
	
	cam.position = cam_start_pos + crouch_offset_pos + bob_offset_pos
	
	cam.fov = _get_fov_offset(delta)

func _physics_process(delta: float):
	var input_vector := Vector2.ZERO
	
	# Get input
	input_vector = Input.get_vector("left", "right", "up", "down")
	input_vector = input_vector.rotated(-rotation.y)
	
	is_crouching = _handle_crouch(Input.is_action_pressed("crouch"), delta)
	is_sprinting = _handle_sprint(Input.is_action_pressed("sprint"), input_vector, delta)
	
	# Handle x & z: walking
	var velocity_xz := Vector2(velocity.x, velocity.z)
	
	if input_vector != Vector2.ZERO:
		velocity_xz = velocity_xz.lerp(input_vector * _get_speed(), acceleration * delta)
		
	else:
		velocity_xz = velocity_xz.lerp(Vector2.ZERO, friction * delta)
	
	velocity.x = velocity_xz.x
	velocity.z = velocity_xz.y
	
	# Handle y: jumping and gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		# velocity.y = 0
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_strength
		
	move_and_slide()
	
func _get_speed() -> float:
	if is_sprinting:
		return speed * sprint_speed_multiplier
	if is_crouching:
		return speed * crouch_speed_multiplier
	return speed
	
func _handle_crouch(crouch_input: bool, delta: float) -> bool:
	# keep crouching on invalid uncrouch
	if is_crouching and not crouch_input:
		if shape_cast and shape_cast.is_colliding():
			return true
	
	stand_col.disabled = crouch_input
	crouch_col.disabled = not crouch_input
	return crouch_input

func _handle_sprint(sprint_input: bool, input_vector: Vector2, delta: float) -> bool:
	# if not sprinting, then recharge
	if not sprint_input or is_crouching or is_on_wall():
		if input_vector == Vector2.ZERO:
			current_sprint_time += stand_recharge_rate * delta
		else:
			current_sprint_time += walk_recharge_rate * delta
		current_sprint_time = clamp(current_sprint_time, 0, max_sprint_time)
		return false
	
	# if sprinting, drain sprint time
	current_sprint_time -= delta
	if current_sprint_time <= 0:
		current_sprint_time = 0
		return false
	
	return true

func _reset_crouch() -> void:
	_handle_crouch(false, 0)

func _get_headbob_offset(delta: float) -> Vector3:
	var offset := Vector3.ZERO
	bob_time += delta * velocity.length() * int(is_on_floor())
	
	offset.x = cos(bob_time * bob_frequency / 2) * bob_amplitude
	offset.y = sin(bob_time * bob_frequency) * bob_amplitude
	return offset

func _get_crouch_offset(delta: float) -> Vector3:
	var offset := Vector3.ZERO
	if is_crouching:
		offset.y = lerp(crouch_offset_pos.y, -crouch_offset_y, crouch_speed * delta)
	else:
		offset.y = lerp(crouch_offset_pos.y, 0.0, crouch_speed * delta)
	return offset

func _get_fov_offset(delta: float) -> float:
	var velocity_length = Vector2(velocity.x, velocity.z).length()
	var velocity_clamped = clamp(velocity_length, 0.5, speed * sprint_speed_multiplier * 2)
	var target_fov = fov + fov_speed_change * velocity_clamped
	return lerp(cam.fov, target_fov, delta * 15)
