extends CharacterBody2D
class_name PlayerCharacter

const COLORS := {
    "Casual": Color(0.74, 0.58, 0.28),
    "Street": Color(0.82, 0.39, 0.24),
    "Training": Color(0.28, 0.54, 0.82),
    "Match": Color(0.18, 0.68, 0.38)
}

var body: Polygon2D
var shadow: Polygon2D
var speed: float = 180.0
var outfit: String = "Casual"

func _ready() -> void:
    body = Polygon2D.new()
    body.polygon = PackedVector2Array([
        Vector2(-12, -18), Vector2(12, -18), Vector2(16, 18), Vector2(-16, 18)
    ])
    body.color = COLORS[outfit]
    add_child(body)

    shadow = Polygon2D.new()
    shadow.polygon = PackedVector2Array([
        Vector2(-14, 18), Vector2(14, 18), Vector2(18, 22), Vector2(-18, 22)
    ])
    shadow.color = Color(0, 0, 0, 0.35)
    add_child(shadow)

func _physics_process(_delta: float) -> void:
    var input_vec := Vector2.ZERO
    if Input.is_action_pressed("ui_left"):
        input_vec.x -= 1
    if Input.is_action_pressed("ui_right"):
        input_vec.x += 1
    if Input.is_action_pressed("ui_up"):
        input_vec.y -= 1
    if Input.is_action_pressed("ui_down"):
        input_vec.y += 1

    if input_vec.length() > 0:
        velocity = input_vec.normalized() * speed
    else:
        velocity = Vector2.ZERO
    move_and_slide()

func switch_outfit(new_outfit: String) -> void:
    if COLORS.has(new_outfit):
        outfit = new_outfit
        body.color = COLORS[new_outfit]

func set_player_name(_name: String) -> void:
    pass
