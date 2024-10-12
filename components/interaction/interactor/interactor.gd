extends Component
class_name Interactor

@onready var ray_cast: RayCast3D = $RayCast3D

var target: Interactable

var _is_interacting: bool

func _ready():
	var parent = get_parent_entity()
	if parent:
		ray_cast.add_exception(parent)
	ray_cast.enabled = false

func _unhandled_key_input(event):
	if event.is_echo():
		return
	if event.is_action_pressed("interact"):
		print("interacted")
		if _is_interacting:
			print("interaction ended")
			end_interaction(true)
			return
		
		ray_cast.enabled = true
		ray_cast.force_raycast_update()
		var target_entity = ray_cast.get_collider() as Entity
		ray_cast.enabled = false
		if not target_entity:
			return
		# HACK: THIS IS BAD
		print("hack")
		var interactables = target_entity.get_components_of_type("Interactable")
		for interactable in interactables:
			start_interaction(interactable)

func get_pos_along_ray(distance: float):
	return ray_cast.global_position - ray_cast.global_transform.basis.z * distance

func start_interaction(interactable: Interactable):
	_is_interacting = true
	target = interactable
	target.interact(self)

func end_interaction(recall = false):
	_is_interacting = false
	# Recall is used when the interactable needs another call to end the interaction
	if recall and is_instance_valid(target):
		target.interact(self)
	target = null
	
