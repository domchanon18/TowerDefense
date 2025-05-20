extends Node2D

const ROAD_TILE_ID = 0 
const OBSTACLE_TILE_ID = 1  

onready var road_tilemap = $TowerExclusion
onready var obstacle_tilemap = $Obstacles

var obstacle_positions = []

func _ready():
	randomize()
	generate_obstacles()

func generate_obstacles():
	# Clear existing obstacles first
	obstacle_tilemap.clear()
	obstacle_positions.clear()
	
	# Get all road tiles
	var road_cells = road_tilemap.get_used_cells_by_id(ROAD_TILE_ID)
	
	# Shuffle the array for randomness
	road_cells.shuffle()
	
	# Place obstacles on 10% of road tiles (adjust as needed)
	var obstacle_count = int(road_cells.size() * 0.1)
	
	for i in range(obstacle_count):
		var cell = road_cells[i]
		obstacle_tilemap.set_cellv(cell, OBSTACLE_TILE_ID)
		obstacle_positions.append(cell)
