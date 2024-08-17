extends CharacterBody3D

@export var speed = 10.0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity.x = 0
	
	var input_vector = Vector3(0,0,0)
	
	
	
	
	if Input.is_action_pressed("ui_right"):
		input_vector.x = 1
	
	if Input.is_action_pressed("ui_left"):
		input_vector.x = -1
		
	if Input.is_action_pressed("ui_up"):
		input_vector.z = 1
		
	if Input.is_action_pressed("ui_down"):
		input_vector.z = -1
	
	input_vector = input_vector.normalized()
	velocity = velocity.lerp(input_vector*speed, .1)
	
	
	move_and_slide()
	
	
