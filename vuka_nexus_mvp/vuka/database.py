"""Database access boundary for VUKA NEXUS V1.1.

All Supabase client creation and database access should pass through this
module rather than being scattered throughout the Streamlit UI.

Security:
    - No credentials are stored here.
    - Configuration is obtained through vuka.config.
    - Privileged service-role credentials are not used by the client app.
"""

from __future__ import annotations

from typing import Any, Optional

from vuka.config import AppConfig, get_config


class DatabaseConfigurationError(RuntimeError):
    """Raised when the database cannot be configured safely."""


def validate_database_config(config: AppConfig) -> None:
    """Validate that the required public Supabase settings are available."""

    if not config.supabase_configured:
        raise DatabaseConfigurationError(
            "Supabase is not configured. "
            "SUPABASE_URL and SUPABASE_ANON_KEY must be supplied "
            "through the runtime environment or Streamlit secrets."
        )


def create_supabase_client(
    config: Optional[AppConfig] = None,
) -> Any:
    """Create the Supabase client without embedding credentials.

    Importing the Supabase SDK occurs inside this function so that the
    architecture can be validated before the dependency is installed.
    """

    runtime_config = config or get_config()

    validate_database_config(runtime_config)

    try:
        from supabase import create_client
    except ImportError as exc:
        raise DatabaseConfigurationError(
            "The Supabase Python SDK is not installed yet."
        ) from exc

    return create_client(
        runtime_config.supabase_url,
        runtime_config.supabase_anon_key,
    )
