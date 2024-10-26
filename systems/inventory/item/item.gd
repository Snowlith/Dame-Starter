extends Resource
class_name Item

# View model scale should be handled by instantiated item itself

@export var name: String = "Item"
@export_multiline var description: String = ""

@export var view_model: PackedScene
@export var icon: Texture2D

@export var is_stackable: bool = true
@export var is_droppable: bool = true
@export_enum("Common", "Rare", "Dame") var rarity: String = "Common"
@export_enum("Front", "Side", "Angled", "Top") var icon_orientation: String = "Front"

@export var pickup_sound: AudioStream
@export var drop_sound: AudioStream

func is_same(item: Item):
	if not item:
		return false
	return resource_path == item.resource_path
