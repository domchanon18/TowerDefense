extends Control



func _ready():
	pass # Replace with function body.




func _on_Level1_button_pressed():
	get_tree().change_scene("res://Scenes/MainScenes/GameScene.tscn")



func _on_Level2_button_pressed():
	get_tree().change_scene("res://Scenes/MainScenes/GameScene2.tscn")


func _on_Level3_button_pressed():
	get_tree().change_scene("res://Scenes/MainScenes/GameScene3.tscn")




func _on_return_button_pressed():
	get_tree().reload_current_scene()
