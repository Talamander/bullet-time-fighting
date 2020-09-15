extends KinematicBody2D

var velocity = Vector2.ZERO
export(int) var speed = 1000

func _process(delta):
	position += velocity * delta


func _on_decayTimer_timeout():
	queue_free()
