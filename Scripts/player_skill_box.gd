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

func _on_player_turn(is_player_turn: bool, current_entity: Node) -> void:
	"""Chamado quando mudar o turno - atualiza PlayerEntity para o turno atual"""
	PlayerEntity = current_entity  # Always sync to the current active entity
	
	if is_player_turn:
		# Habilitar seleção de alvo
		SelectedTarget = null
		_update_target_buttons()
		_update_skill_button_states()  # Update cooldown states
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
	
	# Validate skill is in PlayerEntity's skills and not on cooldown
	var skill_index = PlayerEntity.AttackNode.Skills.find(skill)
	if skill_index == -1:
		print("Habilidade não encontrada!")
		return
	
	if PlayerEntity.AttackNode.Cooldowns[skill_index] != 0:
		print("Habilidade em recarga: ", skill.SkillName)
		return
	
	# Executar o ataque
	PlayerEntity.AttackNode.Attack(skill)
	
	# Limpar seleção de alvo para próximo turno
	SelectedTarget = null
	_clear_target_buttons()

func _update_skill_button_states() -> void:
	"""Atualiza o estado dos botões de habilidade com base em recarga e seleção de alvo"""
	if PlayerEntity == null:
		return
	
	for i in range(SkillButtons.size()):
		var button = SkillButtons[i]
		var cooldown = PlayerEntity.AttackNode.Cooldowns[i]
		
		if SelectedTarget == null:
			# Aguardando seleção de alvo
			button.disabled = true
		elif cooldown > 0:
			# Habilidade em recarga
			button.disabled = true
			button.text = PlayerStats.Skills[i].SkillName + " (CD: " + str(cooldown) + ")"
		else:
			# Habilidade disponível
			button.disabled = false
			button.text = PlayerStats.Skills[i].SkillName
