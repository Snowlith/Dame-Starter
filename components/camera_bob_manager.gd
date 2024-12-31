extends Component
class_name CameraBobManager

@onready var character_body: CharacterBody3D = get_parent_entity().get_physics_body()

@export var frequency := Vector2(1, 2)
@export var amplitude := Vector2(0.04, 0.08)
@export var reset_smoothing_speed: float = 10

var camera_offset: Vector3
var _bob_time: float = 0

var enabled: bool = true

var _reset_pos: Vector3

var _epsilon: float = 0.01

func _ready():
	_reset_pos = _get_bob_at_t(0)

func _process(delta: float) -> void:
	if enabled:
		_bob_time += delta * character_body.velocity.length() * int(character_body.is_on_floor())
		
		camera_offset = _get_bob_at_t(_bob_time)
	else:
		_bob_time = 0
		
		if (camera_offset - _reset_pos).length_squared() < pow(_epsilon, 2):
			return
		camera_offset = camera_offset.lerp(_reset_pos, delta * reset_smoothing_speed)

func _get_bob_at_t(t: float) -> Vector3:
	var bob = Vector3.ZERO
	
	bob.x = sin(t * frequency.x) * amplitude.x
	bob.y = sin(t * frequency.y) * amplitude.y
	return bob
	
func disable():
	enabled = false

func enable():
	enabled = true
