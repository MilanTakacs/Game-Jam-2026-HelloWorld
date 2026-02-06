extends Path2D

@onready var follow = $PathFollow2D
@onready var sprite = $PathFollow2D/AnimatedSprite2D

@export var rychlost = 100.0
@onready var druha_cesta = $"../Path2D2"
@onready var tretia_cesta = $"../Path2D3"

var uz_skoncilo = false

func _process(delta):
	if uz_skoncilo:
		return

	follow.progress += rychlost * delta

	if follow.progress_ratio >= 0.9:
		ukonc_a_odovzdaj()

func ukonc_a_odovzdaj():
	uz_skoncilo = true
	sprite.visible = false

	druha_cesta.active = true
	tretia_cesta.active = true
