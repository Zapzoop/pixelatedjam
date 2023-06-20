extends Control
class_name volume_slider

var master_bus = AudioServer.get_bus_index("Master")
var sound_fx_bus = AudioServer.get_bus_index("SoundFX")


func _on_Music_value_changed(value):
	set_bus_volume(master_bus, value)


func _on_Soundfx_value_changed(value):
	set_bus_volume(sound_fx_bus, value)


func set_bus_volume(audio_bus, value) -> void:
	AudioServer.set_bus_volume_db(audio_bus, value)
	
	if value == -30:
		AudioServer.set_bus_mute(audio_bus, true)
	else:
		AudioServer.set_bus_mute(audio_bus, false)
