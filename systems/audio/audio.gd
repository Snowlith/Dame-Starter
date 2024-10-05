extends Node

@onready var tree := get_tree()

func _play_sound(sound: AudioStream, player, autoplay := true):
	if not sound:
		return
	if not is_node_ready():
		return
		
	player.stream = sound
	player.autoplay = autoplay
	player.finished.connect(func(): player.queue_free())
	tree.current_scene.call_deferred("add_child", player)
	return player

# Use this for non-diagetic music or UI sounds which have no position
func play_sound(sound: AudioStream, autoplay := true) -> AudioStreamPlayer:
	return _play_sound(sound, AudioStreamPlayer.new(), autoplay)
