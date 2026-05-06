import pytest
from unittest.mock import patch, MagicMock
from app.worker import process_job


def test_process_job_returns_expected_fields():
    """El job retorna email, payload_len y duration_ms"""
    
    # Simular el contexto de Celery (self.request.id)
    mock_request = MagicMock()
    mock_request.id = "test-job-123"
    
    with patch("app.worker.time.sleep"):  # no esperamos 2-5s reales
        with patch.object(process_job, "request", mock_request):
            result = process_job.run("test@test.com", "hello world")
    
    assert result["email"] == "test@test.com"
    assert result["payload_len"] == len("hello world")
    assert "duration_ms" in result


def test_process_job_payload_length():
    """payload_len refleja el largo real del payload"""
    
    mock_request = MagicMock()
    mock_request.id = "test-job-456"
    
    with patch("app.worker.time.sleep"):
        with patch.object(process_job, "request", mock_request):
            result = process_job.run("a@b.com", "x" * 50)
    
    assert result["payload_len"] == 50


def test_process_job_duration_ms_is_positive():
    """duration_ms siempre es positivo"""
    
    mock_request = MagicMock()
    mock_request.id = "test-job-789"
    
    with patch("app.worker.time.sleep"):
        with patch.object(process_job, "request", mock_request):
            result = process_job.run("a@b.com", "data")
    
    assert result["duration_ms"] >= 0