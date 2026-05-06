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

@app.get("/")
async def root():
    return {"status": "AI Engine is online"}

@app.post("/suggest-best-employee")
async def suggest_employee(task: TaskContext, employees: List[Employee]):
    ranked_suggestions = []

    print(f"Analyzing task with skills: {task.requiredSkills}")
    print(f"Number of employees to analyze: {len(employees)}")

    for emp in employees:
        if not emp.isAvailable:
            print(f"Skipping {emp.name} (Not Available)")
            continue

        # 1. Skill Match (Max 100 points)
        # We use lowercase comparison and check if the required skill is contained in any employee skill
        required = [s.lower().strip() for s in task.requiredSkills]
        owned = [s.lower().strip() for s in emp.skills]

        match_count = 0
        if required:
            for req_skill in required:
                # Direct match or partial match
                if any(req_skill in o or o in req_skill for o in owned):
                    match_count += 1
            skill_score = (match_count / len(required)) * 100
        else:
            skill_score = 100 # No skills required, everyone matches

        # 2. Workload Factor (Max 100 points)
        # Higher workload = Lower score. 0% load = 100 points, 100% load = 0 points
        workload_score = max(0, 100 - emp.currentWorkloadPercentage)

        # 3. Urgency Weighting
        now = datetime.now(timezone.utc)
        # Ensure task.endTime is offset-aware
        task_end = task.endTime.replace(tzinfo=timezone.utc) if task.endTime.tzinfo is None else task.endTime
        hours_to_deadline = (task_end - now).total_seconds() / 3600

        urgency_multiplier = 1.0
        if hours_to_deadline < 0:
            urgency_multiplier = 0.5 # Penalty for overdue tasks
        elif hours_to_deadline < 4:
            urgency_multiplier = 1.5
        elif hours_to_deadline < 24:
            urgency_multiplier = 1.2

        # 4. Final Aggregated Score (Max 200)
        # Weighting: 70% skills, 30% workload (since skills are usually more critical)
        base_score = (skill_score * 0.7 + workload_score * 0.3)
        final_score = base_score * urgency_multiplier
        
        # Match Level out of 10 (Normalized)
        # We divide by 20 because max base_score is 100, and max urgency can boost it.
        # We use max/min to clamp instead of .clamp() which doesn't exist in Python
        match_level = max(0.0, min(10.0, base_score / 10.0))

        print(f"Employee: {emp.name} | Skill Score: {skill_score} | Workload Score: {workload_score} | Match Level: {match_level}")

        ranked_suggestions.append({
            "userId": emp.userId,
            "name": emp.name,
            "score": final_score,
            "matchLevel": round(match_level, 1),
            "reason": f"{int(skill_score)}% Skill Match | {int(emp.currentWorkloadPercentage)}% Workload"
        })

    # Sort by highest score
    ranked_suggestions.sort(key=lambda x: x["score"], reverse=True)

    print(f"Returning {len(ranked_suggestions)} suggestions")
    return ranked_suggestions
