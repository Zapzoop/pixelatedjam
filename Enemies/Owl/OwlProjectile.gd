extends Area2D

export var damage: int = 1.0
export var speed: float = 15.0
var dir: Vector2

func _ready() -> void:
	yield(get_tree(), "idle_frame")
	
	var timer = Timer.new()
	add_child(timer)
	
	timer.start(1.0)
	yield(timer, "timeout")
	
	queue_free()

func _physics_process(delta: float) -> void:
	position += dir * speed

func set_projectile_position(position: Vector2, dir: Vector2) -> void:
	self.position = position + dir * 0.5
	self.dir = dir
