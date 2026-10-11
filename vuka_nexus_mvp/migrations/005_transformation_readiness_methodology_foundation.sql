-- ============================================================
-- VUKA NEXUS Value Discovery™
-- Migration 005
-- Transformation Readiness Methodology Foundation
-- Methodology Version: 1.1
-- ============================================================

BEGIN;

-- ============================================================
-- 1. EVOLVE READINESS RESPONSES TO QUESTION-LEVEL ASSESSMENT
-- ============================================================

-- V1 stored one response per readiness dimension.
-- V1.1 stores one response per readiness question.
-- The table is currently empty, so no legacy response migration
-- is required.

ALTER TABLE public.readiness_responses
    ADD COLUMN IF NOT EXISTS question_key text,
    ADD COLUMN IF NOT EXISTS question_text text,
    ADD COLUMN IF NOT EXISTS lens text;

-- Remove the V1 uniqueness rule:
-- one response per engagement + dimension.
ALTER TABLE public.readiness_responses
    DROP CONSTRAINT IF EXISTS
    readiness_responses_engagement_id_dimension_key_key;

-- ============================================================
-- 2. READINESS QUESTION-LEVEL UNIQUENESS
-- ============================================================

ALTER TABLE public.readiness_responses
    ADD CONSTRAINT readiness_responses_engagement_question_key_key
    UNIQUE (engagement_id, question_key);

-- ============================================================
-- 3. APPROVED TRANSFORMATION READINESS LENSES
-- ============================================================

ALTER TABLE public.readiness_responses
    ADD CONSTRAINT readiness_responses_lens_check
    CHECK (
        lens IS NULL
        OR lens IN (
            'foundation',
            'capability',
            'governance',
            'execution'
        )
    );

-- ============================================================
-- 4. APPROVED TRANSFORMATION READINESS DIMENSIONS
-- ============================================================

ALTER TABLE public.readiness_responses
    ADD CONSTRAINT readiness_responses_dimension_name_check
    CHECK (
        dimension_name IN (
            'Data',
            'Technology',
            'Process Maturity',
            'AI Capability',
            'Leadership',
            'Workforce Readiness',
            'governance',
            'Cybersecurity & Privacy'
        )
    );

-- ============================================================
-- 5. HARDEN QUESTION-LEVEL FIELDS
-- ============================================================

-- No readiness responses currently exist, so these fields can
-- safely become mandatory for all future V1.1 responses.

ALTER TABLE public.readiness_responses
    ALTER COLUMN question_key SET NOT NULL,
    ALTER COLUMN question_text SET NOT NULL,
    ALTER COLUMN lens SET NOT NULL;

-- ============================================================
-- 6. INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS
    idx_readiness_responses_engagement
    ON public.readiness_responses (engagement_id);

CREATE INDEX IF NOT EXISTS
    idx_readiness_responses_engagement_dimension
    ON public.readiness_responses (engagement_id, dimension_key);

CREATE INDEX IF NOT EXISTS
    idx_readiness_responses_question_key
    ON public.readiness_responses (question_key);

-- ============================================================
-- 7. QUESTION BANK SUPPORT FOR TRANSFORMATION READINESS
-- ============================================================

-- diagnostic_questions already provides the governed,
-- versioned methodology question bank.
--
-- Value Leakage:
-- diagnostic_type = 'value_leakage'
--
-- Transformation Readiness:
-- diagnostic_type = 'transformation_readiness'
--
-- No separate readiness question table is required.

-- Expand the approved diagnostic types while preserving the
-- existing Value Leakage methodology.

ALTER TABLE public.diagnostic_questions
    DROP CONSTRAINT IF EXISTS diagnostic_questions_type_check;

ALTER TABLE public.diagnostic_questions
    ADD CONSTRAINT diagnostic_questions_type_check
    CHECK (
        diagnostic_type IN (
            'value_leakage',
            'transformation_readiness'
        )
    );

-- Replace the Value Leakage-only dimension constraint with a
-- diagnostic-type-aware constraint.

ALTER TABLE public.diagnostic_questions
    DROP CONSTRAINT IF EXISTS diagnostic_questions_dimension_check;

ALTER TABLE public.diagnostic_questions
    ADD CONSTRAINT diagnostic_questions_dimension_check
    CHECK (
        (
            diagnostic_type = 'value_leakage'
            AND dimension IN (
                'performance',
                'process',
                'data_technology',
                'management_control'
            )
        )
        OR
        (
            diagnostic_type = 'transformation_readiness'
            AND dimension IN (
                'foundation',
                'capability',
                'governance',
                'execution'
            )
        )
    );

-- ============================================================
-- 8. SECURITY
-- ============================================================

-- Methodology definitions remain read-only to authenticated
-- application users. Methodology changes are controlled through
-- migrations, not through the application UI.

REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
ON public.diagnostic_questions
FROM authenticated;

GRANT SELECT
ON public.diagnostic_questions
TO authenticated;

COMMIT;

-- ============================================================
-- END MIGRATION 005
-- ============================================================
