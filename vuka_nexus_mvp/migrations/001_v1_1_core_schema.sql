-- ============================================================
-- VUKA NEXUS Value Discovery™
-- V1.1 Core PostgreSQL / Supabase Schema
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- 1. USER PROFILES
-- Authentication itself will be handled by Supabase Auth.
-- ============================================================

CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT,
    email TEXT,
    platform_role TEXT NOT NULL DEFAULT 'consultant'
        CHECK (platform_role IN (
            'admin',
            'consultant',
            'client_executive',
            'client_contributor'
        )),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 2. ORGANISATIONS
-- One organisation may have multiple engagements over time.
-- ============================================================

CREATE TABLE IF NOT EXISTS organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name TEXT NOT NULL,
    industry TEXT,
    country TEXT,
    employee_count INTEGER,
    annual_revenue NUMERIC(18,2),

    primary_contact_name TEXT,
    primary_contact_email TEXT,

    created_by UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 3. ORGANISATION USERS
-- Controls which users belong to which client workspace.
-- ============================================================

CREATE TABLE IF NOT EXISTS organization_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id) ON DELETE CASCADE,

    user_id UUID NOT NULL
        REFERENCES profiles(id) ON DELETE CASCADE,

    organization_role TEXT NOT NULL
        CHECK (organization_role IN (
            'admin',
            'consultant',
            'client_executive',
            'client_contributor'
        )),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE (organization_id, user_id)
);

-- ============================================================
-- 4. ENGAGEMENTS
-- The engagement becomes the main V1.1 unit of work.
-- ============================================================

CREATE TABLE IF NOT EXISTS engagements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id) ON DELETE CASCADE,

    name TEXT NOT NULL,

    status TEXT NOT NULL DEFAULT 'draft'
        CHECK (status IN (
            'draft',
            'in_progress',
            'review',
            'approved',
            'closed'
        )),

    start_date DATE,
    end_date DATE,

    created_by UUID REFERENCES profiles(id),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 5. STRATEGIC PRIORITIES
-- Replaces strategy fields stored directly on V1 organisations.
-- ============================================================

CREATE TABLE IF NOT EXISTS strategic_priorities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    engagement_id UUID NOT NULL
        REFERENCES engagements(id) ON DELETE CASCADE,

    priority_type TEXT,
    title TEXT NOT NULL,
    description TEXT,

    importance_score INTEGER
        CHECK (importance_score BETWEEN 1 AND 5),

    created_by UUID REFERENCES profiles(id),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 6. STRATEGY PROFILE
-- Preserves richer V1 strategy information.
-- ============================================================

CREATE TABLE IF NOT EXISTS strategy_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    engagement_id UUID NOT NULL UNIQUE
        REFERENCES engagements(id) ON DELETE CASCADE,

    revenue_objectives TEXT,
    cost_pressures TEXT,
    customer_challenges TEXT,
    risk_concerns TEXT,
    decision_gaps TEXT,
    future_state TEXT,

    created_by UUID REFERENCES profiles(id),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 7. VALUE LEAKAGE RESPONSES
-- V1.1 diagnostic responses linked to an engagement.
-- ============================================================

CREATE TABLE IF NOT EXISTS value_leakage_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    engagement_id UUID NOT NULL
        REFERENCES engagements(id) ON DELETE CASCADE,

    domain TEXT NOT NULL,

    question_key TEXT NOT NULL,
    question_text TEXT NOT NULL,

    severity INTEGER
        CHECK (severity BETWEEN 1 AND 5),

    evidence_text TEXT,

    evidence_status TEXT NOT NULL DEFAULT 'unsubstantiated'
        CHECK (evidence_status IN (
            'unsubstantiated',
            'management_assertion',
            'evidence_provided',
            'consultant_validated'
        )),

    created_by UUID REFERENCES profiles(id),
    updated_by UUID REFERENCES profiles(id),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE (engagement_id, question_key)
);

