extends Area3D

@onready var c = $CollisionShape3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		body.velocity += get_funny_velocity()

func _process(delta):
	DebugDraw3D.draw_arrow(c.global_transform.origin, c.global_transform.origin + get_funny_velocity(), Color(1, 0.7, 0), 0.1)

func get_funny_velocity():
	return global_transform.basis * Vector3.FORWARD * 30
