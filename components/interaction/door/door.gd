extends Interactable
class_name Door

@export var is_open: bool = false

@export var opening_duration: float = 0.5
@export var closing_duration: float = 0.5

@export_enum("Linear", "Cubic", "Bounce", "Elastic", "Spring", "Sine") var interpolation: String = "Cubic"
@export_enum("Ease in", "Ease out", "Ease in out", "Ease out in") var easing: String = "Ease out"

@onready var _ab: AnimatableBody3D = get_parent_entity() as PhysicsBody3D

func interact(interactor: Interactor):
	is_open = not is_open
	
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
