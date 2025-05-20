extends TileMap

onready var astar = AStar2D.new()
onready var walkable_tile_id = 0
onready var used_cells = get_used_cells()
onready var line2d = $PathLine  # <--- Line2D ต้องเป็นลูกของ TileMap
onready var path2d = $Path2D

onready var timer = Timer.new()
var change_interval = 5.0
var alternate_tile_id = 3
var changing_cells = []

var path = []
var blocked_points = []
var point_ids = {}
var world_to_cell_map = {}

func _ready():
	initialize_astar()
	calculate_initial_path()
	setup_automatic_changes()

func setup_automatic_changes():
	# Add specific fixed cells to change automatically
	var fixed_cells = [Vector2(9, 4), Vector2(8, 2)]
	
	for cell in fixed_cells:
		if get_cellv(cell) == walkable_tile_id:
			changing_cells.append(cell)
		else:
			print("Cell ", cell, " is not walkable (tile ID: ", get_cellv(cell), ")")
	
	# Configure and start timer
	if changing_cells.size() > 0:
		add_child(timer)
		timer.wait_time = change_interval
		timer.connect("timeout", self, "_on_tile_change_timeout")
		timer.start()
	else:
		print("No valid cells found for automatic changes")

func _on_tile_change_timeout():
	if changing_cells.size() > 0:
		# Get and remove the first cell in the array
		var cell = changing_cells.pop_front()
		
		# Change it permanently
		set_cellv(cell, alternate_tile_id)
		block_cell(cell)
		
		# Update AStar grid and paths
		initialize_astar()
		calculate_initial_path()
	else:
		timer.stop()
		print("All tiles have been changed - stopping automatic changes")


func initialize_astar():
	var id = 0
	point_ids.clear()
	world_to_cell_map.clear()
	astar.clear()
	
	# Only add points for tiles with walkable_tile_id (0)
	for cell in used_cells:
		if get_cellv(cell) == walkable_tile_id:  # Only tile ID 0 is walkable
			var world_pos = map_to_world(cell) + cell_size / 2
			astar.add_point(id, world_pos)
			point_ids[cell] = id
			world_to_cell_map[world_pos] = cell
			id += 1

	# Connect only walkable tiles
	for cell in point_ids.keys():
		var from_id = point_ids[cell]
		for offset in [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]:
			var neighbor = cell + offset
			if point_ids.has(neighbor):  # Only if neighbor is also walkable
				var to_id = point_ids[neighbor]
				if not astar.are_points_connected(from_id, to_id):
					astar.connect_points(from_id, to_id)

func calculate_initial_path():
	# 3. Start and end points of the path
	var start_cell = Vector2(-1, 9)
	var end_cell = Vector2(21, 1)
	
	if point_ids.has(start_cell) and point_ids.has(end_cell):
		update_path_visuals(point_ids[start_cell], point_ids[end_cell])

func update_path_visuals(start_id, end_id):
	path = astar.get_point_path(start_id, end_id)
	print("Path: ", path)
	print("Number of points in path: ", path.size())

	# 4. Draw line in Line2D
	line2d.clear_points()
	for point in path:
		line2d.add_point(to_local(point))
	line2d.width = 4
	line2d.default_color = Color.red

	# 5. Create Path2D (Curve2D)
	var curve = Curve2D.new()
	for point in path:
		curve.add_point(to_local(point))
	path2d.curve = curve

func get_cell_at_position(world_position):
	# Convert world position to tile cell coordinates
	return world_to_map(world_position)

func get_point_id_for_cell(cell):
	# Get AStar point ID for a tile cell
	return point_ids.get(cell, -1)

func block_cell(cell):
	# Block a cell in the AStar grid
	if point_ids.has(cell):
		var point_id = point_ids[cell]
		if not blocked_points.has(point_id):
			blocked_points.append(point_id)
			astar.set_point_disabled(point_id, true)
			recalculate_paths()

func unblock_cell(cell):
	# Unblock a cell in the AStar grid
	if point_ids.has(cell):
		var point_id = point_ids[cell]
		if blocked_points.has(point_id):
			blocked_points.erase(point_id)
			astar.set_point_disabled(point_id, false)
			recalculate_paths()

func recalculate_paths():
	# Recalculate all paths when the grid changes
	calculate_initial_path()
	# Notify enemies to update their paths
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("update_path"):
			enemy.update_path()
