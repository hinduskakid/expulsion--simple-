extends Node2D
#Variables
@onready var party: Array = [$Player1, $Michla]
@onready var enemy: Enemy = $Enemy
@onready var hand: Hand = $BattleUI/Hand
@onready var choice_dialogue: ChoiceDialogue = $BattleUI/ChoiceDialogue
var player_souls: int = 0
var _downed_enemy_was_attacked := false
var _personification_was_used := false
var _selected_member = null
var _race_card_played := false
var _race_member_selected := false
@onready var enemies: Array = [$Enemy, $Enemy2]
var _last_targeted_enemy: Enemy = null

const CARDS_PER_TURN := 3


#Functions
func _ready() -> void:
	Events.party_member_selected.connect(_on_party_member_selected)
	Events.enemy_attacked_while_downed.connect(func(e):
		print("Signal received in combat!")
		_downed_enemy_was_attacked = true
		_last_targeted_enemy = e)
	Events.personification_redemption_attempted.connect(_on_personification_used)
	for member in party:
		print(member.name, " stats: ", member.stats)  # debug check
		if member.stats == null:
			print("ERROR: ", member.name, " has no stats assigned!")
			return
		member.stats.draw_pile.cards = member.stats.deck.cards.duplicate()
		member.stats.draw_pile.shuffle()
		hand.clear_hand()  
	await game_loop()
func _on_party_member_selected(member) -> void:
	_selected_member = member


	
func game_loop() -> void:
	var members_played := []
	while true:
		print("=== NEW ROUND ===")
		members_played.clear()
		print("members_played cleared")
		
		while members_played.size() < party.size():
			print("Waiting for member selection...")
			var member = await _wait_for_member_selection(members_played)
			print("Selected: ", member.name)
			
			hand.clear_hand()
			hand.preview_cards(CARDS_PER_TURN, member.stats)
			
			var action = await _wait_for_card_or_reselect(member, members_played)
			
			if action == "reselected":
				continue
			
			hand.clear_hand()
			await get_tree().process_frame

# handle downed enemy interactions
			if _personification_was_used and is_instance_valid(get_last_targeted_enemy()):
				await _on_personification_redemption(get_last_targeted_enemy())
				await get_tree().process_frame
			elif _downed_enemy_was_attacked:
				await _on_enemy_attacked_while_downed(get_last_targeted_enemy())
				await get_tree().process_frame

			_personification_was_used = false
			_downed_enemy_was_attacked = false
			await get_tree().process_frame
			
			if all_enemies_dead():
				end_game("You win!")
				return
			
			member.has_played = true
			member.modulate = Color(0.5, 0.5, 0.5)
			members_played.append(member)
			
			if get_living_enemies().any(func(e): return not e.stats.is_downed):
				await enemy_turn()
			else:
				round_end()
				if all_enemies_dead():
					end_game("You win!")
					return
				continue
			
			if check_party_dead():
				end_game("You lose!")
				return
		
		print("Resetting party modulates...")
		for member in party:
			print("Resetting: ", member.name)
			member.modulate = Color.WHITE
			member.has_played = false
		
		print("Calling round_end...")
		round_end()
		print("round_end finished, looping...")
func _wait_for_member_selection(already_played: Array) -> Node:
	while true:
		await Events.party_member_selected
		if _selected_member and not already_played.has(_selected_member):
			return _selected_member
		print(_selected_member.name + " already played this round!")
	return party[0]  # fallback, never actually reached

func _wait_for_card_or_reselect(current_member, already_played: Array) -> String:
	while true:
		var result = await _race_signals()
		if result == "card_played":
			return "card_played"
		if _selected_member != current_member and not already_played.has(_selected_member):
			hand.clear_hand()
			hand.preview_cards(CARDS_PER_TURN, _selected_member.stats)
			current_member = _selected_member
	return "card_played"  # fallback, never actually reached

