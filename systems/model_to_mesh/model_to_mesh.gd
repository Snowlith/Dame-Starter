extends Node

@export_dir var import_dir
@export_dir var export_dir

# Called when the node enters the scene tree for the first time.
func _ready():
	var dir = DirAccess.open(import_dir)
	if not dir:
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir() or not file_name.ends_with('.gltf'):
			file_name = dir.get_next()
			continue
		var ps := load(import_dir + "/" + file_name)
		if not ps is PackedScene : continue
		var s := (ps as PackedScene).instantiate()
		var mesh := extract_meshes_rec(s)[0]
		var resource_name = file_name.trim_suffix('.gltf')
		var error = ResourceSaver.save(mesh, export_dir+"/"+resource_name+".tres")

		file_name = dir.get_next()

func extract_meshes_rec(n:Node, mesh_array:Array[Mesh]=[]) -> Array[Mesh] :
	if n is MeshInstance3D : mesh_array.push_back(n.mesh)
	for c in n.get_children() : extract_meshes_rec(c, mesh_array) 
	return mesh_array

func snake_to_pascal(snake_case: String) -> String:
	var parts = snake_case.split("_")
	for i in range(parts.size()):
		parts[i] = parts[i].capitalize()
	return "".join(parts)
