extends MovementState
class_name LadderState

@export var max_speed: float = 5
@export var acceleration: float = 5
@export var friction: float = 10

@export var climb_max_speed: float = 5
@export var climb_acceleration: float = 7
@export var climb_friction: float = 10

var active: bool = false

var current_ladder: Node3D
var ladder_normal: Vector2

# TODO: make player slide down after a while

func handle(delta: float):
	var climb_direction = input_int("jump") - input_int("crouch")
	
	if climb_direction == 0:
		_cb.velocity.y = lerp(_cb.velocity.y, 0.0, climb_friction * delta)
	else:
		_cb.velocity.y = lerp(_cb.velocity.y, climb_direction * climb_max_speed, climb_acceleration * delta)
	
	_apply_acceleration(max_speed, acceleration, delta)
	_apply_friction(friction, delta)
	
	_cb.move_and_slide()

func update_status(delta: float):
	if current_ladder:
		return Status.ACTIVE
	return Status.INACTIVE

func enter_ladder(ladder, normal):
	if current_ladder:
		return
	active = true
	current_ladder = ladder
	ladder_normal = normal.rotated(-ladder.rotation.y)

func exit_ladder():
	active = false
	current_ladder = null
	ladder_normal = Vector2.ZERO
