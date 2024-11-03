extends Node3D

var root_scene = "res://root.tscn"

@onready var background = $Background
@onready var chique = $"Node3D/Node3D/toon/AnimationPlayer"
@onready var boxo = $"Node3D/Node3D"
@onready var ground = $Node3D/Node3D/Ground
@onready var flopster = $Start/Flopster
@onready var audio = $AudioStreamPlayer3D
@onready var camera = $Camera3D
@onready var labels = $Start/Labels
@onready var title = $Title
@onready var man = $Man

var last_label:Label3D = null
var start_time : float = .0
var last_second : int = 0

var OFFSET = Vector2(.0,.0)
var GO = Vector2(.0,.0)
const BLACK = Color(.0,.0,.0)
const WHITE = Color(1.,1.,1.)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var s = .22
	flopster.scale = Vector3(s,s,s)
	flopster.light.visible = false
	start_time = now();
	chique.play("running")

func now() -> float:
	return Time.get_unix_time_from_system()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	chique.play("running")
	background.get_active_material(0).set_shader_parameter("OFFSET", OFFSET)
	
	var elapsed = now()
	var sex = int(elapsed)
	var tex = int(elapsed * 6.)
	
	if elapsed - start_time > 3. and  tex != last_second:
		title.text = title.text.substr(1) + title.text[0]
		last_second = tex
	
	var f = .000300
	if sex % 2:
		OFFSET.x += f
	else:
		OFFSET.y += f
	
	var b4 = sex % 4
	boxo.rotation.y = deg_to_rad(b4 * 90)
	GO.y += .01
	ground.get_active_material(0).set_shader_parameter("OFFSET", GO)
	
	var iTime = int(elapsed * .125) % flopster.icons.size()
	flopster.iconic(flopster.icons[iTime])

func start_game() -> void:
	get_tree().change_scene_to_file(root_scene)

func end_game() -> void:
	# TODO prompt
	UtilMe.quit()

func show_info() -> void:
	man.visible = true

func _on_audio_stream_player_3d_finished() -> void:
	audio.play()

########################################################################################################
# event handling is boring...

func _input(event) -> void:
	if Input.is_action_just_pressed("ui_fullscreen"):
		return UtilMe.toggle_fullscreen()
		
	if event.is_action_pressed("ui_mute"):
		UtilMe.toggle_mute()
		return
		
	var accept = event.is_action_pressed("ui_accept")
	var renounce = event.is_action_pressed("ui_renounce") or event.is_action_pressed("ui_quit")
	var mouse_press = event is InputEventMouseButton and event.pressed 
		
	if man.visible:
		if accept or renounce or mouse_press:
			man.visible = false
		return

	if accept:
		start_game()
	if renounce:
		end_game()
	
	if event is InputEventMouseMotion:
		mouse_move(event)
	if mouse_press:
		mouse_click(event)

func mouse_move(_event):	
	var under = UtilMe.camera_mouse(labels, camera)
	if not under:
		if last_label:
			last_label.outline_modulate = BLACK
			last_label = null
		return
		
	var parent = under.get_parent()
	if not parent is Label3D:
		if last_label:
			last_label.outline_modulate = BLACK
			last_label = null
		return
		
	var label : Label3D = parent
	if last_label and label != last_label:
		last_label.outline_modulate = BLACK
	last_label = label
	label.outline_modulate = WHITE

func mouse_click(_event) -> void:
	if not last_label:
		return
	if "Enter" == last_label.name:
		return start_game()
	if "Escape" == last_label.name:
		return end_game()
	if "Information" == last_label.name:
		return show_info()
