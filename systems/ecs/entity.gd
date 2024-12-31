extends Node3D
class_name Entity

var components: Dictionary

# TODO: THIS
var _cached_typed_components: Dictionary

func get_physics_body() -> PhysicsBody3D:
	var node: Node = self
	return node as PhysicsBody3D
#
#func _ready():
	#child_entered_tree.connect(_on_child_entered_tree)
	#child_exiting_tree.connect(_on_child_exiting_tree)
	#
	#for child in get_children():
		#_on_child_entered_tree(child)

func get_component(type: Object) -> Component:
	return components.get(type, null)

func has_component(type: Object) -> bool:
	return components.has(type)

# TODO: cache results in cached typed components
func get_components(type: Object) -> Array[Component]:
	var result: Array[Component] = []
	for component in components.values():
		if is_instance_of(component, type):
			result.append(component)
	return result

#func _on_child_entered_tree(node: Node):
	#if is_instance_of(node, Entity):
		#return
	#
	#if node is Component:
		#_register_component(node)
	#
	#node.child_entered_tree.connect(_on_child_entered_tree)
	#node.child_exiting_tree.connect(_on_child_exiting_tree)
	#
	#for child in node.get_children():
		#_on_child_entered_tree(child)
#
#func _on_child_exiting_tree(node):
	#if is_instance_of(node, Entity):
		#return
		#
	#if node is Component:
		#_unregister_component(node)
		#
	#node.child_entered_tree.disconnect(_on_child_entered_tree)
	#node.child_exiting_tree.disconnect(_on_child_exiting_tree)
	#
	#for child in node.get_children():
		#_on_child_exiting_tree(child)

func register_component(component: Component):
	var type: Object = component.get_script()
	if has_component(type):
		push_error("Duplicate component " + str(component) + " at " + str(self))
	else:
		components[type] = component

func unregister_component(component: Component):
	var type: Object = component.get_script()
	if has_component(type):
		components.erase(type)

#func _find_child_components(node: Node) -> Array[Component]:
	#var result: Array[Component] = []
	#result.append_array(node.find_children("", "Component", false))
	#for child in node.get_children():
		#if child is Entity:
			#continue
		#result.append_array(_find_child_components(child))
	#return result
##
