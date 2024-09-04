extends Node
class_name FPSController

@export var speed: float = 6.0
@export var acceleration: float = 10.0
@export var friction: float = 18.0

@export var gravity: float = 40.0
@export var object_push_force: float = 20

@onready var crouch: Crouch = $Crouch
@onready var sprint: Sprint = $Sprint
@onready var jump: Jump = $Jump

var cb: CharacterBody3D

# TODO: add direction change penalty in the air


func _ready():
	cb = get_parent() as CharacterBody3D
	if not cb:
		queue_free()

func _physics_process(delta: float):
	var input_vector := Vector2.ZERO
	
	if not SceneManager.in_transition or not SceneManager.in_menu:
		# Get the normalized input vector (movement direction) rotated towards direction faced
		input_vector = Input.get_vector("left", "right", "up", "down")
		input_vector = input_vector.rotated(-cb.rotation.y)
		
		crouch.handle(Input.is_action_pressed("crouch"))
		var sprint_input = Input.is_action_pressed("sprint") and not crouch.active
		sprint.handle(sprint_input, cb, input_vector, delta)
		
		jump.handle(Input.is_action_just_pressed("jump"), cb, delta)
	
	# Handle x & z: walking
	var velocity_xz := Vector2(cb.velocity.x, cb.velocity.z)
	
	if input_vector != Vector2.ZERO:
		# If moving, interpolate toward desired speed in the direction faced
		velocity_xz = velocity_xz.lerp(input_vector * _get_speed(), acceleration * delta)
	else:
		# If not moving, interpolate toward stop
		velocity_xz = velocity_xz.lerp(Vector2.ZERO, friction * delta)
	
	cb.velocity.x = velocity_xz.x
	cb.velocity.z = velocity_xz.y
	
	# Handle y: jumping and gravity
	if not cb.is_on_floor() and not jump.active:
		cb.velocity.y -= gravity * delta
	
	# Physics interaction
	if cb.move_and_slide():
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
