extends Resource
class_name Item

# FEATURE: slot sizes should be based on item stack sizes instead?

# BUG: all item instances are the same. Recollecting a gun means it is reset.
# make instances unique somehow

# TODO: make an inheritance hierarchy for different types of items

# TODO: add an editor icon for item resources

# ViewModel scale should always be same as the scene
# add a separate variable for dropped scale

# TODO: add to own class, allow defining color for each category
enum ItemCategories { 
	Misc, Melee, Ranged, Ammo,
	Armor, Special, Currency,
	Resource
}


@export var name: String
@export_multiline var description: String
@export var item_category: ItemCategories

@export var viewmodel: PackedScene
@export var icon: Texture2D

@export var stack_size: int = 1
@export var is_use_persistent: bool = false
@export var is_droppable: bool = true
@export_enum("Common", "Rare", "Dame") var rarity: String = "Common"

# This is kind of dumb since icons are no longer automatically assigned anyway
# Add buttons for adjusting this in items_to_icons
@export_enum("Front", "Side", "Angled", "Top") var icon_orientation: String = "Front"

@export var pickup_sound: AudioStream
@export var drop_sound: AudioStream
