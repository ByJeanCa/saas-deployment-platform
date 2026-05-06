import os
from app.db_dsn import build_database_url


def test_build_database_url_success(monkeypatch):
    monkeypatch.setenv("DB_HOST", "localhost")
    monkeypatch.setenv("DB_PORT", "5432")
    monkeypatch.setenv("DB_NAME", "testdb")
    monkeypatch.setenv("DB_USER", "user")
    monkeypatch.setenv("DB_PASSWORD", "pass")

    url = build_database_url()

    assert url == "postgresql://user:pass@localhost:5432/testdb"


def test_build_database_url_missing_values(monkeypatch):
    monkeypatch.delenv("DB_HOST", raising=False)

    url = build_database_url()

    assert url is None


def test_build_database_url_encodes_credentials(monkeypatch):
    monkeypatch.setenv("DB_HOST", "localhost")
    monkeypatch.setenv("DB_NAME", "testdb")
    monkeypatch.setenv("DB_USER", "user@test")
    monkeypatch.setenv("DB_PASSWORD", "p@ss")

    url = build_database_url()

    assert "user%40test" in url
    assert "p%40ss" in url