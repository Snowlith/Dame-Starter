extends Node

const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

const Player = preload("res://scenes/player.tscn")

func host_server():
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	print("hosting server")
	add_player(multiplayer.get_unique_id())
	
	#upnp_setup()

func join_server():
	# CHANGE THIS
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
