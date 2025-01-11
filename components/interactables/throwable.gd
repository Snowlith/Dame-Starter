extends Interactable
class_name Throwable

@export var throw_strength: float = 10

@onready var rigid_body: RigidBody3D = get_parent_entity().get_physics_body()

signal thrown

func _ready():
	assert(is_instance_valid(rigid_body))

func interact(interactor: Interactor):
	super(interactor)
	thrown.emit()
	var impulse = interactor.get_pos_along_ray(throw_strength) - rigid_body.global_position
	rigid_body.apply_central_impulse(impulse)
