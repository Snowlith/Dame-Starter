extends Node3D
class_name DroppedItem

@export var slot: Slot
@onready var area = $Area3D
@onready var view_model = $ViewModel
@onready var anim_player = $AnimationPlayer

var _init_transform: Transform3D
var _bob_time: float

func _ready() -> void:
	_init_transform = view_model.transform
	_bob_time += (global_position.x + global_position.z) / 10
	area.body_entered.connect(_on_body_entered)
	if not slot or not slot.item:
		get_parent().remove_child(self)
		queue_free()
	var item_node = slot.item.view_model.instantiate()
	view_model.add_child(item_node)
	anim_player.play("appear")

func _on_body_entered(body: Node3D):
	if not slot:
		return
	var entity = body as Entity
	if not entity:
		return
	var inventory: Inventory = entity.get_component("Inventory")
	if not inventory:
		return
	var amount_left = inventory.insert(slot.item, slot.amount)
	if amount_left == 0:
		slot = null
		anim_player.play("disappear")
		await anim_player.animation_finished
		get_parent().remove_child(self)
		queue_free()
	else:
		slot.amount = amount_left

func _process(delta) -> void:
	_bob(delta)

func _reset_bob():
	_bob_time = 0
	view_model.transform = _init_transform
	view_model.rotation.y = 0

func _bob(delta):
	_bob_time += delta
	view_model.transform.origin = _init_transform.origin + Vector3(0, (sin(_bob_time) + 1) * 0.1, 0)
	view_model.rotate_y(delta)
