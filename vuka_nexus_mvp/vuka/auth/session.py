"""Authentication session boundary for VUKA NEXUS V1.1.

This module contains application-level authentication/session state only.

It deliberately does NOT:
- render Streamlit UI;
- contain credentials;
- use privileged backend access;
- query database tables directly;
- bypass Supabase Row Level Security.

Authentication providers and UI components will interact with this
boundary rather than scattering authentication state throughout the app.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Optional


ALLOWED_PLATFORM_ROLES = frozenset(
    {
        "admin",
        "consultant",
        "client_executive",
        "client_contributor",
    }
)


@dataclass(frozen=True)
class SessionState:
    """Immutable representation of the authenticated application context."""

    user_id: str
    email: str
    platform_role: str

    organization_id: Optional[str] = None
    organization_role: Optional[str] = None
    engagement_id: Optional[str] = None

    access_token: Optional[str] = None
    refresh_token: Optional[str] = None

    def __post_init__(self) -> None:
        if not self.user_id.strip():
            raise ValueError("user_id is required.")

        if not self.email.strip():
            raise ValueError("email is required.")

        if self.platform_role not in ALLOWED_PLATFORM_ROLES:
            raise ValueError(
                f"Unsupported platform role: {self.platform_role}"
            )

        if self.engagement_id and not self.organization_id:
            raise ValueError(
                "An engagement cannot be selected without an organisation."
            )

    @property
    def is_platform_admin(self) -> bool:
        return self.platform_role == "admin"

    @property
    def is_consultant(self) -> bool:
        return self.platform_role in {"admin", "consultant"}

    @property
    def has_organization_context(self) -> bool:
        return bool(self.organization_id)

    @property
    def has_engagement_context(self) -> bool:
        return bool(self.engagement_id)

    def select_organization(
        self,
        organization_id: str,
        organization_role: str,
    ) -> "SessionState":
        """Return a new session scoped to an organisation."""

        if not organization_id.strip():
            raise ValueError("organization_id is required.")

        if not organization_role.strip():
            raise ValueError("organization_role is required.")

        return SessionState(
            user_id=self.user_id,
            email=self.email,
            platform_role=self.platform_role,
            organization_id=organization_id,
            organization_role=organization_role,
            engagement_id=None,
            access_token=self.access_token,
            refresh_token=self.refresh_token,
        )

    def select_engagement(self, engagement_id: str) -> "SessionState":
        """Return a new session scoped to an engagement."""

        if not self.organization_id:
            raise ValueError(
                "Select an organisation before selecting an engagement."
            )

        if not engagement_id.strip():
            raise ValueError("engagement_id is required.")

        return SessionState(
            user_id=self.user_id,
            email=self.email,
            platform_role=self.platform_role,
            organization_id=self.organization_id,
            organization_role=self.organization_role,
            engagement_id=engagement_id,
            access_token=self.access_token,
            refresh_token=self.refresh_token,
        )

    def clear_engagement(self) -> "SessionState":
        """Return the same session without an engagement selection."""

        return SessionState(
            user_id=self.user_id,
            email=self.email,
            platform_role=self.platform_role,
            organization_id=self.organization_id,
            organization_role=self.organization_role,
            engagement_id=None,
            access_token=self.access_token,
            refresh_token=self.refresh_token,
        )


class AuthSession:
    """Small application boundary around the current authenticated session."""

    def __init__(self) -> None:
        self._state: Optional[SessionState] = None

    @property
    def state(self) -> Optional[SessionState]:
        return self._state

    @property
    def is_authenticated(self) -> bool:
        return self._state is not None

    def establish(self, state: SessionState) -> None:
        """Establish authenticated application state."""
        self._state = state

    def require(self) -> SessionState:
        """Return the authenticated state or fail closed."""
        if self._state is None:
            raise PermissionError("Authentication is required.")
        return self._state

    def clear(self) -> None:
        """Remove the current authenticated application state."""
        self._state = None
