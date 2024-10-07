extends MovementState
class_name CrouchState

@export var max_speed: float = 3
@export var acceleration: float = 10
@export var friction: float = 12

@export var head_duck: HeadDuckManager

# TODO: make slide higher priority?

var camera_offset: Vector3

func _init():
	input = {"left": 0, "right": 0, "up": 0, "down": 0, "crouch": 0}

func enter():
	head_duck.enable()

func exit():
	head_duck.disable()
	_cb.apply_floor_snap()

func update_status(delta: float) -> Status:
	var uncrouch_value = int(not head_duck.can_disable())
	var input_value = int(input["crouch"] or uncrouch_value)
	return (input_value + uncrouch_value * 2) as Status
	
	#var can_uncrouch = head_duck.can_disable()
	#if head_duck.can_disable():
		#if input["crouch"]:
			#return Status.ACTIVE_FORCED
		#pass
	#else:
		#if input["crouch"]:
			#pass
		#pass
	#if input["crouch"] and not head_duck.can_disable():
		#return Status.ACTIVE_FORCED
	#if not head_duck.can_disable():
		#return Status.FORCED
	#if input["crouch"]:
		#return Status.ACTIVE  
	#return Status.INACTIVE

func handle(delta: float):
	_apply_acceleration(max_speed, acceleration, delta)
	_apply_friction(friction, delta)
	_cb.move_and_slide()
