extends Node2D

var map_node
var build_mode = false
var build_valid = false
var build_tile
var build_location 
var build_type

var current_wave = 1
var enemies_in_wave = GameData.enemywaveLV3

var popup_scene = preload("res://Scenes/UIScenes/Pop_up_Menu.tscn")  # เปลี่ยนเส้นทางให้ถูกต้อง
var popup_instance  # ตัวแปรสำหรับเก็บอินสแตนซ์ของ Popup
var popup_vic = preload("res://Scenes/UIScenes/pop_up_victory2.tscn")
var popup_vicinstance

onready var money_label = get_node("UI/HBoxContainer/Money")
onready var play_pause = get_node("UI/HUD/HBoxContainer/play_paused")
onready var x2_button = get_node("UI/HUD/HBoxContainer/X2")






func _ready():
	GameData.connect("money_changed", self, "_on_money_changed")
	_update_money_display()  # แสดงเงินเริ่มต้น
	GameData.connect("enemy_changed", self, "_on_enemy_changed")
	check_victory()
	
	popup_instance = popup_scene.instance()  # สร้างอินสแตนซ์ของ Popup
	popup_instance.visible = false  # ซ่อน Popup ตั้งแต่เริ่ม
	add_child(popup_instance)  # เพิ่ม Popup ไปยัง Scene
	
	popup_instance.get_node("TextureRect/continue").connect("pressed", self, "_on_continue_pressed")
	popup_instance.get_node("TextureRect/restart").connect("pressed", self, "_on_restart_pressed")
	popup_instance.get_node("TextureRect/quit").connect("pressed", self, "_on_quit_pressed")
	
	
	
	map_node = get_node("Map3") 
	
	# เชื่อมต่อปุ่มสำหรับการสร้างตึก
	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.connect("pressed", self, "initiate_build_mode", [i.get_name()])
	
	start_next_wave()


func _process(delta):
	if build_mode:
		update_tower_preview()


func _unhandled_input(event):
	if event.is_action_released("ui_cancel") and build_mode == true:
		cancel_build_mode()
	if event.is_action_released("ui_accept") and build_mode == true:
		verify_and_build()
		cancel_build_mode()


##Buildings placements
func initiate_build_mode(tower_type):
	if build_mode:
		cancel_build_mode()
	build_type = tower_type + "T1"
	build_mode = true
	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())


func update_tower_preview():
	var mouse_position = get_global_mouse_position()
	var current_tile = map_node.get_node("TowerExclusion").world_to_map(mouse_position)
	var tile_position = map_node.get_node("TowerExclusion").map_to_world(current_tile)
	
	# ตรวจสอบว่าตำแหน่งกริดที่เลือกเป็นที่ว่างหรือไม่
	if map_node.get_node("TowerExclusion").get_cellv(current_tile) == -1:
		get_node("UI").update_tower_preview(tile_position, "ad54ff3c")
		build_valid = true
		build_location = tile_position
		build_tile = current_tile
	else:
		get_node("UI").update_tower_preview(tile_position, "adff4545")
		build_valid = false


func cancel_build_mode():
	build_mode = false
	build_valid = false
	get_node("UI/TowerPreview").free()
	


func verify_and_build():
	if build_valid:
		var tower_cost = GameData.tower_data[build_type]["cost"]
		if GameData.money >= tower_cost:
			var new_tower = load("res://Scenes/Turrets/" + build_type + ".tscn").instance()
			new_tower.position = build_location
			new_tower.built = true
			new_tower.type = build_type
			new_tower.category = GameData.tower_data[build_type]["category"]
			map_node.get_node("Turrets").add_child(new_tower, true)
			map_node.get_node("TowerExclusion").set_cellv(build_tile, 5)
			GameData.subtract_money(tower_cost)
		else:
			print("not enough money")
	else:
		return


##Wave Functions
func start_next_wave():
	var wave_data = retrieve_wave_data()
	yield(get_tree().create_timer(0.2),"timeout")
	spawn_enemies(wave_data)


