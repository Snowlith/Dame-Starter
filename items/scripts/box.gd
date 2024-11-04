extends ItemBehavior

@export var placed_scene: PackedScene

@export var shoot_sound: AudioStream
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _unhandled_input(event):
	if event is InputEventMouseMotion or event.is_echo():
		return
	if anim_player.is_playing():
		return
	if event.is_action_pressed("primary_attack"):
		primary_attack()
	#elif event.is_action_pressed("inspect"):
		#play_inspect()

func primary_attack():
	shoot()
	anim_player.play("fire")
	Audio.play_sound(shoot_sound)
	print("shot a bullet")
	#var inv: Inventory = _user.get_component("Inventory")
	#
	#if inv:
		#inv.remove_from(inv.hand_slot)

# could make a component that stores camera pos?

func shoot():
	pass
	#var cam: FPSCamera = _user.get_node("FPSCamera")
	#
	#var projectile = placed_scene.instantiate()
	#assert(projectile is RigidBody3D)
	#
	#get_tree().current_scene.add_child(projectile)
	#projectile.global_position = cam.global_position + cam.get_look_dir() * 2.5
	#
	#projectile.apply_central_impulse(cam.get_look_dir() * 10)
