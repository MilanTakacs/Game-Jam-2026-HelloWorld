extends Camera2D

func _ready():
	# Počkáme jeden frame, aby sa celá scéna levelu stihla načítať
	await get_tree().process_frame
	
	# Hľadáme TileMap alebo TileMapLayer
	var map = get_tree().current_scene.find_child("TileMap", true, false)

	if map:
		var map_rect = map.get_used_rect()
		var tile_size = map.tile_set.tile_size
		var world_pos = map.global_position # Pozícia mapy v rámci levelu
		var map_scale = map.scale # Ak si mapu v leveli zväčšoval cez Scale
		
		# Výpočet limitov: (Pozícia dlaždice * veľkosť * mierka) + globálny posun mapy
		limit_left = int((map_rect.position.x * tile_size.x * map_scale.x) + world_pos.x)
		limit_top = int((map_rect.position.y * tile_size.y * map_scale.y) + world_pos.y)
		limit_right = int((map_rect.end.x * tile_size.x * map_scale.x) + world_pos.x)
		limit_bottom = int((map_rect.end.y * tile_size.y * map_scale.y) + world_pos.y)
