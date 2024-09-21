extends Entity

@onready var cam: FPSCamera = $FPSCamera

@onready var crouch: Crouch = $FPSController/Crouch

func _process(delta: float):
	var crouch_offset = crouch.get_offset(delta)
	cam.update_camera(delta, crouch_offset)

func _ready():
	super()
