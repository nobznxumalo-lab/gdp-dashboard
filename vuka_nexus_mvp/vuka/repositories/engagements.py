"""Engagement repository for VUKA NEXUS V1.1."""

from __future__ import annotations

from typing import Any, Dict, List, Optional

from vuka.repositories.base import BaseRepository


class EngagementRepository(BaseRepository):
    """Persistence operations for VUKA NEXUS engagements."""

    TABLE_NAME = "engagements"

    def list_for_organization(
        self,
        organization_id: str,
    ) -> List[Dict[str, Any]]:
        """Return engagements visible to the authenticated user."""

        response = (
            self.client
            .table(self.TABLE_NAME)
            .select("*")
            .eq("organization_id", organization_id)
            .order("created_at", desc=True)
            .execute()
        )

        return response.data or []

    def get_by_id(
        self,
        engagement_id: str,
    ) -> Optional[Dict[str, Any]]:
        """Return one engagement if visible under current RLS context."""

        response = (
            self.client
            .table(self.TABLE_NAME)
            .select("*")
            .eq("id", engagement_id)
            .limit(1)
            .execute()
        )

        rows = response.data or []

        return rows[0] if rows else None
