extends Node2D

#var astar = AStar2D.new()

#func _ready():
#	var tilemap = $TowerExclusion
#	var used_rect = tilemap.get_used_rect()
#	var cell_size = tilemap.cell_size

#	for x in range(used_rect.position.x, used_rect.end.x):
#		for y in range(used_rect.position.y, used_rect.end.y):
#			var tile_id = tilemap.get_cellv(Vector2(x, y))
#			if tile_id == 0:  # ถ้าเป็น tile ที่เดินได้ (ID 0)
#				var point_id = hash(Vector2(x, y))  # ใช้ hash เพื่อแปลง Vector2 เป็น int
#				var world_pos = tilemap.map_to_world(Vector2(x, y)) + cell_size / 2
#				astar.add_point(point_id, world_pos)  # เพิ่มจุดใน AStar

#	for x in range(used_rect.position.x, used_rect.end.x):
#		for y in range(used_rect.position.y, used_rect.end.y):
#			var tile_id = tilemap.get_cellv(Vector2(x, y))
#			if tile_id == 0:  # ถ้าเป็น tile ที่เดินได้
#				var from_id = hash(Vector2(x, y))
#				var directions = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
#				for dir in directions:
#					var neighbor = Vector2(x, y) + dir
#					var to_id = hash(neighbor)
#					if astar.has_point(to_id):
#						astar.connect_points(from_id, to_id)

#func find_astar_path(start: Vector2, end: Vector2) -> PoolVector2Array:
#	var start_id = hash(start)  # ใช้ hash เพื่อแปลง Vector2 เป็น int
#	var end_id = hash(end)  # ใช้ hash เพื่อแปลง Vector2 เป็น int
#	return astar.get_point_path(start_id, end_id)  # ค้นหาเส้นทาง

