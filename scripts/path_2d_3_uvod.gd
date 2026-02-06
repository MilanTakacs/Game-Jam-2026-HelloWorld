extends Path2D

@onready var follow = $PathFollow2D
@export var speed = 100.0
@export var active = false

func _process(delta):
	if not active:
		return

	follow.progress += speed * delta

	if follow.progress_ratio >= 0.9:
		stop_path()

func stop_path():
	active = false
