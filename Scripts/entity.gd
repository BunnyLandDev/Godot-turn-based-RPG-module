extends Control

#Nós
@export var HealthNode: Node
@export var AttackNode: Node
@onready var entity_sprite = $EntitySprite
@onready var health_bar = $HealthBar

#Alvos
var CurrentTargets: Array
var SelectedTarget: Node = null

#Status
var Str: int
var Dex: int
var Int: int

#Time
var Team: String = "" # "ally" ou "enemy"
var AlliedEntities: Array = []
var EnemyEntities: Array = []

#Funções

func _ready() -> void:
	entity_sprite.play("idle")
	AttackNode.AttackSignal.connect(AttackAnim)

func _process(_delta: float) -> void:
	health_bar.value = HealthNode.CurrentHP / HealthNode.MaxHP


func LoadEntity(TargetRes) -> void:
	if TargetRes != PlayerStats:
		entity_sprite.flip_h = true
	Str = TargetRes.Str
	Dex = TargetRes.Dex
	Int = TargetRes.Int
	HealthNode.MaxHP = TargetRes.MaxHP
	HealthNode.CurrentHP = TargetRes.MaxHP
	
	AttackNode.LoadSkills(TargetRes.Skills)
	HealthNode.Death.connect(Death)

func RecieveDamage(amount, type):
	HealthNode.TakeDamage(amount, type)
	#entity_sprite.play("hurt")

func Death():
	queue_free()


func _on_entity_sprite_animtaion_finished():
	if HealthNode.CurrentHealt > 0:
		entity_sprite.play("idle")

func AttackAnim() -> void:
	pass
	#entity_sprite.play("hit")

func MobAttack():
	AttackNode.MobAttack()
