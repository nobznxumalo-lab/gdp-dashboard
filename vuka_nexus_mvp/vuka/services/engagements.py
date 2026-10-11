"""Engagement business service for VUKA NEXUS V1.1."""

from __future__ import annotations

from typing import Any, Dict, List, Optional

from vuka.repositories.engagements import EngagementRepository


class EngagementServiceError(RuntimeError):
    """Raised when engagement business rules cannot be satisfied."""


class EngagementService:
    """Business logic for VUKA NEXUS engagements."""

    VALID_STATUSES = {
        "draft",
        "in_progress",
        "completed",
        "archived",
    }

    def __init__(self, repository: EngagementRepository) -> None:
        if repository is None:
            raise EngagementServiceError(
                "An EngagementRepository is required."
            )

        self._repository = repository

    def list_engagements(
        self,
        organization_id: str,
    ) -> List[Dict[str, Any]]:
        """Return engagements for an organisation."""

        if not organization_id:
            raise EngagementServiceError(
                "organization_id is required."
            )

        return self._repository.list_for_organization(
            organization_id
        )

    def get_engagement(
        self,
        engagement_id: str,
    ) -> Optional[Dict[str, Any]]:
        """Return one engagement visible to the current user."""

        if not engagement_id:
            raise EngagementServiceError(
                "engagement_id is required."
            )

        return self._repository.get_by_id(engagement_id)

    def validate_status(self, status: str) -> str:
        """Validate and normalise an engagement status."""

        normalized_status = status.strip().lower()

        if normalized_status not in self.VALID_STATUSES:
            raise EngagementServiceError(
                f"Invalid engagement status: {status}"
            )

        return normalized_status
