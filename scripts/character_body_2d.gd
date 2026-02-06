extends CharacterBody2D

signal health_changed(new_health)

@export var speed = 100.0
@export var consumption_rate = 10.0
@export var ray_length = 150.0
@export var lives = 5
@export var destroyed_enemies = 0

@onready var sprite = $AnimatedSprite2D
@onready var water_particles = $GPUParticles2D
@onready var marker_left = $Marker2DLeft
@onready var marker_right = $Marker2DRight
@onready var marker_up = $Marker2DUp
@onready var marker_down = $Marker2DDown
@onready var shape_collision = $ShapeCast2D
@onready var stock_bar = $"../CanvasLayer/stock_bar"

var current_material = "water"
var stocks = {"foam": 100.0, "sand": 100.0, "water": 100.0}
var colors = {"foam": Color.WHITE, "sand": Color.YELLOW, "water": Color("45c0fc"), "fire": Color.RED}
var mapa: TileMap 
var second_ovladanie = false
var last_button_state = 0

func _ready():
	await get_tree().process_frame
	emit_signal("health_changed", lives)
	var najdene_mapy = get_tree().get_nodes_in_group("level")
	if najdene_mapy.size() > 0:
		mapa = najdene_mapy[0]
	else:
		push_warning("Pozor! V scéne sa nenašiel žiaden TileMap.")

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if second_ovladanie:
		direction = Input.get_vector("second_move_left", "second_move_right", "second_move_up", "second_move_down")
	velocity = direction * speed
	move_and_slide()

	var mouse_pos = get_global_mouse_position()
	var look_direction = (mouse_pos - global_position).normalized()

	update_animations(look_direction)
	handle_material_input()

	if Input.is_key_pressed(KEY_SPACE) and mapa:
		var local_pos = mapa.to_local(global_position)
		var map_pos: Vector2i = mapa.local_to_map(local_pos)
		var tile_data = mapa.get_cell_tile_data(0, map_pos)
		if tile_data:
			var typ = tile_data.get_custom_data("okraj_vody")
			if typ == "okraj_vody" and stocks["water"] < 100.0:
				stocks["water"] = min(stocks["water"] + 1.0, 100.0)
			typ = tile_data.get_custom_data("voda")
			if typ == "voda" and stocks["water"] < 100.0:
				stocks["water"] = min(stocks["water"] + 1.0, 100.0)
			typ = tile_data.get_custom_data("sneh")
			if typ == "sneh" and stocks["foam"] < 100.0:
				stocks["foam"] = min(stocks["foam"] + 0.5, 100.0)
			typ = tile_data.get_custom_data("piesok")
			if typ == "piesok" and stocks["sand"] < 100.0:
				stocks["sand"] = min(stocks["sand"] + 1.0, 100.0)

	var is_trying_to_spray = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	var actual_stock = 100
	if current_material != "fire":
		actual_stock = stocks[current_material]
	if is_trying_to_spray and actual_stock > 0:
		water_particles.emitting = true
		
		if last_button_state != is_trying_to_spray and is_trying_to_spray:
			$"../AudioStreamPlayer".play()

		if last_button_state != is_trying_to_spray and get_tree().current_scene.scene_file_path.get_file() == "level_2.tscn" and current_material != "fire" and randi() % 8 == 0:
			current_material = "fire"
		
		if current_material == "foam":
			stocks[current_material] -= consumption_rate * delta * 5
		elif current_material != "fire":
			stocks[current_material] -= consumption_rate * delta

		for i in range(shape_collision.get_collision_count()):
			var collider = shape_collision.get_collider(i)
			if collider and collider.has_method("add_wetness"):
				collider.add_wetness(delta, current_material)
	else:
		water_particles.emitting = false
	
	last_button_state = is_trying_to_spray

	water_particles.set_deferred("emitter_velocity", Vector3(velocity.x, velocity.y, 0))

func take_damage():
	print("damage")
	lives -= 1
	emit_signal("health_changed", lives)

	if lives <= 0:
		die()

func die():
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	sprite.play("die")
	await sprite.animation_finished
	print("Game Over")
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func handle_material_input():
	var particle_material = water_particles.process_material as ParticleProcessMaterial
	if Input.is_key_pressed(KEY_2): current_material = "water"
	elif Input.is_key_pressed(KEY_3): current_material = "sand"
	elif Input.is_key_pressed(KEY_4): current_material = "foam"
	
	particle_material.color = colors[current_material]
	if current_material != "fire":
		stock_bar.value = stocks[current_material]
	stock_bar.modulate = colors[current_material]

func update_animations(look_dir):
	var particle_material = water_particles.process_material as ParticleProcessMaterial
	
	if abs(look_dir.x) > abs(look_dir.y):
		if look_dir.x > 0: # VPRAVO
			sprite.play("right")
			particle_material.direction = Vector3(1, 0, 0)
			water_particles.global_position = marker_right.global_position
			water_particles.z_index = 0
			shape_collision.target_position = Vector2(ray_length, 0)
		else: # VĽAVO
			sprite.play("left")
			particle_material.direction = Vector3(-1, 0, 0)
			water_particles.global_position = marker_left.global_position
			water_particles.z_index = 0
			shape_collision.target_position = Vector2(-ray_length, 0)
	else:
		if look_dir.y > 0: # DOLE
			sprite.play("down")
			particle_material.direction = Vector3(0, 1, 0)
			water_particles.global_position = marker_down.global_position
			water_particles.z_index = 1
			shape_collision.target_position = Vector2(0, ray_length)
		else: # HORE
			sprite.play("up")
			particle_material.direction = Vector3(0, -1, 0)
			water_particles.global_position = marker_up.global_position
			water_particles.z_index = -1
			shape_collision.target_position = Vector2(0, -ray_length)

	shape_collision.global_position = water_particles.global_position

func enemy_destroyed():
	destroyed_enemies += 1
	$"../CanvasLayer/EnemiesDestroyed".text = str(destroyed_enemies)
	if get_tree().current_scene.scene_file_path.get_file() == "level_1.tscn" and destroyed_enemies == 1:
		$"../../CanvasLayer/Surtr".start_sequence()

func enemy_revived():
	if destroyed_enemies > 0:
		destroyed_enemies -= 1
		$"../CanvasLayer/EnemiesDestroyed".text = str(destroyed_enemies)
