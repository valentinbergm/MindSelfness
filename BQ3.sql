-- BQ3_01_Monthly_Churn_Counts.csv:
-- This query calculates the monthly churn count based on user inactivity.
-- Churn is defined as a user being active in the previous month but not in the current month.
WITH MonthlyActiveUsers AS (
    SELECT DISTINCT
        user_id,
        DATE_FORMAT(event_timestamp, '%Y-%m-01') AS activity_month
    FROM
        user_events
),
LaggedActivity AS (
    SELECT
        mau.user_id,
        mau.activity_month,
        LAG(mau.activity_month, 1) OVER (PARTITION BY mau.user_id ORDER BY mau.activity_month) AS prev_activity_month
    FROM
        MonthlyActiveUsers mau
)
SELECT
    la.prev_activity_month AS churn_month, -- This is the month BEFORE churn occurred
    COUNT(DISTINCT la.user_id) AS churned_users_count
FROM
    LaggedActivity la
WHERE
    la.activity_month IS NULL OR la.activity_month > DATE_ADD(la.prev_activity_month, INTERVAL 1 MONTH)
GROUP BY
    churn_month
ORDER BY
    churn_month;

-- BQ3_02_Retention_by_Acquisition_Channel.csv:
-- This query calculates user retention rates broken down by their acquisition channel.
-- It tracks how cohorts from different channels are retained over subsequent months.
WITH UserCohortsChannels AS (
    SELECT
        u.user_id,
        DATE_FORMAT(u.registration_date, '%Y-%m-01') AS registration_month,
        u.acquisition_channel
    FROM
        users u
),
UserActivityMonths AS (
    SELECT DISTINCT
        user_id,
        DATE_FORMAT(event_timestamp, '%Y-%m-01') AS activity_month
    FROM
        user_events
),
CohortActivityChannels AS (
    SELECT
        ucc.user_id,
        ucc.registration_month,
        ucc.acquisition_channel,
        uam.activity_month,
        TIMESTAMPDIFF(MONTH, ucc.registration_month, uam.activity_month) AS months_since_registration
    FROM
        UserCohortsChannels ucc
    JOIN
        UserActivityMonths uam ON ucc.user_id = uam.user_id
    WHERE
        uam.activity_month >= ucc.registration_month
),
RetentionCountsChannels AS (
    SELECT
        ca.acquisition_channel,
        ca.registration_month,
        ca.months_since_registration,
        COUNT(DISTINCT ca.user_id) AS retained_users
    FROM
        CohortActivityChannels ca
    GROUP BY
        ca.acquisition_channel,
        ca.registration_month,
        ca.months_since_registration
)
SELECT
    rcc.acquisition_channel,
    rcc.registration_month,
    rcc.months_since_registration,
    rcc.retained_users,
    (SELECT COUNT(user_id) FROM users WHERE DATE_FORMAT(registration_date, '%Y-%m-01') = rcc.registration_month AND acquisition_channel = rcc.acquisition_channel) AS cohort_channel_size
FROM
    RetentionCountsChannels rcc
ORDER BY
    rcc.acquisition_channel,
    rcc.registration_month,
    rcc.months_since_registration;

