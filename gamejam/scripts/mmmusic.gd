extends AudioStreamPlayer
func _ready():
	var music_file = load("res://assets/les.mp3")
	
	if music_file:
		self.stream = music_file
		self.bus = "Music"
		
		var audio_settings = ConfigFileHandler.load_audio()
		
		# Apply Music Volume
		var music_vol = audio_settings.get("music_volume", 1.0)
		var music_bus_idx = AudioServer.get_bus_index("Music")
		if music_bus_idx != -1:
			AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(music_vol))
			
		var sfx_vol = audio_settings.get("sfx_volume", 1.0)
		var sfx_bus_idx = AudioServer.get_bus_index("SFX")
		if sfx_bus_idx != -1:
			AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(sfx_vol))

		self.play()
		print("Music started successfully at volume: ", music_vol)
	else:
		print("Error: Could not find the music file at the specified path.")
	
