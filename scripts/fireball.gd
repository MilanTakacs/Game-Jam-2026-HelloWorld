extends CharacterBody2D

@export var transform_threshold = 10.0
@export var speed = 80.0
@export var lifetime = 5.0

var current_wetness = 0.0
var player = null

@onready var sprite = $AnimatedSprite2D

func _ready():
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func add_wetness(delta, type):
	if type == "sand":
		current_wetness += 10.0 * delta 
		if current_wetness >= transform_threshold:
			queue_free()

func _physics_process(_delta):
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if player and player.has_method("enemy_destroyed"):
			player.enemy_destroyed()
		if body.has_method("take_damage"):
			body.take_damage()
		queue_free()
