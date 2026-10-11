-- ============================================================
-- VUKA NEXUS Value Discovery™
-- Migration 006
-- Seed Transformation Readiness Question Bank
-- Methodology Version: 1.1
-- 8 dimensions x 4 lenses = 32 questions
-- ============================================================

BEGIN;

INSERT INTO public.diagnostic_questions (
    diagnostic_type,
    domain,
    dimension,
    question_key,
    question_text,
    guidance_text,
    display_order,
    methodology_version,
    is_active
)
VALUES
    ('transformation_readiness', 'Data', 'foundation', 'DATA_FOUND_01', 'Does the organisation have sufficiently available, structured and reliable data to support transformation initiatives?', 'Review key data sources, data inventories, quality reports, completeness assessments, reconciliations and master-data records.', 1, '1.1', true),
    ('transformation_readiness', 'Data', 'capability', 'DATA_CAP_01', 'Can the organisation consistently collect, integrate, manage and use data across the business processes relevant to transformation?', 'Review data flows, integration architecture, ETL processes, APIs, reporting processes and data-management procedures.', 2, '1.1', true),
    ('transformation_readiness', 'Data', 'governance', 'DATA_GOV_01', 'Are data ownership, quality standards, access controls and accountability clearly defined and consistently applied?', 'Review data owners and stewards, policies, quality standards, access matrices, governance forums and issue logs.', 3, '1.1', true),
    ('transformation_readiness', 'Data', 'execution', 'DATA_EXEC_01', 'Can transformation initiatives obtain timely, trusted and usable data without substantial manual remediation?', 'Review project experience, extraction lead times, reconciliation effort, manual cleansing requirements and failed or delayed initiatives.', 4, '1.1', true),
    ('transformation_readiness', 'Technology', 'foundation', 'TECH_FOUND_01', 'Does the existing technology environment provide a sufficiently stable, secure and accessible foundation for transformation?', 'Review the application landscape, infrastructure architecture, system availability, technical-debt assessments and integration constraints.', 5, '1.1', true),
    ('transformation_readiness', 'Technology', 'capability', 'TECH_CAP_01', 'Can existing systems and technology teams support integration, automation, analytics and new digital capabilities at the required scale?', 'Review APIs, integration platforms, automation tools, cloud capability, technical skills and deployment history.', 6, '1.1', true),
    ('transformation_readiness', 'Technology', 'governance', 'TECH_GOV_01', 'Are technology changes governed through clear architecture, security, change-management and investment standards?', 'Review architecture standards, change controls, IT governance forums, project approval processes and technology policies.', 7, '1.1', true),
    ('transformation_readiness', 'Technology', 'execution', 'TECH_EXEC_01', 'Can the organisation deploy, integrate and maintain new technology solutions reliably within acceptable time, cost and operational constraints?', 'Review previous implementations, delivery timelines, outages, budget performance, release records and support capability.', 8, '1.1', true),
    ('transformation_readiness', 'Process Maturity', 'foundation', 'PROC_FOUND_01', 'Are the business processes targeted for transformation sufficiently understood and documented to establish how work currently happens?', 'Review SOPs, process maps, walkthroughs, RACI matrices, policies and process documentation.', 9, '1.1', true),
    ('transformation_readiness', 'Process Maturity', 'capability', 'PROC_CAP_01', 'Are processes sufficiently standardised, measurable and repeatable to support redesign, automation or digital enablement?', 'Review standard procedures, KPIs, cycle times, exception rates, process variants and manual workarounds.', 10, '1.1', true),
    ('transformation_readiness', 'Process Maturity', 'governance', 'PROC_GOV_01', 'Are accountable process owners responsible for performance, controls, improvement and cross-functional issues?', 'Review process-owner assignments, governance forums, KPIs, issue logs, control ownership and improvement plans.', 11, '1.1', true),
    ('transformation_readiness', 'Process Maturity', 'execution', 'PROC_EXEC_01', 'Can the organisation redesign and embed process changes across affected teams without repeatedly reverting to legacy ways of working?', 'Review previous transformation outcomes, adoption metrics, post-implementation reviews, recurring workarounds and benefits tracking.', 12, '1.1', true),
    ('transformation_readiness', 'AI Capability', 'foundation', 'AI_FOUND_01', 'Does the organisation have the basic data, technology, skills and use-case understanding required to evaluate AI opportunities responsibly?', 'Review AI skills, available platforms, prior pilots, use-case inventories, data accessibility and AI awareness.', 13, '1.1', true),
    ('transformation_readiness', 'AI Capability', 'capability', 'AI_CAP_01', 'Can the organisation design, acquire, test and integrate AI solutions that address clearly defined business problems?', 'Review AI and analytics teams, vendors, prototypes, deployment processes, model-development capability and integration experience.', 14, '1.1', true),
    ('transformation_readiness', 'AI Capability', 'governance', 'AI_GOV_01', 'Are AI risks governed through appropriate accountability, privacy, security, ethics, human oversight and validation controls?', 'Review AI policy, governance committees, model controls, privacy assessments, approval processes and human-review requirements.', 15, '1.1', true),
    ('transformation_readiness', 'AI Capability', 'execution', 'AI_EXEC_01', 'Can the organisation move appropriate AI use cases from experimentation into controlled operational use and measure whether they create value?', 'Review production deployments, adoption, monitored outcomes, benefits realisation, model monitoring and lessons from failed pilots.', 16, '1.1', true),
    ('transformation_readiness', 'Leadership', 'foundation', 'LEAD_FOUND_01', 'Is there clear executive understanding of why transformation is required and which strategic outcomes it should support?', 'Review strategy documents, board and executive discussions, transformation objectives and investment priorities.', 17, '1.1', true),
    ('transformation_readiness', 'Leadership', 'capability', 'LEAD_CAP_01', 'Do leaders have the capability to sponsor transformation, make cross-functional decisions and resolve barriers quickly?', 'Review executive sponsorship, steering structures, decision records, escalation processes and prior transformation leadership.', 18, '1.1', true),
    ('transformation_readiness', 'Leadership', 'governance', 'LEAD_GOV_01', 'Are transformation decisions, accountabilities, investment ownership and success measures clearly governed at leadership level?', 'Review steering committees, terms of reference, executive owners, business cases and benefits ownership.', 19, '1.1', true),
    ('transformation_readiness', 'Leadership', 'execution', 'LEAD_EXEC_01', 'Do leaders consistently convert transformation priorities into funded actions, accountable ownership and sustained follow-through?', 'Review approved budgets, roadmaps, progress reviews, intervention on delays, completed initiatives and realised benefits.', 20, '1.1', true),
    ('transformation_readiness', 'Workforce Readiness', 'foundation', 'WORK_FOUND_01', 'Does the organisation understand how proposed transformation may affect roles, skills, responsibilities and ways of working?', 'Review workforce analysis, role mapping, skills assessments, organisational-design work and impact assessments.', 21, '1.1', true),
    ('transformation_readiness', 'Workforce Readiness', 'capability', 'WORK_CAP_01', 'Do affected employees have, or can the organisation realistically develop, the skills required to operate successfully in the future state?', 'Review skills inventories, training plans, competency assessments, recruitment plans and learning records.', 22, '1.1', true),
    ('transformation_readiness', 'Workforce Readiness', 'governance', 'WORK_GOV_01', 'Are workforce impacts managed through clear change, communication, training and accountability structures?', 'Review change-management plans, communications, training governance, HR involvement and employee consultation mechanisms.', 23, '1.1', true),
    ('transformation_readiness', 'Workforce Readiness', 'execution', 'WORK_EXEC_01', 'Can the organisation achieve sustained adoption of new processes and technologies rather than merely completing implementation?', 'Review adoption rates, utilisation, employee feedback, training completion, resistance patterns and post-implementation behaviour.', 24, '1.1', true),
    ('transformation_readiness', 'Governance', 'foundation', 'GOV_FOUND_01', 'Are the decision rights, accountability structures and policies necessary to support transformation clearly established?', 'Review governance structures, delegations of authority, policies, committee mandates and accountability matrices.', 25, '1.1', true),
    ('transformation_readiness', 'Governance', 'capability', 'GOV_CAP_01', 'Can governance structures evaluate transformation investments, manage dependencies and make timely risk-informed decisions?', 'Review investment committees, business-case reviews, portfolio governance, decision turnaround and escalation records.', 26, '1.1', true),
    ('transformation_readiness', 'Governance', 'governance', 'GOV_GOV_01', 'Are transformation initiatives subject to proportionate oversight for risk, compliance, controls, ethics and value realisation?', 'Review risk assessments, compliance reviews, internal controls, assurance processes and benefits governance.', 27, '1.1', true),
    ('transformation_readiness', 'Governance', 'execution', 'GOV_EXEC_01', 'Can governance identify problems early and intervene without creating unnecessary bureaucracy that materially slows delivery?', 'Review issue escalation, exception handling, project decisions, governance turnaround times and lessons learned.', 28, '1.1', true),
    ('transformation_readiness', 'Cybersecurity & Privacy', 'foundation', 'CYBER_FOUND_01', 'Does the organisation have baseline cybersecurity and privacy controls capable of supporting increased digitalisation, data use and system connectivity?', 'Review security policies, privacy frameworks, access controls, asset inventories and vulnerability assessments.', 29, '1.1', true),
    ('transformation_readiness', 'Cybersecurity & Privacy', 'capability', 'CYBER_CAP_01', 'Can security and privacy teams assess and manage the risks introduced by new technologies, integrations, data uses and third parties?', 'Review security assessments, privacy impact assessments, vendor reviews, penetration tests and incident-management capability.', 30, '1.1', true),
    ('transformation_readiness', 'Cybersecurity & Privacy', 'governance', 'CYBER_GOV_01', 'Are cybersecurity, privacy, data protection and third-party risks formally incorporated into transformation governance and approval processes?', 'Review risk committees, approval gates, DPIAs, vendor requirements, security standards and regulatory assessments.', 31, '1.1', true),
    ('transformation_readiness', 'Cybersecurity & Privacy', 'execution', 'CYBER_EXEC_01', 'Can the organisation implement transformation solutions while maintaining appropriate security, privacy, resilience and incident-response controls?', 'Review deployment controls, security testing, incident history, recovery testing, monitoring and remediation records.', 32, '1.1', true)
ON CONFLICT (
    diagnostic_type,
    methodology_version,
    question_key
)
DO UPDATE SET
    domain = EXCLUDED.domain,
    dimension = EXCLUDED.dimension,
    question_text = EXCLUDED.question_text,
    guidance_text = EXCLUDED.guidance_text,
    display_order = EXCLUDED.display_order,
    is_active = EXCLUDED.is_active,
    updated_at = now();

COMMIT;

-- ============================================================
-- END MIGRATION 006
-- ============================================================
