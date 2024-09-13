extends Item

func _unhandled_input(event):
	if event.is_action_pressed("primary attack"):
		primary_attack()
	if event.is_action_pressed("inspect"):
		inspect()

func primary_attack():
	if anim_player.is_playing():
		return
	anim_player.play("fire")
	shoot()

func inspect():
	if anim_player.is_playing():
		return
	anim_player.play("inspect")
	
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
		