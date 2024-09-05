extends Node3D

@export var health_gain: int

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
		anim_player.play("inspect")
		await anim_player.animation_finished
		for child in item_owner.get_children():
			var inv = child as FPSController
			if not inv:
				continue
			inv.queue_impulse(Vector3.UP, 30)
		
