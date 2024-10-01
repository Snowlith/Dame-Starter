extends Resource
class_name TransitionData

var scene_path: String

var transition: PackedScene
var player: Entity
var id: String

func _init(p_scene_path: String):
	scene_path = p_scene_path