-- ============================================================
-- 8. READINESS RESPONSES
-- Separate from value potential by design.
-- ============================================================

CREATE TABLE IF NOT EXISTS readiness_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    engagement_id UUID NOT NULL
        REFERENCES engagements(id) ON DELETE CASCADE,

    dimension_key TEXT NOT NULL,
    dimension_name TEXT NOT NULL,

    score INTEGER
        CHECK (score BETWEEN 1 AND 5),

    evidence_text TEXT,

    evidence_status TEXT NOT NULL DEFAULT 'unsubstantiated'
        CHECK (evidence_status IN (
            'unsubstantiated',
            'management_assertion',
            'evidence_provided',
            'consultant_validated'
        )),

    created_by UUID REFERENCES profiles(id),
    updated_by UUID REFERENCES profiles(id),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE (engagement_id, dimension_key)
);

-- ============================================================
-- 9. OPPORTUNITIES
-- Business problem + intervention + strategic ownership.
-- ============================================================

CREATE TABLE IF NOT EXISTS opportunities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    engagement_id UUID NOT NULL
        REFERENCES engagements(id) ON DELETE CASCADE,

    title TEXT NOT NULL,

    value_domain TEXT NOT NULL,

    pain_point TEXT,
    root_cause TEXT,
    affected_stakeholders TEXT,

    current_process TEXT,
    systems_involved TEXT,

    recommended_intervention TEXT,
    intervention_rationale TEXT,
    alternative_interventions TEXT,

    ai_suitability TEXT
        CHECK (
            ai_suitability IS NULL OR
            ai_suitability IN ('low', 'medium', 'high')
        ),

    dependencies TEXT,

    implementation_complexity INTEGER
        CHECK (
            implementation_complexity IS NULL OR
            implementation_complexity BETWEEN 1 AND 5
        ),

    executive_owner TEXT,

    horizon TEXT,

    status TEXT NOT NULL DEFAULT 'draft'
        CHECK (status IN (
            'draft',
            'validated',
            'recommended',
            'approved',
            'deferred',
            'rejected'
        )),

    created_by UUID REFERENCES profiles(id),
    updated_by UUID REFERENCES profiles(id),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 10. OPPORTUNITY / STRATEGY LINKS
-- One opportunity may support several strategic priorities.
-- ============================================================

CREATE TABLE IF NOT EXISTS opportunity_strategic_priorities (
    opportunity_id UUID NOT NULL
        REFERENCES opportunities(id) ON DELETE CASCADE,

    strategic_priority_id UUID NOT NULL
        REFERENCES strategic_priorities(id) ON DELETE CASCADE,

    PRIMARY KEY (opportunity_id, strategic_priority_id)
);

-- ============================================================
-- 11. BUSINESS CASES
-- Financial assumptions and calculated investment outputs.
-- ============================================================

CREATE TABLE IF NOT EXISTS business_cases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    opportunity_id UUID NOT NULL UNIQUE
        REFERENCES opportunities(id) ON DELETE CASCADE,

    annual_volume NUMERIC(18,2),

    current_annual_process_cost NUMERIC(18,2),

    expected_gross_annual_benefit NUMERIC(18,2),

    implementation_cost NUMERIC(18,2),

    annual_run_cost NUMERIC(18,2),

    net_annual_benefit NUMERIC(18,2),

    first_year_net_benefit NUMERIC(18,2),

    roi_percent NUMERIC(12,2),

    payback_months NUMERIC(12,2),

    three_year_net_benefit NUMERIC(18,2),

    five_year_net_benefit NUMERIC(18,2),

    confidence_level TEXT
        CHECK (
            confidence_level IS NULL OR
            confidence_level IN ('low', 'medium', 'high')
        ),

    assumptions TEXT,

    calculation_version TEXT NOT NULL DEFAULT '1.1',

    created_by UUID REFERENCES profiles(id),
    updated_by UUID REFERENCES profiles(id),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 12. OPPORTUNITY SCORES
