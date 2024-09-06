extends Item

@export var health_gain: int

@onready var anim_player: AnimationPlayer = $AnimationPlayer


func primary_attack():
	if anim_player.is_playing():
		return
	anim_player.play("drink")
	await anim_player.animation_finished
	for child in user.get_children():
		var h = child as Health
		if not h:
			continue
		h.current_health += 10

func inspect():
	if anim_player.is_playing():
		return
	anim_player.play("inspect")
	await anim_player.animation_finished
