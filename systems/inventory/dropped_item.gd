extends Area3D

class_name DroppedItem

@export var item: Item
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	if not item:
		despawn()
	mesh_instance.mesh = item.mesh

func _process(delta) -> void:
	mesh_instance.rotate_y(delta)

func despawn() -> void:
	get_parent().remove_child(self)
	queue_free()
#poo
