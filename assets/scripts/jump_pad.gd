extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(func(body: Node3D) -> void: enter(body))




func enter(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
	var player := body as CharacterBody3D
	player.velocity.y = 50  # Boost the player upward by setting the y velocity
