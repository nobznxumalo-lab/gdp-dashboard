"""Central configuration for VUKA NEXUS V1.1.

Security principle:
    Application code may READ secrets.
    Application code must never CONTAIN secrets.

Supabase credentials will be supplied through the deployment environment
or Streamlit secrets and must never be committed to Git.
"""

from __future__ import annotations

import os
from dataclasses import dataclass
from typing import Optional


@dataclass(frozen=True)
class AppConfig:
    """Runtime configuration available to the VUKA NEXUS application."""

    environment: str
    supabase_url: Optional[str]
    supabase_anon_key: Optional[str]

    @property
    def supabase_configured(self) -> bool:
        """Return True only when both public Supabase settings are available."""
        return bool(self.supabase_url and self.supabase_anon_key)


def _read_setting(name: str) -> Optional[str]:
    """Read a setting without embedding credentials in source code."""

    value = os.getenv(name)

    if value:
        return value

    # Streamlit is optional at module-import level so configuration
    # can also be tested outside a running Streamlit application.
    try:
        import streamlit as st

        if name in st.secrets:
            return str(st.secrets[name])
    except Exception:
        pass

    return None


def get_config() -> AppConfig:
    """Build application configuration from the runtime environment."""

    return AppConfig(
        environment=os.getenv("VUKA_ENV", "development"),
        supabase_url=_read_setting("SUPABASE_URL"),
        supabase_anon_key=_read_setting("SUPABASE_ANON_KEY"),
    )
