extends Node2D

func _ready():
	# Connect event handler to the player_list_changed signal
	Network.connect("player_list_changed", self, "_on_player_list_changed")
	
	# Update the lblLocalPlayer label widget to display the local player name
	$HUD/PanelPlayerList/lblLocalPlayer.text = Global.player_info.name

func _on_player_list_changed():
	# First remove all children from the boxList widget
	for c in $HUD/PanelPlayerList/boxList.get_children():
		c.queue_free()
	
	# Now iterate through the player list creating a new entry into the boxList
	for p in Network.players:
		if (p != Global.player_info.net_id):
			var nlabel = Label.new()
			nlabel.text = Network.players[p].name
			$HUD/PanelPlayerList/boxList.add_child(nlabel)
