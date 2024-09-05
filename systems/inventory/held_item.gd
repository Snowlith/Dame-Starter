extends Node3D
class_name HeldItem

@export var shader_material: ShaderMaterial

# NOTE: when we use albedo, we dont need a texture on the shader mat

@onready var health: Health = $"../Health"

var view_model: Node3D
var item: Item:
	set(value):
		if item == value:
			return
		item = value
		if item:
			if view_model:
				remove_child(view_model)
			view_model = item.get_view_model()
			view_model.item_owner = get_parent()
			add_child(view_model)
			visible = true
			if not shader_material:
				return
			set_material_override_rec(view_model)
		else:
			if view_model:
				remove_child(view_model)
			view_model = null
			visible = false

func set_material_override_rec(node):
	if node is MeshInstance3D:
		node.material_override = shader_material
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for child in node.get_children():
		set_material_override_rec(child)
