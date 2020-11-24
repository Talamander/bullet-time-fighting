extends KinematicBody2D

var playerBullet = preload("res://Player/PlayerBullet.tscn")
var muzzleFlash = preload("res://Effects/MuzzleFlash.tscn")

onready var muzzle1 = $LeftMuzzle
onready var muzzle2 = $RightMuzzle
onready var engineparticles = $EngineParticles

#Movement Variables
export(int)var speed = 300
export(int)var acceleration = 4000
var motion = Vector2.ZERO
puppet var puppet_motion = Vector2.ZERO
puppet var puppet_rotation = global_rotation

#Gun variables
onready var fireRate = $Timers/fireRateNormal
onready var fireRateBT = $Timers/fireRateBulletTime
var canFire = true
var altFire = true
var previous = null
var state = "None"

func _ready():
	if is_network_master():
		Global.PlayerStats.connect("player_died", self, "_on_died")
		$Camera2D.make_current()
		engineparticles.emitting = false

func _physics_process(delta):
	if is_network_master():
		look_rotation()
		
		if Input.is_action_pressed("Thrust"):
			state = "Flying"
			var input_vector = get_input_vector()
			previous = input_vector
			calc_movement(input_vector * acceleration * delta)
		elif Input.is_action_pressed("Drift") && !Input.is_action_pressed("Thrust"):
			calc_movement(previous * acceleration * delta)
			state = "Drifting"
		else:
			apply_friction(acceleration * delta)
		motion = move_and_slide(motion)
		
		rpc('update_particles')
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
	var input_vector = Vector2(1, 0).rotated(rotation)
	return input_vector

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

sync func update_particles():
	if state != "Drifting" && motion != Vector2.ZERO:
		engineparticles.emitting = true
	else:
		engineparticles.emitting = false

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
	var wingspawnpoint
	if altFire == true:
		wingspawnpoint = muzzle1
	elif altFire == false:
		wingspawnpoint = muzzle2
	canFire = false
	if Global.bullet_time == true:
		fireRateBT.start()
	else:
		fireRate.start()
	var bullet = playerBullet.instance()
	add_child(bullet)
	bullet.global_position = wingspawnpoint.global_position
	bullet.velocity = Vector2.RIGHT.rotated(self.rotation) * bullet.speed
	bullet.set_rotation(global_rotation)
	#motion -= bullet.velocity * 5
	
	var muzzleflash = muzzleFlash.instance()
	add_child(muzzleflash)
	muzzleflash.global_position = wingspawnpoint.global_position
	muzzleflash.set_rotation(self.rotation)
	
	altFire = !altFire


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
