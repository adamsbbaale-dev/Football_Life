extends Node2D

var city_root: Node2D
var apartment_root: Node2D
var stadium_root: Node2D
var ui_layer: CanvasLayer
var log_label: RichTextLabel
var stats_label: RichTextLabel
var player: CharacterBody2D
var current_scene: String = "apartment"
var npc_list: Array = []

func _ready() -> void:
    Game.connect("stats_changed", _refresh_hud)
    build_world()
    build_ui()
    player = create_player()
    spawn_npcs()
    travel_to("apartment")
    show_message("Welcome to Metro Bay. Your apartment is your home base. Your player can roam the city, buy gear, and prepare for matches.")
    _refresh_hud()

func build_world() -> void:
    city_root = Node2D.new(); city_root.name = "CityRoot"; add_child(city_root)
    apartment_root = Node2D.new(); apartment_root.name = "ApartmentRoot"; add_child(apartment_root)
    stadium_root = Node2D.new(); stadium_root.name = "StadiumRoot"; add_child(stadium_root)

    build_city_layout()
    build_apartment_layout()
    build_stadium_layout()

func add_polygon(target: Node2D, points: Array, color: Color, name: String = "shape") -> void:
    var poly := Polygon2D.new()
    poly.name = name
    poly.polygon = PackedVector2Array(points)
    poly.color = color
    target.add_child(poly)

func build_city_layout() -> void:
    var road := Line2D.new()
    road.width = 42
    road.default_color = Color(0.16, 0.18, 0.2)
    road.add_point(Vector2(0, 170))
    road.add_point(Vector2(1200, 170))
    road.add_point(Vector2(1200, 540))
    road.add_point(Vector2(0, 540))
    city_root.add_child(road)

    for i in range(8):
        var b := Polygon2D.new()
        b.polygon = PackedVector2Array([
            Vector2(50 + i * 120, 40),
            Vector2(150 + i * 120, 40),
            Vector2(150 + i * 120, 120),
            Vector2(50 + i * 120, 120)
        ])
        b.color = Color(0.2 + float(i) * 0.04, 0.34, 0.42)
        city_root.add_child(b)

    add_polygon(city_root, [Vector2(150, 210), Vector2(910, 210), Vector2(910, 340), Vector2(150, 340)], Color(0.22, 0.32, 0.42), "MainStreet")
    add_polygon(city_root, [Vector2(960, 210), Vector2(1130, 210), Vector2(1130, 410), Vector2(960, 410)], Color(0.38, 0.38, 0.4), "Garage")
    add_polygon(city_root, [Vector2(110, 600), Vector2(420, 600), Vector2(420, 710), Vector2(110, 710)], Color(0.45, 0.31, 0.28), "Clinic")
    add_polygon(city_root, [Vector2(500, 640), Vector2(760, 640), Vector2(760, 710), Vector2(500, 710)], Color(0.42, 0.22, 0.45), "ClothesShop")
    add_polygon(city_root, [Vector2(820, 620), Vector2(1040, 620), Vector2(1040, 700), Vector2(820, 700)], Color(0.18, 0.6, 0.54), "StreetPitch")

func build_apartment_layout() -> void:
    add_polygon(apartment_root, [Vector2(180, 100), Vector2(660, 100), Vector2(660, 540), Vector2(180, 540)], Color(0.2, 0.18, 0.24), "ApartmentFloor")
    add_polygon(apartment_root, [Vector2(230, 160), Vector2(330, 160), Vector2(330, 260), Vector2(230, 260)], Color(0.55, 0.48, 0.42), "Bed")
    add_polygon(apartment_root, [Vector2(390, 160), Vector2(540, 160), Vector2(540, 210), Vector2(390, 210)], Color(0.47, 0.5, 0.6), "Table")
    add_polygon(apartment_root, [Vector2(430, 290), Vector2(530, 290), Vector2(530, 480), Vector2(430, 480)], Color(0.6, 0.45, 0.3), "Wardrobe")
    add_polygon(apartment_root, [Vector2(260, 370), Vector2(350, 370), Vector2(350, 470), Vector2(260, 470)], Color(0.75, 0.76, 0.8), "Sofa")

