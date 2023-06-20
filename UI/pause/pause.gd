extends Control

export(String, FILE) var main_menu_path
var is_paused = false

func _input(event):
	if event.is_action_pressed("pause") and is_paused == false:
		get_tree().paused = true
		is_paused = true
		self.visible = true
	elif event.is_action_pressed("pause") and is_paused:
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
