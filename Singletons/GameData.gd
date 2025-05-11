extends Node

var tower_data = {
	"GunT1": {
		"damage": 20,
		"rof": 1,
		"range": 350,
		"cost": 100,
		"category": "Projectile"},
	"GunT2":{
		"damage": 30,
		"rof": 1,
		"range": 350,
		"cost": 150,
		"category": "Projectile"},
	"MissileT1": {
		"damage": 100,
		"rof": 3,
		"range": 550,
		"cost": 200,
		"category": "Missile"},
	"BlockadeT1": {
		"cost": 50,
		"range": 0,
		"category": "placement"},}


signal money_changed(new_money)

var money = 200

func add_money(amount):
	money += amount
	emit_signal("money_changed", money)

func subtract_money(amount):
	if money >= amount:
		money -= amount
		emit_signal("money_changed", money)



var enemywaveLV1 = 2
var enemywaveLV2 = 3
var enemywaveLV3 = 4



signal enemy_changed(new_enemy)
var enemies_destroy = 0

func enemy_changed(amount) :
	enemies_destroy += amount
	emit_signal("enemy_changed", enemies_destroy)

