"""Pydantic schemas for data validation."""

from datetime import datetime
from enum import Enum
from typing import Any

from bson import ObjectId
from pydantic import BaseModel, Field, field_validator


class ProcessingStatus(str, Enum):
    """Status of document processing."""

    UPLOADED = "uploaded"
    EXTRACTING = "extracting"
    EXTRACTED = "extracted"
    GENERATING = "generating"
    READY = "ready"
    FAILED = "failed"


class QuestionType(str, Enum):
    """Types of questions."""

    MCQ = "mcq"
    FILL_IN_BLANK = "fill_in_blank"
    TRUE_FALSE = "true_false"


class Difficulty(str, Enum):
    """Question difficulty levels."""

    EASY = "easy"
    MEDIUM = "medium"
    HARD = "hard"


# Upload Schemas
class UploadResponse(BaseModel):
    """Response after file upload."""

    file_id: str
    filename: str
    status: ProcessingStatus
    message: str
    upload_time: datetime


# Question Schemas
class QuestionOption(BaseModel):
    """Single option for MCQ."""

    label: str
    text: str


class Question(BaseModel):
    """Question schema."""

    id: str | None = Field(default=None, alias="_id")
    type: QuestionType
    question: str
    options: list[QuestionOption] | None = None  # For MCQ
    correct_answer: str
    explanation: str
    difficulty: Difficulty
    topic: str | None = None
    file_id: str | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None

    class Config:
        populate_by_name = True
        json_schema_extra = {
            "example": {
                "type": "mcq",
                "question": "What is the capital of France?",
                "options": [
                    {"label": "A", "text": "London"},
                    {"label": "B", "text": "Paris"},
                    {"label": "C", "text": "Berlin"},
                    {"label": "D", "text": "Madrid"},
                ],
                "correct_answer": "B",
                "explanation": "Paris is the capital and largest city of France.",
                "difficulty": "easy",
                "topic": "Geography",
            }
        }


class QuestionCreate(BaseModel):
    """Schema for creating a question."""

    type: QuestionType
    question: str
    options: list[QuestionOption] | None = None
    correct_answer: str
    explanation: str
    difficulty: Difficulty
    topic: str | None = None


class QuestionUpdate(BaseModel):
    """Schema for updating a question."""

    question: str | None = None
    options: list[QuestionOption] | None = None
    correct_answer: str | None = None
    explanation: str | None = None
    difficulty: Difficulty | None = None
    topic: str | None = None


class GeneratedQuestionsResponse(BaseModel):
    """Response containing generated questions."""

    file_id: str
    questions: list[Question]
    total_count: int
    status: ProcessingStatus


class SaveQuestionsRequest(BaseModel):
    """Request to save reviewed questions."""

    file_id: str
    questions: list[QuestionCreate]


class SaveQuestionsResponse(BaseModel):
    """Response after saving questions."""

    saved_count: int
    message: str
    question_ids: list[str]


# Processing Status Schema
class ProcessingStatusResponse(BaseModel):
    """Response for processing status."""

    file_id: str
    filename: str
    status: ProcessingStatus
    progress: str
    error: str | None = None


# Upload Metadata
class UploadMetadata(BaseModel):
    """Metadata stored in database for uploads."""

    id: str | None = Field(default=None, alias="_id")
    file_id: str
    filename: str
    file_path: str
    status: ProcessingStatus
    upload_time: datetime
    extracted_text_path: str | None = None
    generated_questions_path: str | None = None
    error: str | None = None
    progress_current: int | None = 0
    progress_total: int | None = 0
    progress_message: str | None = None

    @field_validator("id", mode="before")
    @classmethod
    def convert_objectid(cls, v: Any) -> str | None:
        """Convert MongoDB ObjectId to string."""
        if isinstance(v, ObjectId):
            return str(v)
        return v

    class Config:
        populate_by_name = True
