extends State
class_name WalkState

@export var speed: float = 10
@export var acceleration: float = 10
@export var friction: float = 10

func _init():
	input = {"left": 0, "right": 0, "up": 0, "down": 0}

func is_active():
	return character_body.is_on_floor()

func handle(delta: float):
	var input_vector = Vector2(input["right"] - input["left"], input["down"] - input["up"])
	var xz = Vector2(character_body.velocity.x, character_body.velocity.z)
	
	if input_vector == Vector2.ZERO:
		xz = xz.lerp(Vector2.ZERO, friction * delta)
	else:
		input_vector = input_vector.normalized().rotated(-character_body.rotation.y)
		xz = xz.lerp(input_vector * speed, acceleration * delta)
	
	character_body.velocity.x = xz.x
	character_body.velocity.z = xz.y
	character_body.move_and_slide()
