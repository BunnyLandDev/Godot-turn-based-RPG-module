extends Control

var PlayerEntity
var EnemyEntity
@onready var player_skill_box = $PlayerSkillBox

const ENTITY = preload("res://Nodes/entity.tscn")
const SLIME = preload("res://Resources/Mobs/Slime.tres")

var currentTurn

signal PlayerTurn(boolean)

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
	PlayerEntity.AttackNode.AttackSignal.connect(changeTurn.bind(EnemyEntity))
	EnemyEntity.AttackNode.AttackSignal.connect(changeTurn.bind(PlayerEntity))
	SelectTurn()

func changeTurn(target) -> void:
	currentTurn = target
	if target == PlayerEntity:
		PlayerTurn.emit(false)
	else:
		PlayerTurn.emit(true)
		await get_tree().create_timer(1).timeout
		EnemyEntity.MobAttack()

func SelectTurn():
	if randi_range(0, 1) == 0:
		changeTurn(PlayerEntity)
	else:
		changeTurn(EnemyEntity)
