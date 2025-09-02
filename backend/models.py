from sqlalchemy import Table, Column, String, Integer, ForeignKey, JSON, MetaData

metadata = MetaData()

users = Table(
    "users", metadata,
    Column("id", String, primary_key=True),
    Column("role", String),  # student, teacher, admin
)

quizzes = Table(
    "quizzes", metadata,
    Column("id", String, primary_key=True),
    Column("topic", String),
    Column("difficulty", String),
    Column("questions", JSON)
)

results = Table(
    "results", metadata,
    Column("id", Integer, primary_key=True, autoincrement=True),
    Column("quiz_id", String, ForeignKey("quizzes.id")),
    Column("student_id", String, ForeignKey("users.id")),
    Column("score", Integer),
    Column("mistakes", JSON)
)