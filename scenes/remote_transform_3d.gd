extends RemoteTransform3D


func _physics_process(delta):
	print(global_transform.origin)
	print(get_parent().get_parent().global_transform.origin)
	#force_update_transform()
