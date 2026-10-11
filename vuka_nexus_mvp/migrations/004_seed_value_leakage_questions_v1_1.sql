-- ============================================================
-- VUKA NEXUS Value Discovery™
-- Migration 004: Seed Value Leakage Diagnostic V1.1
--
-- Purpose:
-- Seed the approved 32-question Value Leakage Diagnostic.
--
-- Methodology:
-- 8 Value Leakage Domains
-- ×
-- 4 Diagnostic Dimensions
-- =
-- 32 Diagnostic Questions
--
-- Dimensions:
--   performance
--   process
--   data_technology
--   management_control
--
-- IMPORTANT:
-- Transformation Readiness is assessed separately.
-- ============================================================


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

-- ============================================================
-- 1. REVENUE
-- ============================================================

(
    'value_leakage',
    'Revenue',
    'performance',
    'REV_PERF_01',
    'To what extent is the organisation losing potential revenue through missed sales, weak conversion, customer churn, under-utilised offerings or unrealised growth opportunities?',
    'Consider missed sales, conversion performance, customer churn, lost renewals, under-utilised products or services, cross-sell and upsell opportunities, pricing leakage and other identifiable sources of unrealised revenue.',
    1,
    '1.1',
    true
),

(
    'value_leakage',
    'Revenue',
    'process',
    'REV_PROC_01',
    'To what extent do inefficient, fragmented or manual revenue-generating processes cause delays, missed opportunities or lost sales?',
    'Consider lead-to-sale, quotation, pricing, contracting, onboarding, renewal, cross-sell and similar commercial processes. Look for delays, excessive hand-offs, manual activity, bottlenecks and opportunities that are not followed through.',
    2,
    '1.1',
    true
),

(
    'value_leakage',
    'Revenue',
    'data_technology',
    'REV_DATA_01',
    'To what extent does limited, fragmented or unreliable customer, sales or commercial data prevent the organisation from identifying and acting on revenue opportunities?',
    'Consider disconnected CRM, sales and customer information, poor data quality, limited customer insight, weak commercial analytics, incomplete customer views and inability to identify patterns or opportunities.',
    3,
    '1.1',
    true
),

(
    'value_leakage',
    'Revenue',
    'management_control',
    'REV_MGMT_01',
    'To what extent does management lack timely visibility into revenue performance, pipeline health, customer behaviour or emerging commercial opportunities?',
    'Consider pipeline visibility, conversion reporting, customer profitability, churn indicators, pricing performance, forecast accuracy and management''s ability to identify and act on emerging commercial opportunities.',
    4,
    '1.1',
    true
),


-- ============================================================
-- 2. COST
-- ============================================================

(
    'value_leakage',
    'Cost',
    'performance',
    'COST_PERF_01',
    'To what extent is the organisation incurring avoidable or excessive operating costs that reduce margins or overall financial performance?',
    'Consider unnecessary spend, duplicated expenditure, excessive overheads, waste, poor resource utilisation, avoidable external costs and recurring inefficiencies that adversely affect margins or financial performance.',
    5,
    '1.1',
    true
),

(
    'value_leakage',
    'Cost',
    'process',
    'COST_PROC_01',
    'To what extent do inefficient, fragmented, duplicated or manual processes create unnecessary operating costs or rework?',
    'Consider duplicated activities, manual processing, excessive hand-offs, rework, approval bottlenecks, processing time, FTE effort, outsourcing costs and activities that do not materially contribute to the desired business outcome.',
    6,
    '1.1',
    true
),

(
    'value_leakage',
    'Cost',
    'data_technology',
    'COST_DATA_01',
    'To what extent do fragmented systems, poor data or inadequate technology prevent the organisation from identifying, controlling or reducing unnecessary costs?',
    'Consider limited cost transparency, disconnected systems, unreliable cost information, weak spend analytics, manual cost analysis and inability to identify the underlying drivers of expenditure.',
    7,
    '1.1',
    true
),

