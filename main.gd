extends Node2D

@onready var host_button = $HostButton
@onready var join_button = $JoinButton
@onready var label = $ConnectionStatusLabel

var peer
var player_scene = preload("res://Player.tscn")

func _ready():
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)

func _on_host_pressed():
	# Create the server peer
	peer = ENetMultiplayerPeer.new()
	var port = 1234
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	# Connect signals for new connections and disconnections
	peer.connect("peer_connected", Callable(self, "_on_multiplayer_peer_connected"))
	peer.connect("peer_disconnected", Callable(self, "_on_multiplayer_peer_disconnected"))
	# Spawn the host player
	_spawn_player(multiplayer.get_unique_id())
	label.text = "Hosting on port %s" % port
	print("Server started. Waiting for peers...")

func _on_join_pressed():
	# Create a client peer (replace "localhost" with host IP when needed)
	peer = ENetMultiplayerPeer.new()
	var host_ip = "localhost"
	var port = 9978
	var error = peer.create_client(host_ip, port)
	if error:
		label.text = "Error connecting: %s" % str(error)
		print("Failed to connect to host: error ", error)
		return
	multiplayer.multiplayer_peer = peer
	# Connect client-specific signals for connection events
	peer.connect("connection_succeeded", Callable(self, "_on_connection_succeeded"))
	peer.connect("connection_failed", Callable(self, "_on_connection_failed"))
	# Note: The host will get the peer_connected signal when this client connects.
	label.text = "Joining host..."
	print("Attempting to join host at %s:%s" % [host_ip, port])

func _spawn_player(id):
	var player = player_scene.instantiate()
	player.name = str(id)
	add_child(player)
	print("Spawning player with ID ", id)

func _on_multiplayer_peer_connected(id):
	print("Peer with ID ", id, " is connecting...")
	_spawn_player(id)
	print("Peer with ID ", id, " has joined!")

func _on_multiplayer_peer_disconnected(id):
	print("Peer with ID ", id, " disconnected.")
	if has_node(str(id)):
		get_node(str(id)).queue_free()

func _on_connection_succeeded():
	print("Successfully connected to host!")
	
func _on_connection_failed():
	print("Failed to connect to host!")
