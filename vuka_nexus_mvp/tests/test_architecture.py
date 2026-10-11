"""Architecture guardrails for VUKA NEXUS V1.1."""

from pathlib import Path
import ast


ROOT = Path(__file__).resolve().parents[1]
VUKA = ROOT / "vuka"


def read(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8")


def test_vuka_package_structure_exists():
    required = [
        "vuka/__init__.py",
        "vuka/config.py",
        "vuka/database.py",
        "vuka/repositories/__init__.py",
        "vuka/repositories/base.py",
        "vuka/repositories/engagements.py",
        "vuka/services/__init__.py",
        "vuka/services/engagements.py",
        "vuka/scoring/__init__.py",
        "vuka/ui/__init__.py",
    ]

    missing = [
        path for path in required
        if not (ROOT / path).exists()
    ]

    assert not missing, f"Missing architecture files: {missing}"


def test_all_vuka_python_files_have_valid_syntax():
    python_files = list(VUKA.rglob("*.py"))

    assert python_files, "No VUKA Python files found."

    for path in python_files:
        ast.parse(
            path.read_text(encoding="utf-8"),
            filename=str(path),
        )


def test_service_layer_does_not_call_database_tables_directly():
    service_files = list((VUKA / "services").glob("*.py"))

    for path in service_files:
        text = path.read_text(encoding="utf-8")
        assert ".table(" not in text, (
            f"Service layer must not call database tables directly: {path}"
        )


def test_repository_does_not_embed_privileged_credentials():
    repository_files = list((VUKA / "repositories").glob("*.py"))

    forbidden = [
        "service_role",
        "database_password",
        "postgresql://",
        "postgres://",
    ]

    for path in repository_files:
        text = path.read_text(encoding="utf-8").lower()

        for term in forbidden:
            assert term not in text, (
                f"Forbidden credential reference '{term}' found in {path}"
            )


def test_config_does_not_embed_privileged_credentials():
    text = read("vuka/config.py").lower()

    forbidden = [
        "service_role",
        "database_password",
        "postgresql://",
        "postgres://",
    ]

    for term in forbidden:
        assert term not in text


def test_v1_app_remains_sqlite_based_during_architecture_build():
    text = read("app.py").lower()

    assert "sqlite" in text or "vuka_nexus.db" in text, (
        "V1 app.py appears to have been altered away from its "
        "existing SQLite implementation."
    )
