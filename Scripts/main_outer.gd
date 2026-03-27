extends Control

var PlayerEntity
var EnemyEntity
@onready var player_skill_box = $PlayerSkillBox

const ENTITY = preload("res://Nodes/entity.tscn")
const SLIME = preload("res://Resources/Mobs/Slime.tres")

func _ready() -> void:
	PlayerEntity = ENTITY.instantiate()
	add_child(PlayerEntity)
	PlayerEntity.LoadEntity(PlayerStats)
	PlayerEntity.position = Vector2(200, 200)
	player_skill_box.initiate(PlayerEntity)
	
	EnemyEntity = ENTITY.instantiate()
	add_child(EnemyEntity)
	EnemyEntity.LoadEntity(SLIME)
	EnemyEntity.position = Vector2(1000, 200)
	
	PlayerEntity.CurrentTargets.append(EnemyEntity)
	EnemyEntity.CurrentTargets.append(PlayerEntity)
