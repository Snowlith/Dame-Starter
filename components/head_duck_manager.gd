extends Component
class_name HeadDuckManager

@onready var character_body: CharacterBody3D = get_parent_entity() as PhysicsBody3D

@export var stand_collider: CollisionShape3D
@export var crouch_collider: CollisionShape3D
@export var shape_cast: ShapeCast3D

@export var y_offset: float = 0.5
@export var y_offset_change_speed: float = 100

var camera_offset: Vector3

var enabled: bool = false

var _epsilon: float = 0.01

# TODO: add many states to transition between
# Crouch state
# Lay state

func _ready():
	shape_cast.add_exception(character_body)
	shape_cast.max_results = 1
	_toggle_colliders()

func _process(delta: float) -> void:
	var target_offset: float = 0
	if enabled:
		target_offset = -y_offset
	# Check if value is close enough
	#if abs(target_offset - camera_offset.y) < _epsilon:
		#return
	camera_offset.y = lerp(camera_offset.y, target_offset, y_offset_change_speed * delta)

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

func is_hitting_head():
	return shape_cast and shape_cast.is_colliding()