-- V1.1 approved prioritisation methodology.
-- ============================================================

CREATE TABLE IF NOT EXISTS opportunity_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    opportunity_id UUID NOT NULL UNIQUE
        REFERENCES opportunities(id) ON DELETE CASCADE,

    financial_value INTEGER NOT NULL
        CHECK (financial_value BETWEEN 1 AND 5),

    strategic_alignment INTEGER NOT NULL
        CHECK (strategic_alignment BETWEEN 1 AND 5),

    stakeholder_impact INTEGER NOT NULL
        CHECK (stakeholder_impact BETWEEN 1 AND 5),

    feasibility INTEGER NOT NULL
        CHECK (feasibility BETWEEN 1 AND 5),

    data_readiness INTEGER NOT NULL
        CHECK (data_readiness BETWEEN 1 AND 5),

    implementation_risk INTEGER NOT NULL
        CHECK (implementation_risk BETWEEN 1 AND 5),

    adjusted_risk_score INTEGER
        CHECK (
            adjusted_risk_score IS NULL OR
            adjusted_risk_score BETWEEN 1 AND 5
        ),

    opportunity_score NUMERIC(6,2),

    value_potential_score NUMERIC(6,2),

    execution_readiness_score NUMERIC(6,2),

    portfolio_classification TEXT
        CHECK (
            portfolio_classification IS NULL OR
            portfolio_classification IN (
                'Quick Win',
                'Strategic Bet',
                'Develop',
                'Deprioritise'
            )
        ),

    scoring_version TEXT NOT NULL DEFAULT '1.1',

    created_by UUID REFERENCES profiles(id),
    updated_by UUID REFERENCES profiles(id),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 13. EVIDENCE
-- Metadata for evidence stored in Supabase Storage.
-- ============================================================

CREATE TABLE IF NOT EXISTS evidence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    engagement_id UUID NOT NULL
        REFERENCES engagements(id) ON DELETE CASCADE,

    opportunity_id UUID
        REFERENCES opportunities(id) ON DELETE CASCADE,

    evidence_type TEXT,

    title TEXT NOT NULL,

    description TEXT,

    storage_path TEXT,

    source_reference TEXT,

    validation_status TEXT NOT NULL DEFAULT 'provided'
        CHECK (validation_status IN (
            'provided',
            'reviewed',
            'validated',
            'rejected'
        )),

    uploaded_by UUID REFERENCES profiles(id),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 14. REPORTS
-- Metadata for generated executive reports.
-- ============================================================

CREATE TABLE IF NOT EXISTS reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    engagement_id UUID NOT NULL
        REFERENCES engagements(id) ON DELETE CASCADE,

    report_type TEXT NOT NULL DEFAULT 'value_discovery',

    report_version TEXT NOT NULL DEFAULT '1.1',

    status TEXT NOT NULL DEFAULT 'draft'
        CHECK (status IN (
            'draft',
            'generated',
            'issued',
            'superseded'
        )),

    storage_path TEXT,

    generated_by UUID REFERENCES profiles(id),
    generated_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 15. INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_engagements_organization
    ON engagements(organization_id);

CREATE INDEX IF NOT EXISTS idx_value_leakage_engagement
    ON value_leakage_responses(engagement_id);

CREATE INDEX IF NOT EXISTS idx_readiness_engagement
    ON readiness_responses(engagement_id);

CREATE INDEX IF NOT EXISTS idx_opportunities_engagement
    ON opportunities(engagement_id);

CREATE INDEX IF NOT EXISTS idx_evidence_engagement
    ON evidence(engagement_id);

CREATE INDEX IF NOT EXISTS idx_reports_engagement
    ON reports(engagement_id);

-- ============================================================
-- END V1.1 CORE SCHEMA
-- Row Level Security policies will be added separately.
-- ============================================================
