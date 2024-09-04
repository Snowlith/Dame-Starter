extends CharacterBody3D

@onready var cam: FPSCamera = $FPSCamera

@onready var crouch: Crouch = $FPSController/Crouch

func _ready():
	add_to_group(SceneManager.PLAYER)

func _process(delta: float):
	var crouch_offset = crouch.get_offset(delta)
	cam.update_camera(delta, crouch_offset)
