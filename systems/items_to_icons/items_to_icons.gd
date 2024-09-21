extends Node3D

@export_dir var item_dir
@export_dir var icon_dir

@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var cam: Camera3D = $SubViewportContainer/SubViewport/Camera3D

var default_cam_pos
var default_mesh_instance_pos

var capture_time: float = 0.4

var _debug_aabbs = []
var _debug_positions = []


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
		await get_tree().create_timer(capture_time).timeout
		save_image(item_scene)
		rig.remove_child(item_scene)
	
	get_tree().quit()

func _process(delta):
	for aabb in _debug_aabbs:
		DebugDraw3D.draw_aabb(aabb)
	for pos in _debug_positions:
		DebugDraw3D.draw_position(pos)

func get_rig(item):
	var rig = sub_viewport.get_node_or_null(item.icon_orientation)
	if rig:
		return rig
	return $SubViewportContainer/SubViewport/Front

func adjust_scene(scene_root: Node3D):
	var combined_aabb = get_combined_aabb_rec(scene_root, AABB(Vector3.ZERO, Vector3.ZERO))
	if combined_aabb.size == Vector3.ZERO:
		print("no valid aabb")
		return # No valid AABB found

	var center = -combined_aabb.size * 0.5
	var max_dimension = combined_aabb.get_longest_axis_size()
	
	#_debug_aabbs.clear()
	#_debug_aabbs.append(combined_aabb)
	#
	#_debug_positions.clear()
	#_debug_positions.append(scene_root.transform)

	# Adjust the scene position
	
	scene_root.transform.origin -= combined_aabb.get_center()
	
	# Adjust camera position based on AABB
	cam.transform.origin = default_cam_pos * max_dimension * 1.7

func get_combined_aabb_rec(node: Node3D, combined_aabb: AABB):
	var mesh_instance = node as MeshInstance3D
	if mesh_instance:
		if mesh_instance.mesh:
			var aabb_transform = mesh_instance.transform
			aabb_transform.origin = Vector3.ZERO
			var aabb = mesh_instance.mesh.get_aabb() * aabb_transform
			aabb *= Transform3D(Basis(), -mesh_instance.transform.origin)
			if not combined_aabb:
				combined_aabb = aabb
			else:
				combined_aabb = combined_aabb.merge(aabb)
	for child in node.get_children():
		if not child is Node3D:
			continue
		combined_aabb = get_combined_aabb_rec(child, combined_aabb)
	return combined_aabb

func save_image(item):
	var image = sub_viewport.get_viewport().get_texture().get_image()
	var image_path = icon_dir + "/%s.png" % get_item_name(item)
	image.save_png(image_path)
	
func get_item_name(item: Item):
	return item.scene_file_path.split('/')[-1]
	#.trim_suffix('.tscn')
