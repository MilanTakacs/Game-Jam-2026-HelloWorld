extends TileMap

@export var max_enemies = 20
@export var spawn_interval = 1.0

var enemy_scenes = []
var player: CharacterBody2D
var timer = 0.0
var station_tiles = []

func _ready():
	GlobalNode.previous_scene_for_gameover = "res://scenes/level_2.tscn"
	create_boundary_walls()
	
	player = get_tree().get_first_node_in_group("player")
	update_station_tile_list()
	
	var all_enemies = get_tree().get_nodes_in_group("enemy")
	for enemy_node in all_enemies:
		if enemy_node:
			enemy_scenes.append(load(enemy_node.scene_file_path))

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

func update_station_tile_list():
	station_tiles.clear()
	
	var layer = 0
	var used_cells = get_used_cells(layer)
	
	for cell_pos in used_cells:
		var global_tile_pos = to_global(map_to_local(cell_pos))
		station_tiles.append(global_tile_pos)
		
func _process(delta):
	timer += delta
	if timer >= spawn_interval:
		timer = 0.0
		if get_tree().get_nodes_in_group("enemy").size() < max_enemies:
			spawn_enemy_logic()

func spawn_enemy_logic():
	if not player or enemy_scenes.is_empty() or station_tiles.is_empty(): 
		return

	var final_pos = Vector2.ZERO
	var found_valid_spot = false
	
	for i in range(15):
		var random_tile = station_tiles.pick_random()
		
		if not is_position_on_screen(random_tile):
			final_pos = random_tile
			found_valid_spot = true
			break

	if found_valid_spot:
		var enemy_scene = enemy_scenes.pick_random()
		if enemy_scene:
			var new_enemy = enemy_scene.instantiate()
			new_enemy.global_position = final_pos
			new_enemy.add_to_group("enemy")
			get_parent().add_child(new_enemy)

func is_position_on_screen(pos: Vector2) -> bool:
	var canvas = get_canvas_transform()
	var viewport_rect = get_viewport_rect()
	var screen_pos = canvas * pos
	
	var buffer = 50.0
	var expanded_rect = viewport_rect.grow(buffer)
	
	return expanded_rect.has_point(screen_pos)
