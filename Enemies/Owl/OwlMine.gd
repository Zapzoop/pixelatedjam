extends StaticBody2D

export var pkg_projectile: PackedScene
onready var sprite = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var scale = self.scale
	self.scale = Vector2.ZERO
	
	var tween = create_tween()
	tween.tween_property(self, "scale", scale, 0.35)
	tween.tween_callback(self, "_setup")

func _setup() -> void:
	var timer = Timer.new()
	add_child(timer)
	
	timer.start(1.5)
	yield(timer, "timeout")
	
	for dir in [Vector2.UP, Vector2.RIGHT]:
		_spawn_projectile(dir)
		_spawn_projectile(-dir)
	
	var hitbox = $Hitbox
	hitbox.monitoring = true
	hitbox.monitorable = true
	
	sprite.play()
	yield(sprite, "animation_finished")
	
	queue_free()

func _spawn_projectile(dir: Vector2) -> void:
	var projectile = pkg_projectile.instance()
	get_tree().current_scene.add_child(projectile)
	
	projectile.set_projectile_position(global_position, dir)