func _race_signals() -> String:
	_race_card_played = false
	_race_member_selected = false
	
	Events.card_played.connect(_on_race_card_played, CONNECT_ONE_SHOT)
	Events.party_member_selected.connect(_on_race_member_selected, CONNECT_ONE_SHOT)
	
	while not _race_card_played and not _race_member_selected:
		await get_tree().process_frame
	
	# disconnect whichever didn't fire
	if Events.card_played.is_connected(_on_race_card_played):
		Events.card_played.disconnect(_on_race_card_played)
	if Events.party_member_selected.is_connected(_on_race_member_selected):
		Events.party_member_selected.disconnect(_on_race_member_selected)
	
	if _race_card_played:
		return "card_played"
	return "selected"

func _on_race_card_played(_c) -> void:
	_race_card_played = true

func _on_race_member_selected(_m) -> void:
	_race_member_selected = true

func check_party_dead() -> bool:
	for member in party:
		if member.stats.health > 0:
			return false
	return true
func _on_personification_redemption(attacked_enemy: Enemy) -> void:
	var roll := randf()
	if roll < 0.666:  # 2/3 chance instead of 1/3
		print("Personification redemption successful!")
		attacked_enemy.queue_free()
		player_souls += 1
		Events.player_gained_soul.emit()
		print("Souls: %d" % player_souls)
	else:
		print("Personification redemption failed!")
	
func enemy_turn() -> void:
	print("Enemy turn")
	await get_tree().create_timer(0.5).timeout
	for e in get_living_enemies():
		var action := randi() % 2
		if action == 0:
			print(e.name + " attacks!")
			var target = party[randi() % party.size()]
			await enemy_lunge_specific(e, target)
			target.stats.take_damage(10)
		else:
			print(e.name + " blocks!")
			e.stats.set_block(5)
		await get_tree().create_timer(0.3).timeout  # pause between each enemy acting

func enemy_lunge_specific(e: Enemy, target: Node2D) -> void:
	var original_pos := e.global_position
	var target_pos := Vector2(target.global_position.x + 100, e.global_position.y)
	
	var lunge_tween := create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	lunge_tween.tween_property(e, "global_position", target_pos, 0.2)
	await lunge_tween.finished
	
	await get_tree().create_timer(0.1).timeout
	
	var return_tween := create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	return_tween.tween_property(e, "global_position", original_pos, 0.3)
	await return_tween.finished
func round_end() -> void:
	print("Round end")
	hand.clear_hand()
	for e in enemies:
		if is_instance_valid(e) and e.stats.is_downed:
			e.stats.downed_rounds_remaining -= 1
			print(e.name + " downed for %d more rounds" % e.stats.downed_rounds_remaining)
			if e.stats.downed_rounds_remaining <= 0:
				e.revive()

func end_game(message: String) -> void:
	print(message)
	# get_tree().change_scene_to_file("res://Scenes/game_over.tscn")
func _on_enemy_attacked_while_downed(attacked_enemy: Enemy) -> void:
	choice_dialogue.prompt()
	var choice: String = await choice_dialogue.choice_made
	if choice == "execute":
		var roll := randf()
		if roll < 0.666:
			print("Execution successful!")
			attacked_enemy.queue_free()
		else:
			print("Execution failed!")
	elif choice == "redeem":
		var roll := randf()
		if roll < 0.333:
			print("Redemption successful!")
			attacked_enemy.queue_free()
			player_souls += 1
			Events.player_gained_soul.emit()
			print("Souls: %d" % player_souls)
		else:
			print("Redemption failed!")
func all_enemies_dead() -> bool:
	for e in enemies:
		if is_instance_valid(e):
			return false
	return true

func get_living_enemies() -> Array:
	var living := []
	for e in enemies:
		if is_instance_valid(e):
			living.append(e)
	return living

func _on_personification_used(e: Enemy) -> void:
	_personification_was_used = true
	_last_targeted_enemy = e

func get_last_targeted_enemy() -> Enemy:
	return _last_targeted_enemy
