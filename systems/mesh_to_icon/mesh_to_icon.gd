extends Node3D

@export_dir var item_dir
@export_dir var icon_dir

@onready var sub_viewport = $SubViewport
@onready var mesh_instance_3d = $SubViewport/MeshInstance3D

func _ready():
	if not item_dir:
		return
	for filename in DirAccess.get_files_at(item_dir):
		var item: Item = load(item_dir + "/" + filename)
		if not item.mesh:
			continue
		mesh_instance_3d.mesh = item.mesh
		await RenderingServer.frame_post_draw
		#call_deferred("save_image", get_resource_name(item))
		save_image(item)
	
	#sub_viewport.tree_exiting.connect(fuck)
	#mesh_instance_3d.mesh = target_mesh
	#call_deferred("save_image")
	get_tree().quit()
 
func fuck():
	print("fuck")

func save_image(item):
	var image = sub_viewport.get_viewport().get_texture().get_image()
	var image_path = icon_dir + "/%s.png" % get_resource_name(item)
	image.save_png(image_path)
	
func get_resource_name(resource: Resource):
	return resource.resource_path.get_file().trim_suffix('.tres')
