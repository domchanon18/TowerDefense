extends Node2D

var type
var category
var enemy_array = []
var built = false
var enemy
var ready = true
var tile_position = Vector2()  # For blockade position tracking

func _ready():
	if built:
		# Only configure range if this tower type has one
		if "range" in GameData.tower_data[type]:
			var range_node = get_node_or_null("Range")
			if range_node:
				var collision_shape = range_node.get_node_or_null("CollisionShape2D")
				if collision_shape and collision_shape.get_shape():
					collision_shape.get_shape().radius = 0.5 * GameData.tower_data[type]["range"]
		
		# Special initialization for blockades
		if category == "placement":
			initialize_blockade()

func initialize_blockade():
	# Get TileMap reference safely
	var tilemap = get_node_or_null("/root/SceneHandler/GamesScene/Map1/TowerExclusion")
	if not tilemap:
		push_error("TileMap not found for blockade initialization")
		return
	
	# Convert position to tile coordinates
	tile_position = tilemap.world_to_map(global_position)
	
	# Register with pathfinding system
	if tilemap.has_method("block_cell"):
		tilemap.block_cell(tile_position)
	else:
		push_error("TileMap missing block_cell method")
	
	# Disable attack range if exists
	var range_collision = get_node_or_null("Range/CollisionShape2D")
	if range_collision:
		range_collision.disabled = true

func _physics_process(delta):
	if category != "placement":  # Skip targeting for blockades
		if enemy_array.size() != 0 and built:
			select_enemy()
			turn()
			if ready:
				fire()
		else:
			enemy = null

func turn():
	if category != "placement" and enemy:  # Blockades don't turn
		get_node("Turret").look_at(enemy.position)

func select_enemy():
	if category != "placement":  # Blockades don't select enemies
		var enemy_progress_array = []
		for i in enemy_array:
			enemy_progress_array.append(i.offset)
		var max_offset = enemy_progress_array.max()
		var enemy_index = enemy_progress_array.find(max_offset)
		enemy = enemy_array[enemy_index]

func fire():
	if category == "placement":
		return  # Blockades don't fire
		
	ready = false
	match category:
		"Projectile":
			fire_gun()
		"Missile":
			fire_missile()
	
	if enemy:  # Only deal damage if enemy exists
		enemy.on_hit(GameData.tower_data[type]["damage"])
	yield(get_tree().create_timer(GameData.tower_data[type]["rof"]), "timeout")
	ready = true

func block():
	# This is called when the blockade is placed
	pass

func fire_gun():
	get_node("AnimationPlayer").play("Fire")

func fire_missile():
	pass

func _on_Range_body_entered(body):
	if category != "placement":  # Blockades don't track enemies
		enemy_array.append(body.get_parent())

func _on_Range_body_exited(body):
	if category != "placement":  # Blockades don't track enemies
		enemy_array.erase(body.get_parent())

func _exit_tree():
	# Clean up for blockade when destroyed
	if category == "placement":
		var astar = get_node("/root/SceneHandler/GamesScene/Map1/TowerExclusion")
		if astar and astar.has_method("unblock_cell"):
			astar.unblock_cell(tile_position)
