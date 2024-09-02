extends Area3D
class_name DroppedItem

@export var item: Item
@export var amount: int = 1:
	set(value):
		if amount == value:
			return
		amount = value
		#update_model_stack()
		

@onready var model_stack: Node3D = $ModelStack
var init_pos: Vector3

var bob_time: float

# TODO: make items fall on ready
# TODO: don't replace all items when collected

func _ready() -> void:
	if not item:
		get_parent().remove_child(self)
		queue_free()
	init_pos = model_stack.transform.origin
	bob_time += (global_position.x + global_position.z) / 10
	if not item:
		despawn()
	var view_model = item.get_view_model()
	if not view_model:
		return
	model_stack.add_child(view_model)
	#update_model_stack()

func _process(delta) -> void:
	bob_time += delta
	model_stack.transform.origin = init_pos + Vector3(0, sin(bob_time) * 0.1, 0)
	model_stack.rotate_y(delta)

func despawn() -> void:
	get_parent().remove_child(self)
	queue_free()

#func update_model_stack() -> void:
	#if not mesh_stack:
		#return
	## Remove all children of the mesh stack except the first one
	#for i in mesh_stack.get_child_count() - 1: 
		#mesh_stack.remove_child(mesh_stack.get_child(i))
	#
	## Loop to create new instances with random offsets if amount > 4
	#var stack_size: int = clamp(amount - 1, 0, 3)
	#for i in stack_size:
		#duplicate_mesh_instance()
#
## Function to duplicate the mesh instance with a random offset
#func duplicate_mesh_instance() -> void:
	## Create a new instance of MeshInstance3D
	#var new_mesh_instance = MeshInstance3D.new()
	#new_mesh_instance.mesh = item.mesh
	#new_mesh_instance.transform = mesh_instance.transform
	#
	## Add the new instance to the mesh stack
	#mesh_stack.add_child(new_mesh_instance)
	#
	## Set a random offset position for the new mesh instance
	#var random_offset = Vector3(randf() * 0.5 - 0.25, 0, randf() * 0.5 - 0.25)
	#new_mesh_instance.transform.origin = mesh_instance.transform.origin + random_offset
