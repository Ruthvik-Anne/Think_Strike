interface Curriculum {
  id: string;
  subject: string;
  department: string;
  semester: number;
  year: number;
  units: {
    unitNo: number;
    title: string;
    topics: string[];
    hours: number;
    textbookRefs: string[];
  }[];
  textbooks: {
    id: string;
    title: string;
    author: string;
    edition: string;
    uploadedAt: Date;
    uploadedBy: string;
    url: string;
  }[];
  lastUpdated: Date;
  approvedBy: string;
  status: 'DRAFT' | 'APPROVED' | 'ARCHIVED';
}

const curriculumSchema = new Schema<Curriculum>({
  id: { type: String, required: true, unique: true },
  subject: { type: String, required: true },
  department: { type: String, required: true },
  semester: { type: Number, required: true },
  year: { type: Number, required: true },
  units: [{
    unitNo: Number,
    title: String,
    topics: [String],
    hours: Number,
    textbookRefs: [String]
  }],
  textbooks: [{
    id: String,
    title: String,
    author: String,
    edition: String,
    uploadedAt: Date,
    uploadedBy: String,
    url: String
  }],
  lastUpdated: { type: Date, default: Date.now },
  approvedBy: String,
  status: { type: String, enum: ['DRAFT', 'APPROVED', 'ARCHIVED'], default: 'DRAFT' }
});