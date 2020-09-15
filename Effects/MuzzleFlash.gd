extends Node2D

func _ready():
	$Particles2D.emitting = true


func _on_decayTimer_timeout():
	queue_free()
