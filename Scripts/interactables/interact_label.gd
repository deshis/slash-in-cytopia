extends Label3D

@export var hitbox: Area3D
@export var interactable_object: Node

var interact_keybind = null


func _ready() -> void:
	hitbox.body_entered.connect(_on_body_entered)
	hitbox.body_exited.connect(_on_body_exited)
	visible = false


func _physics_process(_delta: float) -> void:
	if not GameManager.player or GameManager.player is not Player:
		return
	
	var interactables = GameManager.player.interactables
	if interactables.size() < 1:
		visible = false
		return
	
	update_interact_keybind()
	if interactables.front() == get_parent():
		visible = true
		var p_rot = get_parent().rotation
		rotation = Vector3(rotation.x, -p_rot.y, -p_rot.z)
	else:
		visible = false

func update_interact_keybind() -> void:
	var keybind = Helper.get_keybind("interact")
	
	if keybind == interact_keybind:
		return
	
	text = "[%s] Interact" % keybind

func _on_body_entered(_body: Node3D) -> void:
	GameManager.player.interactables.append(get_parent())
	
	if not interactable_object:
		return
	
	if interactable_object.has_method("on_interaction_area_entered"):
		interactable_object.on_interaction_area_entered()


func _on_body_exited(_body: Node3D) -> void:
	GameManager.player.interactables.erase(get_parent())
	
	if not interactable_object:
		return
	
	if interactable_object.has_method("on_interaction_area_exited"):
		interactable_object.on_interaction_area_exited()
