extends Node2D

func _ready():
	$Particles2D.emitting = true
	set_as_toplevel(true)

func _process(delta):
	if Global.bullet_time == true:
		$Particles2D.speed_scale = .5
	if Global.bullet_time == false:
		$Particles2D.speed_scale = 1

func _on_decayTimer_timeout():
	queue_free()