(
    'value_leakage',
    'Cost',
    'management_control',
    'COST_MGMT_01',
    'To what extent does management lack timely visibility, accountability or effective controls over cost drivers, spending patterns and opportunities for cost optimisation?',
    'Consider cost ownership, budget accountability, variance analysis, spend visibility, cost-driver reporting, escalation mechanisms and management''s ability to intervene when costs deviate from expectations.',
    8,
    '1.1',
    true
),


-- ============================================================
-- 3. PRODUCTIVITY
-- ============================================================

(
    'value_leakage',
    'Productivity',
    'performance',
    'PROD_PERF_01',
    'To what extent is organisational capacity being lost through low throughput, excessive processing time, delays, rework or inefficient use of employee resources?',
    'Consider cycle time, throughput, backlogs, overtime, utilisation, rework, output per employee or team and other evidence that available organisational capacity is not being converted efficiently into business output.',
    9,
    '1.1',
    true
),

(
    'value_leakage',
    'Productivity',
    'process',
    'PROD_PROC_01',
    'To what extent do manual activities, unnecessary hand-offs, bottlenecks, duplicated work or poorly designed workflows reduce productivity and operational throughput?',
    'Consider repetitive activities, unnecessary approvals, duplicate entry, hand-offs, waiting time, spreadsheet-heavy workflows, avoidable manual intervention and process bottlenecks.',
    10,
    '1.1',
    true
),

(
    'value_leakage',
    'Productivity',
    'data_technology',
    'PROD_DATA_01',
    'To what extent do disconnected systems, repetitive data handling, poor information flows or inadequate technology require employees to spend time on work that could be simplified, automated or eliminated?',
    'Consider copying information between applications, repetitive data entry, manual report preparation, fragmented information, repeated data extraction and employees acting as the manual integration layer between systems.',
    11,
    '1.1',
    true
),

(
    'value_leakage',
    'Productivity',
    'management_control',
    'PROD_MGMT_01',
    'To what extent does management lack visibility into workload, capacity, cycle times, bottlenecks or productivity performance across key processes?',
    'Consider process KPIs, capacity measures, workload visibility, cycle-time reporting, bottleneck analysis, utilisation information and clarity of process ownership.',
    12,
    '1.1',
    true
),


-- ============================================================
-- 4. CUSTOMER EXPERIENCE
-- ============================================================

(
    'value_leakage',
    'Customer Experience',
    'performance',
    'CX_PERF_01',
    'To what extent are customers experiencing service failures, delays, inconsistent experiences, dissatisfaction or unmet expectations that reduce the value delivered to them?',
    'Consider customer complaints, satisfaction measures, service failures, response and resolution times, abandonment, repeat contacts, escalations, customer feedback and other indicators of customer friction or dissatisfaction.',
    13,
    '1.1',
    true
),

(
    'value_leakage',
    'Customer Experience',
    'process',
    'CX_PROC_01',
    'To what extent do fragmented, complex, slow or poorly coordinated customer-facing processes create unnecessary effort, delays or frustration for customers?',
    'Consider customer journey friction, repeated requests for information, excessive hand-offs, long turnaround times, unclear ownership, inconsistent service and unnecessary customer effort.',
    14,
    '1.1',
    true
),

(
    'value_leakage',
    'Customer Experience',
    'data_technology',
    'CX_DATA_01',
    'To what extent do fragmented customer data, disconnected systems or inadequate digital capabilities prevent the organisation from delivering timely, consistent and relevant customer experiences?',
    'Consider incomplete customer views, disconnected channels, repeated requests for the same information, poor digital experiences, inconsistent information and technology limitations affecting service delivery.',
    15,
    '1.1',
    true
),

(
    'value_leakage',
    'Customer Experience',
    'management_control',
    'CX_MGMT_01',
    'To what extent does management lack timely visibility into customer needs, service performance, complaints, journey friction and emerging experience problems?',
    'Consider customer satisfaction measures, complaint themes, service-level reporting, journey analytics, escalation trends, customer feedback and management''s ability to identify deteriorating customer outcomes.',
    16,
    '1.1',
    true
),


