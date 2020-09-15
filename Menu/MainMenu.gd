extends CanvasLayer


func _ready():
	Network.connect("server_created", self, "_on_ready_to_play")
	Network.connect("join_success", self, "_on_ready_to_play")
	Network.connect("join_fail", self, "_on_join_fail")


func _on_btCreate_pressed():
	# Gather values from the GUI and fill the network.server_info dictionary
	if (!$VBoxContainer/PanelHost/txtServerName.text.empty()):
		Network.server_info.name = $VBoxContainer/PanelHost/txtServerName.text
	Network.server_info.max_players = int($VBoxContainer/PanelHost/txtMaxPlayers.value)
	Network.server_info.used_port = int($VBoxContainer/PanelHost/txtServerPort.text)
	
	# And create the server, using the function previously added into the code
	Network.create_server()

func _on_btJoin_pressed():
	var port = int($VBoxContainer/PanelJoin/txtJoinPort.text)
	var ip = $VBoxContainer/PanelJoin/txtJoinIP.text
	Network.join_server(ip, port)


func _on_ready_to_play():
	get_tree().change_scene("res://World/Arena.tscn")

func _on_join_fail():
	print("Failed to join server")

