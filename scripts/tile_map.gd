extends TileMap

@export var max_enemies = 15
@export var spawn_radius = 450.0 
@export var spawn_interval = 2.0

var enemy_scenes = []
var player: CharacterBody2D
var timer = 0.0

func _ready():
	GlobalNode.previous_scene_for_gameover = "res://scenes/level_1.tscn"
	create_boundary_walls()
	
	player = get_tree().get_first_node_in_group("player")	
	var all_enemies = get_tree().get_nodes_in_group("enemy")

	for enemy_node in all_enemies:
		if enemy_node:
			var scene_path = enemy_node.scene_file_path
			var loaded_scene = load(scene_path)
			enemy_scenes.append(loaded_scene)

func create_boundary_walls():
	var rect = get_used_rect()
	var tile_size = tile_set.tile_size
	
	var top_left = to_global(Vector2(rect.position.x * tile_size.x, rect.position.y * tile_size.y))
	var bottom_right = to_global(Vector2(rect.end.x * tile_size.x, rect.end.y * tile_size.y))
	
	var L = top_left.x
	var T = top_left.y
	var R = bottom_right.x
	var B = bottom_right.y

	var static_body = StaticBody2D.new()
	static_body.name = "MapBoundaries"
	add_child(static_body)

	var walls = [
		[Vector2(L, T), Vector2(R, T)],
		[Vector2(L, B), Vector2(R, B)],
		[Vector2(L, T), Vector2(L, B)],
		[Vector2(R, T), Vector2(R, B)]
	]

	for wall in walls:
		var collision_shape = CollisionShape2D.new()
		var segment = SegmentShape2D.new()
		segment.a = wall[0] - global_position
		segment.b = wall[1] - global_position
		
		collision_shape.shape = segment
		static_body.add_child(collision_shape)

func _process(delta):
	timer += delta
	if timer >= spawn_interval:
		timer = 0.0
		var current_enemies = get_tree().get_nodes_in_group("enemy").size()
		if current_enemies < max_enemies:
			spawn_enemy_logic()

func spawn_enemy_logic():
	if not player: return

	var valid_position = false
	var spawn_pos = Vector2.ZERO
	var attempts = 0
	
	while not valid_position and attempts < 20:
		var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
		spawn_pos = player.global_position + (random_direction * spawn_radius)
		
		if not is_position_on_screen(spawn_pos):
			if is_tile_walkable(spawn_pos):
				valid_position = true
		
		attempts += 1

	if valid_position:
		var random_scene = enemy_scenes.pick_random()
		var new_enemy = random_scene.instantiate()
		new_enemy.global_position = spawn_pos
		get_parent().add_child(new_enemy)

func is_tile_walkable(world_pos: Vector2) -> bool:
	var map_pos = local_to_map(to_local(world_pos))
	
	var tile_data = get_cell_tile_data(0, map_pos)
	
	if tile_data == null:
		return false

	var je_horlave = tile_data.get_custom_data("horlave")
	return je_horlave == "horlave"

func is_position_on_screen(pos: Vector2) -> bool:
	var canvas = get_canvas_transform()
	var viewport_rect = get_viewport_rect()
	var screen_pos = canvas * pos
	return viewport_rect.has_point(screen_pos)
