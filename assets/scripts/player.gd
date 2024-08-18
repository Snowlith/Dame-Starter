extends CharacterBody3D

@export_subgroup("Physics")
@export var speed: float = 4.0
@export var acceleration: float = 10.0
@export var friction: float = 18.0

@export var gravity: float = 50.0
@export var jump_strength: float = 15.0

@onready var _spring_arm: SpringArm3D = $SpringArm3D
@onready var _model: Node3D = $character_knight

func _ready():
	pass

func _physics_process(delta: float):
	var input_vector := Vector2.ZERO
	
	# Get input
	input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	input_vector = input_vector.rotated(-_spring_arm.rotation.y)

	# Handle x & z: walking
	var velocity_xz := Vector2(velocity.x, velocity.z)
	
	if input_vector != Vector2.ZERO:
		velocity_xz = velocity_xz.lerp(input_vector * speed, acceleration * delta)
		
	else:
		velocity_xz = velocity_xz.lerp(Vector2.ZERO, friction * delta)
	
	velocity.x = velocity_xz.x
	velocity.z = velocity_xz.y
	
	
	if velocity.length() > 0.2:
		var look_direction = Vector2(velocity.z, velocity.x)
		_model.rotation.y = look_direction.angle()
	
	# Handle y: jumping and gravity
	print(velocity.y)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		# velocity.y = 0
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = jump_strength
		
	move_and_slide()
	
	
func _process(delta: float) -> void:
	_spring_arm.position = position
	
