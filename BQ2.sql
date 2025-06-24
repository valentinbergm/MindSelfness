-- BQ2_01_Daily_Active_Users_Trend.csv:
-- This query calculates the Daily Active Users (DAU) to understand user engagement trends over time.
SELECT
    CAST(event_timestamp AS DATE) AS activity_date, -- Cast directly to DATE to get just the date part
    COUNT(DISTINCT user_id) AS daily_active_users
FROM
    user_events
GROUP BY
    CAST(event_timestamp AS DATE)
ORDER BY
    activity_date;

-- BQ2_02 Overall_Session_Metrics.csv:
-- This query provides overall session metrics, including average session duration and total sessions.
SELECT
    AVG(s.session_duration_seconds) AS average_session_duration_seconds,
    COUNT(s.original_session_id) AS total_sessions
FROM
    sessions s;

-- BQ2_03_Top_Used_Features.csv:
-- This query identifies the top 5 most frequently used features based on event count.
SELECT
    ue.event_name,
    COUNT(ue.event_id) AS event_count
FROM
    user_events ue
WHERE
    ue.event_name IS NOT NULL AND ue.event_name != '' -- Exclude events without a name
GROUP BY
    ue.event_name
ORDER BY
    event_count DESC
LIMIT 5;

-- BQ2_04_Feature_Usage_Over_Time.csv:
-- This query tracks the usage of various features over time, aggregated by month.
-- Note: Event names were potentially renamed/transformed in Power BI/DAX for compactness.
SELECT
    DATE_FORMAT(event_timestamp, '%Y-%m-01') AS activity_month,
    event_name,
    COUNT(event_id) AS event_count
FROM
    user_events
WHERE
    event_name IS NOT NULL AND event_name != ''
GROUP BY
    activity_month,
    event_name
ORDER BY
    activity_month,
    event_name;

-- BQ2_05_Average_Events_per_User_Compact.csv:
-- This query calculates the average number of events per user, broken down by age group and gender.
-- Note: This data was indicated to be further processed/transformed in Excel from a non-compact form.
WITH UserEventCounts AS (
    SELECT
        user_id,
        COUNT(event_id) AS total_events
    FROM
        user_events
    GROUP BY
        user_id
)
SELECT
    u.age_group,
    u.gender,
    AVG(uec.total_events) AS average_events_per_user
FROM
    users u
JOIN
    UserEventCounts uec ON u.user_id = uec.user_id
WHERE
    u.age_group IS NOT NULL AND u.gender IS NOT NULL -- Exclude rows with missing demographic info
GROUP BY
    u.age_group,
    u.gender
ORDER BY
    u.age_group,
    u.gender;