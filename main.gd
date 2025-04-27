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
	peer = ENetMultiplayerPeer.new()
	peer.create_server(1234)
	multiplayer.multiplayer_peer = peer
	_spawn_player(multiplayer.get_unique_id())
	label.text = "Hosting..."

func _on_join_pressed():
	peer = ENetMultiplayerPeer.new()
	peer.create_client("localhost", 1234)  # replace localhost with host IP
	multiplayer.multiplayer_peer = peer
	label.text = "Joining..."

func _spawn_player(id):
	var player = player_scene.instantiate()
	player.name = str(id)
	add_child(player)

func _on_player_connected(id):
	_spawn_player(id)

func _on_player_disconnected(id):
	if has_node(str(id)):
		get_node(str(id)).queue_free()

func _on_multiplayer_peer_connected(id):
	_on_player_connected(id)

func _on_multiplayer_peer_disconnected(id):
	_on_player_disconnected(id)
