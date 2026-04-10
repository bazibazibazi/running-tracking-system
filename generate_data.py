import random
from datetime import date, timedelta

random.seed(42)

# =========================
# CONFIG
# =========================
RUNNERS_COUNT = 1200
ROUTES_COUNT = 250
ACHIEVEMENT_TYPES_COUNT = 12
SHOES_COUNT = 2400
ACTIVITIES_COUNT = 36000
TRAINING_GOALS_COUNT = 1800
RUNNER_ACHIEVEMENTS_COUNT = 5000
TELEMETRY_POINTS_MIN = 20
TELEMETRY_POINTS_MAX = 40

OUTPUT_FILE = "generated_data.sql"

# =========================
# HELPERS
# =========================
def rand_date(start: date, end: date) -> date:
    delta = (end - start).days
    return start + timedelta(days=random.randint(0, delta))

def sql_date(d: date) -> str:
    return f"DATE '{d.isoformat()}'"

def clamp(value, min_v, max_v):
    return max(min_v, min(value, max_v))

def escape_sql(text: str) -> str:
    return text.replace("'", "''")

# =========================
# LOOKUP DATA
# =========================
first_names_m = ["Jakub", "Adam", "Tobiasz", "Kamil", "Piotr", "Marek", "Jan", "Pawel", "Michal", "Krzysztof"]
first_names_f = ["Anna", "Julia", "Marta", "Natalia", "Katarzyna", "Oliwia", "Zuzanna", "Magdalena", "Alicja", "Karolina"]
last_names = ["Kaminski", "Nowak", "Kowalski", "Wojcik", "Lewandowski", "Zielinski", "Szymanski", "Kaczmarek", "Mazur", "Pawlak"]

surface_types = ["Asphalt", "Mixed", "Trail", "Gravel"]
activity_types = ["Easy Run", "Long Run", "Tempo Run", "Recovery Run", "Intervals"]

achievement_types = [
    ("First 5K", "Complete your first 5 km run", "distance", 5),
    ("First 10K", "Complete your first 10 km run", "distance", 10),
    ("First Half Marathon", "Complete your first half marathon", "distance", 21),
    ("10 Activities Completed", "Complete 10 activities", "count", 10),
    ("50 km in a Month", "Run 50 km in one month", "distance", 50),
    ("100 km in a Month", "Run 100 km in one month", "distance", 100),
    ("Long Run 15K", "Complete a run longer than 15 km", "distance", 15),
    ("Tempo Specialist", "Complete multiple tempo runs", "count", 5),
    ("Endurance Badge", "Build strong endurance", "count", 20),
    ("Consistent Runner", "Run regularly for a period", "count", 15),
    ("Trail Explorer", "Complete trail routes", "count", 5),
    ("Fast 5K", "Achieve a fast 5 km result", "performance", 5),
]

goal_names = [
    "Run 100 km this month",
    "Run 150 km this month",
    "Complete 20 activities in 3 months",
    "Half marathon under 2 hours",
    "Improve endurance",
    "Stay consistent for 8 weeks",
]

shoe_models = [
    "Nike Pegasus", "Adidas Boston", "Asics Novablast", "Hoka Clifton",
    "Saucony Ride", "Brooks Ghost", "New Balance 1080", "Puma Velocity",
    "Nike Invincible", "Asics Gel Cumulus"
]

# Real-ish Poland bounding box
# latitude: ~49.0 - 54.8
# longitude: ~14.1 - 24.2
def random_poland_gps():
    lat = round(random.uniform(49.0, 54.8), 6)
    lon = round(random.uniform(14.1, 24.2), 6)
    return f"{lat},{lon}"

# =========================
# GENERATION STORAGE
# =========================
route_distances = {}
activity_info = []  # (activity_id, runner_id, route_id, activity_date, avg_bpm)

