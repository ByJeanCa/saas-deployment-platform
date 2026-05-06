from app.healthchecks import check_redis, check_db


def test_check_redis_success(monkeypatch):
    class FakeRedis:
        def ping(self):
            return True

    monkeypatch.setattr("redis.Redis.from_url", lambda *a, **k: FakeRedis())

    ok, msg = check_redis()

    assert ok is True
    assert msg == "ok"


def test_check_redis_failure(monkeypatch):
    class FakeRedis:
        def ping(self):
            raise Exception("fail")

    monkeypatch.setattr("redis.Redis.from_url", lambda *a, **k: FakeRedis())

    ok, msg = check_redis()

    assert ok is False
    assert "redis_error" in msg


def test_check_db_missing_dsn(monkeypatch):
    monkeypatch.setattr("app.healthchecks.build_database_url", lambda: None)

    ok, msg = check_db()

    assert ok is False
    assert "missing" in msg