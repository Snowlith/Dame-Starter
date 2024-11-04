extends Area3D

@export var rotating_door: RotatingDoor

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if body is Entity and body is CharacterBody3D:
		rotating_door.undo()
