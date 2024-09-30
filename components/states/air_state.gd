extends State
class_name AirState

@export var gravity: float = -30

@export var speed: float = 12
@export var acceleration: float = 2

# TODO: don't allow building up speed in the air
# rather, make the jump add some horizontal speed
# allow changing direction in the air but not adding speed

# When turning mouse and moving in that direction, turn vel instead of lerping

func _init():
	input = {"left": 0, "right": 0, "up": 0, "down": 0}

func is_active():
	return not character_body.is_on_floor()

func handle(delta: float):
	var input_vector = Vector2(input["right"] - input["left"], input["down"] - input["up"])
	var xz = Vector2(character_body.velocity.x, character_body.velocity.z)
	
	if input_vector == Vector2.ZERO:
		pass
	else:
		input_vector = input_vector.normalized().rotated(-character_body.rotation.y)
		xz = xz.lerp(input_vector * speed, acceleration * delta)
	
	character_body.velocity.y += gravity * delta
	character_body.velocity.x = xz.x
	character_body.velocity.z = xz.y
	character_body.move_and_slide()
