extends MovementState
class_name SlideState

@export var stand_collider: CollisionShape3D
@export var crouch_collider: CollisionShape3D
@export var shape_cast: ShapeCast3D

@export var y_offset: float = 0.5
@export var y_offset_change_speed: float = 10

var active: bool = false

var camera_offset: Vector3

func _init():
	super()
	input["crouch"] = 0

func _ready():
	shape_cast.add_exception(stand_collider.get_parent())
	_toggle_colliders()

func _toggle_colliders() -> void:
	active = input["crouch"]
	stand_collider.disabled = active
	crouch_collider.disabled = not active

func enter():
	_toggle_colliders()

func exit():
	_toggle_colliders()

func is_active():
	var xz = Vector2(character_body.velocity.x, character_body.velocity.z)
	var floor_normal = character_body.get_floor_normal()
	var slope_direction = Vector2(floor_normal.x, floor_normal.z)
	# Get the floor's normal and calculate the slope direction in the xz-plane
	var is_going_down_slope = xz.dot(slope_direction) > 0
	print(is_going_down_slope)
	 # Adjust the angle threshold if needed
	#print(is_moving_down_slope)
	# Ensure the player has enough velocity to slide and is moving down the slope
	if is_going_down_slope or xz.length_squared() > pow(3, 2):
		if active and not input["crouch"]:
			return shape_cast and shape_cast.is_colliding()
		return input["crouch"]
	return false
	
# NOTE:
# Could adjust snap length or apply_floor_snap()
func handle(delta: float):
	#var input_vector = Vector2(input["right"] - input["left"], input["down"] - input["up"]).normalized()
	var xz = Vector2(character_body.velocity.x, character_body.velocity.z)
	
	# Get the floor's normal and calculate the slope angle
	var floor_normal = character_body.get_floor_normal()
	var slope_angle = acos(floor_normal.y)  # The steeper the slope, the smaller the y component of the normal

	# Adjust speed based on the slope angle
	var slope_multiplier = clamp(1.0 + slope_angle * 2.0, 1.0, 4.0)  # Adjust the slope factor to control the speed increase
	print(slope_multiplier)
	var lerped = xz.lerp(xz.normalized() * speed * slope_multiplier, acceleration * delta)
	if xz.length_squared() < lerped.length_squared():
		xz = lerped
	
	character_body.velocity.x = xz.x
	character_body.velocity.z = xz.y
	
	_handle_gravity(delta)
	character_body.move_and_slide()
	
func _process(delta):
	if active:
		camera_offset.y = lerp(camera_offset.y, -y_offset, y_offset_change_speed * delta)
	else:
		camera_offset.y = lerp(camera_offset.y, 0.0, y_offset_change_speed * delta)
