extends Component
class_name StairSnapManager

@export var max_step_height: float = 0.45

@onready var _cb: CharacterBody3D = get_parent_entity() as PhysicsBody3D

@onready var below_ray = $StairsBelowRayCast3D
@onready var ahead_ray = $StairsAheadRayCast3D

# NOTE: must be before move and slide

func _ready():
	below_ray.add_exception(_cb)
	ahead_ray.add_exception(_cb)
	
func is_surface_too_steep(normal: Vector3):
	return normal.angle_to(Vector3.UP) > _cb.floor_max_angle

func snap_down_stairs():
	below_ray.force_raycast_update()
	var floor_below : bool = below_ray.is_colliding() and not is_surface_too_steep(below_ray.get_collision_normal())
	if not _cb.is_on_floor() and _cb.velocity.y <= 0 and floor_below:
		var body_test_result = KinematicCollision3D.new()
		if _cb.test_move(_cb.global_transform, Vector3(0,-max_step_height,0), body_test_result):
			var translate_y = body_test_result.get_travel().y
			_cb.position.y += translate_y
			_cb.apply_floor_snap()
			#print("snapped down")

func snap_up_stairs(delta) -> bool:
	if not _cb.is_on_floor(): 
		return false
		
	if _cb.velocity.y > 0 or not Vector2(_cb.velocity.x, _cb.velocity.z):
		return false
		
	var expected_move_motion = _cb.velocity * Vector3(1,0,1) * delta
	# magic num, fix this
	var step_pos_with_clearance = _cb.global_transform.translated(expected_move_motion + Vector3(0, max_step_height * 2, 0))
	# Run a body_test_motion slightly above the pos we expect to move to, towards the floor.
	#  We give some clearance above to ensure there's ample room for the player.
	#  If it hits a step <= MAX_STEP_HEIGHT, we can teleport the player on top of the step
	#  along with their intended motion forward.
	print(_cb.velocity)
	DebugDraw3D.draw_position(step_pos_with_clearance)
	var down_check_result = KinematicCollision3D.new()
	var test = _cb.test_move(step_pos_with_clearance, Vector3(0,-max_step_height*2,0), down_check_result)
	if not test:
		print("failed test")
		return false
	# invert this if
	if down_check_result.get_collider() is PhysicsBody3D or down_check_result.get_collider() is CSGShape3D:
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - _cb.global_position).y
		# Note I put the step_height <= 0.01 in just because I noticed it prevented some physics glitchiness
		# 0.02 was found with trial and error. Too much and sometimes get stuck on a stair. Too little and can jitter if running into a ceiling.
		# The normal character controller (both jolt & default) seems to be able to handled steps up of 0.1 anyway
		if step_height > max_step_height or step_height <= 0.01 or (down_check_result.get_position() - _cb.global_position).y > max_step_height: 
			return false
		ahead_ray.global_position = down_check_result.get_position() + Vector3(0,max_step_height,0) + expected_move_motion.normalized() * 0.1
		ahead_ray.force_raycast_update()
		if ahead_ray.is_colliding() and not is_surface_too_steep(ahead_ray.get_collision_normal()):
			_cb.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			_cb.apply_floor_snap()
			#print("snapped up")
	return true