-- ============================================================
-- 5. WORKING CAPITAL
-- ============================================================

(
    'value_leakage',
    'Working Capital',
    'performance',
    'WC_PERF_01',
    'To what extent is cash unnecessarily tied up or delayed through slow collections, excess or slow-moving inventory, inefficient payment practices or other working-capital constraints?',
    'Consider DSO, DPO, inventory days, cash-conversion cycle, overdue receivables, bad-debt trends, excess or slow-moving inventory, unbilled revenue or WIP and other evidence of inefficient cash conversion.',
    17,
    '1.1',
    true
),

(
    'value_leakage',
    'Working Capital',
    'process',
    'WC_PROC_01',
    'To what extent do inefficient, fragmented or manual billing, collections, inventory, purchasing or payment processes delay cash conversion or create unnecessary working-capital requirements?',
    'Consider billing delays, invoice disputes, collection activity, purchasing processes, inventory replenishment, payment processes, manual intervention and bottlenecks affecting the operating cash cycle.',
    18,
    '1.1',
    true
),

(
    'value_leakage',
    'Working Capital',
    'data_technology',
    'WC_DATA_01',
    'To what extent do fragmented systems, poor-quality data or inadequate analytics prevent the organisation from identifying and acting on working-capital risks and opportunities?',
    'Consider receivables ageing, inventory visibility, payment timing, dispute information, cash-conversion trends, cash-flow forecasting, fragmented finance data and limited working-capital analytics.',
    19,
    '1.1',
    true
),

(
    'value_leakage',
    'Working Capital',
    'management_control',
    'WC_MGMT_01',
    'To what extent does management lack timely visibility, accountability or effective governance over working-capital performance and its underlying drivers?',
    'Consider ownership of working-capital metrics, targets, DSO, DPO, inventory days, cash-conversion reporting, escalation mechanisms, forecasting and management intervention.',
    20,
    '1.1',
    true
),


-- ============================================================
-- 6. RISK & CONTROLS
-- ============================================================

(
    'value_leakage',
    'Risk & Controls',
    'performance',
    'RISK_PERF_01',
    'To what extent is the organisation exposed to material financial, operational, regulatory, compliance, fraud or reputational losses because key risks are not being adequately prevented, detected or managed?',
    'Consider control failures, financial adjustments, fraud incidents, regulatory breaches, compliance exceptions, operational incidents, losses, audit findings and other evidence of actual or potential enterprise value at risk.',
    21,
    '1.1',
    true
),

(
    'value_leakage',
    'Risk & Controls',
    'process',
    'RISK_PROC_01',
    'To what extent are control activities manual, duplicated, fragmented, inconsistently performed or excessively burdensome, creating either control gaps or unnecessary operational effort?',
    'Consider manual reconciliations, duplicate reviews, excessive approvals, inconsistent control execution, control workarounds, unnecessary checking, fragmented responsibilities and control activities that consume significant operational capacity.',
    22,
    '1.1',
    true
),

(
    'value_leakage',
    'Risk & Controls',
    'data_technology',
    'RISK_DATA_01',
    'To what extent do fragmented systems, poor-quality data or limited monitoring capabilities prevent the organisation from identifying unusual activity, control failures or emerging risks in a timely manner?',
    'Consider retrospective monitoring, incomplete data, manual sampling, limited exception reporting, segregation-of-duties information, access monitoring, anomaly detection and the ability to identify unusual activity across complete populations.',
    23,
    '1.1',
    true
),

(
    'value_leakage',
    'Risk & Controls',
    'management_control',
    'RISK_MGMT_01',
    'To what extent does management lack timely, reliable and actionable visibility into key risks, control effectiveness, incidents, exceptions and remediation progress?',
    'Consider risk reporting, control-performance information, repeat findings, incident reporting, remediation ageing, ownership, escalation and management''s ability to determine whether identified weaknesses have actually been resolved.',
    24,
    '1.1',
    true
),


-- ============================================================
-- 7. DECISION INTELLIGENCE
-- ============================================================

