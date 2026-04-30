import os
from typing import List, Optional
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime

# 1. Initialize Firebase
# Make sure to place your serviceAccountKey.json in the backend_ai folder
cred_path = os.path.join(os.path.dirname(__file__), "serviceAccountKey.json")
if os.path.exists(cred_path):
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)
else:
    # Fallback for environments where key is provided via env vars (like Render/Railway)
    # This requires GOOGLE_APPLICATION_CREDENTIALS to be set
    firebase_admin.initialize_app()

db = firestore.client()

app = FastAPI(title="AIQ Smart Scheduler AI")

# --- Models ---

class TaskRequest(BaseModel):
    companyId: str
    requiredSkills: List[str]
    startTime: datetime
    endTime: datetime

class EmployeeRecommendation(BaseModel):
    userId: str
    name: str
    score: float
    workload: float
    skillMatch: float
    isAvailable: bool

# --- AI Logic Helpers ---

def calculate_skill_match(user_skills: List[str], required_skills: List[str]) -> float:
    if not required_skills:
        return 100.0
    matches = set(user_skills).intersection(set(required_skills))
    return (len(matches) / len(required_skills)) * 100.0

def check_availability(user_id: str, start_time: datetime, end_time: datetime) -> bool:
    # Query tasks for overlap
    tasks_ref = db.collection("tasks")
    query = tasks_ref.where("assignedTo", "==", user_id).where("status", "!=", "Completed").stream()

    for doc in query:
        task = doc.to_dict()
        t_start = task["startTime"]
        t_end = task["endTime"]

        # Firestore returns datetime objects. Compare them.
        if start_time < t_end and end_time > t_start:
            return False
    return True

# --- Endpoints ---

@app.get("/")
def read_root():
    return {"status": "AIQ AI Service is Online"}

@app.post("/recommend", response_model=List[EmployeeRecommendation])
async def get_recommendations(request: TaskRequest):
    try:
        # 1. Fetch all employees in the company
        users_ref = db.collection("users")
        users_query = users_ref.where("companyId", "==", request.companyId).stream()

        recommendations = []

        for doc in users_query:
            user_data = doc.to_dict()
            user_id = doc.id

            # 2. Availability Check
            is_available = check_availability(user_id, request.startTime, request.endTime)

            # 3. Workload Check (assuming 0-100 percentage stored in profile)
            workload = user_data.get("currentWorkloadPercentage", 0.0)

            # 4. Skill Match
            user_skills = user_data.get("skills", [])
            skill_score = calculate_skill_match(user_skills, request.requiredSkills)

            # 5. Final AI Score Formula: (100 - workload) + availability_bonus + skill_match
            # Availability bonus: 50 points if available, 0 if not
            availability_bonus = 50.0 if is_available else 0.0

            final_score = (100.0 - workload) + availability_bonus + skill_score

            recommendations.append(EmployeeRecommendation(
                userId=user_id,
                name=user_data.get("name", "Unknown"),
                score=round(final_score, 2),
                workload=workload,
                skillMatch=round(skill_score, 2),
                isAvailable=is_available
            ))

        # Sort by highest score
        recommendations.sort(key=lambda x: x.score, reverse=True)

        return recommendations

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
