-- ============================================================
-- VUKA NEXUS Value Discovery™
-- Migration 003: Diagnostic Methodology Foundation
-- Version: V1.1
--
-- Purpose:
-- 1. Formalise the diagnostic question bank in source control.
-- 2. Establish the approved four-dimension Value Leakage model.
-- 3. Protect VUKA methodology through Row Level Security.
-- 4. Prepare the database for versioned diagnostic content.
-- ============================================================


-- ------------------------------------------------------------
-- 1. DIAGNOSTIC QUESTION BANK
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.diagnostic_questions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    diagnostic_type text NOT NULL
        DEFAULT 'value_leakage',

    domain text NOT NULL,

    dimension text NOT NULL,

    question_key text NOT NULL,

    question_text text NOT NULL,

    guidance_text text,

    display_order integer NOT NULL,

    methodology_version text NOT NULL
        DEFAULT '1.1',

    is_active boolean NOT NULL
        DEFAULT true,

    created_at timestamptz NOT NULL
        DEFAULT now(),

    updated_at timestamptz NOT NULL
        DEFAULT now(),

    CONSTRAINT diagnostic_questions_unique_version_key
        UNIQUE (
            diagnostic_type,
            methodology_version,
            question_key
        )
);


-- ------------------------------------------------------------
-- 2. FORMALISE APPROVED V1.1 DIMENSIONS
-- ------------------------------------------------------------
-- Value Leakage is assessed through four lenses:
--
-- performance
--     Is measurable enterprise value being lost?
--
-- process
--     Are business processes contributing to the leakage?
--
-- data_technology
--     Are data or technology constraints contributing?
--
-- management_control
--     Can management see, manage and respond to the problem?
--
-- Transformation Readiness remains a separate assessment.
-- ------------------------------------------------------------

DO $$
DECLARE
    constraint_record record;
BEGIN

    -- Remove any previous CHECK constraint on the dimension
    -- column so the manually-created prototype constraint does
    -- not conflict with the approved V1.1 methodology.

    FOR constraint_record IN
        SELECT con.conname
        FROM pg_constraint con
        JOIN pg_class rel
            ON rel.oid = con.conrelid
        JOIN pg_namespace nsp
            ON nsp.oid = rel.relnamespace
        WHERE nsp.nspname = 'public'
          AND rel.relname = 'diagnostic_questions'
          AND con.contype = 'c'
          AND pg_get_constraintdef(con.oid)
                ILIKE '%dimension%'
    LOOP
        EXECUTE format(
            'ALTER TABLE public.diagnostic_questions DROP CONSTRAINT %I',
            constraint_record.conname
        );
    END LOOP;

END $$;


ALTER TABLE public.diagnostic_questions
ADD CONSTRAINT diagnostic_questions_dimension_check
CHECK (
    dimension IN (
        'performance',
        'process',
        'data_technology',
        'management_control'
    )
);


-- ------------------------------------------------------------
-- 3. VALIDATE SUPPORTED DIAGNOSTIC TYPE
-- ------------------------------------------------------------

ALTER TABLE public.diagnostic_questions
DROP CONSTRAINT IF EXISTS diagnostic_questions_type_check;

ALTER TABLE public.diagnostic_questions
ADD CONSTRAINT diagnostic_questions_type_check
CHECK (
    diagnostic_type IN (
        'value_leakage'
    )
);


-- ------------------------------------------------------------
-- 4. BASIC DATA QUALITY CONTROLS
-- ------------------------------------------------------------

ALTER TABLE public.diagnostic_questions
DROP CONSTRAINT IF EXISTS diagnostic_questions_display_order_check;

ALTER TABLE public.diagnostic_questions
ADD CONSTRAINT diagnostic_questions_display_order_check
CHECK (display_order > 0);


-- ------------------------------------------------------------
-- 5. INDEXES
-- ------------------------------------------------------------

CREATE INDEX IF NOT EXISTS
    idx_diagnostic_questions_lookup
ON public.diagnostic_questions (
    diagnostic_type,
    methodology_version,
    domain,
    display_order
);

CREATE INDEX IF NOT EXISTS
    idx_diagnostic_questions_active
ON public.diagnostic_questions (
    diagnostic_type,
    methodology_version,
    is_active
);


-- ------------------------------------------------------------
-- 6. ROW LEVEL SECURITY
-- ------------------------------------------------------------

ALTER TABLE public.diagnostic_questions
ENABLE ROW LEVEL SECURITY;


-- Remove policy first so this migration can be safely rerun
-- during controlled development.

DROP POLICY IF EXISTS
    "diagnostic_questions_authenticated_read"
ON public.diagnostic_questions;


-- Authenticated platform users may read the methodology.
-- They may NOT modify methodology content through this policy.

CREATE POLICY
    "diagnostic_questions_authenticated_read"
ON public.diagnostic_questions
FOR SELECT
TO authenticated
USING (is_active = true);


-- ------------------------------------------------------------
-- 7. TABLE PRIVILEGES
-- ------------------------------------------------------------

REVOKE ALL
ON TABLE public.diagnostic_questions
FROM anon;

REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
ON TABLE public.diagnostic_questions
FROM authenticated;

GRANT SELECT
ON TABLE public.diagnostic_questions
TO authenticated;


-- ============================================================
-- END MIGRATION 003
-- ============================================================