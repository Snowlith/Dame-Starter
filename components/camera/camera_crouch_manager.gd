extends Component
class_name CameraCrouchManager

@export var stand_collider: CollisionShape3D
@export var crouch_collider: CollisionShape3D
@export var shape_cast: ShapeCast3D

@export var crouch_offset := Vector3(0, -0.5, 0)
@export var crouch_enter_exit_duration: float = 0.3

@onready var _cb: CharacterBody3D = get_parent_entity().get_physics_body()

var camera_offset: Vector3

var enabled: bool = false

# TODO: add many states to transition between
# Crouch state
# Lay state

func _ready():
	shape_cast.add_exception(_cb)
	shape_cast.max_results = 1
	_toggle_colliders()

func _start_tween():
	var target_pos = Vector3.ZERO
	if enabled:
		target_pos += crouch_offset
		
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "camera_offset", target_pos, crouch_enter_exit_duration)

func _toggle_colliders() -> void:
	stand_collider.disabled = enabled
	crouch_collider.disabled = not enabled

func disable():
	enabled = false
	_toggle_colliders()
	_start_tween()

func enable():
	enabled = true
	_toggle_colliders()
	_start_tween()

func is_enabled():
	return enabled

func is_hitting_head():
	return shape_cast and shape_cast.is_colliding()