func retrieve_wave_data():
	var wave_data = []
	current_wave += 1
	var delay = 0.0

	for i in range(enemies_in_wave):
		var enemy_type = "BlueTank"      # กำหนดประเภทของศัตรู
		delay += rand_range(0.4, 0.8)    # สุ่มเวลาสำหรับการสปอนศัตรู
		wave_data.append([enemy_type, delay])
	enemies_in_wave = wave_data.size()
	return wave_data


func spawn_enemies(wave_data):
	for i in wave_data:
		var new_enemy = load("res://Scenes/Enemies/" + i[0] + ".tscn").instance()
		map_node.get_node("Path").add_child(new_enemy, true)
		yield(get_tree().create_timer(i[1]),"timeout")

# ฟังก์ชันที่เกี่ยวข้องกับการหยุดและเร่งความเร็วเกม
func _paused():  
	if Engine.time_scale > 0:
		Engine.time_scale = 0
		x2_button.disabled = true 
	else:
		Engine.time_scale = 1  
		x2_button.disabled = false


func _on_play_paused_button_down():  
	_paused() 


func _on_X2_button_down():  
	if Engine.time_scale == 1:
		Engine.time_scale = 2  
	else:
		Engine.time_scale = 1  


# ฟังก์ชันที่เกี่ยวกับการเปิด Popup เมนู
func _input(event):
	if event.is_action_pressed("Escape"): 
		if Engine.time_scale == 0 and popup_instance.visible == false:
			return  
		popup_instance.visible = !popup_instance.visible
		if popup_instance.visible:
			play_pause.disabled = true
		else:
			play_pause.disabled = false
	
		if Engine.time_scale == 0:
			Engine.time_scale = 1
		else:
			_paused()


# ฟังก์ชันที่ทำงานเมื่อกดปุ่ม "Continue" ใน popup
func _on_continue_pressed():
	popup_instance.visible = false
	play_pause.disabled = false
	_paused() 


# ฟังก์ชันที่ทำงานเมื่อกดปุ่ม "Restart" ใน popup
func _on_restart_pressed():
	popup_instance.visible = false 
	_paused()
	get_tree().reload_current_scene()  
	GameData.money = 200
	GameData.enemies_destroy = 0
	get_tree().change_scene("res://Scenes/MainScenes/GameScene.tscn")


# ฟังก์ชันที่ทำงานเมื่อกดปุ่ม "Quit" ใน popup
func _on_quit_pressed():
	_paused()
	get_tree().reload_current_scene()
	GameData.money = 200
	GameData.enemies_destroy = 0
	get_tree().change_scene("res://SceneHandler.tscn")



# ฟังก์ชันที่ใช้แสดงผลเงินใน Label
func _update_money_display():
	money_label.text = "" + str(GameData.money)


#ฟังชั่นใ้ชรับการเพิ่มลดเงินที่จะไปแสดงผลใน Label
func _on_money_changed(new_money):
	GameData.money = new_money
	_update_money_display()


#ฟังชั่นที่ใช้รับการเปลี่ยนจำนวนศัตรูที่ถูกทำลาย
func _on_enemy_changed(new_enemy):
	GameData.enemies_destroy = new_enemy
	check_victory()


#ฟังชั่นไว้สำหรับเรียกvoictorypopup.sct
func show_victory_popup():
	yield(get_tree().create_timer(0.2), "timeout")  
	if popup_vicinstance == null:
		popup_vicinstance = popup_vic.instance()
		add_child(popup_vicinstance)
		popup_vicinstance.get_node("MainMenu").connect("pressed", self, "_on_quit_pressed")

	else:
		popup_vicinstance.visible = true

	# หยุดเกมไว้ตอนแสดง popup
	Engine.time_scale = 0
	
	

#ฟังก์ชันสำหรับการเช็คเงื่อนไขการชนะ
func check_victory():
	if GameData.enemies_destroy == enemies_in_wave:
		yield(get_tree().create_timer(0.2), "timeout")  
		show_victory_popup()
