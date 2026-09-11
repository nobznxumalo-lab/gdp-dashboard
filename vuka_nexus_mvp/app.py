import sqlite3
from pathlib import Path
from datetime import datetime
import pandas as pd
import streamlit as st
import plotly.express as px
import plotly.graph_objects as go

APP_TITLE = "VUKA NEXUS Value Discovery™"
DB_PATH = Path(__file__).with_name("vuka_nexus.db")

VALUE_DOMAINS = {
    "Revenue": [
        "We lose sales opportunities because leads are not prioritised or followed up consistently.",
        "Pricing, discounting or revenue leakage is difficult to detect quickly.",
        "Cross-sell and upsell opportunities are not systematically identified.",
        "Sales teams spend too much time on administration instead of selling.",
    ],
    "Cost": [
        "Material operating activities are still performed manually at high cost.",
        "Rework, duplicate effort or avoidable hand-offs create unnecessary cost.",
        "We lack visibility into the true cost-to-serve by customer, product or channel.",
        "Back-office processes consume more resources than management believes they should.",
    ],
    "Productivity": [
        "Skilled employees spend significant time copying, reconciling or searching for information.",
        "Reporting requires substantial manual preparation and repeated data manipulation.",
        "Process bottlenecks delay work even when demand is predictable.",
        "Employees perform repetitive, rules-based activities that could be redesigned or automated.",
    ],
    "Customer Experience": [
        "Customers experience slow response or resolution times.",
        "Customers must repeat information across channels or teams.",
        "Recurring complaints indicate unresolved root causes.",
        "We struggle to personalise service using customer context and behaviour.",
    ],
    "Working Capital": [
        "Collections are slower than management would like and overdue balances are difficult to prioritise.",
        "Cash forecasting is unreliable or highly manual.",
        "Inventory levels are not consistently aligned to demand and service requirements.",
        "Invoice disputes, billing issues or process delays negatively affect cash conversion.",
    ],
    "Risk & Controls": [
        "Important controls depend on manual review and are difficult to monitor continuously.",
        "Fraud, anomalies or unusual transactions are often identified late.",
        "Reconciliations and exception management consume substantial finance or risk capacity.",
        "Compliance evidence is fragmented, manual or difficult to retrieve.",
    ],
    "Decision Intelligence": [
        "Executives cannot consistently access timely, trusted performance information.",
        "Important decisions rely too heavily on spreadsheets, intuition or manually assembled reports.",
        "Forecasts are frequently inaccurate or become outdated quickly.",
        "Data is fragmented across systems, making enterprise-wide analysis difficult.",
    ],
    "Employee Experience": [
        "Employees spend significant time searching for policies, procedures or organisational knowledge.",
        "Onboarding, internal support or routine queries consume excessive capacity.",
        "Employees experience frustration because systems and processes are fragmented.",
        "Teams lack sufficient training or support to adopt new digital ways of working.",
    ],
}

READINESS_DIMENSIONS = {
    "Data": "Data is accurate, accessible, governed and sufficiently complete for transformation initiatives.",
    "Technology": "Core systems are sufficiently integrated, secure and scalable to support transformation.",
    "Process Maturity": "Key processes are documented, standardised, measured and owned.",
    "AI / Automation Capability": "The organisation has practical capability to evaluate, build, buy and operate automation or AI solutions.",
    "Leadership": "Senior leaders actively sponsor transformation and make timely investment decisions.",
    "Workforce Readiness": "Employees are equipped, engaged and supported to adopt new ways of working.",
    "Governance": "Clear governance exists for transformation, data, AI, risk and accountability.",
    "Cybersecurity & Privacy": "Security, privacy and access controls are mature enough to support digital transformation safely.",
}

INTERVENTIONS = [
    "Process redesign",
    "Control redesign",
    "Data remediation",
    "Workflow automation",
    "RPA",
    "Analytics / BI",
    "Machine Learning",
    "Generative AI",
    "Agentic AI",
    "Human + AI",
]

WEIGHTS = {
    "financial_value": 0.25,
    "strategic_alignment": 0.20,
    "stakeholder_impact": 0.15,
    "feasibility": 0.15,
    "data_readiness": 0.10,
    "risk_complexity": 0.15,
}


