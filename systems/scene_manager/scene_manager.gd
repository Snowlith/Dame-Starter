extends Node

@export var default_transition: PackedScene

var current_scene_path: String:
	set(value):
		if current_scene_path == value:
			return
		current_scene_path = value
		label.text = current_scene_path
		
var current_transition: Transition

var in_transition: bool = false

@onready var label = $Label
@onready var label_2 = $Label2

# TODO: centralize disabled actions from menu and loading zone

func _process(delta):
	label_2.text = str(Engine.get_frames_per_second())

func _ready() -> void:
	current_scene_path = get_tree().current_scene.scene_file_path

func change_scene(data: TransitionData) -> void:
	if current_scene_path == data.scene_path or in_transition:
		return
	
	await _start_transition(data.transition)
	
	if data.player:
		call_deferred("_deferred_change_scene_player", data.scene_path, data.player, data.id)
	else:
		call_deferred("_deferred_change_scene", data.scene_path)

# used when the player msut be switched between scenes
func _deferred_change_scene_player(scene_path: String, player: Entity, id: String) -> void:
	# remove and free the old scene
	var old_scene = get_tree().current_scene
	player.get_parent().remove_child(player)
	
	get_tree().root.remove_child(old_scene)
	old_scene.queue_free()

	# load and instance the new scene
	var new_scene = load(scene_path).instantiate()
	current_scene_path = scene_path

	# add new scene to tree
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	
	var new_players = get_tree().get_nodes_in_group("player")
	if new_players.is_empty():
		player.queue_free()
	else:
		var new_player = new_players[0]
		var parent = new_player.get_parent()
		parent.remove_child(new_player)
		parent.add_child(player)
		if not _spawn_using_loading_zone(player, id):
			player.position = new_player.position
		new_player.queue_free()
	
	_end_transition()
		
# used when there is no player
func _deferred_change_scene(scene_path: String) -> void:
	# remove and free the old scene
	var old_scene = get_tree().current_scene
	get_tree().root.remove_child(old_scene)
	old_scene.queue_free()

	# load and instance the new scene
	var new_scene = load(scene_path).instantiate()
	current_scene_path = scene_path

	# add new scene to tree
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	
	_end_transition()

func restart_scene() -> void:
	get_tree().reload_current_scene()

func _spawn_using_loading_zone(player: Entity, id: String) -> bool:
	if id == "":
		return false
	
	for zone: LoadingZone in get_tree().get_nodes_in_group("loading zone"):
		if not zone.target_id == id:
			continue
		zone.spawn(player)
		return true
	
	return false

func _start_transition(transition: PackedScene):
	in_transition = true
	
	if transition:
		current_transition = transition.instantiate() as Transition
	elif default_transition:
		current_transition = default_transition.instantiate() as Transition
	else:
		return
		
	add_child(current_transition)
	@warning_ignore("redundant_await")
	await current_transition.fade_out()

func _end_transition():
	if current_transition:
		current_transition.fade_in()
	
	in_transition = false
	
func _unhandled_key_input(event):
	if event.is_action_pressed("quit"):
		get_tree().quit()