# =========================
# GENERATE SQL
# =========================
with open(OUTPUT_FILE, "w", encoding="utf-8") as f:

    # Optional cleanup order
    f.write("-- CLEANUP\n")
    f.write("DELETE FROM Runner_Achievements;\n")
    f.write("DELETE FROM Telemetry_Data;\n")
    f.write("DELETE FROM Training_Goals;\n")
    f.write("DELETE FROM Activities;\n")
    f.write("DELETE FROM Shoes;\n")
    f.write("DELETE FROM Achievements_Types;\n")
    f.write("DELETE FROM Routes;\n")
    f.write("DELETE FROM Runners;\n")
    f.write("COMMIT;\n\n")

    # =========================
    # RUNNERS
    # =========================
    f.write("-- RUNNERS\n")
    for runner_id in range(1, RUNNERS_COUNT + 1):
        sex = "Male" if random.random() < 0.55 else "Female"
        first_name = random.choice(first_names_m if sex == "Male" else first_names_f)
        last_name = random.choice(last_names)
        full_name = escape_sql(f"{first_name} {last_name}")

        weight = round(random.uniform(52, 98), 1)
        height = random.randint(155, 198)
        join_date = rand_date(date(2024, 1, 1), date(2026, 3, 31))
        birthday = rand_date(date(1970, 1, 1), date(2007, 12, 31))

        f.write(
            f"INSERT INTO Runners (runner_id, full_name, sex, weight_kg, height, join_date, birthday_date) "
            f"VALUES ({runner_id}, '{full_name}', '{sex}', {weight}, {height}, {sql_date(join_date)}, {sql_date(birthday)});\n"
        )
    f.write("COMMIT;\n\n")

    # =========================
    # ROUTES
    # =========================
    f.write("-- ROUTES\n")
    for route_id in range(1, ROUTES_COUNT + 1):
        p = random.random()
        if p < 0.40:
            distance = round(random.uniform(3, 6), 2)
        elif p < 0.75:
            distance = round(random.uniform(6, 10), 2)
        elif p < 0.95:
            distance = round(random.uniform(10, 18), 2)
        else:
            distance = round(random.uniform(18, 25), 2)

        surface = random.choices(
            surface_types,
            weights=[45, 25, 20, 10],
            k=1
        )[0]

        base_elev = {
            "Asphalt": random.uniform(0, 120),
            "Mixed": random.uniform(20, 250),
            "Trail": random.uniform(50, 500),
            "Gravel": random.uniform(10, 200),
        }[surface]

        elevation = round(base_elev, 1)

        diff = 1
        if distance > 6:
            diff += 1
        if distance > 12:
            diff += 1
        if elevation > 100:
            diff += 1
        if elevation > 250:
            diff += 1
        difficulty = clamp(diff, 1, 5)

        creation_date = rand_date(date(2024, 1, 1), date(2025, 12, 31))
        route_distances[route_id] = distance

        f.write(
            f"INSERT INTO Routes (route_id, distance_km, creation_date, elevation_gain, surface_type, difficulty_level) "
            f"VALUES ({route_id}, {distance}, {sql_date(creation_date)}, {elevation}, '{surface}', {difficulty});\n"
        )
    f.write("COMMIT;\n\n")

    # =========================
    # ACHIEVEMENTS TYPES
    # =========================
    f.write("-- ACHIEVEMENTS_TYPES\n")
    for achievement_type_id, (name, desc, cond, value) in enumerate(achievement_types, start=1):
        f.write(
            f"INSERT INTO Achievements_Types (achievement_type_id, name, description, condition_type, value) "
            f"VALUES ({achievement_type_id}, '{escape_sql(name)}', '{escape_sql(desc)}', '{cond}', {value});\n"
        )
    f.write("COMMIT;\n\n")

    # =========================
    # SHOES
    # =========================
    f.write("-- SHOES\n")
    for shoe_id in range(1, SHOES_COUNT + 1):
        runner_id = random.randint(1, RUNNERS_COUNT)
        shoe_uses = random.randint(0, 900)
        purchase_date = rand_date(date(2024, 1, 1), date(2026, 3, 31))
        model = escape_sql(random.choice(shoe_models))
        shoe_size = random.randint(38, 47)
        recommended_usage = random.randint(500, 900)

        f.write(
            f"INSERT INTO Shoes (shoe_id, runner_id, shoe_uses, purchase_date, model, shoe_size, recommended_usage) "
            f"VALUES ({shoe_id}, {runner_id}, {shoe_uses}, {sql_date(purchase_date)}, '{model}', {shoe_size}, {recommended_usage});\n"
        )
    f.write("COMMIT;\n\n")

    # =========================
    # ACTIVITIES
    # =========================
    f.write("-- ACTIVITIES\n")

    # More realistic runner activity distribution
    low_users = list(range(1, int(RUNNERS_COUNT * 0.50) + 1))
    mid_users = list(range(int(RUNNERS_COUNT * 0.50) + 1, int(RUNNERS_COUNT * 0.85) + 1))
    high_users = list(range(int(RUNNERS_COUNT * 0.85) + 1, int(RUNNERS_COUNT * 0.97) + 1))
    pro_users = list(range(int(RUNNERS_COUNT * 0.97) + 1, RUNNERS_COUNT + 1))

    for activity_id in range(1, ACTIVITIES_COUNT + 1):
        p_user = random.random()

        if p_user < 0.35:
            runner_id = random.choice(low_users)
        elif p_user < 0.75:
            runner_id = random.choice(mid_users)
        elif p_user < 0.95:
            runner_id = random.choice(high_users)
        else:
            runner_id = random.choice(pro_users)

        route_id = random.randint(1, ROUTES_COUNT)
        distance = route_distances[route_id]

        activity_type = random.choices(
            activity_types,
            weights=[40, 20, 15, 15, 10],
            k=1
        )[0]

        if random.random() < 0.70:
            activity_date = rand_date(date(2026, 1, 1), date(2026, 12, 31))
        else:
            activity_date = rand_date(date(2025, 1, 1), date(2025, 12, 31))

        if activity_type == "Easy Run":
            base_pace = random.uniform(5.2, 6.8)
            avg_bpm = random.randint(132, 155)
        elif activity_type == "Recovery Run":
            base_pace = random.uniform(5.8, 7.2)
            avg_bpm = random.randint(125, 148)
        elif activity_type == "Long Run":
            base_pace = random.uniform(5.1, 6.5)
            avg_bpm = random.randint(138, 160)
        elif activity_type == "Tempo Run":
            base_pace = random.uniform(4.2, 5.4)
            avg_bpm = random.randint(155, 172)
        else:
            base_pace = random.uniform(3.8, 5.0)
            avg_bpm = random.randint(160, 178)

        duration = int(round(distance * base_pace + random.uniform(-3, 6)))
        duration = max(duration, 15)

        max_bpm = clamp(avg_bpm + random.randint(5, 18), avg_bpm + 1, 198)
        min_bpm = clamp(avg_bpm - random.randint(8, 20), 90, avg_bpm - 1)

        activity_info.append((activity_id, runner_id, route_id, activity_date, avg_bpm, activity_type, base_pace))

        f.write(
            f"INSERT INTO Activities (activity_id, runner_id, route_id, activity_type, duration_min, activity_date, avg_bpm, max_bpm, min_bpm) "
            f"VALUES ({activity_id}, {runner_id}, {route_id}, '{activity_type}', {duration}, {sql_date(activity_date)}, {avg_bpm}, {max_bpm}, {min_bpm});\n"
        )
    f.write("COMMIT;\n\n")

    # =========================
    # TRAINING_GOALS
    # =========================
    f.write("-- TRAINING_GOALS\n")
    for goal_id in range(1, TRAINING_GOALS_COUNT + 1):
        runner_id = random.randint(1, RUNNERS_COUNT)
        goal_name = escape_sql(random.choice(goal_names))
        target_value = random.randint(20, 200)
        current_value = random.randint(0, target_value)
        deadline = rand_date(date(2026, 1, 1), date(2026, 12, 31))
        status = 1 if current_value >= target_value else 0
        goal_description = escape_sql(f"Goal related to {goal_name}")

        f.write(
            f"INSERT INTO Training_Goals (goal_id, runner_id, goal_name, target_value, current_value, deadline, status, goal_description) "
            f"VALUES ({goal_id}, {runner_id}, '{goal_name}', {target_value}, {current_value}, {sql_date(deadline)}, {status}, '{goal_description}');\n"
        )
    f.write("COMMIT;\n\n")

    # =========================
    # TELEMETRY DATA
    # =========================
    f.write("-- TELEMETRY_DATA\n")
    telemetry_id = 1

    for activity_id, runner_id, route_id, activity_date, avg_bpm, activity_type, base_pace in activity_info:
        points = random.randint(TELEMETRY_POINTS_MIN, TELEMETRY_POINTS_MAX)

        for _ in range(points):
            heart_rate = clamp(int(round(random.gauss(avg_bpm, 6))), 110, 195)

            if activity_type == "Intervals":
                pace = round(clamp(random.gauss(base_pace, 0.35), 3.5, 6.5), 2)
                running_power = random.randint(260, 420)
            elif activity_type == "Tempo Run":
                pace = round(clamp(random.gauss(base_pace, 0.30), 3.8, 6.8), 2)
                running_power = random.randint(230, 380)
            elif activity_type == "Long Run":
                pace = round(clamp(random.gauss(base_pace, 0.25), 4.5, 7.2), 2)
                running_power = random.randint(200, 330)
            elif activity_type == "Recovery Run":
                pace = round(clamp(random.gauss(base_pace, 0.25), 5.0, 7.8), 2)
                running_power = random.randint(180, 290)
            else:
                pace = round(clamp(random.gauss(base_pace, 0.25), 4.3, 7.5), 2)
                running_power = random.randint(190, 320)

            footsteps = random.randint(150, 190)
            gps_location = random_poland_gps()

            f.write(
                f"INSERT INTO Telemetry_Data (telemetry_id, activity_id, heart_rate_bpm, gps_location, recorded_time, pace, running_power, footsteps) "
                f"VALUES ({telemetry_id}, {activity_id}, {heart_rate}, '{gps_location}', {sql_date(activity_date)}, {pace}, {running_power}, {footsteps});\n"
            )
            telemetry_id += 1

    f.write("COMMIT;\n\n")

    # =========================
    # RUNNER_ACHIEVEMENTS
    # =========================
    f.write("-- RUNNER_ACHIEVEMENTS\n")
    for runner_achievement_id in range(1, RUNNER_ACHIEVEMENTS_COUNT + 1):
        activity_id, runner_id, route_id, activity_date, avg_bpm, activity_type, base_pace = random.choice(activity_info)
        achievement_type_id = random.randint(1, ACHIEVEMENT_TYPES_COUNT)
        date_earned = activity_date

        f.write(
            f"INSERT INTO Runner_Achievements (runner_achievement_id, runner_id, achievement_type_id, date_earned, activity_id) "
            f"VALUES ({runner_achievement_id}, {runner_id}, {achievement_type_id}, {sql_date(date_earned)}, {activity_id});\n"
        )
    f.write("COMMIT;\n")

print(f"Generated file: {OUTPUT_FILE}")