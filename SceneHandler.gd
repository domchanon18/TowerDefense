extends Node

func _ready():
	get_node("MainMenu/MarginContainer/VBoxContainer/NewGame").connect("pressed", self, "on_new_game_pressed")
	get_node("MainMenu/MarginContainer/VBoxContainer/Settings").connect("pressed", self, "on_setting_pressed")
	get_node("MainMenu/MarginContainer/VBoxContainer/About").connect("pressed", self, "on_about_pressed")
	get_node("MainMenu/MarginContainer/VBoxContainer/Quit").connect("pressed", self, "on_quit_pressed")
	
func on_new_game_pressed():
	get_node("MainMenu").queue_free()
	var game_scene = load("res://Scenes/MainScenes/GameScene.tscn").instance()
	add_child(game_scene)

func on_setting_pressed():
	get_node("MainMenu").queue_free()
	var setting = load("res://Scenes/UIScenes/Setting.tscn").instance()
	add_child(setting)

func on_about_pressed() :
	OS.shell_open("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
	
	
func on_quit_pressed():
	get_tree().quit()