func build_stadium_layout() -> void:
    add_polygon(stadium_root, [Vector2(80, 80), Vector2(1150, 80), Vector2(1150, 670), Vector2(80, 670)], Color(0.17, 0.19, 0.25), "StadiumMain")
    add_polygon(stadium_root, [Vector2(180, 170), Vector2(980, 170), Vector2(980, 550), Vector2(180, 550)], Color(0.11, 0.52, 0.25), "Pitch")
    add_polygon(stadium_root, [Vector2(200, 210), Vector2(960, 210), Vector2(960, 510), Vector2(200, 510)], Color(0.18, 0.24, 0.18), "PitchMarkings")
    add_polygon(stadium_root, [Vector2(260, 280), Vector2(440, 280), Vector2(440, 430), Vector2(260, 430)], Color(0.6, 0.62, 0.66), "HomeStand")
    add_polygon(stadium_root, [Vector2(720, 280), Vector2(900, 280), Vector2(900, 430), Vector2(720, 430)], Color(0.65, 0.62, 0.58), "AwayStand")

func build_ui() -> void:
    ui_layer = CanvasLayer.new(); add_child(ui_layer)

    var panel := PanelContainer.new(); panel.position = Vector2(18, 18); panel.custom_minimum_size = Vector2(320, 560); ui_layer.add_child(panel)
    var margin := MarginContainer.new(); margin.offset_left = 10; margin.offset_top = 10; margin.offset_right = 10; margin.offset_bottom = 10; panel.add_child(margin)
    var vbox := VBoxContainer.new(); margin.add_child(vbox)

    var title := Label.new(); title.text = "Football Life"; title.add_theme_font_size_override("font_size", 24); vbox.add_child(title)

    stats_label = RichTextLabel.new(); stats_label.bbcode_enabled = true; stats_label.fit_content = true; stats_label.custom_minimum_size = Vector2(260, 150); vbox.add_child(stats_label)

    var buttons := [
        ["Apartment", _go_to_apartment],
        ["City", _go_to_city],
        ["Stadium", _go_to_stadium],
        ["Buy Clothes", _buy_clothes],
        ["Car Shop", _buy_car],
        ["Clinic", _restore_health],
        ["Start Match", _start_match],
        ["Transfer Interest", _check_transfer_interest],
        ["Change Outfit", _cycle_outfit],
    ]

    for item in buttons:
        var button: Button = Button.new(); button.text = item[0]; button.pressed.connect(item[1]); vbox.add_child(button)

    log_label = RichTextLabel.new(); log_label.bbcode_enabled = true; log_label.fit_content = true; log_label.custom_minimum_size = Vector2(260, 220); vbox.add_child(log_label)

func _refresh_hud() -> void:
    if stats_label == null:
        return
    var team = Game.next_team_for_rating()
    stats_label.clear()
    stats_label.append_text("[b]Player:[/b] %s\n" % Game.player_name)
    stats_label.append_text("[b]Club:[/b] %s\n" % Game.club_name)
    stats_label.append_text("[b]City:[/b] %s\n" % Game.city_name)
    stats_label.append_text("[b]Money:[/b] $%d\n" % Game.money)
    stats_label.append_text("[b]Rating:[/b] %d\n" % Game.rating)
    stats_label.append_text("[b]Health:[/b] %d\n" % Game.health)
    stats_label.append_text("[b]Outfit:[/b] %s\n" % Game.current_outfit)
    stats_label.append_text("[b]Transfer Interest:[/b] %s\n" % team)

func show_message(message: String) -> void:
    if log_label == null:
        return
    log_label.clear()
    log_label.append_text("[color=#d8e5ff]%s[/color]" % message)

