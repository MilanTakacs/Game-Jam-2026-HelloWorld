extends CharacterBody2D

@export var transform_threshold = 25.0

var current_wetness = 0.0
var is_good = false

@onready var sprite = $AnimatedSprite2D

func add_wetness(delta, type):
	if not is_good and type == "water":
		current_wetness += 10.0 * delta
		if current_wetness >= transform_threshold:
			if player:
				player.enemy_destroyed()
			is_good = true
			current_wetness = 0
			sprite.play("good")

@export var speed = 35.0
var player = null

func _physics_process(_delta):
	player = get_tree().get_nodes_in_group("player")[0]
	
	if player and not is_good:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not is_good and body.name == "Player":
		if player:
				player.enemy_destroyed()
		is_good = true
		current_wetness = 0
		sprite.play("good")
		body.take_damage()
