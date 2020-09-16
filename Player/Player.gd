extends KinematicBody2D

var playerBullet = preload("res://Player/PlayerBullet.tscn")
var muzzleFlash = preload("res://Effects/MuzzleFlash.tscn")

onready var muzzle = $Muzzle

#Movement Variables
var speed = 600
var acceleration = 4000
var motion = Vector2.ZERO

var canFire = true

func _physics_process(delta):
	look_rotation()
	var input_vector = get_input_vector()
	#Vector2.ZERO is true when no move key is being pressed
	if input_vector == Vector2.ZERO:
		apply_friction(acceleration * delta)
	else:
		calc_movement(input_vector * acceleration * delta)
	motion = move_and_slide(motion)
	
	bullet_time()
	fire_bullet()


func get_input_vector():
	#input vector is direction of key input (WASD)
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	return input_vector.normalized()

func apply_friction(amount):
	#Get the player movement moving smoothly
	if motion.length() > amount:
		motion -= motion.normalized() * amount
	else:
		motion = Vector2.ZERO

func calc_movement(value):
	#Uses the acceleration to ramp up to the speed, so it's not instantaneous
	motion += value
	motion = motion.clamped(speed)

func look_rotation():
	#Gets the mouse location and sets the player rotation to match
	var look_vector = get_global_mouse_position() - global_position
	global_rotation = atan2(look_vector.y, look_vector.x)

func bullet_time():
	if Input.is_action_just_pressed("bullet_time"):
		Engine.time_scale = .5
	if Input.is_action_just_released("bullet_time"):
		Engine.time_scale = 1

func fire_bullet():
	if Input.is_action_pressed("fire") and canFire == true:
		canFire = false
		$Timers/fireRate.start()
		
		var bullet = Global.instance_scene_on_main(playerBullet, muzzle.global_position)
		bullet.velocity = Vector2.RIGHT.rotated(self.rotation) * bullet.speed
		bullet.set_rotation(global_rotation)
		
		var flash = Global.instance_scene_on_main(muzzleFlash, muzzle.global_position)
		flash.set_rotation(global_rotation)
		
		motion -= bullet.velocity * .2


func _on_fireRate_timeout():
	canFire = true
