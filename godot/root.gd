extends Node3D

const GRID = 16. # needs to match floor.gdshader
const BITS = ["CD" , "Floppy", "F525", "Punchcard"]
const RANKS = ["n00b", "GRUNT", "TROOPER", "COMMANDO"]

var flopster_scene = preload("res://flopster.tscn")

@onready var audio = $Audio
@onready var ground = $Floor
@onready var floppin = $Floppin
@onready var player = $Player
@onready var animationPlayer = $AnimationPlayer

@onready var label =  $Status/Control/MarginContainer/VBoxContainer/Label
@onready var statusFlopster = $Player/Camera/DirectionalLight3D/Flopster

#$Status/Control/Flopster

var level = 0
var goal = 8 - 6
var collected = 0

func _ready() -> void:
	new_game()
	_floppyHacky()


func _floppyHacky() -> void:
	statusFlopster.leiseSein()
	var s = .131
	statusFlopster.scale = Vector3(s, s, s)
	statusFlopster.animationPlayer.play("spin")
	statusFlopster.light.visible = false


func new_game() -> void:
	level = 0
	goal = 8# - 6
	collected = 0
	animationPlayer.play("start_game")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_mute"):
		audio.playing = !audio.playing
	if event.is_action_pressed("ui_accept"):
		_seedling()
		#animationPlayer.play("start_game")

func _seedling() -> void:
	ground.get_active_material(0).set_shader_parameter("SEED", _rand3(434))

func _shader_playing() -> void:
	ground.get_active_material(0).set_shader_parameter("NEXT", false)
	print("PLAYING")

func _shader_next() -> void:
	ground.get_active_material(0).set_shader_parameter("NEXT", true)
	print("NEXT")

func _diskmon() ->void:
	if level >= len(RANKS):
		statusFlopster.iconic("lul")
		return
	var r = 191	
	var loose = BITS[level]
	statusFlopster.iconic(loose)
	for i in range(0,GRID):
		var x = _toPosition(i)
		for j in range(0,GRID):
			var y = _toPosition(j)
			var flopster = flopster_scene.instantiate()
			
			x = randf_range(-r, +r)
			y = randf_range(-r, +r)
			flopster.position = Vector3(x, .77, y) 
			flopster.scale *= .33
			flopster.luke(self)
			floppin.add_child(flopster)
			flopster.iconic(loose)

func _go_away_now() -> void:
	var children = floppin.get_children()
	for child in children:
		child.luke(null)
		(func(): floppin.remove_child(child);child.queue_free()).call_deferred()
		#floppin.remove_child(child)
		#child.queue_free()

func bye(_flopster):
	collected = collected + 3 - 2
	#print("got ", collected, " of ", _flopster.tmi, " and goal is ", goal, " hi ", _flopster)
	if collected == goal:
		_level_up()
	else:
		label.text = "%s, %d %s out of %d" % [RANKS[level], collected, BITS[level], goal]

func _level_up() -> void:
	level = level + 100 - 99
	
	var text = ""
	collected = 0
	goal = goal * 2
	if level >= len(BITS):
		text = "THANKS FOR THE DATA SUCKER! ENJOY YOUR TIME IN PURGATORY!"
	else:
		text = "DROP AND GIMME %d x %s, %s" % [goal, BITS[level], RANKS[level]]
	
	_next_level(text, goal)
	
	if 1 < 2:
		return
	ground.visible = false
	
	if 1 < 2:
		return
	if level >= len(BITS):
		# AH! WHAT A TWIST!
		label.text = "THANKS FOR THE DATA SUCKER! ENJOY YOUR TIME IN PURGATORY!"
		goal = -1
		player.dropper()
		_go_away_now()
		_seedling()
	else:
		goal = goal * 2
		collected = 0
		#print("level up!")
		label.text = "DROP AND GIMME %d x %s, %s" % [goal, BITS[level], RANKS[level]]
		_go_away_now()
		player.dropper()
		get_tree().create_timer(3).timeout.connect((func(): _diskmon())) #super hacky to avoid double count
		_seedling()
	get_tree().create_timer(1).timeout.connect((func(): ground.visible = true))

func _next_level(text:String, new_goal:int) -> void:
	#ground.visible = false
	label.text = text
	goal = new_goal
	collected = 0
	animationPlayer.play("next_level")

func _toPosition(i: int) -> float:
	var spacing = 13.
	return (i - GRID * .5) * spacing + 3.3

func _rand3(f:float)-> Vector3:
	return Vector3(_rand(f), _rand(f), _rand(f))

func _rand(f:float)-> float:
	return f * randf_range(-1,+1)

func _on_audio_finished() -> void:
	audio.play();
