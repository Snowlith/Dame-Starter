extends Resource

class_name Item

var icon_dir = "res://items/icons/"

@export var name: String = ""
@export var mesh: Mesh
@export_enum("Common:1", "Rare:2", "Dame:3") var rarity: int = 1

func get_icon_path():
	return icon_dir + resource_name.get_file().trim_suffix('.tres')
