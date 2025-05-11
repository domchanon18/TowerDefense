extends PathFollow2D

var speed = 100

func _process(delta):
	offset += speed * delta

