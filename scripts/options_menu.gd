extends Control

@onready var music_slider: HSlider = $GridContainer/MusicSlider
@onready var sfx_slider: HSlider = $GridContainer/SFXSlider

func _ready() -> void:
	var audio_settings = ConfigFileHandler.load_audio()
	

	music_slider.set_value_no_signal(min(audio_settings.music_volume, 1.0) * 100)
	sfx_slider.set_value_no_signal(min(audio_settings.sfx_volume, 1.0) * 100)


func update_bus_volume(bus_name: String, value: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		var volume_db = linear_to_db(value / 100.0)
		AudioServer.set_bus_volume_db(bus_index, volume_db)



func _on_music_slider_value_changed(value: float) -> void:
	update_bus_volume("Music", value)
	ConfigFileHandler.save_audio("music_volume", value / 100.0)


func _on_sfx_slider_value_changed(value: float) -> void:
	update_bus_volume("SFX", value)
	ConfigFileHandler.save_audio("sfx_volume", value / 100.0)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