func create_player() -> CharacterBody2D:
    var new_player = CharacterBody2D.new(); new_player.name = "Player"; new_player.set_script(load("res://scripts/Player.gd")); add_child(new_player)
    new_player.position = Vector2(300, 220)
    return new_player

func spawn_npcs() -> void:
    var names := ["Maya", "Chris", "Dani"]
    var moods := ["friendly", "neutral", "angry"]
    var colors := [Color(0.86, 0.52, 0.66), Color(0.34, 0.68, 0.86), Color(0.72, 0.44, 0.54)]
    for i in range(names.size()):
        var npc = load("res://scripts/NPC.gd").new()
        npc.npc_name = names[i]
        npc.mood = moods[i]
        npc.body_color = colors[i]
        npc.position = Vector2(430 + i * 120, 360 + (i % 2) * 60)
        city_root.add_child(npc)
        npc_list.append(npc)

func travel_to(scene_name: String) -> void:
    current_scene = scene_name
    Game.current_scene = scene_name
    city_root.visible = scene_name == "city"
    apartment_root.visible = scene_name == "apartment"
    stadium_root.visible = scene_name == "stadium"
    player.visible = true

    if scene_name == "city":
        player.position = Vector2(320, 420)
        show_message("You roam the city. Shops, street pitches, and the stadium are all nearby.")
    elif scene_name == "apartment":
        player.position = Vector2(350, 330)
        show_message("You return to your apartment, where you can change clothes and rest.")
    elif scene_name == "stadium":
        player.position = Vector2(560, 430)
        show_message("You enter the stadium. Players walk out to the pitch and the match atmosphere builds.")
    Game.update_stats()

func _go_to_apartment() -> void:
    travel_to("apartment")

func _go_to_city() -> void:
    travel_to("city")

func _go_to_stadium() -> void:
    travel_to("stadium")

func _buy_clothes() -> void:
    if Game.buy_item("clothes", 240):
        Game.current_outfit = "Street"
        player.switch_outfit("Street")
        show_message("You buy a new street outfit. The city style changes your look.")
    else:
        show_message("Not enough money for new clothes.")
    Game.update_stats()

func _buy_car() -> void:
    if Game.buy_item("car", 1800):
        show_message("You buy a new city car. Driving around Metro Bay is now available in the next expansion.")
    else:
        show_message("The garage says the car is out of budget for now.")
    Game.update_stats()

func _restore_health() -> void:
    Game.restore_health(30)
    show_message("Your health is restored at the clinic. You feel ready for the next match.")
    Game.update_stats()

func _cycle_outfit() -> void:
    var index := Game.outfits.find(Game.current_outfit)
    var next_index := (index + 1) % Game.outfits.size()
    Game.change_outfit(Game.outfits[next_index])
    player.switch_outfit(Game.current_outfit)
    show_message("You change into %s kit." % Game.current_outfit)
    Game.update_stats()

func _check_transfer_interest() -> void:
    var next_team := Game.next_team_for_rating()
    show_message("The market is watching. %s are interested in your profile if your rating remains around %d." % [next_team, Game.rating])

func _start_match() -> void:
    var match_data := MatchManager.begin_match(Game.player_name, Game.club_name, Game.rating, Game.current_match_type)
    Game.money += match_data["bonus"]
    Game.reputation += 8
    Game.rating = clampi(Game.rating + 1, 50, 99)
    player.switch_outfit("Match")
    Game.current_outfit = "Match"
    show_message(match_data["result_text"] + " Result: %d-%d. Trophy scene: %s." % [match_data["home_score"], match_data["away_score"], "Yes" if match_data["trophy_scene"] else "Not yet"])
    if match_data["trophy_scene"]:
        show_message("The captain lifts the trophy while the squad celebrates. The medal ceremony follows with the entire team smiling and fans cheering.")
    Game.update_stats()
    travel_to("stadium")