def conn():
    return sqlite3.connect(DB_PATH, check_same_thread=False)


def init_db():
    with conn() as c:
        c.execute("""
            CREATE TABLE IF NOT EXISTS organizations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                industry TEXT,
                employees INTEGER,
                annual_revenue REAL,
                strategic_priorities TEXT,
                revenue_objectives TEXT,
                cost_pressures TEXT,
                customer_challenges TEXT,
                risk_concerns TEXT,
                decision_gaps TEXT,
                future_state TEXT,
                created_at TEXT
            )
        """)
        c.execute("""
            CREATE TABLE IF NOT EXISTS diagnostic_responses (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                organization_id INTEGER,
                diagnostic_type TEXT,
                domain TEXT,
                question TEXT,
                score INTEGER,
                evidence TEXT,
                updated_at TEXT,
                UNIQUE(organization_id, diagnostic_type, domain, question)
            )
        """)
        c.execute("""
            CREATE TABLE IF NOT EXISTS opportunities (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                organization_id INTEGER,
                title TEXT,
                domain TEXT,
                pain_point TEXT,
                root_cause TEXT,
                intervention TEXT,
                current_process TEXT,
                systems TEXT,
                annual_volume REAL,
                current_annual_cost REAL,
                expected_annual_benefit REAL,
                implementation_cost REAL,
                annual_technology_cost REAL,
                financial_value INTEGER,
                strategic_alignment INTEGER,
                stakeholder_impact INTEGER,
                feasibility INTEGER,
                data_readiness INTEGER,
                risk_complexity INTEGER,
                owner TEXT,
                horizon TEXT,
                evidence TEXT,
                created_at TEXT
            )
        """)
        c.commit()


