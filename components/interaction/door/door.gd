extends Interactable
class_name Door

@export var is_open: bool = false

@export var target: Node3D

@export var opening_duration: float = 0.5
@export var closing_duration: float = 0.5

@export_enum("Linear", "Cubic", "Bounce", "Elastic", "Spring", "Sine") var interpolation: String = "Cubic"
@export_enum("Ease in", "Ease out", "Ease in out", "Ease out in") var easing: String = "Ease out"

func _ready():
	if not target:
		var parent = get_parent_entity()
		if parent:
			target = get_parent_entity()
		else:
			queue_free()
			return
	if target is AnimatableBody3D:
		target.sync_to_physics = false
		
func interact(interactor: Interactor):
	is_open = not is_open

func get_duration() -> float:
	return opening_duration if is_open else closing_duration
	
func get_interpolation() -> Tween.TransitionType:
	match interpolation:
		"Linear":
			return Tween.TRANS_LINEAR
		"Cubic":
			return Tween.TRANS_CUBIC
		"Bounce":
			return Tween.TRANS_BOUNCE
		"Elastic":
			return Tween.TRANS_ELASTIC
		"Sine":
			return Tween.TRANS_SINE
		"Spring":
			return Tween.TRANS_SPRING
	return Tween.TRANS_LINEAR

func get_easing() -> Tween.EaseType:
	match easing:
		"Ease in":
			return Tween.EASE_IN
		"Ease out":
			return Tween.EASE_OUT
		"Ease in out":
			return Tween.EASE_IN_OUT
		"Ease out in":
			return Tween.EASE_OUT_IN
	return Tween.EASE_IN
