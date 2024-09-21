extends RayCast3D
class_name Interactor

var current_collider
var target_interactable: Interactable

var in_interaction: bool

# TODO: use ray query or disable raycast when not in use

func _unhandled_key_input(event):
	if event.is_echo():
		return
	if event.is_action_pressed("interact"):
		if in_interaction:
			
			end_interaction()
			return
		
		if not current_collider:
			return
		
		# NOTE: does not loop recursively
		# look into something like get_component
		for child in current_collider.get_children():
			if child as Interactable:
				start_interaction(child)
				break

func get_pos_along_ray(distance: float):
	return global_position - transform.basis.z * distance

func start_interaction(interactable: Interactable):
	in_interaction = true
	target_interactable = interactable
	target_interactable.interact(self)
	
func end_interaction():
	in_interaction = false
	target_interactable.interact()
	target_interactable = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var collider = get_collider()
	if collider == current_collider:
		return
	elif not collider or not collider.is_in_group("interactable"):
		current_collider = null
		return
	current_collider = collider
	
