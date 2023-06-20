extends ColorRect

var fade_tween: SceneTreeTween = null

func _ready() -> void:
	self.visible = false

func fade_screen(fade_to_black: bool, callback: String = "", callback_target: Object = self) -> void:
	self.visible = true
	
	var colour = self.modulate
	colour.a = 1.0 if fade_to_black else 0.0
	
	if is_instance_valid(fade_tween) && fade_tween.is_running():
		fade_tween.stop()
	
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate", colour, 1.0)
	
	if callback.empty():
		return
	
	fade_tween.tween_callback(callback_target, callback)
