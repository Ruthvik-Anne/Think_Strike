"""
ThinkStrike - Communication Routes
Created: 2025-08-07 15:30:28
Author: Ruthvik-Anne
"""

from fastapi import APIRouter, Depends, HTTPException, WebSocket, WebSocketDisconnect
from sqlmodel import Session
from typing import List
from database import get_session
from models import Message, User
from datetime import datetime

router = APIRouter(prefix="/api/communication", tags=["communication"])

class ConnectionManager:
    def __init__(self):
        self.active_connections: dict = {}

    async def connect(self, websocket: WebSocket, user_id: str):
        await websocket.accept()
        self.active_connections[user_id] = websocket

    def disconnect(self, user_id: str):
        if user_id in self.active_connections:
            del self.active_connections[user_id]

    async def send_personal_message(self, message: str, user_id: str):
        if user_id in self.active_connections:
            await self.active_connections[user_id].send_text(message)

manager = ConnectionManager()

@router.websocket("/ws/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: str):
    await manager.connect(websocket, user_id)
    try:
        while True:
            data = await websocket.receive_text()
            # Process received message
            await manager.send_personal_message(f"You wrote: {data}", user_id)
    except WebSocketDisconnect:
        manager.disconnect(user_id)

@router.post("/messages")
async def send_message(
    sender_id: int,
    receiver_id: int,
    content: str,
    db: Session = Depends(get_session)
):
    """Send a message to a teacher/student"""
    message = Message(
        sender_id=sender_id,
        receiver_id=receiver_id,
        content=content,
        timestamp=datetime.utcnow()
    )
    db.add(message)
    db.commit()
    db.refresh(message)
    return message

@router.get("/messages/{user_id}")
async def get_messages(
    user_id: int,
    db: Session = Depends(get_session)
):
    """Get all messages for a user"""
    messages = db.query(Message).filter(
        (Message.sender_id == user_id) | (Message.receiver_id == user_id)
    ).order_by(Message.timestamp.desc()).all()
    return messages

@router.get("/teachers")
async def get_available_teachers(db: Session = Depends(get_session)):
    """Get list of available teachers"""
    teachers = db.query(User).filter(User.role == "teacher").all()
    return teachers