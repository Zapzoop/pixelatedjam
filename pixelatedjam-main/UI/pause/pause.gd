extends Control

export(String, FILE) var main_menu_path
var is_paused = false

onready var option: = get_node("PauseOptionCotainer")
onready var audio_setting: = get_node("AudioSettingContainer")

func _input(event):
	if event.is_action_pressed("pause") and is_paused == false:
		get_tree().paused = true
		is_paused = true
		self.visible = true
	elif event.is_action_pressed("pause") and is_paused:
		toggle_audio_option(false)
		get_tree().paused = false
		is_paused = false
		self.visible = false

func _on_Resume_pressed():
	if is_paused:
		get_tree().paused = false
		self.visible = false
		is_paused = false


func _on_Back_pressed(): #Change scene to main menu
	var tree = get_tree()
	
	tree.paused = false
	tree.change_scene(main_menu_path)


func _on_Audio_pressed():
	toggle_audio_option(true)


func _on_audio_back_pressed():
	toggle_audio_option(false)

func toggle_audio_option(value: bool) -> void:
	audio_setting.visible = value
	option.visible = not value
