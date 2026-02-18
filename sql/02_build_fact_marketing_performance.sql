CREATE OR REPLACE TABLE `hale-photon-487521-p2.ads_demo.fact_ads` AS

-- Facebook
SELECT
  date,
  'Facebook' AS platform,
  campaign_id,
  campaign_name,
  ad_set_id   AS ad_group_id,
  ad_set_name AS ad_group_name,
  impressions,
  clicks,
  spend,
  conversions
FROM `hale-photon-487521-p2.ads_demo.facebook_ads`

UNION ALL

-- Google
SELECT
  date,
  'Google' AS platform,
  campaign_id,
  campaign_name,
  ad_group_id,
  ad_group_name,
  impressions,
  clicks,
  cost AS spend,
  conversions
FROM `hale-photon-487521-p2.ads_demo.google_ads`

UNION ALL

-- TikTok
SELECT
  date,
  'TikTok' AS platform,
  campaign_id,
  campaign_name,
  adgroup_id   AS ad_group_id,
  adgroup_name AS ad_group_name,
  impressions,
  clicks,
  cost AS spend,
  conversions
FROM `hale-photon-487521-p2.ads_demo.tiktok_ads`;

