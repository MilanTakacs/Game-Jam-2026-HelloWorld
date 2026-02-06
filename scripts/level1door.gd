extends Area2D

@onready var fade_rect = $"../CanvasLayer/FadeRect"

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	var players = get_tree().get_nodes_in_group("player")
	
	if players.size() > 0 and body == players[0]:
		if players[0].destroyed_enemies >= 5:
			trigger_transition()
		else:
			players[0].get_parent().get_node("CanvasLayer").get_node("Message").text = "Potrebuješ uhasiť aspoň 5 nepriateľov"

func trigger_transition():
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0
	fade_rect.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fade_rect, "modulate:a", 1.0, 1.0)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/level_1_cleared.tscn")
