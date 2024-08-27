extends Node3D

@export_dir var item_dir
@export_dir var icon_dir

@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var cam: Camera3D = $SubViewportContainer/SubViewport/Camera3D

@onready var mesh_front: MeshInstance3D = $SubViewportContainer/SubViewport/MeshFront
@onready var mesh_angled: MeshInstance3D = $SubViewportContainer/SubViewport/MeshAngled

var default_cam_pos

func _ready():
	default_cam_pos = cam.transform.origin
	if not item_dir:
		return
	for filename in DirAccess.get_files_at(item_dir):
		var item: Item = load(item_dir + "/" + filename)
		if not item.mesh:
			continue
		var mesh_instance = get_mesh_instance(item)
		mesh_instance.mesh = item.mesh
		mesh_instance.visible = true
		adjust_camera(item.mesh)
		await RenderingServer.frame_post_draw
		save_image(item)
		mesh_instance.visible = false
	
	get_tree().quit()

func get_mesh_instance(item):
	match item.icon_orientation:
			"Front":
				return mesh_front
			"Angled":
				return mesh_angled
	return mesh_front
		

func adjust_camera(mesh):
	if not mesh:
		return
		
	cam.transform.origin = default_cam_pos
	var aabb: AABB = mesh.get_aabb()
	var size: Vector3 = aabb.size
	var max_dimension = max(size.x, size.y, size.z)
	
	# Move camera back based on the size
	cam.transform.origin *= max_dimension * 1.7

func save_image(item):
	var image = sub_viewport.get_viewport().get_texture().get_image()
	var image_path = icon_dir + "/%s.png" % get_resource_name(item)
	image.save_png(image_path)
	
func get_resource_name(resource: Resource):
	return resource.resource_path.get_file().trim_suffix('.tres')
