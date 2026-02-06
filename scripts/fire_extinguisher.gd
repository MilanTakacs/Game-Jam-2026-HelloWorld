extends Node2D


func _ready() -> void:
	$Player.health_changed.connect($CanvasLayer/HeartsContainer.update_hearts)
	$CanvasLayer/HeartsContainer.update_hearts($Player.lives)
