/*
01_qa_source_tables.sql
Purpose: Pre-unification QA/UAT checks for Facebook, Google, TikTok source tables in BigQuery.

Project: hale-photon-487521-p2
Dataset: ads_demo
Tables: facebook_ads, google_ads, tiktok_ads
*/

-- =========================
-- 0) Quick smoke test: preview
-- =========================
SELECT * FROM `hale-photon-487521-p2.ads_demo.facebook_ads` LIMIT 10;
SELECT * FROM `hale-photon-487521-p2.ads_demo.google_ads` LIMIT 10;
SELECT * FROM `hale-photon-487521-p2.ads_demo.tiktok_ads` LIMIT 10;


-- =========================
-- 1) Row count validation
-- =========================
SELECT 'facebook_ads' AS table_name, COUNT(*) AS row_count
FROM `hale-photon-487521-p2.ads_demo.facebook_ads`
UNION ALL
SELECT 'google_ads', COUNT(*)
FROM `hale-photon-487521-p2.ads_demo.google_ads`
UNION ALL
SELECT 'tiktok_ads', COUNT(*)
FROM `hale-photon-487521-p2.ads_demo.tiktok_ads`;


-- =========================
-- 2) Date coverage checks
-- =========================
SELECT 'facebook_ads' AS table_name, MIN(DATE(date)) AS min_date, MAX(DATE(date)) AS max_date, COUNT(DISTINCT DATE(date)) AS distinct_days
FROM `hale-photon-487521-p2.ads_demo.facebook_ads`
UNION ALL
SELECT 'google_ads', MIN(DATE(date)), MAX(DATE(date)), COUNT(DISTINCT DATE(date))
FROM `hale-photon-487521-p2.ads_demo.google_ads`
UNION ALL
SELECT 'tiktok_ads', MIN(DATE(date)), MAX(DATE(date)), COUNT(DISTINCT DATE(date))
FROM `hale-photon-487521-p2.ads_demo.tiktok_ads`;


-- =========================
-- 3) Null checks for critical identifiers + core metrics
--    Note: spend field differs (Facebook=spend, Google/TikTok=cost)
-- =========================

-- 3A) Facebook null checks
SELECT
  'facebook_ads' AS table_name,
  COUNT(*) AS total_rows,
  COUNTIF(date IS NULL) AS null_date,
  COUNTIF(campaign_id IS NULL) AS null_campaign_id,
  COUNTIF(campaign_name IS NULL) AS null_campaign_name,
  COUNTIF(ad_set_id IS NULL) AS null_ad_set_id,
  COUNTIF(impressions IS NULL) AS null_impressions,
  COUNTIF(clicks IS NULL) AS null_clicks,
  COUNTIF(spend IS NULL) AS null_spend,
  COUNTIF(conversions IS NULL) AS null_conversions
FROM `hale-photon-487521-p2.ads_demo.facebook_ads`;

-- 3B) Google null checks
SELECT
  'google_ads' AS table_name,
  COUNT(*) AS total_rows,
  COUNTIF(date IS NULL) AS null_date,
  COUNTIF(campaign_id IS NULL) AS null_campaign_id,
  COUNTIF(campaign_name IS NULL) AS null_campaign_name,
  COUNTIF(ad_group_id IS NULL) AS null_ad_group_id,
  COUNTIF(impressions IS NULL) AS null_impressions,
  COUNTIF(clicks IS NULL) AS null_clicks,
  COUNTIF(cost IS NULL) AS null_cost,
  COUNTIF(conversions IS NULL) AS null_conversions
FROM `hale-photon-487521-p2.ads_demo.google_ads`;

-- 3C) TikTok null checks
SELECT
  'tiktok_ads' AS table_name,
  COUNT(*) AS total_rows,
  COUNTIF(date IS NULL) AS null_date,
  COUNTIF(campaign_id IS NULL) AS null_campaign_id,
  COUNTIF(campaign_name IS NULL) AS null_campaign_name,
  COUNTIF(adgroup_id IS NULL) AS null_adgroup_id,
  COUNTIF(impressions IS NULL) AS null_impressions,
  COUNTIF(clicks IS NULL) AS null_clicks,
  COUNTIF(cost IS NULL) AS null_cost,
  COUNTIF(conversions IS NULL) AS null_conversions
FROM `hale-photon-487521-p2.ads_demo.tiktok_ads`;


-- =========================
-- 4) Duplicate checks (by date + campaign + ad group)
--    If these return rows, you should investigate before unifying.
-- =========================

-- 4A) Facebook potential duplicates
SELECT
  DATE(date) AS date,
  campaign_id,
  ad_set_id AS ad_group_id,
  COUNT(*) AS duplicate_rows
FROM `hale-photon-487521-p2.ads_demo.facebook_ads`
GROUP BY 1,2,3
HAVING COUNT(*) > 1
ORDER BY duplicate_rows DESC, date DESC;

-- 4B) Google potential duplicates
SELECT
  DATE(date) AS date,
  campaign_id,
  ad_group_id,
  COUNT(*) AS duplicate_rows
FROM `hale-photon-487521-p2.ads_demo.google_ads`
GROUP BY 1,2,3
HAVING COUNT(*) > 1
ORDER BY duplicate_rows DESC, date DESC;

-- 4C) TikTok potential duplicates
SELECT
  DATE(date) AS date,
  campaign_id,
  adgroup_id AS ad_group_id,
  COUNT(*) AS duplicate_rows
