extends Node2D

export(String, FILE) var main_scene_path
onready var fader = get_node("%Fader")

func _ready() -> void:
	fader.fade_screen(false)

func _on_play() -> void:
	fader.fade_screen(true, "_go_to_main_scene", self)

func _on_quit() -> void:
	fader.fade_screen(true, "quit", get_tree())

func _go_to_main_scene():
	get_tree().change_scene(main_scene_path)
