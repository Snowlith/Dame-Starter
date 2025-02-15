extends MovementState
class_name SwingState

@export var gravity: float = 25

@export var max_speed: float = 5
@export var acceleration: float = 2

@export var min_swing_distance: float = 0.5

@export var spring_stiffness: float = 100.0
@export var damping_coefficient: float = 5

@export var reel_speed: float = 3

var _is_attached: bool = false

var swing_point: Vector3
var swing_distance: float

#func _physics_process(delta):
	#if Input.is_action_pressed("jump"):
		#if not _cb.is_on_floor():
			#detach()

func _process(delta):
	if _is_attached:
		# Calculate the current stretch of the rope
		var relative_pos = _cb.global_position - swing_point
		var current_length = max(relative_pos.length(), 0.0)
		
		# Normalize the displacement to a range of 0 to 1 for color interpolation
		var stretch_ratio = current_length / swing_distance
		var stretch = max(stretch_ratio - 1, 0)
		
		# Interpolate between green (no stretch) and red (fully stretched)
		var line_color = Color(stretch * 100, 1.0 - stretch * 100, 0)
		# Draw the debug line with the dynamic color
		DebugDraw3D.draw_line(swing_point, _cb.global_position, line_color)
		DebugDraw3D.draw_position(Transform3D(Basis.IDENTITY, swing_point), Color(0, 1, 0))
		
# TODO
func reel(distance: float):
	swing_distance = max(swing_distance - distance, min_swing_distance)

func handle(delta: float):
	_apply_acceleration(max_speed, acceleration, delta)
	
	if Input.is_action_pressed("primary"):
		reel(reel_speed * delta)
	
	_cb.velocity.y -= gravity * delta
	
	var relative_pos = _cb.global_position - swing_point
	
	var current_length = relative_pos.length()
	var displacement = max(current_length - swing_distance, 0.0)  # Only apply force when stretched
	var radial_direction = relative_pos.normalized()
	
	# Calculate radial velocity component
	var radial_velocity = radial_direction.dot(_cb.velocity) * radial_direction
	
	# Spring and damping forces
	var spring_force = -spring_stiffness * displacement * radial_direction
	var damping_force = -damping_coefficient * radial_velocity
	if displacement == 0:
		damping_force = Vector3.ZERO
	
	# Apply acceleration to velocity
	_cb.velocity += (spring_force + damping_force) * delta
	
	_cb.move_and_slide()

func update_status(delta: float):
	if _is_attached and not _cb.is_on_floor():
		#if _cb.position.distance_squared_to(swing_point) > pow(swing_distance, 2):
		return Status.ACTIVE
			
	#if not _cb.is_on_floor() and _is_attached:
		#return Status.ACTIVE
	return Status.INACTIVE


func attach(pos):
	_is_attached = true
	swing_point = pos
	
	var relative_pos = _cb.global_position - swing_point
	swing_distance = relative_pos.length()
	
	if swing_distance < min_swing_distance:
		detach()
		print("DETACHED")

func detach():
	_is_attached = false
	swing_point = Vector3.ZERO
	swing_distance = 0
