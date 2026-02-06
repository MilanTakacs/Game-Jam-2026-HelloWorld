extends CharacterBody2D

@export var transform_threshold = 15.0
@export var explosion_time = 10.0
@export var speed = 35.0

var current_wetness = 0.0
var is_good = false
var player = null

@onready var sprite = $AnimatedSprite2D

func _ready():
	var timer = Timer.new()
	timer.wait_time = explosion_time
	timer.one_shot = true
	timer.autostart = true
	add_child(timer)
	timer.timeout.connect(_on_explosion_timer_timeout)

func _on_explosion_timer_timeout():
	if not is_good:
		explode()

func explode():
	sprite.play("explosion")
	$Area2D.scale = Vector2(3.0, 2.0)
	await sprite.animation_finished
	queue_free()

func add_wetness(delta, type):
	if not is_good and type == "foam":
		current_wetness += 10.0 * delta
		if current_wetness >= transform_threshold:
			become_good()
	elif is_good and type == "fire":
		if player:
			player.enemy_revived()
		is_good = false
		current_wetness = 0
		sprite.play("run")

func become_good():
	if player:
		player.enemy_destroyed()
	is_good = true
	current_wetness = 0
	sprite.play("good")

func _physics_process(_delta):
	if player == null:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]
	
	if player and not is_good:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not is_good and body.name == "Player":
		become_good()
		if body.has_method("take_damage"):
			body.take_damage()
