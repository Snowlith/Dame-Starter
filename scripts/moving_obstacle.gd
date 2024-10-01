extends AnimatableBody3D

var _t: float = 0

var start_pos: Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	_t += randi_range(0, 1000)
	start_pos = global_transform.origin

func _physics_process(delta):
	_t += delta
	global_transform.origin = start_pos + Vector3(sin(_t * 1.5) * 4, 0, 0)
