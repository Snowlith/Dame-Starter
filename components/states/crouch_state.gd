extends State
class_name CrouchState

@export var crouch_speed: float = 3
@export var crouch_acceleration: float = 10
@export var crouch_friction: float = 12
@export var slide_friction: float = 1
@export var slide_velocity_cutoff: float = 3

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
	shape_cast.add_exception(character_body)
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
	var xz = Vector2(character_body.velocity.x, character_body.velocity.z)
	var floor_normal = character_body.get_floor_normal()
	var slope_direction = Vector2(-floor_normal.x, -floor_normal.z)
	
	if xz.dot(slope_direction) < 0:
		head_bob.disable()
		# Slide down slope
		var slope_angle = acos(floor_normal.y)
		var slope_velocity = -slope_direction.normalized() * slope_angle * 40
		xz = xz.lerp(slope_velocity, delta)
	elif xz.length_squared() > pow(slide_velocity_cutoff, 2):
		head_bob.disable()
		# Sliding on ground
		xz = xz.lerp(Vector2.ZERO, slide_friction * delta)
	else:
		head_bob.enable()
		# Crouching
		var input_vector = Vector2(input["right"] - input["left"], input["down"] - input["up"]).normalized()
		
		if input_vector == Vector2.ZERO:
			xz = xz.lerp(Vector2.ZERO, crouch_friction * delta)
		else:
			input_vector = input_vector.normalized().rotated(-character_body.rotation.y)
			xz = xz.lerp(input_vector * crouch_speed, crouch_acceleration * delta)
	
	
	character_body.velocity.x = xz.x
	character_body.velocity.z = xz.y
	
	character_body.move_and_slide()

func _process(delta):
	if active:
		camera_offset.y = lerp(camera_offset.y, -y_offset, y_offset_change_speed * delta)
	else:
		camera_offset.y = lerp(camera_offset.y, 0.0, y_offset_change_speed * delta)
