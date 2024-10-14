extends StandardSlot
class_name HandSlot

@export var viewmodel_material: ShaderMaterial
@export var default_item: Item
@onready var hand = $Hand

var held_item: Item

var user: Entity

# TODO: low priority but equip animation

func _ready():
	if not hand:
		queue_free()
	super()

	user = _get_user_rec(get_parent())
	
func _get_user_rec(node) -> Entity:
	if node is not Entity:
		if not node.get_parent():
			return null
		return _get_user_rec(node.get_parent())
	return node

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
		held_item.drop()
		
	held_item = item
	
	if held_item:
		hand.add_child(held_item)
		held_item.pick_up(user)
		hand.visible = true
		if not viewmodel_material:
			return
		apply_mat_recursive(held_item, viewmodel_material)
	else:
		hand.visible = false

func apply_mat_recursive(node, mat):
	var mesh_instance = node as MeshInstance3D
	if mesh_instance:
		if mat:
			for i in mesh_instance.get_surface_override_material_count():
				var s: ShaderMaterial = mat.duplicate()
				var active_material = mesh_instance.get_active_material(i)
				if active_material.albedo_texture:
					s.set_shader_parameter("albedo_texture", active_material.albedo_texture)
					s.set_shader_parameter("use_texture", true)
				else:
					s.set_shader_parameter("albedo_color", active_material.albedo_color)
					s.set_shader_parameter("use_texture", false)
				mesh_instance.set_surface_override_material(i, s)
			mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		else:
			for i in mesh_instance.get_surface_override_material_count():
				mesh_instance.set_surface_override_material(i, null)
			mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	for child in node.get_children():
		apply_mat_recursive(child, mat)
