"""Workspace state tests for VUKA NEXUS V1.1."""

import pytest

from vuka.ui.workspace import WorkspaceState


def test_new_workspace_starts_at_authenticated_user_level():
    state = WorkspaceState(user_id="user-001")

    assert state.user_id == "user-001"
    assert state.organisation_id is None
    assert state.engagement_id is None
    assert not state.has_organisation
    assert not state.has_engagement
    assert not state.is_ready


def test_organisation_can_be_selected():
    state = WorkspaceState(user_id="user-001")

    selected = state.select_organisation(
        organisation_id="org-001",
        organisation_name="VUKA NEXUS",
    )

    assert selected.user_id == "user-001"
    assert selected.organisation_id == "org-001"
    assert selected.organisation_name == "VUKA NEXUS"
    assert selected.has_organisation
    assert not selected.has_engagement
    assert not selected.is_ready


def test_engagement_requires_organisation():
    state = WorkspaceState(user_id="user-001")

    with pytest.raises(
        ValueError,
        match="organisation must be selected",
    ):
        state.select_engagement(
            engagement_id="eng-001",
            engagement_name="Internal Pilot",
        )


def test_engagement_can_be_selected_inside_organisation():
    state = WorkspaceState(user_id="user-001").select_organisation(
        organisation_id="org-001",
        organisation_name="VUKA NEXUS",
    )

    selected = state.select_engagement(
        engagement_id="eng-001",
        engagement_name="Internal Pilot",
    )

    assert selected.organisation_id == "org-001"
    assert selected.engagement_id == "eng-001"
    assert selected.engagement_name == "Internal Pilot"
    assert selected.is_ready


def test_switching_organisation_clears_previous_engagement():
    state = (
        WorkspaceState(user_id="user-001")
        .select_organisation("org-001", "Client A")
        .select_engagement("eng-001", "Client A Engagement")
    )

    switched = state.select_organisation(
        organisation_id="org-002",
        organisation_name="Client B",
    )

    assert switched.organisation_id == "org-002"
    assert switched.organisation_name == "Client B"
    assert switched.engagement_id is None
    assert switched.engagement_name is None
    assert not switched.is_ready


def test_clear_engagement_preserves_organisation():
    state = (
        WorkspaceState(user_id="user-001")
        .select_organisation("org-001", "VUKA NEXUS")
        .select_engagement("eng-001", "Internal Pilot")
    )

    cleared = state.clear_engagement()

    assert cleared.organisation_id == "org-001"
    assert cleared.organisation_name == "VUKA NEXUS"
    assert cleared.engagement_id is None
    assert cleared.engagement_name is None
    assert not cleared.is_ready


def test_clear_organisation_returns_to_user_context():
    state = (
        WorkspaceState(user_id="user-001")
        .select_organisation("org-001", "VUKA NEXUS")
        .select_engagement("eng-001", "Internal Pilot")
    )

    cleared = state.clear_organisation()

    assert cleared.user_id == "user-001"
    assert cleared.organisation_id is None
    assert cleared.organisation_name is None
    assert cleared.engagement_id is None
    assert cleared.engagement_name is None
    assert not cleared.is_ready


def test_workspace_state_has_no_streamlit_or_database_dependency():
    """Workspace state must remain independent of UI and persistence layers."""
    import ast
    from pathlib import Path

    source = Path("vuka/ui/workspace.py").read_text(encoding="utf-8")
    tree = ast.parse(source)

    imported_modules = set()

    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for alias in node.names:
                imported_modules.add(alias.name.split(".")[0])

        elif isinstance(node, ast.ImportFrom) and node.module:
            imported_modules.add(node.module.split(".")[0])

    assert "streamlit" not in imported_modules
    assert "supabase" not in imported_modules

    lowered = source.lower()

    assert ".table(" not in lowered
    assert "service_role" not in lowered
