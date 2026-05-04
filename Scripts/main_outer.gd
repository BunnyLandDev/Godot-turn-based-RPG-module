extends Control

# Equipes
var AlliesTeam: Array = []
var EnemiesTeam: Array = []

# Sistema de turnos
var TurnQueue: Array = []
var CurrentTurnIndex: int = 0
var CurrentTurnEntity: Node = null

@onready var player_skill_box = $PlayerSkillBox

const ENTITY = preload("res://Nodes/entity.tscn")
const SLIME = preload("res://Resources/Mobs/Slime.tres")

signal PlayerTurn(is_player_turn: bool, current_entity: Node)

func _ready() -> void:
	# Criar aliados (jogador)
	var player_entity_warrior = ENTITY.instantiate()
	add_child(player_entity_warrior)
	player_entity_warrior.LoadEntity(PlayerStats)
	player_entity_warrior.Team = "ally"
	player_entity_warrior.position = Vector2(200, 200)
	AlliesTeam.append(player_entity_warrior)
	
	var player_entity_mage = ENTITY.instantiate()
	add_child(player_entity_mage)
	player_entity_mage.LoadEntity(PlayerStats)
	player_entity_mage.Team = "ally"
	player_entity_mage.position = Vector2(400, 400)
	AlliesTeam.append(player_entity_mage)
	
	var player_entity_rogue = ENTITY.instantiate()
	add_child(player_entity_rogue)
	player_entity_rogue.LoadEntity(PlayerStats)
	player_entity_rogue.Team = "ally"
	player_entity_rogue.position = Vector2(200, 600)
	AlliesTeam.append(player_entity_rogue)
	
	# Criar inimigos
	var enemy_slime = ENTITY.instantiate()
	add_child(enemy_slime)
	enemy_slime.LoadEntity(SLIME)
	enemy_slime.Team = "enemy"
	enemy_slime.position = Vector2(1200, 200)
	EnemiesTeam.append(enemy_slime)
	
	var enemy_goblin = ENTITY.instantiate()
	add_child(enemy_goblin)
	enemy_goblin.LoadEntity(SLIME)
	enemy_goblin.Team = "enemy"
	enemy_goblin.position = Vector2(1000, 400)
	EnemiesTeam.append(enemy_goblin)
	
	var enemy_draco = ENTITY.instantiate()
	add_child(enemy_draco)
	enemy_draco.LoadEntity(SLIME)
	enemy_draco.Team = "enemy"
	enemy_draco.position = Vector2(1200, 600)
	EnemiesTeam.append(enemy_draco)
	
	# Configurar referências de equipes para todas as entidades
	_setup_entity_references()
	
	# Inicializar UI de skills
	player_skill_box.initiate(AlliesTeam[0])
	
	# Inicializar fila de turnos e começar combate
	InitializeTurnQueue()

func _setup_entity_references() -> void:
	"""Configura referências de equipes para todas as entidades"""
	for ally in AlliesTeam:
		ally.AlliedEntities = AlliesTeam
		ally.EnemyEntities = EnemiesTeam
		ally.AttackNode.ActionResolved.connect(NextTurn)
		ally.HealthNode.Death.connect(_on_entity_died.bind(ally))
		
	for enemy in EnemiesTeam:
		enemy.AlliedEntities = EnemiesTeam
		enemy.EnemyEntities = AlliesTeam
		enemy.AttackNode.ActionResolved.connect(NextTurn)
		enemy.HealthNode.Death.connect(_on_entity_died.bind(enemy))

func _on_entity_died(entity: Node) -> void:
	"""Callback quando uma entidade morre"""
	entity.queue_free()

func InitializeTurnQueue() -> void:
	"""Cria a fila de turnos com todas as entidades vivas"""
	TurnQueue.clear()
	TurnQueue.append_array(AlliesTeam)
	TurnQueue.append_array(EnemiesTeam)
	TurnQueue.shuffle()
	CurrentTurnIndex = 0
	
	print(TurnQueue)
	
	StartNextTurn()

func NextTurn() -> void:
	"""Avança para o próximo turno na fila"""
	CurrentTurnIndex += 1
	
	# Remover entidades mortas da fila
	TurnQueue = TurnQueue.filter(func(entity): return is_instance_valid(entity) and entity.HealthNode.CurrentHP > 0)
	
	# Verificar condições de vitória/derrota
	var alive_enemies = EnemiesTeam.filter(func(entity): return is_instance_valid(entity) and entity.HealthNode.CurrentHP > 0)
	var alive_allies = AlliesTeam.filter(func(entity): return is_instance_valid(entity) and entity.HealthNode.CurrentHP > 0)
	
	if alive_enemies.is_empty():
		print("Vitória! Todos os inimigos foram derrotados!")
		return
	
	if alive_allies.is_empty():
		print("Derrota! Todos os aliados foram derrotados!")
		return
	
	# Reiniciar fila se chegou ao final
	if CurrentTurnIndex >= TurnQueue.size():
		CurrentTurnIndex = 0
	
	StartNextTurn()

func StartNextTurn() -> void:
	"""Inicia o turno da entidade atual"""
	if TurnQueue.is_empty():
		print("Lista vazia")
		return
		
	CurrentTurnEntity = TurnQueue[CurrentTurnIndex]
	
	if not is_instance_valid(CurrentTurnEntity) or CurrentTurnEntity.HealthNode.CurrentHP <= 0:
		print("Proximo turno")
		NextTurn()
		return
	
	if CurrentTurnEntity.Team == "ally":
		# Turno do jogador - aguarda input
		PlayerTurn.emit(true, CurrentTurnEntity)
	else:
		# Turno do inimigo - IA automática
		PlayerTurn.emit(false, CurrentTurnEntity)
		await get_tree().create_timer(1).timeout
		if is_instance_valid(CurrentTurnEntity) and CurrentTurnEntity.HealthNode.CurrentHP > 0:
			_execute_enemy_ai()

func _execute_enemy_ai() -> void:
	"""Lógica de IA para inimigos"""
	var available_targets = CurrentTurnEntity.EnemyEntities.filter(
		func(entity): return is_instance_valid(entity) and entity.HealthNode.CurrentHP > 0
	)
	
	if available_targets.is_empty():
		NextTurn()
		return
	
	# Selecionar alvo aleatório
	var target = available_targets[randi_range(0, available_targets.size() - 1)]
	CurrentTurnEntity.SelectedTarget = target
	CurrentTurnEntity.CurrentTargets = [target]
	
	# Encontra as habilidades disponiveis (fora do cooldown)
	var available_skills: Array = []
	for i in range(CurrentTurnEntity.AttackNode.Skills.size()):
		if CurrentTurnEntity.AttackNode.Cooldowns[i] == 0:
			available_skills.append(CurrentTurnEntity.AttackNode.Skills[i])
	
	# Seleciona uma habilidade aleatória, ou o ataque normal se não tiver nenhuma disponível
	if available_skills.is_empty():
		print("No skills available, using first skill anyway")
		CurrentTurnEntity.AttackNode.Attack(CurrentTurnEntity.AttackNode.Skills[0])
	else:
		var chosen_skill = available_skills[randi_range(0, available_skills.size() - 1)]
		CurrentTurnEntity.AttackNode.Attack(chosen_skill)

func get_current_turn_entity() -> Node:
	"""Retorna a entidade que está em turno"""
	return CurrentTurnEntity
