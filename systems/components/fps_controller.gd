extends Component
class_name FPSController

@export var speed: float = 6.0
@export var acceleration: float = 10.0
@export var friction: float = 18.0

@export var gravity: float = 30.0
@export var air_control_scalar: float = 0.5

@export var object_push_force: float = 20

@onready var crouch: Crouch = $Crouch
@onready var sprint: Sprint = $Sprint
@onready var jump: Jump = $Jump
@onready var ladder_handler: LadderHandler = $LadderHandler

var input: Dictionary = {"left": 0, "right": 0, "up": 0, "down": 0}

var _queued_impulses: Array[Vector3]

var cb: CharacterBody3D

# TODO: zero velocity when applying impulse

func _ready():
	cb = get_parent() as CharacterBody3D
	if not cb:
		queue_free()

func queue_impulse(dir: Vector3, scalar: float):
	_queued_impulses.append(dir.normalized() * scalar)

func _unhandled_key_input(event):
	if event.is_echo():
		return
		
	for key in input.keys():
		if event.is_action(key):
			input[key] = int(event.is_pressed())
			return
	
func _physics_process(delta: float):
	var input_vector = Vector2(input["right"] - input["left"], input["down"] - input["up"]).normalized()
	input_vector = input_vector.rotated(-cb.rotation.y)
	
	ladder_handler.handle(cb, input_vector, delta)
	
	crouch.handle()
	if crouch.active:
		sprint.input = false
	sprint.handle(cb, input_vector, delta)
	
	# Handle x & z: walking
	var velocity_xz := Vector2(cb.velocity.x, cb.velocity.z)
	
	if input_vector != Vector2.ZERO:
		if cb.is_on_floor():
			velocity_xz = velocity_xz.lerp(input_vector * _get_speed(), acceleration * delta)
		else:
			velocity_xz = velocity_xz.lerp(input_vector * _get_speed(), acceleration * air_control_scalar * delta)
	else:
		if cb.is_on_floor():
			velocity_xz = velocity_xz.lerp(Vector2.ZERO, friction * delta)
		else:
			velocity_xz = velocity_xz.lerp(Vector2.ZERO, friction * air_control_scalar * delta)
	
	cb.velocity.x = velocity_xz.x
	cb.velocity.z = velocity_xz.y
	
	# Handle y: jumping and gravity
	if not ladder_handler.active and not jump.handle(cb, delta):
		cb.velocity.y -= gravity * delta
	
	_apply_impulses()
	
	# Physics interaction
	if cb.move_and_slide():
		_handle_physics_interaction()
		
func _apply_impulses() -> void:
	for impulse in _queued_impulses:
		cb.velocity += impulse
	_queued_impulses.clear()

func _handle_physics_interaction() -> void:
	for i in cb.get_slide_collision_count():
		var col = cb.get_slide_collision(i)
		if col.get_collider() is RigidBody3D:
			col.get_collider().apply_force(col.get_normal() * -object_push_force)
	
func _get_speed() -> float:
	if sprint.active:
		return speed * sprint.speed_scalar
	if crouch.active:
		return speed * crouch.speed_scalar
	return speed
