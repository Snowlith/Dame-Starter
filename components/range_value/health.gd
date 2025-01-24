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

func decrease(amount_lost: int):
	super(amount_lost)
	var label = Label3D.new()
	get_tree().current_scene.add_child(label)
	label.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	label.pixel_size = 0.01
	label.modulate = Color.RED
	label.text = str(amount_lost)
	label.global_position = get_parent_entity().global_position
	var target_position = label.global_position + Vector3.UP * 2
	var pos_tween = create_tween().bind_node(label)
	pos_tween.tween_property(label, "global_position", target_position, 2)
	get_tree().create_timer(2).timeout.connect(func(): label.queue_free())
	
