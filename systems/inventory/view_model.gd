extends MeshInstance3D
class_name ViewModel

@export var shader_material: ShaderMaterial
var item: Item:
	set(value):
		if item == value:
			return
		item = value
		

# Called when the node enters the scene tree for the first time.
func _ready():
	if not shader_material:
		return
	material_override = shader_material
