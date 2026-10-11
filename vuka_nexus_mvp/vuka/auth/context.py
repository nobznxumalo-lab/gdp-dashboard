"""Authorised organisation context for VUKA NEXUS V1.1.

Authentication establishes identity.
This module resolves the organisations that the authenticated user may access.

Security principles:
- queries execute through the authenticated Supabase client;
- Row Level Security remains authoritative;
- no privileged credentials are used;
- organisation context is derived from membership records;
- absence of authorised membership fails closed.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any


class AuthorisationError(Exception):
    """Raised when an authorised application context cannot be established."""


@dataclass(frozen=True)
class OrganisationContext:
    """An organisation the authenticated user is authorised to access."""

    organization_id: str
    organization_name: str
    organization_role: str


class AuthorisedContextResolver:
    """Resolve organisation access for an authenticated VUKA user."""

    def __init__(self, client: Any) -> None:
        self._client = client

    def list_organisations(self, user_id: str) -> list[OrganisationContext]:
        """Return organisations visible to the authenticated user.

        Membership is read from organization_users and organisation details
        are obtained through RLS-protected queries.
        """

        if not user_id:
            raise ValueError("Authenticated user ID is required.")

        try:
            membership_response = (
                self._client
                .table("organization_users")
                .select("organization_id,organization_role")
                .eq("user_id", user_id)
                .execute()
            )
        except Exception as exc:
            raise AuthorisationError(
                "Unable to retrieve organisation memberships."
            ) from exc

        memberships = getattr(membership_response, "data", None) or []

        contexts: list[OrganisationContext] = []

        for membership in memberships:
            organization_id = str(
                membership.get("organization_id", "") or ""
            )
            organization_role = str(
                membership.get("organization_role", "") or ""
            )

            if not organization_id or not organization_role:
                continue

            organisation = self._load_organisation(organization_id)

            if organisation is None:
                continue

            contexts.append(
                OrganisationContext(
                    organization_id=organization_id,
                    organization_name=str(organisation["name"]),
                    organization_role=organization_role,
                )
            )

        return contexts

    def require_organisation(
        self,
        user_id: str,
        organization_id: str,
    ) -> OrganisationContext:
        """Require explicit membership of the requested organisation."""

        if not organization_id:
            raise ValueError("Organisation ID is required.")

        organisations = self.list_organisations(user_id)

        for context in organisations:
            if context.organization_id == organization_id:
                return context

        raise AuthorisationError(
            "The authenticated user is not authorised for this organisation."
        )

    def _load_organisation(
        self,
        organization_id: str,
    ) -> dict[str, Any] | None:
        """Retrieve an organisation through the authenticated RLS boundary."""

        try:
            response = (
                self._client
                .table("organizations")
                .select("id,name")
                .eq("id", organization_id)
                .maybe_single()
                .execute()
            )
        except Exception as exc:
            raise AuthorisationError(
                "Unable to retrieve authorised organisation."
            ) from exc

        data = getattr(response, "data", None)

        if not data:
            return None

        return dict(data)
