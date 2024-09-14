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
		var item_scene := load(item_dir + "/" + filename).instantiate() as Item
		if not item_scene:
			continue
		item_scene.process_mode = PROCESS_MODE_DISABLED
		var rig = get_rig(item_scene)
		rig.add_child(item_scene)
		adjust_scene(item_scene)
		
		
		await RenderingServer.frame_post_draw
		await get_tree().create_timer(.5).timeout
		save_image(item_scene)
		rig.remove_child(item_scene)
	
	get_tree().quit()

func get_rig(item):
	var rig = sub_viewport.get_node_or_null(item.icon_orientation)
	if rig:
		return rig
	return $SubViewportContainer/SubViewport/Front

func adjust_scene(scene_root: Node3D):
	var combined_aabb = get_combined_aabb(scene_root)
	
	if combined_aabb.size == Vector3.ZERO:
		return # No valid AABB found

	var center = combined_aabb.position + combined_aabb.size * 0.5
	var size = combined_aabb.size
	var max_dimension = combined_aabb.get_longest_axis_size()

	# Adjust the scene position
	scene_root.transform.origin -= center
	
	# Adjust camera position based on AABB
	cam.transform.origin = default_cam_pos * max_dimension * 1.7

func get_combined_aabb(scene_root: Node3D) -> AABB:
	var combined_aabb: AABB
	var found_aabb = false
	
	# Iterate through all MeshInstance3D nodes in the scene
	for child in scene_root.get_children():
		if child is MeshInstance3D:
			var mesh = child.mesh
			if mesh:
				var aabb = mesh.get_aabb() * child.transform
				if not found_aabb:
					combined_aabb = aabb
					found_aabb = true
				else:
					combined_aabb = combined_aabb.merge(aabb)
					
	return combined_aabb

func save_image(item):
	var image = sub_viewport.get_viewport().get_texture().get_image()
	var image_path = icon_dir + "/%s.png" % get_item_name(item)
	image.save_png(image_path)
	
func get_item_name(item: Item):
	return item.scene_file_path.split('/')[-1]
	#.trim_suffix('.tscn')
