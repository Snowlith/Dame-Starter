extends Resource

class_name Item

var icon_dir = "res://items/icons/"

@export var name: String = ""
@export var mesh: Mesh
@export_enum("Common", "Rare", "Dame") var rarity: String = "Common"
@export_enum("Front", "Angled", "Top") var icon_orientation: String = "Front"

func get_icon_path():
	var filename = resource_path.split("/")[-1]
	return icon_dir + filename.trim_suffix(".tres") + ".png"
	
