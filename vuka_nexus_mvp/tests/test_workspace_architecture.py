"""Workspace architecture guardrails for VUKA NEXUS V1.1."""

from pathlib import Path
import ast


ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def parse(path: str):
    return ast.parse(read(path))


def class_names(path: str):
    return {
        node.name
        for node in parse(path).body
        if isinstance(node, ast.ClassDef)
    }


def test_authentication_service_exists():
    assert (ROOT / "vuka/auth/service.py").exists()


def test_organisation_context_exists():
    assert (ROOT / "vuka/auth/context.py").exists()


def test_engagement_context_exists():
    assert (ROOT / "vuka/auth/engagement_context.py").exists()


def test_engagement_service_exists():
    assert (ROOT / "vuka/services/engagements.py").exists()


def test_engagement_repository_exists():
    assert (ROOT / "vuka/repositories/engagements.py").exists()


def test_engagement_context_contract_exists():
    classes = class_names("vuka/auth/engagement_context.py")
    assert "EngagementContext" in classes
    assert "EngagementContextResolver" in classes


def test_engagement_service_contract_exists():
    classes = class_names("vuka/services/engagements.py")
    assert "EngagementService" in classes


def test_repository_contract_exists():
    classes = class_names("vuka/repositories/engagements.py")
    assert classes, "Engagement repository must expose a repository class."


def test_workspace_layers_do_not_depend_on_streamlit():
    paths = [
        "vuka/auth/service.py",
        "vuka/auth/context.py",
        "vuka/auth/engagement_context.py",
        "vuka/services/engagements.py",
        "vuka/repositories/engagements.py",
    ]

    for path in paths:
        text = read(path).lower()
        assert "import streamlit" not in text
        assert "from streamlit" not in text


def test_workspace_layers_do_not_embed_privileged_credentials():
    paths = [
        "vuka/auth/service.py",
        "vuka/auth/context.py",
        "vuka/auth/engagement_context.py",
        "vuka/services/engagements.py",
        "vuka/repositories/engagements.py",
    ]

    forbidden = [
        "service_role_key",
        "database_password",
        "postgresql://",
        "postgres://",
    ]

    for path in paths:
        text = read(path).lower()
        for token in forbidden:
            assert token not in text, f"{token} found in {path}"


def test_v1_app_remains_sqlite_based():
    text = read("app.py").lower()
    assert "sqlite" in text
