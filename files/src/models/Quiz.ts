interface Quiz {
  // ... previous interface definition ...
  createdAt: Date;  // Default: 2025-08-07T22:03:27+05:30
  lastModified: Date;
}

const quizSchema = new Schema<Quiz>({
  // ... previous schema definition ...
  createdAt: { 
    type: Date, 
    default: new Date('2025-08-07T22:03:27+05:30')
  },
  lastModified: {
    type: Date,
    default: new Date('2025-08-07T22:03:27+05:30')
  }
});