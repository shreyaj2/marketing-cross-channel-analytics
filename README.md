# Marketing Cross-Channel Analytics

## Overview
This project integrates advertising performance data from Facebook, Google Ads, and TikTok into a unified data model in BigQuery and visualizes cross-channel performance in Power BI.

## Architecture

- Cloud Data Warehouse: Google BigQuery
- Project ID: hale-photon-487521-p2
- Dataset: ads_demo
- BI Tool: Power BI
- Version Control: GitHub
- CI/CD: GitHub Actions

## Data Model

A unified fact table (`fact_ads`) was created to standardize metrics across platforms:

- date
- platform
- campaign_id
- campaign_name
- ad_group_id
- ad_group_name
- impressions
- clicks
- spend
- conversions

Platform-specific fields were normalized (e.g., cost → spend).

## Data Quality Checks

Implemented validation layer:
- Number of Column Mismatch check
- Row count validation
- Null checks
- Duplicate detection
- Schema validation
- Sanity checks (clicks <= impressions, no negative spend)

See: `sql/01_validate_source_tables.sql`

## Dashboard

Power BI dashboard provides:
- Spend, Impressions, Clicks, Conversions
- CTR, CPC, CPA
- Cross-platform comparison
- Campaign-level drilldown

Live Dashboard Link:
[PASTE POWER BI LINK HERE]

## Deployment

SQL deployment automated via GitHub Actions:
`.github/workflows/bigquery-deploy.yml`
