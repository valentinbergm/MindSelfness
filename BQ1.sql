-- BQ1_01 - Monthly Registrations Trend.csv:
-- This query counts the number of new users registered each month.
-- It is used to analyze the overall user growth trend and identify peak periods.
SELECT
    DATE_FORMAT(u.registration_date, '%Y-%m-01') AS registration_month, -- Standardize to start of month for consistent grouping
    COUNT(u.user_id) AS new_users_count
FROM
    users u
GROUP BY
    registration_month
ORDER BY
    registration_month;

-- BQ1_02 Acquisition Channel Performance Registrations.csv:
-- This query analyzes the performance of user acquisition channels,
-- counting the total number of users acquired and their percentage of the total user base.
SELECT
    u.acquisition_channel,
    COUNT(u.user_id) AS total_users_acquired,
    (COUNT(u.user_id) * 100.0 / (SELECT COUNT(user_id) FROM users)) AS percentage_of_total_users
FROM
    users u
GROUP BY
    u.acquisition_channel
ORDER BY
    total_users_acquired DESC;

-- BQ1_03_Subscription_Status_by_Acquisition_Channel.csv:
-- This query details the subscription status of users (e.g., active/canceled)
-- by each acquisition channel, showing the user count and their percentage within the channel.
SELECT
    u.acquisition_channel,
    u.subscription_status,
    COUNT(u.user_id) AS users_count,
    (COUNT(u.user_id) * 100.0 / (SELECT COUNT(user_id) FROM users WHERE acquisition_channel = u.acquisition_channel)) AS percentage_in_channel
FROM
    users u
GROUP BY
    u.acquisition_channel,
    u.subscription_status
ORDER BY
    u.acquisition_channel,
    users_count DESC;

-- BQ1_04_Subscription_Status_by_Acquisition_Channel.csv:
-- This query also details the subscription status of users by acquisition channel,
-- similar to BQ1_03, focusing on user counts and percentages within each channel.
SELECT
    u.acquisition_channel,
    u.subscription_status,
    COUNT(u.user_id) AS users_count,
    (COUNT(u.user_id) * 100.0 / (SELECT COUNT(user_id) FROM users WHERE acquisition_channel = u.acquisition_channel)) AS percentage_in_channel
FROM
    users u
GROUP BY
    u.acquisition_channel,
    u.subscription_status
ORDER BY
    u.acquisition_channel,
    users_count DESC;

-- BQ1_05_Age_Group_Demog.csv:
-- Query to determine the distribution of users by age groups.
SELECT
    age_group,
    COUNT(DISTINCT user_id) AS user_count
FROM
    users
GROUP BY
    age_group
ORDER BY
    age_group;

-- BQ1_06_Country_Group_Demog.csv:
-- Query to determine the distribution of users by country.
SELECT
    country,
    COUNT(DISTINCT user_id) AS user_count
FROM
    users
GROUP BY
    country
ORDER BY
    user_count DESC;

-- BQ1_07_Gender_Group_Demog.csv:
-- Query to determine the distribution of users by gender.
SELECT
    gender,
    COUNT(DISTINCT user_id) AS user_count
FROM
    users
GROUP BY
    gender
ORDER BY
    gender;
