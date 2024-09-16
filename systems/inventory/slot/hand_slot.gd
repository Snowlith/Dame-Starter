extends StandardSlot
class_name HandSlot

@export var user: Node3D
@export var shader_material: ShaderMaterial
@onready var hand: Node3D = $Hand

var held_item: Item

# TODO: low priority but equip animation
# NOTE: could add node config warning maybe?

func _ready():
	super()

func get_item_copy():
	if not item:
		return null
	var copy = item.duplicate()
	apply_mat_recursive(copy, null)
	return copy

func _on_item_changed():
	super()
	if held_item:
		apply_mat_recursive(held_item, null)
		hand.remove_child(held_item)
		held_item.user = null
		
	held_item = item
	
	if held_item:
		hand.add_child(held_item)
		held_item.user = user
		hand.visible = true
		if not shader_material:
			return
		apply_mat_recursive(held_item, shader_material)
	else:
		hand.visible = false

func apply_mat_recursive(node, mat):
	var mesh_instance = node as MeshInstance3D
	if mesh_instance:
		if mat:
			mesh_instance.material_override = mat
			mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		else:
			mesh_instance.material_override = null
			mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	for child in node.get_children():
		apply_mat_recursive(child, mat)
