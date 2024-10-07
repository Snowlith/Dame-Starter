extends State
class_name LadderState

@export var climb_speed: float = 5
@export var climb_acceleration: float = 7
@export var climb_friction: float = 10

@export var exit_speed: float = 5
@export var exit_velocity: float = 5
@export var exit_friction: float = 10

@export var climb_bob_frequency: float = 4
@export var climb_bob_amplitude: float = 0.2
var _bob_time: float = 0.0

var active: bool = false

var camera_offset: Vector3

var current_ladder: Node3D
var ladder_normal: Vector2

# make player slide down after a while
# TODO: rewrite ladder physics with vector3

func _init():
	input = {"left": 0, "right": 0, "up": 0, "down": 0, "crouch": 0, "jump": 0}

func handle(delta: float):
	var y = _cb.velocity.y
	var xz = Vector2(_cb.velocity.x, _cb.velocity.z)
	var climb_direction = input["jump"] - input["crouch"]
	var input_vector = Vector2(input["right"] - input["left"], input["down"] - input["up"])
	
	if input_vector == Vector2.ZERO and climb_direction == 0:
		y = lerp(y, 0.0, climb_friction * delta)
		xz = xz.lerp(Vector2.ZERO, exit_friction * delta)
	else:
		
		input_vector = input_vector.normalized().rotated(-_cb.rotation.y)
		xz = xz.lerp(input_vector * exit_speed, exit_velocity * delta)
		y = lerp(y, climb_direction * climb_speed, climb_acceleration * delta)
	
	
	_cb.velocity.x = xz.x
	_cb.velocity.y = y
	_cb.velocity.z = xz.y
	_cb.move_and_slide()

func _process(delta):
	if active:
		# Increase the timer by delta to create continuous bobbing
		_bob_time += delta * _cb.velocity.y
		
		# Calculate the offset based on a sine wave for smooth bobbing
		camera_offset.y = sin(_bob_time * climb_bob_frequency) * climb_bob_amplitude
	else:
		# Reset camera offset when not climbing
		camera_offset.y = lerp(camera_offset.y, 0.0, delta * 10)
		_bob_time = 0

func update_status(delta: float):
	#if current_ladder != null:
		#current_status = Status.ACTIVE
	#else:
		#current_status = Status.INACTIVE
	#return current_status
	#
	#current_status = int(current_ladder != null) as Status
	#return current_status
	
	if current_ladder != null:
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
