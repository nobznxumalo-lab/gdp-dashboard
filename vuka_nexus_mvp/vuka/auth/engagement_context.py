"""Authorised engagement context for VUKA NEXUS V1.1.

An authenticated user first establishes an authorised organisation context.
This module then resolves the engagements available inside that organisation.

Security model:
    Identity -> Organisation Membership -> Engagement -> RLS -> Data

The application must never treat a UI-selected engagement ID as proof of
authorisation. Engagement access is resolved through the authenticated client
and remains subject to database Row Level Security.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from .context import AuthorisationError


@dataclass(frozen=True)
class EngagementContext:
    """An engagement visible within an authorised organisation."""

    engagement_id: str
    organization_id: str
    engagement_name: str
    status: str


class EngagementContextResolver:
    """Resolve engagement context through the authenticated RLS boundary."""

    def __init__(self, client: Any) -> None:
        self._client = client

    def list_engagements(
        self,
        organization_id: str,
    ) -> list[EngagementContext]:
        """Return engagements visible for an authorised organisation."""

        if not organization_id:
            raise ValueError("Organisation ID is required.")

        try:
            response = (
                self._client
                .table("engagements")
                .select("id,organization_id,name,status")
                .eq("organization_id", organization_id)
                .order("created_at")
                .execute()
            )
        except Exception as exc:
            raise AuthorisationError(
                "Unable to retrieve authorised engagements."
            ) from exc

        rows = getattr(response, "data", None) or []

        contexts: list[EngagementContext] = []

        for row in rows:
            engagement_id = str(row.get("id", "") or "")
            row_organization_id = str(
                row.get("organization_id", "") or ""
            )
            engagement_name = str(row.get("name", "") or "")
            status = str(row.get("status", "") or "")

            if (
                not engagement_id
                or not row_organization_id
                or not engagement_name
            ):
                continue

            contexts.append(
                EngagementContext(
                    engagement_id=engagement_id,
                    organization_id=row_organization_id,
                    engagement_name=engagement_name,
                    status=status,
                )
            )

        return contexts

    def require_engagement(
        self,
        organization_id: str,
        engagement_id: str,
    ) -> EngagementContext:
        """Require the requested engagement inside the organisation context."""

        if not engagement_id:
            raise ValueError("Engagement ID is required.")

        engagements = self.list_engagements(organization_id)

        for context in engagements:
            if (
                context.engagement_id == engagement_id
                and context.organization_id == organization_id
            ):
                return context

        raise AuthorisationError(
            "The requested engagement is not authorised "
            "for this organisation context."
        )
