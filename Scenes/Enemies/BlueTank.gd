extends PathFollow2D

var speed = 130
var maxhp = 50
var hp = 50
var is_dead = false

onready var health_bar = $HealthBar
onready var impact_area = $Impact
var projectile_impact = preload("res://Scenes/SupportScenes/ProjectileImpact.tscn")

func _ready():
	health_bar.max_value = maxhp
	health_bar.value = hp

func _physics_process(delta):
	if not is_dead:
		offset += speed * delta

func on_hit(damage):
	if is_dead:
		return

	impact()
	hp -= damage
	health_bar.value = hp
	
	if hp <= 0:
		is_dead = true
		on_destroy()

func impact():
	randomize()
	var x_pos = randi() % 31
	var y_pos = randi() % 31
	var impact_location = Vector2(x_pos, y_pos)
	var new_impact = projectile_impact.instance()
	new_impact.position = impact_location
	impact_area.add_child(new_impact)

func on_destroy():
	GameData.add_money(10)
	GameData.enemy_changed(1)

	var explosion = load("res://Scenes/Enemies/explode.tscn").instance()
	explosion.global_position = global_position
	get_tree().get_root().add_child(explosion)

	yield(get_tree().create_timer(0.2), "timeout")
	explosion.queue_free()
	queue_free()
