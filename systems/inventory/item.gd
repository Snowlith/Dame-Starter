extends Resource

class_name Item

var icon_dir = "res://items/icons/"

@export var name: String = ""
@export var view_model: PackedScene
@export var is_stackable: bool = true
@export_enum("Common", "Rare", "Dame") var rarity: String = "Common"
@export_enum("Front", "Angled", "Top") var icon_orientation: String = "Front"

signal a

func deplete():
	a.emit()

func get_icon_path():
	var filename = resource_path.split("/")[-1]
	return icon_dir + filename.trim_suffix(".tres") + ".png"

func get_view_model() -> Node3D:
	var scene = view_model.instantiate()
	return scene

# TODO: use scenes instead of meshes
