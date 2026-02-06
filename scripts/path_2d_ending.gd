extends Path2D

func _process(delta: float) -> void:
	$PathFollow2D.progress += 70.0 * delta
	if $PathFollow2D.progress_ratio == 1.0:
		ukonc_a_odovzdaj()

func ukonc_a_odovzdaj():
	$"../Path2D2".active = true
