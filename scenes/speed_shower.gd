extends CharacterBody3D

@onready var label = $Label

func _physics_process(delta):
	label.text = "Velocity: " + str(round((velocity * Vector3(1, 0, 1)).length()))

func _unhandled_key_input(event):
	if event.is_action_pressed("reset"):
		global_transform.origin = Vector3(0, 100, 0)
