"""Base repository infrastructure for VUKA NEXUS V1.1."""

from __future__ import annotations

from typing import Any


class RepositoryError(RuntimeError):
    """Base exception for repository-layer failures."""


class BaseRepository:
    """Base class for VUKA NEXUS data repositories.

    Repositories receive a database client rather than creating their
    own connection. This keeps connection management centralised and
    makes repositories easier to test.
    """

    def __init__(self, client: Any) -> None:
        if client is None:
            raise RepositoryError(
                "A database client is required to initialise a repository."
            )

        self._client = client

    @property
    def client(self) -> Any:
        """Return the configured database client."""
        return self._client
