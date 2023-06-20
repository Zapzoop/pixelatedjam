extends Camera2D

export var displace_amount: float = 100.0
export var noise: OpenSimplexNoise

var t: float = 0.0
onready var original_pos := position

func _process(delta: float) -> void:
	t += delta
	
	var displacement = Vector2(
		noise.get_noise_1d(t),
		noise.get_noise_1d(t + 10.0)
	)
	
	position = original_pos + displacement * displace_amount
	
