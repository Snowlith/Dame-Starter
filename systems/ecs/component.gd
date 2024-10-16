extends Node
class_name Component

func get_parent_entity() -> Entity:
	return _get_parent_entity_rec(self)
	
func _get_parent_entity_rec(node) -> Entity:
	if node is Entity:
		return node
	if not node.get_parent():
		return null
	return _get_parent_entity_rec(node.get_parent())
