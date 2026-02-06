extends Node2D

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ENTER):
		get_tree().change_scene_to_file("res://scenes/level_1.tscn")