def seed_demo():
    with conn() as c:
        count = c.execute("SELECT COUNT(*) FROM organizations").fetchone()[0]
        if count:
            return
        cur = c.execute("""
            INSERT INTO organizations (
                name, industry, employees, annual_revenue, strategic_priorities,
                revenue_objectives, cost_pressures, customer_challenges,
                risk_concerns, decision_gaps, future_state, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            "Ubuntu Industrial Services (Demo)", "Industrial Services", 850, 1_250_000_000,
            "Grow recurring revenue; improve margins; strengthen cash conversion; modernise decision support",
            "Increase recurring and cross-sell revenue across major accounts",
            "High back-office effort, fragmented reporting and duplicate manual processing",
            "Slow turnaround on service queries and inconsistent account information",
            "Manual controls, delayed anomaly detection and fragmented compliance evidence",
            "Leadership reporting is spreadsheet-heavy and often arrives after decisions are needed",
            "A digitally enabled organisation with trusted data, faster decisions and automation embedded into core operations",
            datetime.utcnow().isoformat()
        ))
        org_id = cur.lastrowid
        demo_ops = [
            ("Automate accounts payable exception handling", "Cost", "Finance staff spend excessive time processing invoice exceptions", "Semi-structured invoices and email-driven approvals", "Human + AI", "Email + ERP + spreadsheets", "ERP, email", 42000, 7200000, 3200000, 1800000, 420000, 4, 5, 4, 4, 4, 2, "CFO", "3–6 months", "High invoice volumes and manual exception queues"),
            ("AI-assisted collections prioritisation", "Working Capital", "Collections teams cannot consistently identify which overdue accounts to prioritise", "Fragmented customer risk signals and manual debtor segmentation", "Machine Learning", "ERP ageing + manual follow-up", "ERP, CRM", 12000, 4800000, 5200000, 2400000, 600000, 5, 5, 4, 3, 3, 3, "Finance Director", "6–12 months", "DSO materially above target"),
            ("Executive performance command centre", "Decision Intelligence", "Leadership decisions rely on delayed spreadsheet packs", "Fragmented source systems and manually assembled reporting", "Analytics / BI", "Manual extraction and monthly reporting pack", "ERP, CRM, HRIS", 12, 3600000, 2100000, 1300000, 240000, 4, 5, 5, 4, 4, 2, "CFO / COO", "3–6 months", "Management pack takes >5 business days to assemble"),
        ]
        c.executemany("""
            INSERT INTO opportunities (
                organization_id, title, domain, pain_point, root_cause, intervention,
                current_process, systems, annual_volume, current_annual_cost,
                expected_annual_benefit, implementation_cost, annual_technology_cost,
                financial_value, strategic_alignment, stakeholder_impact, feasibility,
                data_readiness, risk_complexity, owner, horizon, evidence, created_at
            ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        """, [(org_id,)+op+(datetime.utcnow().isoformat(),) for op in demo_ops])
        c.commit()


def get_orgs():
    with conn() as c:
        return pd.read_sql_query("SELECT * FROM organizations ORDER BY id", c)


def get_org(org_id):
    with conn() as c:
        df = pd.read_sql_query("SELECT * FROM organizations WHERE id=?", c, params=(org_id,))
    return None if df.empty else df.iloc[0]


def get_responses(org_id, dtype):
    with conn() as c:
        return pd.read_sql_query(
            "SELECT * FROM diagnostic_responses WHERE organization_id=? AND diagnostic_type=?",
            c, params=(org_id, dtype)
        )


def save_response(org_id, dtype, domain, question, score, evidence=""):
    with conn() as c:
        c.execute("""
            INSERT INTO diagnostic_responses
            (organization_id, diagnostic_type, domain, question, score, evidence, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(organization_id, diagnostic_type, domain, question)
            DO UPDATE SET score=excluded.score, evidence=excluded.evidence, updated_at=excluded.updated_at
        """, (org_id, dtype, domain, question, score, evidence, datetime.utcnow().isoformat()))
        c.commit()


def opportunity_score(r):
    vals = {
        "financial_value": r["financial_value"],
        "strategic_alignment": r["strategic_alignment"],
        "stakeholder_impact": r["stakeholder_impact"],
        "feasibility": r["feasibility"],
        "data_readiness": r["data_readiness"],
        "risk_complexity": 6 - r["risk_complexity"],
    }
    raw = sum(vals[k] * WEIGHTS[k] for k in WEIGHTS)
    return round(raw / 5 * 100, 1)


def classify_opportunity(score, expected_benefit, implementation_cost, risk_complexity):
    value_ratio = expected_benefit / implementation_cost if implementation_cost and implementation_cost > 0 else 0
    if score >= 75 and risk_complexity <= 3:
        return "Quick Win"
    if score >= 70 or (expected_benefit >= 5_000_000 and value_ratio >= 1):
        return "Strategic Bet"
    if score >= 55:
        return "Develop"
    return "Deprioritise"


def get_opportunities(org_id):
    with conn() as c:
        df = pd.read_sql_query("SELECT * FROM opportunities WHERE organization_id=? ORDER BY id DESC", c, params=(org_id,))
    if not df.empty:
        df["opportunity_score"] = df.apply(opportunity_score, axis=1)
        df["priority"] = df.apply(lambda r: classify_opportunity(r["opportunity_score"], r["expected_annual_benefit"], r["implementation_cost"], r["risk_complexity"]), axis=1)
        df["net_annual_benefit"] = df["expected_annual_benefit"] - df["annual_technology_cost"]
        df["roi_pct"] = df.apply(lambda r: ((r["net_annual_benefit"] - r["implementation_cost"]) / r["implementation_cost"] * 100) if r["implementation_cost"] else None, axis=1)
        df["payback_months"] = df.apply(lambda r: (r["implementation_cost"] / r["net_annual_benefit"] * 12) if r["net_annual_benefit"] > 0 else None, axis=1)
        df["three_year_net_benefit"] = df["net_annual_benefit"] * 3 - df["implementation_cost"]
    return df


def money(v):
    if pd.isna(v):
        return "—"
    return f"R{v:,.0f}"


def domain_summary(org_id):
    df = get_responses(org_id, "value")
    if df.empty:
        return pd.DataFrame(columns=["domain", "score"])
    return df.groupby("domain", as_index=False)["score"].mean().sort_values("score", ascending=False)


def readiness_summary(org_id):
    df = get_responses(org_id, "readiness")
    if df.empty:
        return pd.DataFrame(columns=["domain", "score"])
    return df.groupby("domain", as_index=False)["score"].mean().sort_values("score", ascending=False)


st.set_page_config(page_title=APP_TITLE, layout="wide")
init_db()
seed_demo()

st.title(APP_TITLE)
st.caption("From business ambition to measurable AI-enabled value.")

orgs = get_orgs()
with st.sidebar:
    st.header("Client workspace")
    org_name_map = dict(zip(orgs["name"], orgs["id"]))
    selected_name = st.selectbox("Organisation", list(org_name_map.keys()))
    org_id = int(org_name_map[selected_name])
    page = st.radio("Navigate", [
        "1. Strategy Profile",
        "2. Value Leakage",
        "3. Readiness",
        "4. Opportunity Builder",
        "5. Executive Dashboard",
        "6. Portfolio Data",
    ])
    st.divider()
    st.caption("MVP principle: diagnose value first; recommend technology second.")

org = get_org(org_id)

if page == "1. Strategy Profile":
    st.subheader("Strategy & Future-State Profile")
    st.write("Capture where the organisation is trying to go before diagnosing technology needs.")
    with st.form("org_form"):
        c1, c2 = st.columns(2)
        name = c1.text_input("Organisation name", value=org["name"])
        industry = c2.text_input("Industry", value=org["industry"] or "")
        employees = c1.number_input("Employees", min_value=0, value=int(org["employees"] or 0))
        annual_revenue = c2.number_input("Annual revenue (R)", min_value=0.0, value=float(org["annual_revenue"] or 0), step=100000.0)
        strategic_priorities = st.text_area("Top strategic priorities", value=org["strategic_priorities"] or "")
        revenue_objectives = st.text_area("Revenue-growth objectives", value=org["revenue_objectives"] or "")
        cost_pressures = st.text_area("Biggest cost pressures", value=org["cost_pressures"] or "")
        customer_challenges = st.text_area("Customer challenges", value=org["customer_challenges"] or "")
        risk_concerns = st.text_area("Key risk / control concerns", value=org["risk_concerns"] or "")
        decision_gaps = st.text_area("Decision-information gaps", value=org["decision_gaps"] or "")
        future_state = st.text_area("What would the organisation look like at its optimum?", value=org["future_state"] or "", height=120)
        submitted = st.form_submit_button("Save strategy profile")
        if submitted:
            with conn() as c:
                c.execute("""
                    UPDATE organizations SET name=?, industry=?, employees=?, annual_revenue=?,
                    strategic_priorities=?, revenue_objectives=?, cost_pressures=?, customer_challenges=?,
                    risk_concerns=?, decision_gaps=?, future_state=? WHERE id=?
                """, (name, industry, employees, annual_revenue, strategic_priorities, revenue_objectives,
                      cost_pressures, customer_challenges, risk_concerns, decision_gaps, future_state, org_id))
                c.commit()
            st.success("Strategy profile saved.")

elif page == "2. Value Leakage":
    st.subheader("Value Leakage Diagnostic")
    st.write("Score each statement from **1 (not a material issue)** to **5 (severe / material value leakage)**.")
    existing = get_responses(org_id, "value")
    lookup = {(r.domain, r.question): (int(r.score), r.evidence or "") for _, r in existing.iterrows()}
    tabs = st.tabs(list(VALUE_DOMAINS.keys()))
    for tab, (domain, questions) in zip(tabs, VALUE_DOMAINS.items()):
        with tab:
            st.markdown(f"### {domain}")
            for i, q in enumerate(questions, 1):
                score, evidence = lookup.get((domain, q), (3, ""))
                st.write(f"**{i}. {q}**")
                new_score = st.slider("Severity", 1, 5, score, key=f"v_{domain}_{i}")
                new_evidence = st.text_input("Evidence / observation", value=evidence, key=f"ve_{domain}_{i}")
                if st.button("Save", key=f"vs_{domain}_{i}"):
                    save_response(org_id, "value", domain, q, new_score, new_evidence)
                    st.success("Saved")
    summary = domain_summary(org_id)
    if not summary.empty:
        st.divider()
        st.markdown("### Current value leakage heatmap")
        fig = px.bar(summary, x="score", y="domain", orientation="h", range_x=[0,5], labels={"score":"Average severity", "domain":""})
        st.plotly_chart(fig, use_container_width=True)

elif page == "3. Readiness":
    st.subheader("Transformation Readiness")
    st.write("Score from **1 (weak / not ready)** to **5 (strong / highly ready)**. Readiness is deliberately separate from value potential.")
    existing = get_responses(org_id, "readiness")
    lookup = {(r.domain, r.question): (int(r.score), r.evidence or "") for _, r in existing.iterrows()}
    for i, (dim, desc) in enumerate(READINESS_DIMENSIONS.items(), 1):
        score, evidence = lookup.get((dim, desc), (3, ""))
        with st.expander(dim, expanded=True):
            st.write(desc)
            new_score = st.slider("Readiness", 1, 5, score, key=f"r_{i}")
            new_evidence = st.text_input("Evidence / observation", value=evidence, key=f"re_{i}")
            if st.button("Save", key=f"rs_{i}"):
                save_response(org_id, "readiness", dim, desc, new_score, new_evidence)
                st.success("Saved")
    summary = readiness_summary(org_id)
    if not summary.empty:
        st.divider()
        overall = summary["score"].mean()
        st.metric("Overall readiness", f"{overall:.1f} / 5")
        fig = px.bar(summary.sort_values("score"), x="score", y="domain", orientation="h", range_x=[0,5], labels={"score":"Readiness", "domain":""})
        st.plotly_chart(fig, use_container_width=True)

elif page == "4. Opportunity Builder":
    st.subheader("Opportunity Builder")
    st.write("Convert diagnosed pain into a testable transformation opportunity. **AI is optional, not assumed.**")
    with st.form("opp_form", clear_on_submit=True):
        title = st.text_input("Opportunity title")
        domain = st.selectbox("Value domain", list(VALUE_DOMAINS.keys()))
        pain = st.text_area("Pain / value leakage")
        root = st.text_area("Root cause")
        intervention = st.selectbox("Recommended intervention", INTERVENTIONS)
        current_process = st.text_area("Current process / workflow")
        systems = st.text_input("Systems involved")
        c1, c2, c3 = st.columns(3)
        annual_volume = c1.number_input("Annual volume", min_value=0.0, step=100.0)
        current_cost = c2.number_input("Current annual process cost (R)", min_value=0.0, step=100000.0)
        expected_benefit = c3.number_input("Expected annual gross benefit (R)", min_value=0.0, step=100000.0)
        c4, c5 = st.columns(2)
        implementation_cost = c4.number_input("Implementation cost (R)", min_value=0.0, step=100000.0)
        annual_tech_cost = c5.number_input("Annual technology / run cost (R)", min_value=0.0, step=100000.0)
        st.markdown("#### Prioritisation inputs")
        a,b,c = st.columns(3)
        financial = a.slider("Financial value", 1, 5, 3)
        strategic = b.slider("Strategic alignment", 1, 5, 3)
        stakeholder = c.slider("Stakeholder impact", 1, 5, 3)
        d,e,f = st.columns(3)
        feasibility = d.slider("Feasibility", 1, 5, 3)
        data_ready = e.slider("Data readiness", 1, 5, 3)
        risk = f.slider("Risk / complexity", 1, 5, 3, help="5 = high complexity / risk")
        owner = st.text_input("Executive owner")
        horizon = st.selectbox("Indicative horizon", ["0–3 months", "3–6 months", "6–12 months", "12–18 months", "18+ months"])
        evidence = st.text_area("Evidence / assumptions")
        submit = st.form_submit_button("Add opportunity")
        if submit:
            if not title.strip():
                st.error("Please enter an opportunity title.")
            else:
                with conn() as cdb:
                    cdb.execute("""
                        INSERT INTO opportunities (
                            organization_id, title, domain, pain_point, root_cause, intervention,
                            current_process, systems, annual_volume, current_annual_cost,
                            expected_annual_benefit, implementation_cost, annual_technology_cost,
                            financial_value, strategic_alignment, stakeholder_impact, feasibility,
                            data_readiness, risk_complexity, owner, horizon, evidence, created_at
                        ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                    """, (org_id, title, domain, pain, root, intervention, current_process, systems,
                          annual_volume, current_cost, expected_benefit, implementation_cost, annual_tech_cost,
                          financial, strategic, stakeholder, feasibility, data_ready, risk, owner, horizon,
                          evidence, datetime.utcnow().isoformat()))
                    cdb.commit()
                st.success("Opportunity added.")

elif page == "5. Executive Dashboard":
    st.subheader("Executive Value Discovery Dashboard")
    opp = get_opportunities(org_id)
    value = domain_summary(org_id)
    ready = readiness_summary(org_id)

    if opp.empty:
        st.info("Add opportunities to generate the portfolio dashboard.")
    else:
        total_gross = opp["expected_annual_benefit"].sum()
        total_impl = opp["implementation_cost"].sum()
        net_annual = opp["net_annual_benefit"].sum()
        quick_value = opp.loc[opp["priority"].isin(["Quick Win", "Strategic Bet"]), "expected_annual_benefit"].sum()
        readiness = ready["score"].mean() if not ready.empty else None
        c1,c2,c3,c4 = st.columns(4)
        c1.metric("Potential annual gross value", money(total_gross))
        c2.metric("Implementation investment", money(total_impl))
        c3.metric("Net annual benefit", money(net_annual))
        c4.metric("Readiness", f"{readiness:.1f}/5" if readiness is not None else "Not scored")

        st.caption(f"Priority value pool (Quick Wins + Strategic Bets): {money(quick_value)}")

        left, right = st.columns(2)
        with left:
            st.markdown("### Opportunity portfolio")
            chart_df = opp.copy()
            chart_df["complexity"] = chart_df["risk_complexity"]
            fig = px.scatter(
                chart_df, x="complexity", y="opportunity_score", size="expected_annual_benefit",
                hover_name="title", hover_data=["intervention", "priority"],
                range_x=[0.5,5.5], range_y=[0,100], labels={"complexity":"Risk / complexity", "opportunity_score":"Opportunity score"}
            )
            fig.add_hline(y=70, line_dash="dash")
            fig.add_vline(x=3, line_dash="dash")
            st.plotly_chart(fig, use_container_width=True)
        with right:
            st.markdown("### Priority mix")
            mix = opp.groupby("priority", as_index=False)["expected_annual_benefit"].sum()
            fig2 = px.pie(mix, values="expected_annual_benefit", names="priority", hole=.45)
            st.plotly_chart(fig2, use_container_width=True)

        if not value.empty:
            st.markdown("### Value leakage by domain")
            fig3 = px.bar(value, x="domain", y="score", range_y=[0,5], labels={"domain":"", "score":"Average severity"})
            st.plotly_chart(fig3, use_container_width=True)

        st.markdown("### Recommended portfolio")
        display = opp.sort_values(["opportunity_score", "expected_annual_benefit"], ascending=False).copy()
        display["Expected annual benefit"] = display["expected_annual_benefit"].map(money)
        display["Implementation cost"] = display["implementation_cost"].map(money)
        display["3-year net benefit"] = display["three_year_net_benefit"].map(money)
        display["Payback"] = display["payback_months"].map(lambda x: f"{x:.1f} months" if pd.notna(x) else "—")
        st.dataframe(display[["title","domain","intervention","priority","opportunity_score","Expected annual benefit","Implementation cost","Payback","3-year net benefit","owner","horizon"]], use_container_width=True, hide_index=True)

        st.markdown("### Suggested 90-day focus")
        top = display[display["priority"].isin(["Quick Win", "Strategic Bet"])].head(3)
        if top.empty:
            top = display.head(3)
        for _, r in top.iterrows():
            st.markdown(f"**{r['title']}** — {r['priority']} | Score {r['opportunity_score']}/100 | {money(r['expected_annual_benefit'])} expected annual value")

elif page == "6. Portfolio Data":
    st.subheader("Portfolio Data")
    opp = get_opportunities(org_id)
    if opp.empty:
        st.info("No opportunities yet.")
    else:
        st.dataframe(opp, use_container_width=True, hide_index=True)
        csv = opp.to_csv(index=False).encode("utf-8")
        st.download_button("Download opportunity portfolio CSV", csv, file_name="vuka_nexus_opportunity_portfolio.csv", mime="text/csv")

st.divider()
st.caption("VUKA NEXUS Value Discovery™ MVP v1 • Value first. Technology second. Outcomes always.")
