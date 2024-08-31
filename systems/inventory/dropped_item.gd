extends Area3D

class_name DroppedItem

@export var item: Item
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var init_pos: Vector3

var bob_time: float

# TODO: make items fall on ready

func _ready() -> void:
	init_pos = mesh_instance.transform.origin
	bob_time += randf_range(0, PI)
	if not item:
		despawn()
	mesh_instance.mesh = item.mesh

func _process(delta) -> void:
	bob_time += delta
	mesh_instance.transform.origin = init_pos + Vector3(0, sin(bob_time) * 0.1, 0)
	mesh_instance.rotate_y(delta)

func despawn() -> void:
	get_parent().remove_child(self)
	queue_free()
#poo
