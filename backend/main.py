from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from auth import router as auth_router
from admin_routes import router as admin_router
from analytics_routes import router as analytics_router
from routers.quiz import router as quizzes_router
from db import users_col
from security import hash_password

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*", "Authorization"],
)

@app.on_event("startup")
async def on_startup():
    try:
        await users_col.create_index("email", unique=True)
        # seed default admin if not exists
        admin_email = "admin@thinkstrike.edu"
        exists = await users_col.find_one({"email": admin_email})
        if not exists:
            await users_col.insert_one({
                "email": admin_email,
                "password": hash_password("Admin123!"),
                "role": "admin"
            })
            print("✅ Default admin created: admin@thinkstrike.edu / Admin123!")
    except Exception as e:
        print(f"Admin auto-seed check failed: {e}")

app.include_router(auth_router)
app.include_router(quizzes_router)
app.include_router(admin_router)
app.include_router(analytics_router)

@app.get("/health")
async def health():
    return {"status": "ok"}
