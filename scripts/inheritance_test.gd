extends Node3D
class_name EntityTest

func get_physics_body() -> PhysicsBody3D:
	var node: Node = self
	return node as PhysicsBody3D

func _ready():
	var physics_body = get_physics_body()
	print(physics_body)
	var rigid_body = physics_body as RigidBody3D
	if not rigid_body:
		return
	print(rigid_body)
