extends Component
class_name HeadDuckManager

@onready var character_body: CharacterBody3D = get_parent_entity().physics_body

@export var stand_collider: CollisionShape3D
@export var crouch_collider: CollisionShape3D
@export var shape_cast: ShapeCast3D

@export var y_offset: float = 0.5
@export var y_offset_change_speed: float = 10

var camera_offset: Vector3

var enabled: bool = false

# TODO: add many states to transition between
# Crouch state
# Lay state

func _ready():
	shape_cast.add_exception(character_body)
	_toggle_colliders()

func _process(delta: float) -> void:
	if enabled:
		camera_offset.y = lerp(camera_offset.y, -y_offset, y_offset_change_speed * delta)
	else:
		camera_offset.y = lerp(camera_offset.y, 0.0, y_offset_change_speed * delta)

func _toggle_colliders() -> void:
	stand_collider.disabled = enabled
	crouch_collider.disabled = not enabled

func disable():
	enabled = false
	_toggle_colliders()

func enable():
	enabled = true
	_toggle_colliders()

func is_enabled():
	return enabled

func can_disable():
	return not(shape_cast and shape_cast.is_colliding())
