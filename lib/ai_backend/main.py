from fastapi import FastAPI
from pydantic import BaseModel
from typing import Any, Dict, List
from datetime import datetime, timezone

app = FastAPI(title="AIQ Smart Scheduler Engine")

def skill_tokens(value: str) -> set[str]:
    cleaned = "".join(ch.lower() if ch.isalnum() or ch in {"+", "#", "."} else " " for ch in value)
    tokens = {part.strip() for part in cleaned.split() if part.strip()}
    if "django" in cleaned:
        tokens.update({"django", "python"})
    if "flutter" in cleaned:
        tokens.update({"flutter", "dart"})
    if "firebase" in cleaned:
        tokens.update({"firebase", "firestore"})
    if "sql" in cleaned:
        tokens.add("sql")
    return tokens

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

class AnalyticsDocument(BaseModel):
    title: str
    content: str
    metadata: Dict[str, Any] = {}

class AnalyticsQuestion(BaseModel):
    question: str
    role: str
    documents: List[AnalyticsDocument] = []

class PerformanceSignal(BaseModel):
    userId: str
    employeeName: str
    completedTasks: int = 0
    inProgressTasks: int = 0
    pendingTasks: int = 0
    averageFocusMinutes: float = 0
    appScreenMinutes: float = 0
    typingActivityScore: float = 0
    keystrokesPerHour: float = 0
    workloadPercentage: float = 0

class TaskFollowUpSignal(BaseModel):
    taskId: str
    title: str
    status: str
    basePriority: str
    endTime: datetime
    submissionNote: str = ""
    submissionLink: str = ""
    reviewerFeedback: str = ""

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

        required = set()
        for skill in task.requiredSkills:
            required.update(skill_tokens(skill))
        owned = set()
        for skill in emp.skills:
            owned.update(skill_tokens(skill))

        if required:
            exact_count = len(required.intersection(owned))
            fuzzy_count = sum(
                1 for req_skill in required
                if any(req_skill in owned_skill or owned_skill in req_skill for owned_skill in owned)
            )
            skill_score = min(100, ((exact_count + max(0, fuzzy_count - exact_count) * 0.45) / len(required)) * 100)
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

@app.post("/analytics-rag")
async def analytics_rag(payload: AnalyticsQuestion):
    lower_question = payload.question.lower()
    known_skills = {"django", "flutter", "firebase", "python", "sql", "ml", "ai", "dart", "java", "react", "node"}
    requested_skill = next((skill for skill in known_skills if skill in lower_question), None)
    if requested_skill and any(word in lower_question for word in ["skill", "skills", "employee", "employees", "list", "who"]):
        wanted = skill_tokens(requested_skill)
        matches = []
        for doc in payload.documents:
            if doc.metadata.get("type") != "employee":
                continue
            haystack = f"{doc.title} {doc.content}"
            if wanted.intersection(skill_tokens(haystack)):
                matches.append(doc.title.replace("Employee ", ""))
        if matches:
            return {
                "answer": f"Employees matching {requested_skill}: {', '.join(matches)}.",
                "sources": [{"title": f"Employee {name}", "metadata": {"type": "employee"}} for name in matches]
            }
        return {
            "answer": f"No employees with {requested_skill} were found in the current analytics data.",
            "sources": []
        }

    question_terms = {
        term.strip().lower()
        for term in payload.question.replace("?", " ").replace(",", " ").split()
        if len(term.strip()) > 2
    }

    scored_docs = []
    for doc in payload.documents:
        content = f"{doc.title} {doc.content}".lower()
        score = sum(1 for term in question_terms if term in content)
        if score > 0:
            scored_docs.append((score, doc))

    scored_docs.sort(key=lambda item: item[0], reverse=True)
    selected = [doc for _, doc in scored_docs[:4]] or payload.documents[:4]

    if not selected:
        return {
            "answer": "I do not have enough analytics context yet. Add company, task, payment, or performance data and ask again.",
            "sources": []
        }

    source_lines = [f"- {doc.title}: {doc.content}" for doc in selected]
    answer = (
        f"Based on the {payload.role} analytics context, here are the most relevant signals:\n"
        + "\n".join(source_lines)
        + "\n\nRecommendation: prioritize overloaded teams, stale pending tasks, and low-completion employees before assigning new high-priority work."
    )
    return {
        "answer": answer,
        "sources": [{"title": doc.title, "metadata": doc.metadata} for doc in selected]
    }

@app.post("/performance-insights")
async def performance_insights(signals: List[PerformanceSignal]):
    insights = []
    for signal in signals:
        total_tasks = signal.completedTasks + signal.inProgressTasks + signal.pendingTasks
        completion_rate = (signal.completedTasks / total_tasks * 100) if total_tasks else 0
        focus_score = min(100, max(0, signal.averageFocusMinutes / 120 * 100))
        activity_score = min(100, max(0, signal.typingActivityScore))
        keystroke_score = min(100, max(0, signal.keystrokesPerHour / 1800 * 100))
        balanced_score = round(
            completion_rate * 0.55
            + focus_score * 0.25
            + activity_score * 0.07
            + keystroke_score * 0.03
            + max(0, 100 - signal.workloadPercentage) * 0.10,
            1,
        )

        risk = "Healthy"
        if signal.workloadPercentage > 85 and signal.pendingTasks > signal.completedTasks:
            risk = "Burnout risk"
        elif completion_rate < 40 and total_tasks >= 3:
            risk = "Needs support"

        insights.append({
            "userId": signal.userId,
            "employeeName": signal.employeeName,
            "efficiencyScore": balanced_score,
            "completionRate": round(completion_rate, 1),
            "keystrokesPerHour": round(signal.keystrokesPerHour, 1),
            "risk": risk,
            "recommendation": "Rebalance workload or pair with a skilled teammate." if risk != "Healthy" else "Good candidate for matching skill-based tasks.",
        })

    insights.sort(key=lambda item: item["efficiencyScore"], reverse=True)
    return insights

@app.post("/task-followups")
async def task_followups(tasks: List[TaskFollowUpSignal]):
    followups = []
    now = datetime.now(timezone.utc)

    for task in tasks:
        task_end = task.endTime.replace(tzinfo=timezone.utc) if task.endTime.tzinfo is None else task.endTime
        hours_to_deadline = (task_end - now).total_seconds() / 3600
        status = task.status.lower().strip()
        priority = task.basePriority.lower().strip()

        risk = "Normal"
        if status != "completed" and hours_to_deadline < 0:
            risk = "Overdue"
        elif priority in {"critical", "high"} and status in {"pending", "in progress"} and hours_to_deadline < 24:
            risk = "Needs attention"
        elif status == "submitted":
            risk = "Awaiting review"

        if status == "submitted":
            action = "Review the submission note and proof link, then approve or request rework with concrete feedback."
        elif risk == "Overdue":
            action = "Ask for a blocker update, reduce scope if needed, and consider reassignment."
        elif status == "pending":
            action = "Confirm the assignee has enough context and a realistic start time."
        elif status == "in progress":
            action = "Request a short progress update and validate the delivery window."
        else:
            action = "Capture final learnings and keep the assignee available for similar future work."

        followups.append({
            "taskId": task.taskId,
            "title": task.title,
            "risk": risk,
            "hoursToDeadline": round(hours_to_deadline, 1),
            "action": action,
        })

    risk_order = {"Overdue": 0, "Needs attention": 1, "Awaiting review": 2, "Normal": 3}
    followups.sort(key=lambda item: (risk_order.get(item["risk"], 9), item["hoursToDeadline"]))
    return followups
