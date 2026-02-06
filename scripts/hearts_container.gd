extends HBoxContainer

@onready var full_heart = preload("res://assets/fullHeart.webp")
@onready var empty_heart = preload("res://assets/emptyHeart.webp")

func update_hearts(current_health: int):
	for child in get_children():
		child.queue_free()
	
	for i in range(current_health):
		var heart = TextureRect.new()
		heart.texture = full_heart
		heart.custom_minimum_size = Vector2(32, 32)
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		add_child(heart)

	for i in range(current_health, 5):
		var heart = TextureRect.new()
		heart.texture = empty_heart
		heart.custom_minimum_size = Vector2(32, 32)
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		add_child(heart)
