"""Supabase authentication service for VUKA NEXUS V1.1.

Responsibilities:
- authenticate users through Supabase Auth;
- retrieve the authenticated user's VUKA profile;
- translate Supabase authentication into SessionState;
- sign users out safely.

This layer does not render UI and does not determine tenant access.
Organisation and engagement authorisation remain governed by membership
records and Supabase Row Level Security.
"""

from __future__ import annotations

from typing import Any

from vuka.auth.session import AuthSession, SessionState


class AuthenticationError(Exception):
    """Raised when authentication cannot be completed safely."""


class AuthenticationService:
    """Application authentication boundary around Supabase Auth."""

    def __init__(self, client: Any, session: AuthSession) -> None:
        self._client = client
        self._session = session

    def sign_in(self, email: str, password: str) -> SessionState:
        """Authenticate a user and establish VUKA application state."""

        if not email or not email.strip():
            raise ValueError("Email is required.")

        if not password:
            raise ValueError("Password is required.")

        try:
            response = self._client.auth.sign_in_with_password(
                {
                    "email": email.strip(),
                    "password": password,
                }
            )
        except Exception as exc:
            raise AuthenticationError(
                "Authentication failed."
            ) from exc

        user = getattr(response, "user", None)
        auth_session = getattr(response, "session", None)

        if user is None or auth_session is None:
            raise AuthenticationError(
                "Supabase did not return a valid authenticated session."
            )

        user_id = str(getattr(user, "id", "") or "")
        user_email = str(getattr(user, "email", "") or email).strip()

        if not user_id:
            raise AuthenticationError(
                "Authenticated user ID was not returned."
            )

        profile = self._load_profile(user_id)

        platform_role = profile.get("platform_role")

        if not platform_role:
            raise AuthenticationError(
                "The authenticated user does not have a VUKA platform role."
            )

        state = SessionState(
            user_id=user_id,
            email=user_email,
            platform_role=str(platform_role),
            access_token=getattr(auth_session, "access_token", None),
            refresh_token=getattr(auth_session, "refresh_token", None),
        )

        self._session.establish(state)

        return state

    def _load_profile(self, user_id: str) -> dict[str, Any]:
        """Retrieve the authenticated user's VUKA profile.

        The query executes using the authenticated Supabase client.
        Row Level Security remains authoritative.
        """

        try:
            response = (
                self._client
                .table("profiles")
                .select("id,email,full_name,platform_role")
                .eq("id", user_id)
                .maybe_single()
                .execute()
            )
        except Exception as exc:
            raise AuthenticationError(
                "Unable to retrieve the authenticated user profile."
            ) from exc

        data = getattr(response, "data", None)

        if not data:
            raise AuthenticationError(
                "No VUKA profile exists for the authenticated user."
            )

        return dict(data)

    def sign_out(self) -> None:
        """Sign out from Supabase and clear local application state."""

        try:
            self._client.auth.sign_out()
        finally:
            self._session.clear()
