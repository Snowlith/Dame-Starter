extends Node3D

@export var bullet: PackedScene
@onready var anim_player = $AnimationPlayer

var item_owner

# TODO: maybe 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not item_owner or SceneManager.in_menu:
		return
	if anim_player.is_playing():
		return
	if Input.is_action_just_pressed("primary attack"):
		anim_player.play("fire")
		shoot2()

func shoot():
	var cam: FPSCamera
	for child in item_owner.get_children():
		cam = child as FPSCamera
		if cam:
			break
	if not cam:
		return
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(cam.global_position,
		cam.global_position - cam.get_look_dir() * 100)
	var collision = space.intersect_ray(query)
	print(collision)

func shoot2():
	var ray_cast = RayCast3D.new()
	var cam: FPSCamera
	for child in item_owner.get_children():
		cam = child as FPSCamera
		if cam:
			break
	if not cam:
		return
	add_child(ray_cast)
	ray_cast.top_level = true
	ray_cast.global_position = cam.global_position
	ray_cast.transform.basis.z = cam.get_look_dir()
	ray_cast.target_position = Vector3.BACK * 100
	ray_cast.add_exception(item_owner)
	ray_cast.debug_shape_custom_color = Color(1, 0, 0)
	ray_cast.force_raycast_update()
	if ray_cast.is_colliding():
		var col = ray_cast.get_collider()
		col.get_parent().remove_child(col)
		col.queue_free()
	
	# debug shoot
	#await get_tree().create_timer(2).timeout
	remove_child(ray_cast)
	print("removed now")
	ray_cast.queue_free()
	#ray_cast.global_position = 
		
