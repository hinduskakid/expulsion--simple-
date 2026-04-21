extends Node2D

@onready var enemy: Enemy = $Enemy


func _ready() -> void:
	print("Combat starts.")
	await game_loop()

func game_loop() -> void:
	while is_instance_valid(enemy):
		await player_turn()
		await get_tree().process_frame
		
		if not is_instance_valid(enemy):
			end_game()
			return
		
		await enemy_turn()
		round_end()

func player_turn() -> void:
	print("Player turn")

func enemy_turn() -> void:
	print("Enemy turn")
	

func round_end() -> void:
	print("Round end")

func end_game() -> void:
	print("Enemy defeated! Game over.")
	# replace this with your actual next step, e.g:
	# get_tree().change_scene_to_file("res://win_screen.tscn")
