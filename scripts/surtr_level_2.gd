extends AnimatedSprite2D

var queue = ["dialog3"]
var current_step = 0
var active = false

func _ready():
	hide()

func start_sequence():
	active = true
	get_tree().paused = true
	show()
	current_step = 0
	_play_current()

func _play_current():
	play(queue[current_step])

func _unhandled_input(event):
	if not active:
		return
		
	if event.is_action_pressed("ui_accept"):
		current_step += 1
		
		if current_step < queue.size():
			_play_current()
		else:
			finish_sequence()

func finish_sequence():
	active = false
	$"../../FireExtinguisher/Player".second_ovladanie = false
	get_tree().paused = false
	queue_free()
