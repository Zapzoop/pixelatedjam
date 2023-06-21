extends Control
export(String, FILE) var main_scene_path

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	$AnimatedSprite.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button2_pressed():
	get_tree().change_scene("res://UI/main_menu/MainMenu.tscn")

func _on_Button_pressed():
	$"/root/SaveSystem".load_file()
	get_tree().change_scene(main_scene_path)
	Signalbus.emit_signal("load_scene")
