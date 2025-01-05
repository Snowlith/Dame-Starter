extends Area3D
class_name DroppedItem

@export var slot: Slot
@export var pickup_cooldown: float = 1

@onready var viewmodel = $Viewmodel
@onready var anim_player = $AnimationPlayer
@onready var collision_shape = $CollisionShape3D
@onready var label_3d = $Viewmodel/Label3D

var _init_transform: Transform3D
var _bob_time: float

var _throw_rigid_body: RigidBody3D

var _entities_on_collision_cooldown: Array[Entity]
var _entities_collided_with_during_cooldown: Dictionary
var _collision_cooldown_timer: SceneTreeTimer

# TODO: colliding with another droppeditem should stack them

func _ready() -> void:
	_init_transform = viewmodel.transform
	_bob_time += (global_position.x + global_position.z) / 10
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if not slot or not slot.item:
		get_parent().remove_child(self)
		queue_free()
	var item_node = slot.item.viewmodel.instantiate()
	item_node.process_mode = PROCESS_MODE_DISABLED
	viewmodel.add_child(item_node)
	anim_player.play("appear")
	label_3d.text = str(slot.amount)

func throw(starting_velocity: Vector3, entities_on_cooldown: Array[Entity] = []):
	_throw_rigid_body = RigidBody3D.new()
	_throw_rigid_body.contact_monitor = true
	_throw_rigid_body.max_contacts_reported = 1
	_throw_rigid_body.axis_lock_angular_x = true
	_throw_rigid_body.axis_lock_angular_y = true
	_throw_rigid_body.axis_lock_angular_z = true
	_throw_rigid_body.body_entered.connect(_end_throw)
	_throw_rigid_body.collision_layer = 0b00000000_00000000_00000000_00000000
	_throw_rigid_body.add_child(collision_shape.duplicate())
	get_parent().add_child(_throw_rigid_body)
	_throw_rigid_body.global_position = global_position
	reparent(_throw_rigid_body)
	_throw_rigid_body.linear_velocity = starting_velocity
	
	if entities_on_cooldown.is_empty():
		return
	_entities_on_collision_cooldown = entities_on_cooldown
	_collision_cooldown_timer = get_tree().create_timer(pickup_cooldown)
	_collision_cooldown_timer.timeout.connect(_collision_cooldown_over)

func _collision_cooldown_over():
	_entities_on_collision_cooldown.clear()
	for entity in _entities_collided_with_during_cooldown.keys():
		_on_body_entered(entity.get_physics_body())
	_entities_collided_with_during_cooldown.clear()
	_collision_cooldown_timer = null

func _end_throw(body):
	reparent.call_deferred(_throw_rigid_body.get_parent())
	_throw_rigid_body.queue_free()
	_throw_rigid_body = null
	
func _on_body_entered(body: Node3D):
	print(body)
	if body is DroppedItem:
		print("COLLIDED WITH DROPPED ITEM!!! YES!!!")
	if not slot.item:
		return
	var entity = body as Entity
	if not entity:
		return
	if entity in _entities_on_collision_cooldown:
		_entities_collided_with_during_cooldown[entity] = true
		return
	var inventory: Inventory = entity.get_component(Inventory)
	if not inventory:
		return
	var amount_left = inventory.insert(slot, slot.amount)
	if amount_left == 0:
		anim_player.play("disappear")
		if _throw_rigid_body:
			_end_throw(null)
		await anim_player.animation_finished
		get_parent().remove_child(self)
		queue_free()
	else:
		label_3d.text = str(amount_left)

func _on_body_exited(body: Node3D):
	var entity = body as Entity
	if not entity:
		return
	if entity in _entities_collided_with_during_cooldown:
		_entities_collided_with_during_cooldown.erase(entity)

func _process(delta) -> void:
	_bob(delta)

func _reset_bob():
	_bob_time = 0
	viewmodel.transform = _init_transform
	viewmodel.rotation.y = 0

func _bob(delta):
	_bob_time += delta
	viewmodel.transform.origin = _init_transform.origin + Vector3(0, (sin(_bob_time) + 1) * 0.1, 0)
	viewmodel.rotate_y(delta)
