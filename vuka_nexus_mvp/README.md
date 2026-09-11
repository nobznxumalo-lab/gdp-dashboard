# VUKA NEXUS Value Discovery™ — MVP v1

A local Streamlit MVP for diagnosing enterprise value leakage, prioritising transformation opportunities, and building simple business cases.

## What it includes
- Organisation and strategy profile
- Value Leakage Diagnostic across 8 domains
- Readiness Diagnostic across 8 dimensions
- Opportunity Builder
- Transparent prioritisation engine
- Business-case calculator (ROI, payback, 3-year net benefit)
- Executive dashboard with heatmaps, portfolio view, and recommended priorities
- SQLite persistence
- Seed demo company and demo opportunities

## Run locally

```bash
python -m venv .venv
# Windows
.venv\Scripts\activate
# macOS/Linux
source .venv/bin/activate

pip install -r requirements.txt
streamlit run app.py
```

The app creates `vuka_nexus.db` automatically.

## MVP scoring model
Opportunity Score (0–100):
- Financial Value: 25%
- Strategic Alignment: 20%
- Stakeholder Impact: 15%
- Feasibility: 15%
- Data Readiness: 10%
- Risk / Complexity: 15% (inverse scored)

Readiness is deliberately shown separately from opportunity value.

## Important design principle
The app does **not** assume AI is the answer. Interventions can include process redesign, control redesign, data remediation, workflow automation, RPA, analytics, ML, GenAI, Agentic AI, or Human + AI.
