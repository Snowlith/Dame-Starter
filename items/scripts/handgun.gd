extends ItemBehavior

@export var required_bullet_item: Item
@export var loaded_bullets: int = 0
@export var max_bullets: int = 6

@export var shoot_sound: AudioStream
@export var reload_sound: AudioStream

func _unhandled_input(event):
	if event is InputEventMouseMotion or event.is_echo():
		return
	if %AnimationPlayer.is_playing():
		return
	if event.is_action_pressed("primary"):
		var inventory: Inventory = user.get_component(Inventory)
		if not inventory:
			return
		if loaded_bullets <= 0:
			return
		shoot()
		loaded_bullets -= 1
		update_ammo_counter()
		%AnimationPlayer.play("primary")
		Audio.play_sound(shoot_sound)
	elif event.is_action_pressed("reload"):
		var inventory: Inventory = user.get_component(Inventory)
		if not inventory:
			return
		var inventory_bullets = inventory.count(required_bullet_item, true)
		var bullets_to_load = min(inventory_bullets, max_bullets - loaded_bullets)
		if bullets_to_load <= 0:
			return
		loaded_bullets += bullets_to_load
		inventory.remove(required_bullet_item, bullets_to_load)
		update_ammo_counter()
		%AnimationPlayer.play("reload")
		Audio.play_sound(reload_sound)

func shoot():
	var space_state = get_world_3d().get_direct_space_state()
	var cam = get_viewport().get_camera_3d()
	
	var from = cam.global_position
	var to = from + -cam.global_transform.basis.z * 100
	var ray_params = PhysicsRayQueryParameters3D.create(from, to)
	
	ray_params.exclude = [user.get_rid()]
	
	var ray = space_state.intersect_ray(ray_params)
	if ray.has("collider"):
		var entity = ray["collider"] as Entity
		print(entity)
		if entity:
			var h = entity.get_component(Health)
			if h:
				h.decrease(100)

func update_ammo_counter():
	%AmmoCounter.text = "Loaded bullets: " + str(loaded_bullets)
