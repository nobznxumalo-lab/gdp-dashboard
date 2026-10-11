"""Authentication architecture guardrails for VUKA NEXUS V1.1."""

from pathlib import Path
import ast


AUTH_DIR = Path("vuka/auth")


def _read(name: str) -> str:
    return (AUTH_DIR / name).read_text(encoding="utf-8")


def test_authentication_package_exists():
    required = [
        "__init__.py",
        "session.py",
        "service.py",
        "context.py",
        "engagement_context.py",
    ]

    for filename in required:
        assert (AUTH_DIR / filename).exists(), (
            f"Missing authentication component: {filename}"
        )


def test_all_authentication_files_have_valid_python_syntax():
    for path in AUTH_DIR.glob("*.py"):
        ast.parse(path.read_text(encoding="utf-8"))


def test_auth_layer_contains_no_streamlit_ui_dependency():
    for path in AUTH_DIR.glob("*.py"):
        text = path.read_text(encoding="utf-8").lower()

        assert "import streamlit" not in text
        assert "from streamlit" not in text


def test_auth_layer_contains_no_privileged_credentials():
    forbidden = [
        "service_role",
        "service-role",
        "database_password",
        "db_password",
    ]

    for path in AUTH_DIR.glob("*.py"):
        text = path.read_text(encoding="utf-8").lower()

        for token in forbidden:
            assert token not in text, (
                f"Forbidden credential reference '{token}' "
                f"found in {path}"
            )


def test_organisation_context_uses_membership_boundary():
    text = _read("context.py")

    assert '.table("organization_users")' in text
    assert '.eq("user_id", user_id)' in text
    assert "def require_organisation" in text
    assert "AuthorisationError" in text


def test_engagement_context_uses_organisation_boundary():
    text = _read("engagement_context.py")

    assert '.table("engagements")' in text
    assert '.eq("organization_id", organization_id)' in text
    assert "def require_engagement" in text
    assert "context.organization_id == organization_id" in text
    assert "AuthorisationError" in text


def test_authentication_service_uses_supabase_auth():
    text = _read("service.py")

    assert ".auth." in text
    assert "AuthenticationService" in text
    assert "AuthenticationError" in text


def test_session_layer_exists():
    text = _read("session.py")

    assert "AuthSession" in text
    assert "SessionState" in text


def test_v1_app_remains_sqlite_based_during_foundation_build():
    text = Path("app.py").read_text(encoding="utf-8").lower()

    assert "sqlite" in text, (
        "V1 app architecture appears to have changed before "
        "the controlled V1.1 integration stage."
    )
