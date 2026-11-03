extends RefCounted
class_name MatchManager

static func begin_match(player_name: String, club_name: String, rating: int, match_type: String = "League") -> Dictionary:
    var home_score := 1 + int(rating / 30)
    var away_score := randi_range(0, 2)
    var trophy_bonus := 500 + (rating * 12)
    var scenario := "League Match"

    if match_type == "Final":
        scenario = "Championship Final"
        trophy_bonus += 1500

    var story := "%s and %s walk to the pitch together. The anthem plays, players greet each other, and the crowd roars before kickoff. This is the %s." % [player_name, club_name, scenario]

    return {
        "result_text": story,
        "home_score": home_score,
        "away_score": away_score,
        "match_type": scenario,
        "bonus": trophy_bonus,
        "trophy_scene": home_score >= away_score,
    }
