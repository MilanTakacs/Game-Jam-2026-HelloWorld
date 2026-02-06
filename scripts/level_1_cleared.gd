extends Control

func _ready() -> void:
	get_tree().paused = false
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/level_2.tscn")
 
