extends GravityState
class_name IdleState

@export var friction: float = 10

var active: bool = false

func _init():
	input = {"left": 0, "right": 0, "up": 0, "down": 0}
	
func _ready():
	input_changed.connect(_on_input_changed)

func _on_input_changed(_action: String, _value: int):
	var horizontal = input["right"] - input["left"]
	var vertical = input["down"] - input["up"]
	active = horizontal == 0 and vertical == 0

func is_active():
	return active

func handle(delta: float):
	var input_vector = Vector2(input["right"] - input["left"], input["down"] - input["up"]).normalized()
	input_vector = input_vector.rotated(-character_body.rotation.y)
	var xz = Vector2(character_body.velocity.x, character_body.velocity.z)
	xz = xz.lerp(Vector2.ZERO, friction * delta)
	
	character_body.velocity.x = xz.x
	character_body.velocity.z = xz.y
	_handle_gravity(delta)
	character_body.move_and_slide()
