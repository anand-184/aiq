from fastapi import FastAPI, Body
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime,timezone

app = FastAPI(title="AIQ Smart Engine")

#Data models
class Employee(BaseModel):
    userId:str
    name:str
    skills:List[str]
    currentWorkloadPercentage:float
    isAvailable:bool

class  taskContext(BaseModel):
    requiredSkills:List[str]
    basePriority:str
    endTime:datetime
    isBlocking:bool=False

def calculate_priority_score(base_priority:str,deadline:datetime,is_blocking:bool)->float:
    weights = {"Critical":40,"High":30,"Medium":20,"Low":10}
    score = weights.get(base_priority,10)  

    now = datetime.now(timezone.utc)
    hours_left = (deadline-now).total_seconds/3600

    if hours_left<=0 :score+=60  #overdue
    elif hours_left < 4: score += 50 # Immediate
    elif hours_left < 24: score += 30 # Today
    elif hours_left < 72: score += 15 # Soon 

    if is_blocking :score+=10
    return score

@app.post("/suggest-best-employee")
async def suggest_employee(task:taskContext,employees:List[Employee]):
    ranked_suggestions=[]

    for emp in employees:
        if not emp.isAvailable:continue

        workload_score = 100-emp.currentWorkloadPercentage

        match_count = len(set(task.requiredSkills)&set(emp.skills))
        skill_score = match_count *25

        total_score = workload_score +skill_score
        ranked_suggestions.append(
            {
                "userId":emp.userId,
                "name":emp.name,
                "score":total_score,
                "reason":f"Workload:{emp.currentWorkloadPercentage}%,Matches:{match_count}skill"
            
            }
        )

        ranked_suggestions.sort(key=lambda x:x["score"],reverse=True)
        return ranked_suggestions
    
@app.post("/get-task-priority")
async def get_priority(task:taskContext):
    score =calculate_priority_score(task.basePriority,task.endTime,task.isBlocking)
    return {"priorityScore":score}


