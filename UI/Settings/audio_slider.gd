extends VBoxContainer
class_name audio_slider

var music_bus = AudioServer.get_bus_index("Music")
var sound_fx_bus = AudioServer.get_bus_index("SoundFX")


func _on_MusicSlider_value_changed(value):
	set_bus_volume(music_bus, value)


func _on_SoundFxSlider_value_changed(value):
	set_bus_volume(sound_fx_bus, value)


func set_bus_volume(audio_bus, value) -> void:
	AudioServer.set_bus_volume_db(audio_bus, value)
	
	if value == -30:
		AudioServer.set_bus_mute(audio_bus, true)
	else:
		AudioServer.set_bus_mute(audio_bus, false)
