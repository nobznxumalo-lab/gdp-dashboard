"""Workspace state model for VUKA NEXUS V1.1.

This module defines the UI-facing workspace state only.

It does not:
- authenticate users;
- query Supabase directly;
- make authorisation decisions;
- depend on Streamlit;
- contain credentials.

Authorisation remains the responsibility of the authentication/context layer.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class WorkspaceState:
    """Current authorised VUKA NEXUS workspace selection."""

    user_id: str
    organisation_id: str | None = None
    organisation_name: str | None = None
    engagement_id: str | None = None
    engagement_name: str | None = None

    @property
    def has_organisation(self) -> bool:
        return bool(self.organisation_id)

    @property
    def has_engagement(self) -> bool:
        return bool(self.engagement_id)

    @property
    def is_ready(self) -> bool:
        """True when the user has selected a complete engagement workspace."""
        return self.has_organisation and self.has_engagement

    def select_organisation(
        self,
        organisation_id: str,
        organisation_name: str,
    ) -> "WorkspaceState":
        """Select an organisation and clear any previous engagement."""
        return WorkspaceState(
            user_id=self.user_id,
            organisation_id=organisation_id,
            organisation_name=organisation_name,
        )

    def select_engagement(
        self,
        engagement_id: str,
        engagement_name: str,
    ) -> "WorkspaceState":
        """Select an engagement inside the current organisation."""
        if not self.has_organisation:
            raise ValueError(
                "An organisation must be selected before an engagement."
            )

        return WorkspaceState(
            user_id=self.user_id,
            organisation_id=self.organisation_id,
            organisation_name=self.organisation_name,
            engagement_id=engagement_id,
            engagement_name=engagement_name,
        )

    def clear_engagement(self) -> "WorkspaceState":
        """Return to organisation-level context."""
        return WorkspaceState(
            user_id=self.user_id,
            organisation_id=self.organisation_id,
            organisation_name=self.organisation_name,
        )

    def clear_organisation(self) -> "WorkspaceState":
        """Return to authenticated user context."""
        return WorkspaceState(user_id=self.user_id)
