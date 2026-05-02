extends HBoxContainer

var PlayerEntity
var SkillButtons: Array = []
var TargetButtons: Array = []
var SelectedTarget: Node = null

@onready var combat_manager = get_parent()

func initiate(player) -> void:
	PlayerEntity = player
	get_parent().PlayerTurn.connect(_on_player_turn)
	
	# Criar botões de habilidades
	for skill in PlayerStats.Skills:
		var newButton = Button.new()
		add_child(newButton)
		newButton.text = skill.SkillName
		newButton.pressed.connect(_on_skill_selected.bind(skill))
		newButton.disabled = true
		SkillButtons.append(newButton)

func _on_player_turn(is_player_turn: bool, _current_entity: Node) -> void:
	"""Chamado quando mudar o turno"""
	if is_player_turn:
		# Habilitar seleção de alvo
		SelectedTarget = null
		_update_target_buttons()
		# Desabilitar botões de skill até alvo ser selecionado
		for button in SkillButtons:
			button.disabled = true
	else:
		# Desabilitar botões quando não é turno do jogador
		for button in SkillButtons:
			button.disabled = true
		_clear_target_buttons()

func _update_target_buttons() -> void:
	"""Cria botões para seleção de alvo"""
	_clear_target_buttons()
	
	var available_enemies = PlayerEntity.EnemyEntities.filter(
		func(entity): return entity.HealthNode.CurrentHP > 0
	)
	
	if available_enemies.is_empty():
		return
	
	# Criar botão para cada inimigo disponível
	for enemy in available_enemies:
		var target_button = Button.new()
		target_button.text = "Enemy - HP: %.0f" % enemy.HealthNode.CurrentHP
		target_button.tooltip_text = "Selecione este alvo"
		target_button.pressed.connect(_on_target_selected.bind(enemy))
		add_child(target_button)
		TargetButtons.append(target_button)

func _clear_target_buttons() -> void:
	"""Remove botões de seleção de alvo"""
	for button in TargetButtons:
		button.queue_free()
	TargetButtons.clear()

func _on_target_selected(target: Node) -> void:
	"""Callback quando um alvo é selecionado"""
	SelectedTarget = target
	PlayerEntity.SelectedTarget = target
	PlayerEntity.CurrentTargets = [target]
	
	# Habilitar botões de skill agora que temos um alvo
	for button in SkillButtons:
		button.disabled = false
	
	# Atualizar visual dos botões de alvo (marcar o selecionado)
	for button in TargetButtons:
		button.self_modulate = Color.WHITE

func _on_skill_selected(skill: Resource) -> void:
	"""Callback quando uma habilidade é selecionada"""
	if SelectedTarget == null or SelectedTarget.HealthNode.CurrentHP <= 0:
		print("Nenhum alvo válido selecionado!")
		return
	
	# Executar o ataque
	PlayerEntity.AttackNode.Attack(skill)
	
	# Limpar seleção de alvo para próximo turno
	SelectedTarget = null
	_clear_target_buttons()
