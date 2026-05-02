extends Node

var MaxHP: float
var CurrentHP: float

signal Death

func TakeDamage(amount, _type):
	CurrentHP = clamp(CurrentHP - amount, 0, MaxHP)
	if CurrentHP <= 0:
		Death.emit()
