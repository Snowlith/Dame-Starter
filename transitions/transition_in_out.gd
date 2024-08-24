extends Transition

@export var fade_speed: float = 1.0

@onready var anim_player := $AnimationPlayer

func fade_out() -> void:
	anim_player.play("fade_out", -1, fade_speed)
	await anim_player.animation_finished

func fade_in() -> void:
	anim_player.play("fade_out", -1, -fade_speed, true)
	await anim_player.animation_finished
	get_parent().remove_child(self)
	self.queue_free()
