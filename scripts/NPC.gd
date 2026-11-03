extends CharacterBody2D
class_name FootballNPC

var npc_name: String = "NPC"
var mood: String = "friendly"
var relationship_value: int = 0
var body_color: Color = Color(0.85, 0.58, 0.78)

func _ready() -> void:
    var square := Polygon2D.new()
    square.polygon = PackedVector2Array([
        Vector2(-10, -12), Vector2(10, -12), Vector2(10, 12), Vector2(-10, 12)
    ])
    square.color = body_color
    add_child(square)

func set_mood(value: String) -> void:
    mood = value
    if mood == "angry":
        body_color = Color(0.82, 0.14, 0.19)
    elif mood == "happy":
        body_color = Color(0.31, 0.76, 0.38)
    elif mood == "sad":
        body_color = Color(0.45, 0.48, 0.86)
    else:
        body_color = Color(0.85, 0.58, 0.78)

func ask_for_money() -> String:
    if mood == "angry":
        relationship_value -= 12
        return "%s gets angry and refuses to help." % npc_name
    if mood == "friendly":
        relationship_value += 6
        return "%s smiles and gives a small favor in return." % npc_name
    relationship_value -= 4
    return "%s looks disappointed and asks again later." % npc_name
