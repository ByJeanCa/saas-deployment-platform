from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_health():
    res = client.get("/health")
    assert res.status_code == 200
    assert res.json() == {"ok": True}


def test_ready_failure(monkeypatch):
    monkeypatch.setattr("app.main.check_redis", lambda: (False, "fail"))
    monkeypatch.setattr("app.main.check_db", lambda: (True, "ok"))

    res = client.get("/ready")

    assert res.status_code == 503


def test_enqueue(monkeypatch):
    class FakeResult:
        id = "123"

    class FakeCelery:
        def send_task(self, *args, **kwargs):
            return FakeResult()

    monkeypatch.setattr("app.main.celery_app", FakeCelery())

    res = client.post("/api/enqueue", json={
        "email": "test@test.com",
        "payload": "data"
    })

    assert res.status_code == 200
    assert res.json()["id"] == "123"