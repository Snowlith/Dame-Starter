extends Component
class_name Breakable

@export var drop_item: PackedScene

@onready var parent: Entity = get_parent_entity()

# TODO: have a separate key for break and interact?

var rigid_body: RigidBody3D

func _ready():
	if parent:
		rigid_body = parent.get_physics_body()

func interact(interactor: Interactor):
	var dropped = drop_item.instantiate()
	get_tree().current_scene.add_child(dropped)
	dropped.drop()
	dropped.global_transform.origin = rigid_body.global_transform.origin
	parent.queue_free()
	if interactor:
		interactor.end_interaction(false)
