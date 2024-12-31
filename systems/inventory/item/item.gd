extends Resource
class_name Item


# TODO: make an inheritance hierarchy for different types of items

# TODO: add an icon for item resources

# ViewModel scale should always be same as the scene
# add a separate variable for dropped scale

@export var name: String = "Item"
@export_multiline var description: String = ""

@export var view_model: PackedScene
@export var icon: Texture2D

@export var is_stackable: bool = true
@export var is_droppable: bool = true
@export_enum("Common", "Rare", "Dame") var rarity: String = "Common"

# This is kind of dumb since icons are no longer automatically assigned anyway
@export_enum("Front", "Side", "Angled", "Top") var icon_orientation: String = "Front"

@export var pickup_sound: AudioStream
@export var drop_sound: AudioStream

func is_same(item: Item):
	if not item:
		return false
	return item == self
