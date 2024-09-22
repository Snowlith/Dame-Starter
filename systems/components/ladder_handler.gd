extends Component
class_name LadderHandler

@export var climb_speed: float = 3.0

var active: bool = false

var current_ladder: Node3D
var ladder_normal: Vector2

func handle(cb: CharacterBody3D, input: Vector2, delta: float):
	if not active:
		return
	
	cb.velocity.y = input.dot(-ladder_normal) * climb_speed

func entered(ladder, normal):
	if current_ladder:
		return
	active = true
	current_ladder = ladder
	ladder_normal = normal.rotated(-ladder.rotation.y)

func exited():
	active = false
	current_ladder = null
	ladder_normal = Vector2.ZERO
