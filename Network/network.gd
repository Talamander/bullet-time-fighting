extends Node

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	get_tree().connect("server_disconnected", self, "_on_disconnected_from_server")

# Everyone gets notified whenever a new client joins the server
func _on_player_connected(id):
	pass


# Everyone gets notified whenever someone disconnects from the server
func _on_player_disconnected(id):
	pass


# Peer trying to connect to server is notified on success
func _on_connected_to_server():
	pass


# Peer trying to connect to server is notified on failure
func _on_connection_failed():
	pass


# Peer is notified when disconnected from server
func _on_disconnected_from_server():
	pass
