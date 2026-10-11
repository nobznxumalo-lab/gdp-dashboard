-- ============================================================
-- VUKA NEXUS Value Discovery™
-- V1.1 Row Level Security & Tenant Isolation
-- Migration 002
-- ============================================================

-- PURPOSE
-- Enforce organisation-level client isolation at PostgreSQL level.
-- Users may only access organisations to which they are assigned.
-- VUKA platform administrators may access all organisations.
--
-- IMPORTANT
-- The Supabase service_role bypasses RLS by design.
-- It must NEVER be exposed in the browser or client-side code.

-- ============================================================
-- 1. SECURITY HELPER FUNCTIONS
-- ============================================================

CREATE OR REPLACE FUNCTION public.is_platform_admin()
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.profiles p
        WHERE p.id = auth.uid()
          AND p.platform_role = 'admin'
    );
$$;

CREATE OR REPLACE FUNCTION public.is_organization_member(target_organization_id UUID)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.organization_users ou
        WHERE ou.organization_id = target_organization_id
          AND ou.user_id = auth.uid()
    );
$$;

CREATE OR REPLACE FUNCTION public.can_access_engagement(target_engagement_id UUID)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.engagements e
        WHERE e.id = target_engagement_id
          AND (
              public.is_platform_admin()
              OR public.is_organization_member(e.organization_id)
          )
    );
$$;

CREATE OR REPLACE FUNCTION public.can_access_opportunity(target_opportunity_id UUID)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.opportunities o
        WHERE o.id = target_opportunity_id
          AND public.can_access_engagement(o.engagement_id)
    );
$$;

-- Restrict direct execution to authenticated users.
REVOKE ALL ON FUNCTION public.is_platform_admin() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.is_organization_member(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.can_access_engagement(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.can_access_opportunity(UUID) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.is_platform_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_organization_member(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.can_access_engagement(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.can_access_opportunity(UUID) TO authenticated;

-- ============================================================
-- 2. ENABLE ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.engagements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strategic_priorities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strategy_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.value_leakage_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.readiness_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.opportunities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.opportunity_strategic_priorities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_cases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.opportunity_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.evidence ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 3. PROFILES
-- Users can read/update their own profile.
-- Platform admins can read all profiles.
-- ============================================================

CREATE POLICY "profiles_select"
ON public.profiles
FOR SELECT
TO authenticated
USING (
    id = auth.uid()
    OR public.is_platform_admin()
);

CREATE POLICY "profiles_update_own"
ON public.profiles
FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- ============================================================
-- 4. ORGANIZATIONS
-- ============================================================

CREATE POLICY "organizations_select"
ON public.organizations
FOR SELECT
TO authenticated
USING (
    public.is_platform_admin()
    OR public.is_organization_member(id)
);

CREATE POLICY "organizations_insert"
ON public.organizations
FOR INSERT
TO authenticated
WITH CHECK (
    public.is_platform_admin()
    OR created_by = auth.uid()
);

CREATE POLICY "organizations_update"
ON public.organizations
FOR UPDATE
TO authenticated
USING (
    public.is_platform_admin()
    OR public.is_organization_member(id)
)
WITH CHECK (
    public.is_platform_admin()
    OR public.is_organization_member(id)
);

-- ============================================================
-- 5. ORGANIZATION USERS
-- Membership table controlling tenant access.
-- ============================================================

CREATE POLICY "organization_users_select"
ON public.organization_users
FOR SELECT
TO authenticated
USING (
    user_id = auth.uid()
    OR public.is_platform_admin()
    OR public.is_organization_member(organization_id)
);

CREATE POLICY "organization_users_insert_admin"
ON public.organization_users
FOR INSERT
TO authenticated
WITH CHECK (
    public.is_platform_admin()
);

CREATE POLICY "organization_users_update_admin"
ON public.organization_users
FOR UPDATE
TO authenticated
USING (public.is_platform_admin())
WITH CHECK (public.is_platform_admin());

CREATE POLICY "organization_users_delete_admin"
ON public.organization_users
FOR DELETE
TO authenticated
USING (public.is_platform_admin());

-- ============================================================
-- 6. ENGAGEMENTS
-- ============================================================

CREATE POLICY "engagements_select"
ON public.engagements
FOR SELECT
TO authenticated
USING (
    public.is_platform_admin()
    OR public.is_organization_member(organization_id)
);

CREATE POLICY "engagements_insert"
ON public.engagements
FOR INSERT
TO authenticated
WITH CHECK (
    public.is_platform_admin()
    OR public.is_organization_member(organization_id)
);

CREATE POLICY "engagements_update"
ON public.engagements
FOR UPDATE
TO authenticated
USING (
    public.is_platform_admin()
    OR public.is_organization_member(organization_id)
)
WITH CHECK (
    public.is_platform_admin()
    OR public.is_organization_member(organization_id)
);

-- ============================================================
-- 7. ENGAGEMENT-LEVEL TABLES
-- ============================================================

CREATE POLICY "strategic_priorities_access"
ON public.strategic_priorities
FOR ALL
TO authenticated
USING (
    public.can_access_engagement(engagement_id)
)
WITH CHECK (
    public.can_access_engagement(engagement_id)
);

CREATE POLICY "strategy_profiles_access"
ON public.strategy_profiles
FOR ALL
TO authenticated
USING (
    public.can_access_engagement(engagement_id)
)
WITH CHECK (
    public.can_access_engagement(engagement_id)
);

CREATE POLICY "value_leakage_access"
ON public.value_leakage_responses
FOR ALL
TO authenticated
USING (
    public.can_access_engagement(engagement_id)
)
WITH CHECK (
    public.can_access_engagement(engagement_id)
);

CREATE POLICY "readiness_access"
ON public.readiness_responses
FOR ALL
TO authenticated
USING (
    public.can_access_engagement(engagement_id)
)
WITH CHECK (
    public.can_access_engagement(engagement_id)
);

CREATE POLICY "opportunities_access"
ON public.opportunities
FOR ALL
TO authenticated
USING (
    public.can_access_engagement(engagement_id)
)
WITH CHECK (
    public.can_access_engagement(engagement_id)
);

CREATE POLICY "evidence_access"
ON public.evidence
FOR ALL
TO authenticated
USING (
    public.can_access_engagement(engagement_id)
)
WITH CHECK (
    public.can_access_engagement(engagement_id)
);

CREATE POLICY "reports_access"
ON public.reports
FOR ALL
TO authenticated
USING (
    public.can_access_engagement(engagement_id)
)
WITH CHECK (
    public.can_access_engagement(engagement_id)
);

-- ============================================================
-- 8. OPPORTUNITY-LEVEL TABLES
-- ============================================================

CREATE POLICY "business_cases_access"
ON public.business_cases
FOR ALL
TO authenticated
USING (
    public.can_access_opportunity(opportunity_id)
)
WITH CHECK (
    public.can_access_opportunity(opportunity_id)
);

CREATE POLICY "opportunity_scores_access"
ON public.opportunity_scores
FOR ALL
TO authenticated
USING (
    public.can_access_opportunity(opportunity_id)
)
WITH CHECK (
    public.can_access_opportunity(opportunity_id)
);

CREATE POLICY "opportunity_strategy_links_access"
ON public.opportunity_strategic_priorities
FOR ALL
TO authenticated
USING (
    public.can_access_opportunity(opportunity_id)
)
WITH CHECK (
    public.can_access_opportunity(opportunity_id)
);

-- ============================================================
-- END MIGRATION 002
-- ============================================================
