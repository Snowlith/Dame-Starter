extends MovementState
class_name SwingState

@export var gravity: float = -30

@export var max_speed: float = 5
@export var acceleration: float = 5

@export var min_swing_distance: float = 3

# TODO:
# * Draw from barrel of gun
# * Position will have to account for fov shader
# * Gun will have to turn with grapple
# * Definitely add a cooldown
# * Don't allow shooting it directly below

# TODO:
# going toward does not work
# maybe disable correction?


var active: bool = false

var swing_point: Vector3
var swing_distance: float

func _ready():
	super()
	input_changed.connect(_on_input_changed)

func _on_input_changed(action: String, value: int):
	if action == "jump" and value:
		if not _cb.is_on_floor():
			detach()

func _process(delta):
	if active:
		DebugDraw3D.draw_line(swing_point, _cb.global_transform.origin, Color(0, 0, 0.5))
		DebugDraw3D.draw_position(Transform3D(Basis.IDENTITY, swing_point), Color(0, 1, 0))

func _init():
	input = {"left": 0, "right": 0, "up": 0, "down": 0, "jump": 0, "reel_in": 0}

func reel(distance: float):
	swing_distance = max(swing_distance - distance, min_swing_distance)

func handle(delta: float):
	_apply_acceleration(max_speed, acceleration, delta)
	
	_cb.velocity.y += gravity * delta
	
	# When going away from point, swing
	# When going toward point, shorten line
	
	var relative_pos = _cb.global_transform.origin - swing_point
	if not swing_distance:
		swing_distance = relative_pos.length()
		
	var radial_direction = relative_pos.normalized()
	var radial_velocity = radial_direction.dot(_cb.velocity) * radial_direction
	
	if radial_direction.dot(_cb.velocity) < 0:
		swing_distance = max(swing_distance + radial_direction.dot(_cb.velocity) * delta, min_swing_distance)
	
	#var corrected_position = swing_point + radial_direction * swing_distance
	#_cb.global_transform.origin = corrected_position
	
	var correction_velocity = _cb.global_transform.origin - (swing_point + radial_direction * swing_distance)
	# only should affect when under tension
	
	var tangential_velocity = _cb.velocity - radial_velocity
	_cb.velocity = tangential_velocity - correction_velocity
	
	_cb.move_and_slide()

func is_active():
	if _cb.position.distance_squared_to(swing_point) > pow(swing_distance, 2):
		return active
	return not _cb.is_on_floor() and active

func attach(pos):
	active = true
	swing_point = pos

func detach():
	active = false
	swing_point = Vector3.ZERO
	swing_distance = 0
