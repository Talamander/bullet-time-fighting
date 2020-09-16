extends KinematicBody2D

puppet var puppet_motion = Vector2.ZERO

var velocity = Vector2.ZERO
export(int) var speed = 1000

func _process(delta):
	if is_network_master():
		
		position += velocity * delta
		rset("puppet_motion", position)
	else:
		position = puppet_motion


func _on_decayTimer_timeout():
	queue_free()
