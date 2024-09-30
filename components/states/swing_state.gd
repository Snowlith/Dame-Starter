extends State
class_name SwingState

@export var gravity: float = -30

@export var speed: float = 5
@export var acceleration: float = 1

# When turning mouse and moving in that direction, turn vel instead of lerping

var active: bool = false

var swing_point: Vector3
var swing_distance: float

func _process(delta):
	if active:
		DebugDraw3D.draw_line(swing_point, character_body.global_transform.origin, Color(0, 0, 0.5))
		DebugDraw3D.draw_position(Transform3D(Basis.IDENTITY, swing_point), Color(0, 1, 0))
		# For the real grapple hook:
		# * Draw from barrel of gun
		# * Position will have to account for fov shader
		# * Gun will have to turn with grapple
		# * Definitely add a cooldown
		# * Don't allow shooting it directly below

func _init():
	input = {"left": 0, "right": 0, "up": 0, "down": 0, "jump": 0}

func handle(delta: float):
	var input_vector = Vector2(input["right"] - input["left"], input["down"] - input["up"])
	var xz = Vector2(character_body.velocity.x, character_body.velocity.z)
	
	if input_vector == Vector2.ZERO:
		pass
	else:
		input_vector = input_vector.normalized().rotated(-character_body.rotation.y)
		xz = xz.lerp(xz + input_vector * speed, acceleration * delta)
	
	character_body.velocity.y += gravity * delta
	character_body.velocity.x = xz.x
	character_body.velocity.z = xz.y
	
	character_body.velocity.y += gravity * delta
	
	var relative_pos = character_body.global_transform.origin - swing_point
	if not swing_distance:
		swing_distance = relative_pos.length()
	
	var radial_direction = relative_pos.normalized()
	var radial_velocity = radial_direction.dot(character_body.velocity) * radial_direction
	
	var corrected_position = swing_point + radial_direction * swing_distance
	character_body.global_transform.origin = corrected_position
	
	var tangential_velocity = character_body.velocity - radial_velocity
	character_body.velocity = tangential_velocity
	
	character_body.move_and_slide()
	
	if character_body.is_on_floor() or input["jump"]:
		detach()

func is_active():
	return active

func attach(pos):
	active = true
	swing_point = pos

func detach():
	active = false
	swing_point = Vector3.ZERO
	swing_distance = 0
