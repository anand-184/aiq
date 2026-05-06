from fastapi import FastAPI, Body
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime, timezone

app = FastAPI(title="AIQ Smart Scheduler Engine")

class Employee(BaseModel):
    userId: str
    name: str
    skills: List[str]
    currentWorkloadPercentage: float
    isAvailable: bool

class TaskContext(BaseModel):
    requiredSkills: List[str]
    basePriority: str
    endTime: datetime
    isBlocking: bool = False

@app.post("/suggest-best-employee")
async def suggest_employee(task: TaskContext, employees: List[Employee]):
    ranked_suggestions = []

    for emp in employees:
        if not emp.isAvailable: continue

        # 1. Skill Match (Max 100 points)
        required = set(s.lower() for s in task.requiredSkills)
        owned = set(s.lower() for s in emp.skills)
        match_count = len(required & owned)
        skill_score = (match_count / len(required) * 100) if required else 100

        # 2. Workload Factor (Max 100 points)
        # Higher workload = Lower score. 0% load = 100 points, 100% load = 0 points
        workload_score = 100 - emp.currentWorkloadPercentage

        # 3. Urgency Weighting
        now = datetime.now(timezone.utc)
        hours_to_deadline = (task.endTime - now).total_seconds() / 3600
        urgency_multiplier = 1.0
        if hours_to_deadline < 24: urgency_multiplier = 1.5 # Boost priority for near deadlines

        # 4. Final Aggregated Score (Max 200)
        # You can adjust weights here. Currently 60% skills, 40% workload.
        final_score = (skill_score * 0.6 + workload_score * 0.4) * urgency_multiplier
        
        # Match Level out of 10
        match_level = (final_score / 20).clamp(0, 10) 

        ranked_suggestions.append({
            "userId": emp.userId,
            "name": emp.name,
            "score": final_score,
            "matchLevel": round(match_level, 1),
            "reason": f"{int(skill_score)}% Skill Match | {int(emp.currentWorkloadPercentage)}% Workload"
        })

    # Sort by highest score
    ranked_suggestions.sort(key=lambda x: x["score"], reverse=True)
    return ranked_suggestions