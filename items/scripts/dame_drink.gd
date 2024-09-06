extends Item

@export var health_gain: int

@onready var anim_player: AnimationPlayer = $AnimationPlayer


func primary_attack():
	if anim_player.is_playing():
		return
	anim_player.play("drink")
	await anim_player.animation_finished
	for child in user.get_children():
		var c = child as FPSController
		if not c:
			continue
		c.queue_impulse(Vector3.UP, 30)

func inspect():
	if anim_player.is_playing():
		return
	anim_player.play("inspect")
	await anim_player.animation_finished

		