FROM `hale-photon-487521-p2.ads_demo.tiktok_ads`
GROUP BY 1,2,3
HAVING COUNT(*) > 1
ORDER BY duplicate_rows DESC, date DESC;


-- =========================
-- 5) Sanity checks for impossible / suspicious values
-- =========================

-- 5A) Clicks > impressions (should be zero rows)
SELECT 'facebook_ads' AS table_name, COUNT(*) AS bad_rows
FROM `hale-photon-487521-p2.ads_demo.facebook_ads`
WHERE clicks > impressions
UNION ALL
SELECT 'google_ads', COUNT(*)
FROM `hale-photon-487521-p2.ads_demo.google_ads`
WHERE clicks > impressions
UNION ALL
SELECT 'tiktok_ads', COUNT(*)
FROM `hale-photon-487521-p2.ads_demo.tiktok_ads`
WHERE clicks > impressions;

-- 5B) Negative values (should be zero rows)
SELECT 'facebook_ads' AS table_name, COUNT(*) AS negative_rows
FROM `hale-photon-487521-p2.ads_demo.facebook_ads`
WHERE spend < 0 OR impressions < 0 OR clicks < 0 OR conversions < 0
UNION ALL
SELECT 'google_ads', COUNT(*)
FROM `hale-photon-487521-p2.ads_demo.google_ads`
WHERE cost < 0 OR impressions < 0 OR clicks < 0 OR conversions < 0
UNION ALL
SELECT 'tiktok_ads', COUNT(*)
FROM `hale-photon-487521-p2.ads_demo.tiktok_ads`
WHERE cost < 0 OR impressions < 0 OR clicks < 0 OR conversions < 0;

-- 5C) Extremely high CTR outliers (CTR > 50% is rare; inspect if any)
SELECT *
FROM (
  SELECT 'facebook_ads' AS table_name, DATE(date) AS date, campaign_id, SAFE_DIVIDE(clicks, impressions) AS ctr
  FROM `hale-photon-487521-p2.ads_demo.facebook_ads`
  UNION ALL
  SELECT 'google_ads', DATE(date), campaign_id, SAFE_DIVIDE(clicks, impressions)
  FROM `hale-photon-487521-p2.ads_demo.google_ads`
  UNION ALL
  SELECT 'tiktok_ads', DATE(date), campaign_id, SAFE_DIVIDE(clicks, impressions)
  FROM `hale-photon-487521-p2.ads_demo.tiktok_ads`
)
WHERE ctr > 0.50
ORDER BY ctr DESC
LIMIT 100;


-- =========================
-- 6) Completeness: % of rows with core metrics populated
-- =========================
SELECT
  'facebook_ads' AS table_name,
  ROUND(100 * AVG(CASE WHEN impressions IS NOT NULL THEN 1 ELSE 0 END), 2) AS pct_impressions_present,
  ROUND(100 * AVG(CASE WHEN clicks IS NOT NULL THEN 1 ELSE 0 END), 2) AS pct_clicks_present,
  ROUND(100 * AVG(CASE WHEN spend IS NOT NULL THEN 1 ELSE 0 END), 2) AS pct_spend_present,
  ROUND(100 * AVG(CASE WHEN conversions IS NOT NULL THEN 1 ELSE 0 END), 2) AS pct_conversions_present
FROM `hale-photon-487521-p2.ads_demo.facebook_ads`

UNION ALL

SELECT
  'google_ads',
  ROUND(100 * AVG(CASE WHEN impressions IS NOT NULL THEN 1 ELSE 0 END), 2),
  ROUND(100 * AVG(CASE WHEN clicks IS NOT NULL THEN 1 ELSE 0 END), 2),
  ROUND(100 * AVG(CASE WHEN cost IS NOT NULL THEN 1 ELSE 0 END), 2),
  ROUND(100 * AVG(CASE WHEN conversions IS NOT NULL THEN 1 ELSE 0 END), 2)
FROM `hale-photon-487521-p2.ads_demo.google_ads`

UNION ALL

SELECT
  'tiktok_ads',
  ROUND(100 * AVG(CASE WHEN impressions IS NOT NULL THEN 1 ELSE 0 END), 2),
  ROUND(100 * AVG(CASE WHEN clicks IS NOT NULL THEN 1 ELSE 0 END), 2),
  ROUND(100 * AVG(CASE WHEN cost IS NOT NULL THEN 1 ELSE 0 END), 2),
  ROUND(100 * AVG(CASE WHEN conversions IS NOT NULL THEN 1 ELSE 0 END), 2)
FROM `hale-photon-487521-p2.ads_demo.tiktok_ads`;


-- =========================
-- 7) Aggregated totals per source (save these to reconcile after union)
-- =========================
SELECT
  'facebook_ads' AS table_name,
  SUM(impressions) AS impressions,
  SUM(clicks) AS clicks,
  SUM(spend) AS spend,
  SUM(conversions) AS conversions
FROM `hale-photon-487521-p2.ads_demo.facebook_ads`

UNION ALL

SELECT
  'google_ads',
  SUM(impressions),
  SUM(clicks),
  SUM(cost) AS spend,
  SUM(conversions)
FROM `hale-photon-487521-p2.ads_demo.google_ads`

UNION ALL

SELECT
  'tiktok_ads',
  SUM(impressions),
  SUM(clicks),
  SUM(cost) AS spend,
  SUM(conversions)
FROM `hale-photon-487521-p2.ads_demo.tiktok_ads`;
