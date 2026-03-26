import json
import urllib.request
from datetime import datetime, timedelta

def fetch_neo_data(start_date: str, end_date: str) -> dict:
    url = (
        f"https://api.nasa.gov/neo/rest/v1/feed"
        f"?start_date={start_date}&end_date={end_date}&api_key=DEMO_KEY"
    )
    with urllib.request.urlopen(url, timeout=10) as response:
        return json.loads(response.read().decode())
    
def transform(raw: dict) -> list[dict]:
    results = []

    for date, asteroids in raw["near_earth_objects"].items():
        for obj in asteroids:
            approach = obj["close_approach_data"][0]
            diam = obj["estimated_diameter"]["meters"]

            results.append({
                "id": obj["id"],
                "name": obj["name"],
                "close_approach_date": date,
                "min_diameter_m": round(diam["estimated_diameter_min"], 1),
                "max_diameter_m": round(diam["estimated_diameter_max"], 1),
                "miss_distance_km": round(float(approach["miss_distance"]["kilometers"]), 0),
                "miss_distance_lunar": round(float(approach["miss_distance"]["lunar"]), 2),
                "speed_km_s": round(float(approach["relative_velocity"]["kilometers_per_second"]), 2),
                "is_potentially_hazardous": obj["is_potentially_hazardous_asteroid"],
                "threat_level": derive_threat_level(
                    obj["is_potentially_hazardous_asteroid"],
                    round(float(approach["miss_distance"]["lunar"]), 2),
                    diam["estimated_diameter_max"],
                )
            })

    results.sort(key=lambda x: x["miss_distance_km"])

    return results

def derive_threat_level(hazardous: bool, miss_lunar: float, max_diam_m: float) -> str:
    if hazardous and miss_lunar < 1 and max_diam_m > 140:
        return "critical"
    elif hazardous and miss_lunar < 5:
        return "elevated"
    elif hazardous:
        return "watch"
    else:
        return "nominal"

if __name__ == "__main__":
    start = datetime.utcnow().strftime("%Y-%m-%d")
    end = (datetime.utcnow() + timedelta(days=7)).strftime("%Y-%m-%d")
    raw = fetch_neo_data(start, end)
    transformed = transform(raw)
    print(json.dumps(transformed[0], indent=2))