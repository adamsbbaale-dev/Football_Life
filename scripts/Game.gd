extends Node

var player_name: String = "Alex Carter"
var player_face: String = "Default Face"
var club_name: String = "Northbridge FC"
var city_name: String = "Metro Bay"
var money: int = 6500
var reputation: int = 35
var rating: int = 72
var health: int = 100
var energy: int = 100
var current_scene: String = "apartment"
var relationship_points: Dictionary = {
    "Maya": 0,
    "Chris": 0,
    "Dani": 0
}
var outfits: Array[String] = ["Casual", "Street", "Training", "Match"]
var current_outfit: String = "Casual"
var current_match_type: String = "League"

signal stats_changed

func _ready() -> void:
    pass

func update_stats() -> void:
    emit_signal("stats_changed")

func buy_item(item_name: String, cost: int) -> bool:
    if money < cost:
        return false
    money -= cost
    emit_signal("stats_changed")
    return true

func restore_health(amount: int) -> void:
    health = clampi(health + amount, 0, 100)
    emit_signal("stats_changed")

func change_outfit(name: String) -> bool:
    if not outfits.has(name):
        return false
    current_outfit = name
    emit_signal("stats_changed")
    return true

func add_relationship(name: String, value: int) -> void:
    if not relationship_points.has(name):
        relationship_points[name] = 0
    relationship_points[name] += value
    if relationship_points[name] > 100:
        relationship_points[name] = 100
    if relationship_points[name] < -100:
        relationship_points[name] = -100

func next_team_for_rating() -> String:
    if rating >= 85:
        return "European Elite"
    if rating >= 75:
        return "Top League"
    if rating >= 70:
        return "Mid Table"
    return "Development Squad"

func save_state() -> Dictionary:
    return {
        "player_name": player_name,
        "player_face": player_face,
        "club_name": club_name,
        "city_name": city_name,
        "money": money,
        "reputation": reputation,
        "rating": rating,
        "health": health,
        "energy": energy,
        "current_scene": current_scene,
        "current_outfit": current_outfit,
        "relationship_points": relationship_points
    }
