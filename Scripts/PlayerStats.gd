extends Node

var MaxHP: float = 10
var CurrentHP: float = 10
var Str: int = 5
var Dex: int = 5
var Int: int = 2

var Skills: Array[Resource]

var Experience: int
var Level: int

func _ready() -> void:
	for skill in ["res://Resources/Skills/Attack.tres", "res://Resources/Skills/QuickAttack.tres", "res://Resources/Skills/MagicAttack.tres"]:
		var currentSkill = load(skill)
		Skills.append(currentSkill)
