extends Node3D

@export_dir var item_dir
@export_dir var icon_dir

@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var cam: Camera3D = $SubViewportContainer/SubViewport/Camera3D

var default_cam_pos
var default_mesh_instance_pos

# TODO: use scenes instead of meshes

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
		adjust_scene(mesh_instance)
		
		await RenderingServer.frame_post_draw
		save_image(item)
		mesh_instance.visible = false
	
	get_tree().quit()

func get_mesh_instance(item):
	var mesh_instance = sub_viewport.get_node_or_null(item.icon_orientation)
	if mesh_instance:
		return mesh_instance
	return $SubViewportContainer/SubViewport/Front

func adjust_scene(mesh_instance):
	var mesh = mesh_instance.mesh
	if not mesh:
		return
	mesh_instance.transform.origin = Vector3.ZERO
	
	cam.transform.origin = default_cam_pos
	var aabb: AABB = mesh.get_aabb()
	var center = aabb.position + aabb.size * 0.5
	var size: Vector3 = aabb.size
	var max_dimension = max(size.x, size.y, size.z)
	mesh_instance.transform.origin -= center
	
	# Move camera back based on the size
	cam.transform.origin *= max_dimension * 1.7

func save_image(item):
	var image = sub_viewport.get_viewport().get_texture().get_image()
	var image_path = icon_dir + "/%s.png" % get_resource_name(item)
	image.save_png(image_path)
	
func get_resource_name(resource: Resource):
	return resource.resource_path.get_file().trim_suffix('.tres')
