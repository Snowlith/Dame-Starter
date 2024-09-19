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
	elif event.is_action_pressed("reload"):
		reload()
	elif event.is_action_pressed("inspect"):
		inspect()

func primary_attack():
	anim_player.play("fire")
	Audio.play_sound(shoot_sound)
	shoot()

func reload():
	anim_player.play("reload")

func shoot():
	var cam: FPSCamera
	for child in user.get_children():
		cam = child as FPSCamera
		if cam:
			break
	if not cam:
		return
		
	var ray_cast = RayCast3D.new()
	add_child(ray_cast)
	
	# Position
	ray_cast.top_level = true
	ray_cast.global_position = cam.global_position
	ray_cast.transform.basis.z = cam.get_look_dir()
	ray_cast.target_position = Vector3.BACK * 100
	
	ray_cast.add_exception(user)
	ray_cast.debug_shape_custom_color = Color(1, 0, 0)
	ray_cast.force_raycast_update()
	if ray_cast.is_colliding():
		var col = ray_cast.get_collider()
		col.get_parent().remove_child(col)
		col.queue_free()
	
	# debug shoot
	#await get_tree().create_timer(2).timeout
	remove_child(ray_cast)
	ray_cast.queue_free()
		
