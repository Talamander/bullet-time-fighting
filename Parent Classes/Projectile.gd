extends Area2D

puppet var puppet_motion = Vector2.ZERO

var velocity = Vector2.ZERO
var speed = 45

func _ready():
	set_as_toplevel(true)


func _process(delta):
	if Global.bullet_time == true:
		speed = 12
		$Particles2D.speed_scale = .5
	else:
		speed = 45
		$Particles2D.speed_scale = 1
	position += velocity * delta * speed
	


func _on_decayTimer_timeout():
	queue_free()
