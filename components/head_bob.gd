extends Component
class_name HeadBob

@export var character_body: CharacterBody3D

@export var frequency := Vector2(1.2, 2.4)
@export var amplitude := Vector2(0.08, 0.08)

var camera_offset: Vector3
var _bob_time: float = 0

var enabled: bool = true

var _reset_pos: Vector3

func _ready():
	_reset_pos = _get_bob_at_t(0)

func _process(delta: float) -> void:
	if enabled:
		_bob_time += delta * character_body.velocity.length() * int(character_body.is_on_floor())
		
		camera_offset = _get_bob_at_t(_bob_time)
	else:
		_bob_time = 0
		camera_offset.x = lerp(camera_offset.x, _reset_pos.x, delta * 10)
		camera_offset.y = lerp(camera_offset.y, _reset_pos.y, delta * 10)

func _get_bob_at_t(t: float) -> Vector3:
	var bob = Vector3.ZERO
	
	bob.x = cos(t * frequency.x) * amplitude.x
	bob.y = cos(t * frequency.y) * amplitude.y
	return bob
	
func disable():
	enabled = false

func enable():
	enabled = true
