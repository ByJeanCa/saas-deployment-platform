from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


# --- /health ---
def test_health():
    res = client.get("/health")
    assert res.status_code == 200
    assert res.json() == {"ok": True}


# --- /ready ---
def test_ready_success(monkeypatch):
    monkeypatch.setattr("app.main.check_redis", lambda: (True, "ok"))
    monkeypatch.setattr("app.main.check_db", lambda: (True, "ok"))

    res = client.get("/ready")
    assert res.status_code == 200
    assert res.json() == {"ok": True}


def test_ready_redis_failure(monkeypatch):
    monkeypatch.setattr("app.main.check_redis", lambda: (False, "redis_error"))
    monkeypatch.setattr("app.main.check_db", lambda: (True, "ok"))

    res = client.get("/ready")
    assert res.status_code == 503
    assert "redis" in res.json()["detail"]


def test_ready_db_failure(monkeypatch):
    monkeypatch.setattr("app.main.check_redis", lambda: (True, "ok"))
    monkeypatch.setattr("app.main.check_db", lambda: (False, "db_error"))

    res = client.get("/ready")
    assert res.status_code == 503
    assert "db" in res.json()["detail"]


# --- /db-check ---
def test_db_check_success(monkeypatch):
    monkeypatch.setattr("app.main.check_db", lambda: (True, "ok"))

    res = client.get("/db-check")
    assert res.status_code == 200
    assert res.json() == {"ok": True}


def test_db_check_failure(monkeypatch):
    monkeypatch.setattr("app.main.check_db", lambda: (False, "db_error"))

    res = client.get("/db-check")
    assert res.status_code == 503


# --- /api/enqueue ---
def test_enqueue_success(monkeypatch):
    class FakeResult:
        id = "abc-123"

    class FakeCelery:
        def send_task(self, *args, **kwargs):
            return FakeResult()

    monkeypatch.setattr("app.main.celery_app", FakeCelery())

    res = client.post("/api/enqueue", json={
        "email": "test@test.com",
        "payload": "data"
    })

    assert res.status_code == 200
    assert res.json()["id"] == "abc-123"
    assert res.json()["status"] == "queued"


def test_enqueue_invalid_email():
    res = client.post("/api/enqueue", json={
        "email": "not-an-email",
        "payload": "data"
    })
    assert res.status_code == 422


def test_enqueue_missing_fields():
    res = client.post("/api/enqueue", json={})
    assert res.status_code == 422


# --- /api/jobs/{job_id} ---
def test_job_status_success(monkeypatch):
    class FakeResult:
        state = "SUCCESS"
        info = None

    class FakeCelery:
        def AsyncResult(self, job_id):
            return FakeResult()

    monkeypatch.setattr("app.main.celery_app", FakeCelery())

    res = client.get("/api/jobs/abc-123")
    assert res.status_code == 200
    assert res.json()["status"] == "done"
    assert res.json()["celery_state"] == "SUCCESS"


def test_job_status_failure(monkeypatch):
    class FakeResult:
        state = "FAILURE"
        info = Exception("something went wrong")

    class FakeCelery:
        def AsyncResult(self, job_id):
            return FakeResult()

    monkeypatch.setattr("app.main.celery_app", FakeCelery())

    res = client.get("/api/jobs/abc-123")
    assert res.status_code == 200
    assert res.json()["status"] == "failed"
    assert "error" in res.json()


def test_job_status_pending(monkeypatch):
    class FakeResult:
        state = "PENDING"
        info = None

    class FakeCelery:
        def AsyncResult(self, job_id):
            return FakeResult()

    monkeypatch.setattr("app.main.celery_app", FakeCelery())

    res = client.get("/api/jobs/abc-123")
    assert res.status_code == 200
    assert res.json()["status"] == "queued"