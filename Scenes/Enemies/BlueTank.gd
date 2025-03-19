extends PathFollow2D

var speed = 150
var hp = 50

##onready var health_bar = get_node("HealthBar")
onready var impact_area = get_node("Impact")
var projectile_impact = preload("res://Scenes/SupportScenes/ProjectileImpact.tscn")

func _physics_process(delta):
	move(delta)

func move(delta):
	set_offset(get_offset() + speed * delta)

func on_hit(damage):
	impact()
	hp -= damage
	if hp <= 0:
		on_destroy()

func impact():
	randomize()
	var x_pos = randi() % 31
	randomize()
	var y_pos = randi() % 31
	var impact_location = Vector2(x_pos,y_pos)
	var new_impact = projectile_impact.instance()
	new_impact.position = impact_location
	impact_area.add_child(new_impact)

func on_destroy():
	self.queue_free()
