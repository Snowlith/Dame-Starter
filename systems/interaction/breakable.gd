extends Component
class_name Breakable

@export var drop_item: PackedScene

# TODO: have a separate key for break and interact?

var parent: RigidBody3D

func _ready():
	parent = get_parent_entity()
	assert(parent is RigidBody3D)

func interact(interactor: Interactor = null):
	var dropped = drop_item.instantiate()
	get_tree().current_scene.add_child(dropped)
	dropped.drop()
	dropped.global_transform.origin = parent.global_transform.origin
	parent.queue_free()
	if interactor:
		interactor.end_interaction(false)
