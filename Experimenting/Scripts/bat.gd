extends CharacterBody2D
class_name BatEnemy

@onready var animated_sprite = $AnimatedSprite2D

const speed = 20
var dir : Vector2
var is_bat_chase : bool
var player : CharacterBody2D

var health = 10
var max_health = 10
var min_health = 0
var dead = false
var taking_damage = false
var is_roaming : bool

var damage_to_deal = 20

func _ready():
	is_bat_chase = true

func _process(delta):
	Global.batDamageAmount = damage_to_deal
	Global.batDamageZone = $BatDamageZone
	if Global.player_alive:
		is_bat_chase = true
	elif !Global.player_alive:
		is_bat_chase = false
		
	move(delta)
	handle_animation()
	if is_on_floor() and dead:
		await get_tree().create_timer(3.0).timeout
		self.queue_free()

func move(delta):
	player = Global.playerBody
	if !dead:
		is_roaming = true
		if !taking_damage and is_bat_chase and Global.player_alive:
			velocity = position.direction_to(player.position) * speed
			dir.x = abs(velocity.x)/ velocity.x
		elif taking_damage:
			var knockback_dir = position.direction_to(player.position) * -20
			velocity = knockback_dir
		elif !taking_damage:
			velocity += speed * dir * delta
	elif dead and !is_on_floor():
		damage_to_deal = 0
		velocity.y += 50 * delta
	elif dead and is_on_floor():
		damage_to_deal = 0
		velocity.x = move_toward(velocity.x, 0, 0.2)
	move_and_slide()

func _on_timer_timeout():
	$Timer.wait_time = choose([0.5,0.8])
	if !is_bat_chase:
		dir = choose([Vector2.RIGHT,Vector2.UP,Vector2.LEFT,Vector2.DOWN])

func handle_animation():
	if !dead and !taking_damage:
		animated_sprite.play("fly")
		if dir.x == -1:
			animated_sprite.flip_h = true
		elif dir.x == 1:
			animated_sprite.flip_h = false
	if !dead and taking_damage:
		animated_sprite.play("hurt")
		await get_tree().create_timer(0.8).timeout
		taking_damage = false
	elif dead and is_roaming:
		is_roaming = false
		animated_sprite.play("death")
		set_collision_layer_value(2,true)
		set_collision_layer_value(3,false)
		set_collision_mask_value(2,true)
		set_collision_mask_value(3,false)

func choose(array):
	array.shuffle()
	return array.front()


func _on_bat_hitbox_area_entered(area):
	if !dead:
		if area == Global.playerDamageZone:
			var damage = Global.playerDamageAmount
			take_damage(damage)

func take_damage(damage):
	health -= damage
	taking_damage = true
	if health <= 0:
		health = 0
		dead = true
		
