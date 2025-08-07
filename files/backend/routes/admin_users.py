"""
ThinkStrike - Admin User Management Routes
Created: 2025-08-07
Author: Ruthvik-Anne
"""

from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlmodel import Session
from typing import List
import csv
import io
import secrets
import string
from database import get_session
from models import User
import pandas as pd

router = APIRouter(prefix="/api/admin", tags=["admin"])

def generate_password(length=12):
    """Generate a secure random password"""
    alphabet = string.ascii_letters + string.digits + "!@#$%^&*"
    return ''.join(secrets.choice(alphabet) for _ in range(length))

@router.post("/users")
async def create_user(
    roll_number: str,
    name: str,
    role: str,
    password: str = None,
    db: Session = Depends(get_session)
):
    """Create a new user"""
    # Check if roll number exists
    if db.query(User).filter(User.roll_number == roll_number).first():
        raise HTTPException(status_code=400, detail="Roll number already exists")
    
    # Generate password if not provided
    if not password:
        password = generate_password()
    
    user = User(
        roll_number=roll_number,
        name=name,
        role=role,
        password=password  # In production, hash this password
    )
    
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

@router.post("/users/csv")
async def import_users_csv(
    file: UploadFile = File(...),
    generate_passwords: bool = False,
    db: Session = Depends(get_session)
):
    """Import users from CSV file"""
    content = await file.read()
    df = pd.read_csv(io.StringIO(content.decode('utf-8')))
    
    results = {
        "success": 0,
        "failed": 0,
        "generated_passwords": generate_passwords,
        "user_passwords": []
    }
    
    for _, row in df.iterrows():
        try:
            password = generate_password() if generate_passwords else row.get('password', generate_password())
            
            user = User(
                roll_number=str(row['roll_number']),
                name=row['name'],
                role=row['role'],
                password=password  # In production, hash this password
            )
            
            db.add(user)
            db.commit()
            
            results["success"] += 1
            if generate_passwords:
                results["user_passwords"].append({
                    "roll_number": user.roll_number,
                    "password": password
                })
        except Exception as e:
            results["failed"] += 1
            continue
    
    return results

@router.get("/users/export")
async def export_users(db: Session = Depends(get_session)):
    """Export users to CSV"""
    users = db.query(User).all()
    
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(['roll_number', 'name', 'role', 'status', 'last_login'])
    
    for user in users:
        writer.writerow([
            user.roll_number,
            user.name,
            user.role,
            'Active' if user.active else 'Inactive',
            user.last_login.isoformat() if user.last_login else ''
        ])
    
    return Response(
        content=output.getvalue(),
        media_type='text/csv',
        headers={
            'Content-Disposition': 'attachment; filename=users_export.csv'
        }
    )