-- BQ3_03_Retention_by_Age_Gender.csv:
-- This query calculates user retention rates by age group and gender demographics.
-- It shows how different demographic cohorts retain over time.
WITH UserCohortsDemographics AS (
    SELECT
        u.user_id,
        DATE_FORMAT(u.registration_date, '%Y-%m-01') AS registration_month,
        u.age_group,
        u.gender
    FROM
        users u
    WHERE
        u.age_group IS NOT NULL AND u.gender IS NOT NULL
),
UserActivityMonths AS (
    SELECT DISTINCT
        user_id,
        DATE_FORMAT(event_timestamp, '%Y-%m-01') AS activity_month
    FROM
        user_events
),
CohortActivityDemographics AS (
    SELECT
        ucd.user_id,
        ucd.registration_month,
        ucd.age_group,
        ucd.gender,
        uam.activity_month,
        TIMESTAMPDIFF(MONTH, ucd.registration_month, uam.activity_month) AS months_since_registration
    FROM
        UserCohortsDemographics ucd
    JOIN
        UserActivityMonths uam ON ucd.user_id = uam.user_id
    WHERE
        uam.activity_month >= ucd.registration_month
),
RetentionCountsDemographics AS (
    SELECT
        cad.age_group,
        cad.gender,
        cad.registration_month,
        cad.months_since_registration,
        COUNT(DISTINCT cad.user_id) AS retained_users
    FROM
        CohortActivityDemographics cad
    GROUP BY
        cad.age_group,
        cad.gender,
        cad.registration_month,
        cad.months_since_registration
)
SELECT
    rcd.age_group,
    rcd.gender,
    rcd.registration_month,
    rcd.months_since_registration,
    rcd.retained_users,
    (SELECT COUNT(user_id) FROM users WHERE DATE_FORMAT(registration_date, '%Y-%m-01') = rcd.registration_month AND age_group = rcd.age_group AND gender = rcd.gender) AS cohort_demographic_size
FROM
    RetentionCountsDemographics rcd
ORDER BY
    rcd.age_group,
    rcd.gender,
    rcd.registration_month,
    rcd.months_since_registration;

-- BQ3_04_In_Depth_Cohort.csv:
-- This query generates a detailed cohort retention table suitable for creating heatmaps
-- and in-depth analysis of user retention over time.
WITH UserCohorts AS (
    SELECT
        user_id,
        DATE_FORMAT(registration_date, '%Y-%m-01') AS registration_month -- Define cohort by registration month
    FROM
        users
),
UserActivityMonths AS (
    SELECT DISTINCT
        user_id,
        DATE_FORMAT(event_timestamp, '%Y-%m-01') AS activity_month -- Month when user was active
    FROM
        user_events
),
CohortActivity AS (
    SELECT
        uc.user_id,
        uc.registration_month,
        uam.activity_month,
        -- Calculate month number from registration (0 for registration month, 1 for next month, etc.)
        TIMESTAMPDIFF(MONTH, uc.registration_month, uam.activity_month) AS months_since_registration
    FROM
        UserCohorts uc
    JOIN
        UserActivityMonths uam ON uc.user_id = uam.user_id
    WHERE
        uam.activity_month >= uc.registration_month -- Ensure activity is after or in registration month
),
MonthlyRetentionCounts AS (
    SELECT
        ca.registration_month,
        ca.months_since_registration,
        COUNT(DISTINCT ca.user_id) AS retained_users
    FROM
        CohortActivity ca
    GROUP BY
        ca.registration_month,
        ca.months_since_registration
    ORDER BY
        ca.registration_month,
        ca.months_since_registration
)
-- Final output for cohort retention table (Power BI will calculate percentages and create heatmap)
SELECT
    mrc.registration_month,
    mrc.months_since_registration,
    mrc.retained_users,
    (SELECT COUNT(user_id) FROM users WHERE DATE_FORMAT(registration_date, '%Y-%m-01') = mrc.registration_month) AS cohort_size
FROM
    MonthlyRetentionCounts mrc;

-- BQ3_05_Premium_vs_Free_Feature_Usage.csv:
-- This query compares the usage of premium features versus overall app usage (app opens) on a monthly basis.
SELECT
    DATE_FORMAT(event_timestamp, '%Y-%m-01') AS first_day_of_month,
    SUM(CASE WHEN event_name = 'premium_feature_used' THEN 1 ELSE 0 END) AS premium_feature_usage_count,
    SUM(CASE WHEN event_name = 'app_open' THEN 1 ELSE 0 END) AS app_open_count
FROM
    user_events
WHERE
    event_name IN ('premium_feature_used', 'app_open')
GROUP BY
    first_day_of_month
ORDER BY
    first_day_of_month;