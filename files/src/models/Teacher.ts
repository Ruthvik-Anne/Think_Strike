interface Teacher {
  id: string;
  name: string;
  email: string;
  department: string;
  subjects: string[];
  role: 'TEACHER' | 'COORDINATOR';
  joinedAt: Date;
  lastActive: Date;
  permissions: {
    createQuiz: boolean;
    evaluateQuiz: boolean;
    uploadMaterial: boolean;
    viewReports: boolean;
    manageCurriculum: boolean;
  };
}

const teacherSchema = new Schema<Teacher>({
  id: { type: String, required: true, unique: true },
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  department: { type: String, required: true },
  subjects: [{ type: String, required: true }],
  role: { type: String, enum: ['TEACHER', 'COORDINATOR'], default: 'TEACHER' },
  joinedAt: { type: Date, default: Date.now },
  lastActive: { type: Date, default: Date.now },
  permissions: {
    createQuiz: { type: Boolean, default: true },
    evaluateQuiz: { type: Boolean, default: true },
    uploadMaterial: { type: Boolean, default: true },
    viewReports: { type: Boolean, default: true },
    manageCurriculum: { type: Boolean, default: false }
  }
});