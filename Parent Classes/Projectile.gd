extends Area2D

puppet var puppet_motion = Vector2.ZERO

var velocity = Vector2.ZERO
var speed = 1500

func _ready():
	set_as_toplevel(true)


func _process(delta):
	if Global.bullet_time == true:
		speed = 500
		$Particles2D.speed_scale = .5
	else:
		speed = 1500
		$Particles2D.speed_scale = 1
	position += velocity * delta * speed
	


func _on_decayTimer_timeout():
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	pass#queue_free()
