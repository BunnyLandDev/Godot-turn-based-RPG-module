extends HBoxContainer

var PlayerEntity

func initiate(player) -> void:
	PlayerEntity = player
	for skill in PlayerStats.Skills:
		var newButton = Button.new()
		add_child(newButton)
		newButton.text = skill.SkillName
		newButton.pressed.connect(player.AttackNode.Attack.bind(skill))
