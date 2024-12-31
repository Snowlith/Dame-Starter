extends Node
class_name Component

# TODO: use this variable instead of the getter
var parent_entity: Entity

# NOTE: This is largely untested especially with scene changes

func _enter_tree():
	parent_entity = get_parent_entity()
	if not parent_entity:
		return
	parent_entity.register_component(self)

func _exit_tree():
	if not parent_entity:
		return
	parent_entity.unregister_component(self)
	parent_entity = null

func get_parent_entity() -> Entity:
	if is_instance_valid(parent_entity):
		return parent_entity
	return _get_parent_entity_rec(self)
	
func _get_parent_entity_rec(node: Node) -> Entity:
	if node is Entity:
		return node
	if not node.get_parent():
		return null
	return _get_parent_entity_rec(node.get_parent())
