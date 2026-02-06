extends Path2D

@onready var follow = $PathFollow2D
@export var speed = 20.0
@export var active = false

func _process(delta):
	if not active:
		return

	follow.progress += speed * delta