(
    'value_leakage',
    'Decision Intelligence',
    'performance',
    'DI_PERF_01',
    'To what extent are delayed, inconsistent or poorly informed decisions resulting in missed opportunities, avoidable costs, operational underperformance or increased business risk?',
    'Consider decisions made too late, missed opportunities, forecast misses, unexpected cost overruns, delayed corrective action and decisions subsequently reversed because information was incomplete, inconsistent or unavailable.',
    25,
    '1.1',
    true
),

(
    'value_leakage',
    'Decision Intelligence',
    'process',
    'DI_PROC_01',
    'To what extent are decision-making and reporting processes slowed by manual data collection, spreadsheet consolidation, repeated reconciliation, excessive hand-offs or lengthy preparation and approval cycles?',
    'Consider reporting-cycle time, manual data extraction, spreadsheet consolidation, reconciliations, duplicated reporting, repeated information requests and time spent preparing information rather than analysing it.',
    26,
    '1.1',
    true
),

(
    'value_leakage',
    'Decision Intelligence',
    'data_technology',
    'DI_DATA_01',
    'To what extent do fragmented data, inconsistent definitions, poor data quality or disconnected systems prevent decision-makers from accessing a reliable and coherent view of business performance?',
    'Consider conflicting KPIs, inconsistent definitions, master-data problems, disconnected systems, spreadsheet dependencies, data-quality issues and multiple versions of the truth.',
    27,
    '1.1',
    true
),

(
    'value_leakage',
    'Decision Intelligence',
    'management_control',
    'DI_MGMT_01',
    'To what extent does management lack timely, forward-looking and actionable insight into business performance, emerging risks, opportunities and the likely consequences of alternative decisions?',
    'Consider forecasting, scenario modelling, driver-based analysis, predictive insight, early-warning indicators and the ability to connect operational drivers with financial and strategic outcomes.',
    28,
    '1.1',
    true
),


-- ============================================================
-- 8. EMPLOYEE EXPERIENCE
-- ============================================================

(
    'value_leakage',
    'Employee Experience',
    'performance',
    'EE_PERF_01',
    'To what extent are employee frustration, disengagement, capability constraints, turnover or difficulty performing work effectively reducing organisational performance or limiting the organisation''s ability to deliver its objectives?',
    'Consider employee turnover, retention, absenteeism, overtime, engagement feedback, vacancies, capability gaps, performance constraints and evidence that employee friction is affecting organisational outcomes.',
    29,
    '1.1',
    true
),

(
    'value_leakage',
    'Employee Experience',
    'process',
    'EE_PROC_01',
    'To what extent do repetitive administrative work, unnecessary approvals, manual processes, duplicated activities or poorly designed workflows prevent employees from focusing on higher-value work?',
    'Consider administrative burden, repetitive tasks, unnecessary approvals, manual workflows, duplicated data entry, workarounds and the proportion of employee capacity consumed by low-value activities.',
    30,
    '1.1',
    true
),

(
    'value_leakage',
    'Employee Experience',
    'data_technology',
    'EE_DATA_01',
    'To what extent do inadequate tools, fragmented systems, poor information access or difficult-to-use technology create unnecessary effort, frustration or barriers to effective employee performance?',
    'Consider system usability, fragmented applications, information access, support tickets, spreadsheet workarounds, duplicate entry, technology adoption and whether existing tools make work easier or more difficult.',
    31,
    '1.1',
    true
),

(
    'value_leakage',
    'Employee Experience',
    'management_control',
    'EE_MGMT_01',
    'To what extent does management lack visibility into workforce capacity, critical skills, employee pain points, adoption barriers and the capabilities required to support the organisation''s future state?',
    'Consider workforce capacity, critical skills, capability gaps, employee pain points, training needs, change readiness, adoption barriers and management visibility into the people requirements of transformation.',
    32,
    '1.1',
    true
)


-- ============================================================
-- IDEMPOTENT SEED BEHAVIOUR
-- ============================================================

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


-- ============================================================
-- END MIGRATION 004
-- ============================================================