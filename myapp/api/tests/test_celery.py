from app.celery_app import make_celery


def test_make_celery_defaults(monkeypatch):
    monkeypatch.delenv("CELERY_BROKER_URL", raising=False)
    monkeypatch.delenv("REDIS_URL", raising=False)

    app = make_celery()

    assert app.conf.task_track_started is True
    assert app.conf.result_expires == 3600