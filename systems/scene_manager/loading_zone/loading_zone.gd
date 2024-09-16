extends Area3D
class_name LoadingZone

@export_file("*.tscn") var target_scene_path: String

@export var target_id: String
@export var displacement := Vector3(0, 0, 2)
@export var transition: PackedScene = null

# TODO: add tool editor gizmo
# TODO: maybe make player face away from the zone every time

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if not target_scene_path:
		return
	if not body.is_in_group("player"):
		return
	
	var data = TransitionData.new(target_scene_path)
	data.player = body
	data.transition = transition 
	data.id = target_id
	
	SceneManager.change_scene(data)

func spawn(node: Node3D) -> void:
	var spawn_dir = -transform.basis.z.normalized()
	node.position = position + displacement
	for child in node.get_children():
		var cam := child as FPSCamera
		if cam:
			cam.set_look_dir(spawn_dir)
