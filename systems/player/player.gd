extends CharacterBody3D

var parent_entity: Entity

@export var state_machine: StateMachine

# TODO: impulse manager

func _ready():
	top_level = true
	parent_entity = get_parent() as Entity

func _physics_process(delta):
	state_machine.update(delta)
