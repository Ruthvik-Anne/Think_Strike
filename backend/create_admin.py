#!/usr/bin/env python3
import os
import getpass
from pymongo import MongoClient
from auth_utils import hash_password

MONGO_URL = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
DB_NAME = os.getenv("DATABASE_NAME", "thinkstrike")

def main():
    username = os.getenv("ADMIN_USER")
    password = os.getenv("ADMIN_PASSWORD")
    if not username:
        username = input("Admin username: ").strip()
    if not password:
        password = getpass.getpass("Admin password: ").strip()
    client = MongoClient(MONGO_URL)
    db = client[DB_NAME]
    users = db["users"]
    existing = users.find_one({"username": username})
    if existing:
        print("Admin user already exists.")
        return
    hashed = hash_password(password)
    res = users.insert_one({"username": username, "password_hash": hashed, "role": "admin"})
    print("Created admin user with id:", res.inserted_id)

if __name__ == "__main__":
    main()
