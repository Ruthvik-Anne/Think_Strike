from fastapi import FastAPI
from routers import teacher, student, admin
from database import init_db

app = FastAPI(title="ThinkStrike API", version="1.0")

# Routers
app.include_router(teacher.router, prefix="/teacher", tags=["Teacher"])
app.include_router(student.router, prefix="/student", tags=["Student"])
app.include_router(admin.router, prefix="/admin", tags=["Admin"])

@app.on_event("startup")
def startup():
    init_db()