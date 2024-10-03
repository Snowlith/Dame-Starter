extends CharacterBody3D

@onready var label = $Label

func _physics_process(delta):
	label.text = str(round((velocity * Vector3(1, 0, 1)).length()))
