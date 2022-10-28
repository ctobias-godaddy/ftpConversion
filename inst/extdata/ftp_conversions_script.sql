WITH
  session_start AS(
  SELECT
    user_id,
    device_id,
    'All_source' AS campaign_source,
    MIN(start_time) AS install_time
  FROM
    SQL_SESSION_SOURCE
  GROUP BY
    1,
    2
  ),
  
  attrib_session_join AS(
  SELECT
    *
  FROM
    session_start
  WHERE
    session_start.install_time BETWEEN SQL_START_DATE AND SQL_END_DATE
  ),
  
  first_session_data AS(
  SELECT
    user_id,
    device_id,
    install_time,
    campaign_source
  FROM
    attrib_session_join
  ),

  conversions_data AS(
  SELECT
    user_id,
    'Annual' AS type,
    MIN(timestamp) conversion_timestamp
  FROM
    `events.free_trial_converted_to_paid_subscriber`
  WHERE
    _PARTITIONTIME >= TIMESTAMP(SQL_START_DATE)
    AND subscription_provider = SQL_SUB_PROVIDOR
  GROUP BY
    1,
    2
  UNION ALL
  SELECT
    user_id,
    CASE
      WHEN product_id LIKE '%monthly%'THEN 'Monthly'
    ELSE
    'Annual'
  END
    AS type,
    MIN(timestamp) conversion_timestamp
  FROM
    `events.subscription_purchased`
  WHERE
    _PARTITIONTIME >= TIMESTAMP(SQL_START_DATE)
    AND subscription_provider = SQL_SUB_PROVIDOR
  GROUP BY
    1,
    2
  )
  
SELECT
  sess.user_id,
  campaign_source,
  install_time,
  type,
  conversion_timestamp,
  CASE
    WHEN TIMESTAMP_DIFF(conversion_timestamp, install_time, DAY) >= 0 THEN TIMESTAMP_DIFF(conversion_timestamp, install_time, DAY)
    WHEN TIMESTAMP_DIFF(conversion_timestamp, install_time, DAY) IS NULL THEN NULL
  ELSE
  NULL
END
  AS time_to_convert
FROM
  first_session_data sess
LEFT JOIN
  conversions_data conv
ON
  sess.user_id = conv.user_id