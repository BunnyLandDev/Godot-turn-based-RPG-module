extends Node

var Skills: Array = []
var Cooldowns: Array = []

signal AttackSignal
signal ActionResolved # Emitted when an action attempt completes, regardless of success

func Attack(skill):
	var index = Skills.find(skill)
	# Valida se a skill existe
	if index == -1:
		print("Skill not found in Skills array")
		ActionResolved.emit()
		return
	
	# Checa se a skill está em cooldown
	if Cooldowns[index] != 0:
		print("Skill on cooldown: ", skill.SkillName, " - Cooldown: ", Cooldowns[index])
		ActionResolved.emit()
		return
	
	# Executa o ataque
	var Targets = get_parent().CurrentTargets
	var Damage = CalculateDamage(skill)
	for target in Targets:
		if target == null or not is_instance_valid(target):
			continue
		target.RecieveDamage(Damage, skill.SkillType)
	RefreshCooldowns()
	Cooldowns[index] = Skills[index].SkillCooldown
	AttackSignal.emit()
	ActionResolved.emit()

func MobAttack():
	if randi_range(0, 1) == 1 and Cooldowns[1] == 0:
		Attack(Skills[1])
	else:
		Attack(Skills[0])

func CalculateDamage(skill):
	var Damage: float = get_parent().get(skill.SkillType)
	Damage = (Damage / 100) * skill.SkillPower
	return Damage

func LoadSkills(skills):
	for skill in skills:
		Skills.append(skill)
		Cooldowns.append(skill.SkillCooldown)

func RefreshCooldowns():
	for i in len(Cooldowns):
		Cooldowns[i] = max(Cooldowns[i] - 1, 0)
