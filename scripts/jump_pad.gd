extends Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	print("entered!")
	if body is CharacterBody3D:
		body.velocity.y = 50
	elif body is RigidBody3D:
		body.apply_central_force(Vector3.UP * 2000)
