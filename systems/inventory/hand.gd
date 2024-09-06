extends Node3D
class_name Hand

@export var shader_material: ShaderMaterial

# TODO: make input handling better: use input()
# NOTE: when we use albedo, we dont need a texture on the shader mat

var item: Item:
	set(new_item):
		if item == new_item:
			return
		
		if item:
			item.user = null
			remove_child(item)
		
		item = new_item
		if item:
			add_child(item)
			item.user = get_parent()
			visible = true
			if not shader_material:
				return
			set_material_override_rec(item)
		else:
			visible = false

# NOTE: MUST MAKE COPY AS IT WILL BE OVERWRITTEN

func set_material_override_rec(node):
	if node is MeshInstance3D:
		node.material_override = shader_material
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for child in node.get_children():
		set_material_override_rec(child)

func _process(delta):
	if not item or SceneManager.in_menu:
		return
	if Input.is_action_just_pressed("primary attack"):
		item.primary_attack()
	if Input.is_action_just_pressed("secondary attack"):
		item.secondary_attack()
	if Input.is_action_just_pressed("inspect"):
		item.inspect()
