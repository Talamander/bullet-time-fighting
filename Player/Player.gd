extends KinematicBody2D

var playerBullet = preload("res://Player/PlayerBullet.tscn")
var muzzleFlash = preload("res://Effects/MuzzleFlash.tscn")

onready var muzzle = $Muzzle

#Movement Variables
var speed = 300
var acceleration = 4000
var motion = Vector2.ZERO
puppet var puppet_motion = Vector2.ZERO
puppet var puppet_rotation = global_rotation

#Gun variables
onready var fireRate = $Timers/fireRateNormal
onready var fireRateBT = $Timers/fireRateBulletTime
var canFire = true

func _ready():
	if is_network_master():
		Global.PlayerStats.connect("player_died", self, "_on_died")

func _physics_process(delta):
	if is_network_master():
		look_rotation()
		
		var input_vector = get_input_vector()
		#Vector2.ZERO is true when no move key is being pressed
		if input_vector == Vector2.ZERO:
			apply_friction(acceleration * delta)
		else:
			calc_movement(input_vector * acceleration * delta)
		motion = move_and_slide(motion)
		#update_animations(input_vector)
		rpc('update_animations', input_vector)
		rset("puppet_motion", position)
		rset("puppet_rotation", global_rotation)
		
		if Input.is_action_pressed("fire") and canFire == true:
			rpc('fire_bullet')
		if Input.is_action_just_pressed("bullet_time"):
			rpc('bullet_time')
		if Input.is_action_just_released("bullet_time"):
			rpc('bullet_time')
		
	else:
		global_rotation = puppet_rotation
		position = puppet_motion
	

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
	if Global.bullet_time == true:
		motion = motion.clamped(speed/2)
	else:
		motion = motion.clamped(speed)

func look_rotation():
	#Gets the mouse location and sets the player rotation to match
	var look_vector = get_global_mouse_position() - global_position
	global_rotation = atan2(look_vector.y, look_vector.x)

sync func update_animations(input_vector):
	if input_vector.x != 0 or input_vector.y != 0:
		if Global.bullet_time == true:
			$AnimationPlayer.play("Run_BulletTime")
			#print ("Bullet_Time Anim")
		else:
			#print ("Running")
			$AnimationPlayer.play("Run")
	else:
		#print ("Idle")
		$AnimationPlayer.play("Idle")

sync func bullet_time():
	if Global.bullet_time == false:
		Global.bullet_time = true
	else:
		Global.bullet_time = false
	#if Input.is_action_just_pressed("bullet_time"):
		#Global.bullet_time = true
	#if Input.is_action_just_released("bullet_time"):
		#Global.bullet_time = false

sync func fire_bullet():
	canFire = false
	if Global.bullet_time == true:
		fireRateBT.start()
	else:
		fireRate.start()
	var bullet = playerBullet.instance()
	add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.velocity = Vector2.RIGHT.rotated(self.rotation) * bullet.speed
	bullet.set_rotation(global_rotation)
	motion -= bullet.velocity * 5
	
	var muzzleflash = muzzleFlash.instance()
	add_child(muzzleflash)
	muzzleflash.global_position = muzzle.global_position
	muzzleflash.set_rotation(self.rotation)


func _on_fireRate_timeout():
	canFire = true

func _on_fireRateBulletTime_timeout():
	canFire = true


func _on_Torso_hit(damage):
	Global.PlayerStats.health -= damage
	print ("torso")


func _on_Head_hit(damage):
	Global.PlayerStats.health = 0
	print ("head")


func _on_died():
	if is_network_master():
		queue_free()
