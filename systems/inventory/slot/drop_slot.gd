extends Slot
class_name DropSlot

var user: Node3D

func _ready():
	super()
	capacity = 1000000
	user = _get_user_rec(get_parent())
	
func _get_user_rec(node):
	if node is not Inventory:
		return _get_user_rec(node.get_parent())
	return node.get_parent()

func _can_drop_data(_pos, _data):
	return true

func _drop_data(_pos, data):
	var source_slot = data["slot"] as Slot
	var desired_amount = data['amount'] as int
	
	_take_from_slot(source_slot, desired_amount)
	
	drop()

func drop():
	var spawn_location = user.global_position + Vector3.FORWARD.rotated(Vector3.UP, user.global_rotation.y) * 2
	
	for existing_item in _get_existing():
		if spawn_location.distance_to(existing_item.global_transform.origin) < 1.0:
			# If nearby, combine the stacks
			existing_item.stack_size += item.stack_size
			existing_item.added()
			item.queue_free()
			return
	
	while get_tree().current_scene.has_node(str(item.name)):
		item.name = _generate_name("abcdefghijklmnopqrstuvwxyz", 10)
	
	get_tree().current_scene.add_child(item)
	item.stack_size = amount
	item.transform.origin = spawn_location
	item.update()
	item.drop()

func _get_existing():
	return get_tree().current_scene.get_children().filter(func(child):
		return child is Item and item.is_same(child))

func _generate_name(chars, length):
	var word: String = ""
	for i in range(length):
		word += chars[randi() % len(chars)]
	return word
