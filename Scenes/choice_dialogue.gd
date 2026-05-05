class_name ChoiceDialogue
extends Control

signal choice_made(choice: String) # emits "execute" or "redeem"

func _ready() -> void:
	hide()

func prompt() -> void:
	show()

func _on_execute_pressed() -> void:
	choice_made.emit("execute")
	hide()

func _on_redeem_pressed() -> void:
	choice_made.emit("redeem")
	hide()
