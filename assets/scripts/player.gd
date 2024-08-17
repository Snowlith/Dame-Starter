extends CharacterBody3D

@export_subgroup("Physics")
@export var speed: float = 7.0
@export var acceleration: float = 10.0
@export var friction: float = 18.0

@export var gravity: float = 50.0
@export var jump_strength: float = 15.0

func _ready():
	pass

func _physics_process(delta: float):
	var input_vector := Vector2.ZERO
	
	# Get input
	input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Handle x & z: walking
	var velocity_xz := Vector2(velocity.x, velocity.z)
	
	if input_vector != Vector2.ZERO:
		velocity_xz = velocity_xz.lerp(input_vector * speed, acceleration * delta)
		
	else:
		velocity_xz = velocity_xz.lerp(Vector2.ZERO, friction * delta)
	
	velocity.x = velocity_xz.x
	velocity.z = velocity_xz.y
	
	# Handle y: jumping and gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = jump_strength
		
	move_and_slide()
