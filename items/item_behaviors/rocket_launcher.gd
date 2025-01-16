extends ItemBehavior


# TODO: 
# bullet behavior should be defined in the bullet scene, not here
# this includes projectile speed

@export var projectile_scene: PackedScene

@export var projectile_speed: float = 100
#@export var loaded_bullets: int = 0
#@export var max_bullets: int = 6
#
#@export var required_bullet_item: Item

@export var shoot_sound: AudioStream
@export var reload_sound: AudioStream

#func holster(user: Entity):
	#super(user)
	#%AmmoCounter.show()
#
#func unholster():
	#super()
	#%AmmoCounter.hide()
		#
func _unhandled_input(event):
	if event is InputEventMouseMotion or event.is_echo():
		return
	if %AnimationPlayer.is_playing():
		return
	if event.is_action_pressed("primary"):
		#var inventory: Inventory = _user.get_component(Inventory)
		#if not inventory:
			#return
		#if loaded_bullets <= 0:
			#return
		shoot()
		#loaded_bullets -= 1
		#update_ammo_counter()
		%AnimationPlayer.play("primary")
		#%MuzzleFlash.emitting = true
		Audio.play_sound(shoot_sound)
	elif event.is_action_pressed("reload"):
		#var inventory: Inventory = _user.get_component(Inventory)
		#if not inventory:
			#return
		#var inventory_bullets = inventory.count(required_bullet_item)
		#var bullets_to_load = min(inventory_bullets, max_bullets - loaded_bullets)
		#if bullets_to_load <= 0:
			#return
		#loaded_bullets += bullets_to_load
		#inventory.remove(required_bullet_item, bullets_to_load)
		#update_ammo_counter()
		%AnimationPlayer.play("reload")
		Audio.play_sound(reload_sound)

func shoot():
	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	var cam = get_viewport().get_camera_3d()
	projectile.global_position = cam.global_position - cam.global_basis.z * 1.5
	projectile.global_basis = cam.global_basis
	var projectile_behavior = projectile as ProjectileBehavior
	if not projectile_behavior:
		return
	projectile_behavior.shoot(-cam.global_basis.z)
	
