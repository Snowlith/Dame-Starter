extends RangeValue
class_name Health

@onready var inventory: Inventory = parent_entity.get_component(Inventory)

@export var death_effects: Array[CPUParticles3D]

func _ready():
	depleted.connect(_on_depleted)

func _on_depleted():
	#HERE
	#inventory.drop_all()
	for effect in death_effects:
		effect.reparent(get_parent_entity().get_parent())
		# BUG: if closing the game after the timeout, there is an error
		get_tree().create_timer(effect.lifetime+2).timeout.connect(func(): effect.queue_free())
		effect.emitting = true
	get_parent_entity().queue_free()
