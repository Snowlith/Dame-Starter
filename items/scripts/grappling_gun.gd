extends Item

@export var shoot_sound: AudioStream
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _unhandled_input(event):
	if event is InputEventMouseMotion or event.is_echo():
		return
	if in_animation():
		return
	if event.is_action_pressed("primary attack"):
		primary_attack()
	elif event.is_action_pressed("inspect"):
		play_inspect()

func primary_attack():
	anim_player.play("fire")
	Audio.play_sound(shoot_sound)
	shoot()

func reload():
	anim_player.play("reload")

func shoot():
	# TODO: make signals for enter and exit hand
	var swing_state = _user.get_component("SwingState")
	if not swing_state:
		return
	
	swing_state.detach()
	var exclude = swing_state.character_body.get_rid()
	var space_state = get_world_3d().get_direct_space_state()
	var cam = get_viewport().get_camera_3d()
	
	var from = cam.global_position
	var to = from + -cam.global_transform.basis.z * 100
	var ray_params = PhysicsRayQueryParameters3D.create(from, to)
	
	var rid_array: Array[RID]
	rid_array.append(exclude)
	ray_params.exclude = rid_array
	
	var ray = space_state.intersect_ray(ray_params)
	if ray.has("position"):
		swing_state.attach(ray["position"])

		
