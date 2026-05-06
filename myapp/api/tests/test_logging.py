from app.logging_config import set_request_id


def test_set_request_id_with_value():
    rid = set_request_id("abc123")
    assert rid == "abc123"


def test_set_request_id_generates_uuid():
    rid = set_request_id(None)
    assert isinstance(rid, str)
    assert len(rid) > 0