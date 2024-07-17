extends CharacterBody2D


@export var ghost_node : PackedScene
@onready var ghost_timer = $GhostTimer
@onready var dust = preload("res://Scenes/LandingParticles.tscn")
@onready var dash_time = $DashTime
@onready var dash_cooldown = $DashCooldown
@onready var dash_particles = $GPUParticles2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var damage_zone = $DamageZone

var limit_speed_y = 1200
var speed = 200

var jump_velocity = -300.0
var is_grounded = false

var axis = Vector2()

var dash_speed = 30000
var is_dashing = false
var can_dash = false
var just_dashed = false

var health = 100
var max_health = 100
var min_health = 0
var can_take_damage : bool
var dead : bool

var attack_type : String
var currently_attacking : bool

var gravity = 900

func _ready():
	Global.playerBody = self
	currently_attacking = false
	dead = false
	can_take_damage = true
	Global.player_alive = true

func _physics_process(delta):
	Global.playerDamageZone = damage_zone
	var direction = Input.get_axis("ui_left", "ui_right")
	get_input_axis()
	gravity_logic(delta)
	if !dead:
		jump_logic()
		dash(delta)
		if direction and !is_dashing:
			velocity.x = move_toward(velocity.x, direction * speed,15)
		else:
			velocity.x = move_toward(velocity.x, 0, 15)
	
		if !just_dashed:
			if !currently_attacking:
				if Input.is_action_just_pressed("Attack"):
					currently_attacking = true
					print("attacking!")
					if Input.is_action_just_pressed("Attack") and is_on_floor():
						attack_type = "ground_attack"
					else:
						attack_type = "air_attack"
					set_damage(attack_type)
					handle_attack_animation(attack_type)
		animation_logic(direction)
		check_hitbox()
	else: velocity.x *= 0.4
	move_and_slide()

func check_hitbox():
	var hitbox_areas = $Hurtbox.get_overlapping_areas()
	var damage : int
	if hitbox_areas:
		var hitbox = hitbox_areas.front()
		if hitbox.get_parent() is BatEnemy:
				damage = Global.batDamageAmount
			
	if can_take_damage:
		take_damage(damage)
		
func take_damage(damage):
	if damage != 0:
		if health > 0:
			health -= damage
			print("Player Health: ", health)
		if health <= 0:
			health = 0
			dead = true
			Global.player_alive = false
			handle_death_animation()
		take_damage_cooldown(1.0)
	
func handle_death_animation():
	animated_sprite.play("DeathAni")
	await get_tree().create_timer(0.2).timeout
	$Camera2D.zoom.x = 4.5
	$Camera2D.zoom.y = 4.5
	await get_tree().create_timer(3.5).timeout
	self.queue_free()
	
func take_damage_cooldown(wait_time):
	can_take_damage = false
	await get_tree().create_timer(wait_time).timeout
	can_take_damage = true

func dash(delta):
	if !currently_attacking:
		if !can_dash and is_on_floor():
			can_dash = true
		if can_dash and dash_cooldown.time_left <= 0:
			if Input.is_action_just_pressed("Dash"):
				ghost_timer.start()
				velocity = Vector2.ZERO
				dash_time.start()
				dash_cooldown.start()
				is_dashing = true
				can_dash = false
				just_dashed = true
				#experimenting with how much distance going either only using x or y 
				if axis.y and !axis.x:
					velocity.y = axis.y * dash_speed * 0.8 * delta
				elif axis.x and !axis.y:
					velocity.x = axis.x * dash_speed * 1.1 * delta
				#regular dash logic
				else:
					velocity.x = axis.x * dash_speed * 1.3 * delta
					velocity.y = axis.y * dash_speed * 0.85 * delta
		#pretty lights
		if is_dashing:
			dash_particles.emitting = true
		else: dash_particles.emitting = false

func get_input_axis():
	axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	axis = axis.normalized()
	
	if axis == Vector2.ZERO:
		if animated_sprite.flip_h:
			axis.x = -1
		else:
			axis.x = 1

func jump_logic():
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		if !is_dashing:
			velocity.y = jump_velocity

func gravity_logic(delta):
	if velocity.y <= limit_speed_y:
		if !is_dashing:
			velocity.y += gravity * delta
			
	#landing particles and animation
	if is_grounded == false and is_on_floor():
		var instance = dust.instantiate()
		instance.global_position = $Marker2D.global_position
		get_parent().add_child(instance)
	is_grounded = is_on_floor()

func animation_logic(direction):
	#flips sprite and hitbox to direction 
	if !just_dashed:
		if direction > 0:
			animated_sprite.flip_h = false
			damage_zone.scale.x = 1
		elif direction < 0:
			animated_sprite.flip_h = true
			damage_zone.scale.x = -1
	#checks what animations we're currently in
	if !just_dashed:
		if is_on_floor() and !currently_attacking:
			if direction == 0:
				animated_sprite.play("IdleAni")
			elif direction:
				animated_sprite.play("RunAni")
		else:
			if !currently_attacking:
				if velocity.y >= 0:
					animated_sprite.play("ContinuousFallAni")
				elif velocity.y <= 0:
					animated_sprite.play("JumpAni")
	else: 
		if is_on_floor():
			animated_sprite.play("DashAni")
		else:
			animated_sprite.play("AirDashAni")

func _on_dash_time_timeout():
	is_dashing = false
	ghost_timer.stop()
	dash_particles.emitting = false
	if velocity.length() >= speed:
		velocity.x *= 0.45
		velocity.y *= 0.23
	

func _on_dash_cooldown_timeout():
	just_dashed = false

func add_ghost():
	var ghost = ghost_node.instantiate()
	ghost.set_property(position,animated_sprite.scale)
	get_tree().current_scene.add_child(ghost)
	if axis.x > 0:
		ghost.flip_h = false
	elif axis.x < 0:
		ghost.flip_h = true
	if axis.y and !axis.x:
		if animated_sprite.flip_h:
			ghost.flip_h = true
		else:
			ghost.flip_h = false
	
func _on_ghost_timer_timeout():
	add_ghost()

func handle_attack_animation(attack_type):
	if currently_attacking:
		if is_on_floor():
			animated_sprite.play("AttackAni")
			toggle_damage_collisions(attack_type)
		else: 
			animated_sprite.play("AirAttackAni")
			toggle_damage_collisions(attack_type)

func toggle_damage_collisions(attack_type):
	var damage_zone_collision = damage_zone.get_node("CollisionShape2D")
	var wait_time : float
	if attack_type == "air_attack":
		wait_time = 0.3
	elif attack_type == "ground_attack":
		wait_time = 0.4
	damage_zone_collision.disabled = false
	await get_tree().create_timer(wait_time).timeout
	damage_zone_collision.disabled = true

func _on_animated_sprite_2d_animation_finished():
	currently_attacking = false

func set_damage(attack_type):
	var current_damage_to_deal :int
	if attack_type == "ground_attack":
		current_damage_to_deal = 10
	elif attack_type == "air_attack":
		current_damage_to_deal = 10
	Global.playerDamageAmount = current_damage_to_deal
