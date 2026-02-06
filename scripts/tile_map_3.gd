extends TileMap

func _ready():
	GlobalNode.previous_scene_for_gameover = "res://scenes/level_3.tscn"
	create_boundary_walls()

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
