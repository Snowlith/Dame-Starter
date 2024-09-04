extends Node
class_name Crouch

@export var stand_col: CollisionShape3D
@export var crouch_col: CollisionShape3D
@export var shape_cast: ShapeCast3D
@export var speed_scalar: float = 0.3
@export var visual_offset_y: float = 0.5
@export var visual_speed: float = 10

var active: bool = false

var offset_pos: Vector3

func _ready():
	_reset_crouch()
	shape_cast.add_exception(stand_col.get_parent())

func _reset_crouch() -> void:
	handle(false)

func handle(input: bool) -> void:
	# Keep crouching when banging head on ceiling
	if active and not input:
		if shape_cast and shape_cast.is_colliding():
			active = true
			return
	
	# Alternate between colliders
	stand_col.disabled = input
	crouch_col.disabled = not input
	active = input

func get_offset(delta: float) -> Vector3:
	if active:
		offset_pos.y = lerp(offset_pos.y, -visual_offset_y, visual_speed * delta)
	else:
		offset_pos.y = lerp(offset_pos.y, 0.0, visual_speed * delta)
	return offset_pos
