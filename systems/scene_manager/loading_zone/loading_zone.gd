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
	if not body.get_parent().is_in_group("player"):
		return
	
	var data = TransitionData.new(target_scene_path)
	data.player = body.get_parent()
	data.transition = transition 
	data.id = target_id
	
	SceneManager.change_scene(data)

func spawn(player: Entity) -> void:
	var spawn_dir = -transform.basis.z.normalized()
	player.physics_body.position = position + displacement
	for cam in player.find_children("", "FPSCamera"):
		if cam:
			cam.set_look_dir(spawn_dir)
			break
