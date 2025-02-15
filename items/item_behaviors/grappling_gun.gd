extends ItemBehavior

@export var shoot_sound: AudioStream
@export var detach_sound: AudioStream

var swing_state: SwingState

func holster(user: Entity):
	super(user)
	swing_state = user.get_component(SwingState)
	if not swing_state:
		print("Player does not have swing state")

func unholster():
	super()
	swing_state.detach()
	swing_state = null
		
func _unhandled_input(event):
	if event is InputEventMouseMotion or event.is_echo():
		return
	if %AnimationPlayer.is_playing():
		return
	if event.is_action_pressed("primary"):
		shoot()
		%AnimationPlayer.play("primary")
		Audio.play_sound(shoot_sound)
	elif event.is_action_pressed("secondary"):
		swing_state.detach()
		Audio.play_sound(detach_sound)

func shoot():
	var space_state = get_world_3d().get_direct_space_state()
	var cam = get_viewport().get_camera_3d()
	
	var from = cam.global_position
	var to = from + -cam.global_transform.basis.z * 100
	var ray_params = PhysicsRayQueryParameters3D.create(from, to)
	
	ray_params.exclude = [_user.get_rid()]
	
	var ray = space_state.intersect_ray(ray_params)
	swing_state.detach()
	if ray.has("position"):
		swing_state.attach(ray["position"])
