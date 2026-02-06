extends CharacterBody2D

@export var transform_threshold = 100.0  # Koľko "piesku" potrebuje na zmenu
@export var speed = 45.0
# Prednačítame scénu fireballu, aby sme ju mohli vytvárať (inštancovať)
@export var fireball_scene: PackedScene = preload("res://scenes/fireball.tscn")
# Nastavenia pre náhodné časovanie (sekundy)
@export var min_fire_delay = 3.0
@export var max_fire_delay = 7.0
var current_wetness = 0.0

@onready var nav_agent = $NavigationAgent2D

var player = null

func _ready():
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	call_deferred("setup_navigation")
	start_fireball_timer()

func add_wetness(delta, type):
	if type == "sand":
		current_wetness += 10.0 * delta 
		print(current_wetness)
		if current_wetness >= transform_threshold:
			get_tree().change_scene_to_file("res://scenes/level_4.tscn")

func setup_navigation():
	find_player()

func find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func start_fireball_timer():
	var wait_time = randf_range(min_fire_delay, max_fire_delay)
	get_tree().create_timer(wait_time).timeout.connect(shoot_fireball)

func shoot_fireball():
	if fireball_scene:
		var fireball = fireball_scene.instantiate()
		fireball.global_position = global_position
		get_tree().current_scene.add_child(fireball)

	start_fireball_timer()

func _physics_process(_delta):
	if player == null:
		find_player()
		return

	nav_agent.target_position = player.global_position
	
	if nav_agent.is_navigation_finished():
		return

	var current_pos = global_position
	var next_path_pos = nav_agent.get_next_path_position()
	var direction = (next_path_pos - current_pos).normalized()
	
	velocity = direction * speed
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if body.has_method("take_damage"):
			body.take_damage()
