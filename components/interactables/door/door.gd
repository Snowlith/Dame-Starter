extends Toggleable
class_name Door

@export var target: Node3D

@export var opening_duration: float = 0.5
@export var closing_duration: float = 0.5

@export var transition: Tween.TransitionType
@export var easing: Tween.EaseType

func _ready():
	if not target:
		var parent = get_parent_entity()
		if parent:
			target = parent
		else:
			queue_free()
			return
	if target is AnimatableBody3D:
		target.sync_to_physics = false

# TEST THIS
func get_duration() -> float:
	return closing_duration if toggled else opening_duration
