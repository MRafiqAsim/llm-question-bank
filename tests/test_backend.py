"""Backend smoke tests: modules import, settings load, prompts render, the API starts."""

from backend.config import settings
from ml.prompts import get_question_generation_prompt


def test_all_modules_import() -> None:
    """Every backend and ML module imports without a database or LLM running."""
    from backend.api.main import app
    from backend.models import db_manager
    from backend.services.extraction_service import extraction_service
    from backend.services.question_service import question_service
    from backend.services.upload_service import upload_service
    from ml.inference import llm_service

    assert app.title
    assert all([db_manager, extraction_service, question_service, upload_service, llm_service])


def test_settings_defaults() -> None:
    """Settings load with sensible defaults when no .env is present."""
    assert settings.llm_provider in {"mlx", "ollama", "openai"}
    assert settings.max_chunk_size > settings.chunk_overlap
    assert "http://localhost:3000" in settings.cors_origins_list


def test_question_prompt_contains_the_source_text() -> None:
    """The generation prompt embeds the text chunk it should ask questions about."""
    rendered = str(get_question_generation_prompt("Photosynthesis converts light into energy."))
    assert "Photosynthesis converts light into energy." in rendered
