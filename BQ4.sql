-- BQ4_01_Subscription_Status_Breakdown.csv:
-- This query provides a detailed breakdown of user subscription statuses
-- across various dimensions: acquisition channel, age group, and gender.
SELECT
    u.acquisition_channel,
    u.age_group,
    u.gender,
    u.subscription_status,
    COUNT(DISTINCT u.user_id) AS users_count
FROM
    users u
GROUP BY
    u.acquisition_channel,
    u.age_group,
    u.gender,
    u.subscription_status
ORDER BY
    u.acquisition_channel, u.age_group, u.gender, u.subscription_status;

-- BQ4_02_Conversion_Rates_By_Country.csv:
-- This query calculates the conversion rate to 'Premium' subscription status
-- for users from different countries.
SELECT
    country,
    COUNT(user_id) AS total_count,
    SUM(CASE WHEN subscription_status = 'Premium' THEN 1 ELSE 0 END) AS premium_count,
    (SUM(CASE WHEN subscription_status = 'Premium' THEN 1 ELSE 0 END) * 1.0 / COUNT(user_id)) AS premium_to_total_ratio
FROM
    users
GROUP BY
    country
ORDER BY
    premium_to_total_ratio DESC;