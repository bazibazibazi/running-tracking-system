SET SERVEROUTPUT ON
SET TIMING OFF
SET FEEDBACK ON
SET VERIFY OFF
SET ECHO OFF
SET LINESIZE 220
SET PAGESIZE 50000
SET LONG 1000000
SET LONGCHUNKSIZE 1000000
SET TRIMSPOOL ON

SPOOL "here specify your path to create a benchmark file"/benchmark_results.txt

PROMPT ==========================================
PROMPT WORKLOAD BENCHMARK START
PROMPT ==========================================

PROMPT
PROMPT ==========================================
PROMPT ============== RUN 1 START ================
PROMPT ==========================================
PROMPT

-- ==========================================
-- FLUSH CACHE BEFORE WORKLOAD
-- ==========================================
PROMPT --- FLUSH CACHE ---

ALTER SYSTEM FLUSH BUFFER_CACHE;
ALTER SYSTEM FLUSH SHARED_POOL;

-- ==========================================
-- QUERY 1
-- ==========================================
PROMPT --- QUERY PLAN 1 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q1' FOR

SELECT    
    r.runner_id, 
    r.full_name, 
    SUM(ro.distance_km) AS total_distance_km, 
    ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate, 
    ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace, 
    ROUND(AVG(tt.avg_power_per_activity), 2) AS avg_running_power, 
    COUNT(a.activity_id) AS total_activities 
FROM Runners r   
JOIN Activities a  
    ON r.runner_id = a.runner_id   
JOIN Routes ro  
    ON a.route_id = ro.route_id 
JOIN ( 
    SELECT 
        activity_id, 
        AVG(heart_rate_bpm) AS avg_hr_per_activity, 
        AVG(pace) AS avg_pace_per_activity, 
        AVG(running_power) AS avg_power_per_activity 
    FROM Telemetry_Data 
    GROUP BY activity_id 
) tt 
    ON a.activity_id = tt.activity_id 
WHERE EXTRACT(YEAR FROM a.activity_date) = 2026   
  AND r.sex = 'Male' 
  AND r.weight_kg < 90 
  AND r.join_date > (SYSDATE - 100) 
  AND ro.difficulty_level >= 3 
GROUP BY   
    r.runner_id, 
    r.full_name 
HAVING SUM(ro.distance_km) > (   
    SELECT AVG(total_distance)   
    FROM (   
        SELECT  
            SUM(ro2.distance_km) AS total_distance 
        FROM Activities a2   
        JOIN Routes ro2  
            ON a2.route_id = ro2.route_id   
        JOIN Runners r2  
            ON a2.runner_id = r2.runner_id 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity, 
                AVG(pace) AS avg_pace_per_activity, 
                AVG(running_power) AS avg_power_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt2 
            ON a2.activity_id = tt2.activity_id 
        WHERE EXTRACT(YEAR FROM a2.activity_date) = 2026  
          AND r2.sex = 'Male' 
          AND r2.weight_kg < 90 
        GROUP BY a2.runner_id 
    ) dist_sub 
) 
AND AVG(tt.avg_hr_per_activity) < ( 
    SELECT AVG(runner_avg_hr) 
    FROM ( 
        SELECT 
            a3.runner_id, 
            AVG(tt3.avg_hr_per_activity) AS runner_avg_hr 
        FROM Activities a3 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt3 
            ON a3.activity_id = tt3.activity_id 
        WHERE EXTRACT(YEAR FROM a3.activity_date) = 2026 
        GROUP BY a3.runner_id 
    ) hr_sub 
) 
AND AVG(tt.avg_power_per_activity) > ( 
    SELECT AVG(runner_avg_power) 
    FROM ( 
        SELECT 
            a4.runner_id, 
            AVG(tt4.avg_power_per_activity) AS runner_avg_power 
        FROM Activities a4 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(running_power) AS avg_power_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt4 
            ON a4.activity_id = tt4.activity_id 
        WHERE EXTRACT(YEAR FROM a4.activity_date) = 2026 
        GROUP BY a4.runner_id 
    ) power_sub 
) 
ORDER BY total_distance_km DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q1', 'TYPICAL'));

PROMPT --- EXECUTION 1 ---

SET TIMING ON

SELECT    
    r.runner_id, 
    r.full_name, 
    SUM(ro.distance_km) AS total_distance_km, 
    ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate, 
    ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace, 
    ROUND(AVG(tt.avg_power_per_activity), 2) AS avg_running_power, 
    COUNT(a.activity_id) AS total_activities 
FROM Runners r   
JOIN Activities a  
    ON r.runner_id = a.runner_id   
JOIN Routes ro  
    ON a.route_id = ro.route_id 
JOIN ( 
    SELECT 
        activity_id, 
        AVG(heart_rate_bpm) AS avg_hr_per_activity, 
        AVG(pace) AS avg_pace_per_activity, 
        AVG(running_power) AS avg_power_per_activity 
    FROM Telemetry_Data 
    GROUP BY activity_id 
) tt 
    ON a.activity_id = tt.activity_id 
WHERE EXTRACT(YEAR FROM a.activity_date) = 2026   
  AND r.sex = 'Male' 
  AND r.weight_kg < 90 
  AND r.join_date > (SYSDATE - 100) 
  AND ro.difficulty_level >= 3 
GROUP BY   
    r.runner_id, 
    r.full_name 
HAVING SUM(ro.distance_km) > (   
    SELECT AVG(total_distance)   
    FROM (   
        SELECT  
            SUM(ro2.distance_km) AS total_distance 
        FROM Activities a2   
        JOIN Routes ro2  
            ON a2.route_id = ro2.route_id   
        JOIN Runners r2  
            ON a2.runner_id = r2.runner_id 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity, 
                AVG(pace) AS avg_pace_per_activity, 
                AVG(running_power) AS avg_power_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt2 
            ON a2.activity_id = tt2.activity_id 
        WHERE EXTRACT(YEAR FROM a2.activity_date) = 2026  
          AND r2.sex = 'Male' 
          AND r2.weight_kg < 90 
        GROUP BY a2.runner_id 
    ) dist_sub 
) 
AND AVG(tt.avg_hr_per_activity) < ( 
    SELECT AVG(runner_avg_hr) 
    FROM ( 
        SELECT 
            a3.runner_id, 
            AVG(tt3.avg_hr_per_activity) AS runner_avg_hr 
        FROM Activities a3 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt3 
            ON a3.activity_id = tt3.activity_id 
        WHERE EXTRACT(YEAR FROM a3.activity_date) = 2026 
        GROUP BY a3.runner_id 
    ) hr_sub 
) 
AND AVG(tt.avg_power_per_activity) > ( 
    SELECT AVG(runner_avg_power) 
    FROM ( 
        SELECT 
            a4.runner_id, 
            AVG(tt4.avg_power_per_activity) AS runner_avg_power 
        FROM Activities a4 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(running_power) AS avg_power_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt4 
            ON a4.activity_id = tt4.activity_id 
        WHERE EXTRACT(YEAR FROM a4.activity_date) = 2026 
        GROUP BY a4.runner_id 
    ) power_sub 
) 
ORDER BY total_distance_km DESC;

SET TIMING OFF


-- ==========================================
-- QUERY 2
-- ==========================================
PROMPT --- QUERY PLAN 2 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q2' FOR

SELECT     
    r.runner_id,  
    r.full_name,    
    SUM(ro.distance_km) AS total_distance_km,    
    COUNT(DISTINCT ra.runner_achievement_id) AS total_achievements, 
    ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate, 
    ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace 
FROM Runners r    
JOIN Activities a   
    ON r.runner_id = a.runner_id    
JOIN Routes ro   
    ON a.route_id = ro.route_id    
LEFT JOIN Runner_Achievements ra   
    ON r.runner_id = ra.runner_id    
LEFT JOIN Shoes s   
    ON a.runner_id = s.runner_id 
JOIN ( 
    SELECT 
        activity_id, 
        AVG(heart_rate_bpm) AS avg_hr_per_activity, 
        AVG(pace) AS avg_pace_per_activity 
    FROM Telemetry_Data 
    GROUP BY activity_id 
) tt 
    ON a.activity_id = tt.activity_id 
WHERE EXTRACT(YEAR FROM a.activity_date) = 2026    
  AND r.height > 175  
  AND s.model LIKE 'Nike%'  
  AND ro.elevation_gain > 10  
GROUP BY    
    r.runner_id,  
    r.full_name    
HAVING SUM(ro.distance_km) > (    
    SELECT AVG(total_distance)    
    FROM (    
        SELECT  
            SUM(ro2.distance_km) AS total_distance    
        FROM Activities a2    
        JOIN Routes ro2   
            ON a2.route_id = ro2.route_id 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity, 
                AVG(pace) AS avg_pace_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt2 
            ON a2.activity_id = tt2.activity_id 
        WHERE EXTRACT(YEAR FROM a2.activity_date) = 2026    
        GROUP BY a2.runner_id    
    ) dist_sub 
)    
AND AVG(tt.avg_hr_per_activity) < ( 
    SELECT AVG(runner_avg_hr) 
    FROM ( 
        SELECT 
            a3.runner_id, 
            AVG(tt3.avg_hr_per_activity) AS runner_avg_hr 
        FROM Activities a3 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt3 
            ON a3.activity_id = tt3.activity_id 
        WHERE EXTRACT(YEAR FROM a3.activity_date) = 2026 
        GROUP BY a3.runner_id 
    ) hr_sub 
) 
ORDER BY total_distance_km DESC 
FETCH FIRST 10 ROWS ONLY;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q2', 'TYPICAL'));

PROMPT --- EXECUTION 2 ---

SET TIMING ON

SELECT     
    r.runner_id,  
    r.full_name,    
    SUM(ro.distance_km) AS total_distance_km,    
    COUNT(DISTINCT ra.runner_achievement_id) AS total_achievements, 
    ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate, 
    ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace 
FROM Runners r    
JOIN Activities a   
    ON r.runner_id = a.runner_id    
JOIN Routes ro   
    ON a.route_id = ro.route_id    
LEFT JOIN Runner_Achievements ra   
    ON r.runner_id = ra.runner_id    
LEFT JOIN Shoes s   
    ON a.runner_id = s.runner_id 
JOIN ( 
    SELECT 
        activity_id, 
        AVG(heart_rate_bpm) AS avg_hr_per_activity, 
        AVG(pace) AS avg_pace_per_activity 
    FROM Telemetry_Data 
    GROUP BY activity_id 
) tt 
    ON a.activity_id = tt.activity_id 
WHERE EXTRACT(YEAR FROM a.activity_date) = 2026    
  AND r.height > 175  
  AND s.model LIKE 'Nike%'  
  AND ro.elevation_gain > 10  
GROUP BY    
    r.runner_id,  
    r.full_name    
HAVING SUM(ro.distance_km) > (    
    SELECT AVG(total_distance)    
    FROM (    
        SELECT  
            SUM(ro2.distance_km) AS total_distance    
        FROM Activities a2    
        JOIN Routes ro2   
            ON a2.route_id = ro2.route_id 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity, 
                AVG(pace) AS avg_pace_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt2 
            ON a2.activity_id = tt2.activity_id 
        WHERE EXTRACT(YEAR FROM a2.activity_date) = 2026    
        GROUP BY a2.runner_id    
    ) dist_sub 
)    
AND AVG(tt.avg_hr_per_activity) < ( 
    SELECT AVG(runner_avg_hr) 
    FROM ( 
        SELECT 
            a3.runner_id, 
            AVG(tt3.avg_hr_per_activity) AS runner_avg_hr 
        FROM Activities a3 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt3 
            ON a3.activity_id = tt3.activity_id 
        WHERE EXTRACT(YEAR FROM a3.activity_date) = 2026 
        GROUP BY a3.runner_id 
    ) hr_sub 
) 
ORDER BY total_distance_km DESC 
FETCH FIRST 10 ROWS ONLY;

SET TIMING OFF

-- ==========================================
-- QUERY 3
-- ==========================================
PROMPT --- QUERY PLAN 3 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q3' FOR

SELECT *
FROM (
    SELECT      
        r.runner_id,   
        r.full_name,     
        SUM(ro.distance_km) AS total_distance_km,     
        COUNT(DISTINCT ra.runner_achievement_id) AS total_achievements,  
        ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate,  
        ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace,
        ROUND(AVG(tt.avg_power_per_activity), 2) AS avg_running_power,
        DENSE_RANK() OVER (ORDER BY SUM(ro.distance_km) DESC) AS distance_rank
    FROM Runners r     
    JOIN Activities a    
        ON r.runner_id = a.runner_id     
    JOIN Routes ro    
        ON a.route_id = ro.route_id     
    LEFT JOIN Runner_Achievements ra    
        ON r.runner_id = ra.runner_id     
    LEFT JOIN Shoes s    
        ON a.runner_id = s.runner_id  
    JOIN (  
        SELECT  
            activity_id,  
            AVG(heart_rate_bpm) AS avg_hr_per_activity,  
            AVG(pace) AS avg_pace_per_activity,
            AVG(running_power) AS avg_power_per_activity
        FROM Telemetry_Data  
        GROUP BY activity_id  
    ) tt  
        ON a.activity_id = tt.activity_id  
    WHERE EXTRACT(YEAR FROM a.activity_date) = 2026     
      AND r.height > 175   
      AND s.model LIKE 'Nike%'   
      AND ro.elevation_gain > 10   
    GROUP BY     
        r.runner_id,   
        r.full_name     
) ranked
WHERE distance_rank <= 10
  AND avg_heart_rate > (
      SELECT AVG(avg_hr_per_activity)
      FROM (
          SELECT AVG(heart_rate_bpm) AS avg_hr_per_activity
          FROM Telemetry_Data
          GROUP BY activity_id
      ) hr_avg_sub
  )
  AND avg_running_power > (
      SELECT AVG(avg_power_per_activity)
      FROM (
          SELECT AVG(running_power) AS avg_power_per_activity
          FROM Telemetry_Data
          GROUP BY activity_id
      ) power_avg_sub
  )
ORDER BY total_distance_km DESC, avg_running_power DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q3', 'TYPICAL'));

PROMPT --- EXECUTION 3 ---

SET TIMING ON

SELECT *
FROM (
    SELECT      
        r.runner_id,   
        r.full_name,     
        SUM(ro.distance_km) AS total_distance_km,     
        COUNT(DISTINCT ra.runner_achievement_id) AS total_achievements,  
        ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate,  
        ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace,
        ROUND(AVG(tt.avg_power_per_activity), 2) AS avg_running_power,
        DENSE_RANK() OVER (ORDER BY SUM(ro.distance_km) DESC) AS distance_rank
    FROM Runners r     
    JOIN Activities a    
        ON r.runner_id = a.runner_id     
    JOIN Routes ro    
        ON a.route_id = ro.route_id     
    LEFT JOIN Runner_Achievements ra    
        ON r.runner_id = ra.runner_id     
    LEFT JOIN Shoes s    
        ON a.runner_id = s.runner_id  
    JOIN (  
        SELECT  
            activity_id,  
            AVG(heart_rate_bpm) AS avg_hr_per_activity,  
            AVG(pace) AS avg_pace_per_activity,
            AVG(running_power) AS avg_power_per_activity
        FROM Telemetry_Data  
        GROUP BY activity_id  
    ) tt  
        ON a.activity_id = tt.activity_id  
    WHERE EXTRACT(YEAR FROM a.activity_date) = 2026     
      AND r.height > 175   
      AND s.model LIKE 'Nike%'   
      AND ro.elevation_gain > 10   
    GROUP BY     
        r.runner_id,   
        r.full_name     
) ranked
WHERE distance_rank <= 10
  AND avg_heart_rate > (
      SELECT AVG(avg_hr_per_activity)
      FROM (
          SELECT AVG(heart_rate_bpm) AS avg_hr_per_activity
          FROM Telemetry_Data
          GROUP BY activity_id
      ) hr_avg_sub
  )
  AND avg_running_power > (
      SELECT AVG(avg_power_per_activity)
      FROM (
          SELECT AVG(running_power) AS avg_power_per_activity
          FROM Telemetry_Data
          GROUP BY activity_id
      ) power_avg_sub
  )
ORDER BY total_distance_km DESC, avg_running_power DESC;

SET TIMING OFF


-- ==========================================
-- QUERY 4
-- ==========================================
PROMPT --- QUERY PLAN 4 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q4' FOR

INSERT INTO Activities ( 
    activity_id, runner_id, route_id, activity_type,  
    duration_min, activity_date, avg_bpm, max_bpm, min_bpm 
) 
SELECT  
    -- 1. Generujemy nowe ID na podstawie aktualnego MAX + licznik wierszy 
    (SELECT MAX(activity_id) FROM Activities) + ROWNUM, 
    501,  
    10,  
    'Smartwatch Sync',  
    45,  
    CURRENT_DATE, 
    -- 2. Wchodzimy do bazy Telemetry_data i zmuszamy ja 
    -- Do grupowania i agregacje na dużej tabeli ~1 sekund 
    stats.avg_hr, 
    stats.max_hr, 
    stats.min_hr 
FROM ( 
    SELECT  
        ROUND(AVG(heart_rate_bpm)) as avg_hr, 
        MAX(heart_rate_bpm) as max_hr, 
        MIN(heart_rate_bpm) as min_hr 
    FROM Telemetry_Data 
    -- Brak indeksu na tym warunku lub wymuszenie skanowania dużej części tabeli 
    WHERE activity_id IS NOT NULL  
    GROUP BY TRUNC(heart_rate_bpm / 10) -- Sztuczne pogrupowanie co 10 jednostek  
    HAVING COUNT(*) > 100 
    ORDER BY 1 DESC 
) stats 
-- 3. Ograniczenie do 21 wierszy, które zostaną wstawione (grupy sa co 10 wiec nawet wiecej grup nie bedzie) 
-- Jest to dodatkowe zabezpieczenie przed błędnymi danymi jakby np tetno wynosilo 400 
WHERE ROWNUM <= 21;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q4', 'TYPICAL'));

PROMPT --- EXECUTION 4 ---

SET TIMING ON

INSERT INTO Activities ( 
    activity_id, runner_id, route_id, activity_type,  
    duration_min, activity_date, avg_bpm, max_bpm, min_bpm 
) 
SELECT  
    -- 1. Generujemy nowe ID na podstawie aktualnego MAX + licznik wierszy 
    (SELECT MAX(activity_id) FROM Activities) + ROWNUM, 
    501,  
    10,  
    'Smartwatch Sync',  
    45,  
    CURRENT_DATE, 
    -- 2. Wchodzimy do bazy Telemetry_data i zmuszamy ja 
    -- Do grupowania i agregacje na dużej tabeli ~1 sekund 
    stats.avg_hr, 
    stats.max_hr, 
    stats.min_hr 
FROM ( 
    SELECT  
        ROUND(AVG(heart_rate_bpm)) as avg_hr, 
        MAX(heart_rate_bpm) as max_hr, 
        MIN(heart_rate_bpm) as min_hr 
    FROM Telemetry_Data 
    -- Brak indeksu na tym warunku lub wymuszenie skanowania dużej części tabeli 
    WHERE activity_id IS NOT NULL  
    GROUP BY TRUNC(heart_rate_bpm / 10) -- Sztuczne pogrupowanie co 10 jednostek  
    HAVING COUNT(*) > 100 
    ORDER BY 1 DESC 
) stats 
-- 3. Ograniczenie do 21 wierszy, które zostaną wstawione (grupy sa co 10 wiec nawet wiecej grup nie bedzie) 
-- Jest to dodatkowe zabezpieczenie przed błędnymi danymi jakby np tetno wynosilo 400 
WHERE ROWNUM <= 21;

SET TIMING OFF

-- ==========================================
-- QUERY 5
-- ==========================================
PROMPT --- QUERY PLAN 5 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q5' FOR

UPDATE Training_Goals tg
SET 
    tg.current_value = (
        SELECT SUM(ro.distance_km)
        FROM Activities a
        JOIN Routes ro 
            ON a.route_id = ro.route_id
        WHERE a.runner_id = tg.runner_id
          AND a.activity_date BETWEEN (tg.deadline - 30) AND tg.deadline
          AND (
              SELECT AVG(SQRT(heart_rate_bpm))
              FROM Telemetry_Data
              WHERE ROWNUM < 500
          ) > 0
    ),
    tg.status = CASE
        WHEN (
            SELECT SUM(ro2.distance_km)
            FROM Activities a2
            JOIN Routes ro2 
                ON a2.route_id = ro2.route_id
            WHERE a2.runner_id = tg.runner_id
              AND a2.activity_date BETWEEN (tg.deadline - 30) AND tg.deadline
              AND (
                  SELECT COUNT(LOG(10, footsteps))
                  FROM Telemetry_Data
                  WHERE ROWNUM < 1000
              ) >= 0
        ) >= tg.target_value
        THEN 1
        ELSE 0
    END
WHERE tg.runner_id IN (
    SELECT r.runner_id
    FROM Runners r
    WHERE r.join_date < SYSDATE
      AND (
          SELECT SUM(a3.duration_min)
          FROM Activities a3
          WHERE a3.runner_id = r.runner_id
      ) > 0
);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q5', 'TYPICAL'));

PROMPT --- EXECUTION 5 ---

SET TIMING ON

UPDATE Training_Goals tg
SET 
    tg.current_value = (
        SELECT SUM(ro.distance_km)
        FROM Activities a
        JOIN Routes ro 
            ON a.route_id = ro.route_id
        WHERE a.runner_id = tg.runner_id
          AND a.activity_date BETWEEN (tg.deadline - 30) AND tg.deadline
          AND (
              SELECT AVG(SQRT(heart_rate_bpm))
              FROM Telemetry_Data
              WHERE ROWNUM < 500
          ) > 0
    ),
    tg.status = CASE
        WHEN (
            SELECT SUM(ro2.distance_km)
            FROM Activities a2
            JOIN Routes ro2 
                ON a2.route_id = ro2.route_id
            WHERE a2.runner_id = tg.runner_id
              AND a2.activity_date BETWEEN (tg.deadline - 30) AND tg.deadline
              AND (
                  SELECT COUNT(LOG(10, footsteps))
                  FROM Telemetry_Data
                  WHERE ROWNUM < 1000
              ) >= 0
        ) >= tg.target_value
        THEN 1
        ELSE 0
    END
WHERE tg.runner_id IN (
    SELECT r.runner_id
    FROM Runners r
    WHERE r.join_date < SYSDATE
      AND (
          SELECT SUM(a3.duration_min)
          FROM Activities a3
          WHERE a3.runner_id = r.runner_id
      ) > 0
);
SET TIMING OFF

-- ==========================================
-- QUERY 6
-- ==========================================
PROMPT --- QUERY PLAN 6 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q6' FOR

DELETE FROM Telemetry_Data
WHERE activity_id IN (
    WITH telemetry_agg AS (
        SELECT
            td.activity_id,
            AVG(td.heart_rate_bpm) AS avg_hr,
            AVG(td.pace) AS avg_pace,
            AVG(td.running_power) AS avg_power
        FROM Telemetry_Data td
        GROUP BY td.activity_id
    ),
    candidate_activities AS (
        SELECT
            a.activity_id
        FROM Activities a
        JOIN Runners r
            ON a.runner_id = r.runner_id
        JOIN Routes ro
            ON a.route_id = ro.route_id
        JOIN telemetry_agg ta
            ON a.activity_id = ta.activity_id
        WHERE EXTRACT(YEAR FROM a.activity_date) = 2026
          AND r.sex = 'Male'
          AND r.weight_kg < 90
          AND ro.difficulty_level >= 3
          AND ta.avg_hr > (SELECT AVG(avg_hr) FROM telemetry_agg)
          AND ta.avg_power > (SELECT AVG(avg_power) FROM telemetry_agg)
    )
    SELECT activity_id
    FROM candidate_activities
);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q6', 'TYPICAL'));

PROMPT --- EXECUTION 6 ---

SET TIMING ON

DELETE FROM Telemetry_Data
WHERE activity_id IN (
    WITH telemetry_agg AS (
        SELECT
            td.activity_id,
            AVG(td.heart_rate_bpm) AS avg_hr,
            AVG(td.pace) AS avg_pace,
            AVG(td.running_power) AS avg_power
        FROM Telemetry_Data td
        GROUP BY td.activity_id
    ),
    candidate_activities AS (
        SELECT
            a.activity_id
        FROM Activities a
        JOIN Runners r
            ON a.runner_id = r.runner_id
        JOIN Routes ro
            ON a.route_id = ro.route_id
        JOIN telemetry_agg ta
            ON a.activity_id = ta.activity_id
        WHERE EXTRACT(YEAR FROM a.activity_date) = 2026
          AND r.sex = 'Male'
          AND r.weight_kg < 90
          AND ro.difficulty_level >= 3
          AND ta.avg_hr > (SELECT AVG(avg_hr) FROM telemetry_agg)
          AND ta.avg_power > (SELECT AVG(avg_power) FROM telemetry_agg)
    )
    SELECT activity_id
    FROM candidate_activities
);

SET TIMING OFF

ROLLBACK;

PROMPT
PROMPT ==========================================
PROMPT ============== RUN 2 START ================
PROMPT ==========================================
PROMPT

-- ==========================================
-- FLUSH CACHE BEFORE WORKLOAD
-- ==========================================
PROMPT --- FLUSH CACHE ---

ALTER SYSTEM FLUSH BUFFER_CACHE;
ALTER SYSTEM FLUSH SHARED_POOL;

-- ==========================================
-- QUERY 1
-- ==========================================
PROMPT --- QUERY PLAN 1 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q1' FOR

SELECT    
    r.runner_id, 
    r.full_name, 
    SUM(ro.distance_km) AS total_distance_km, 
    ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate, 
    ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace, 
    ROUND(AVG(tt.avg_power_per_activity), 2) AS avg_running_power, 
    COUNT(a.activity_id) AS total_activities 
FROM Runners r   
JOIN Activities a  
    ON r.runner_id = a.runner_id   
JOIN Routes ro  
    ON a.route_id = ro.route_id 
JOIN ( 
    SELECT 
        activity_id, 
        AVG(heart_rate_bpm) AS avg_hr_per_activity, 
        AVG(pace) AS avg_pace_per_activity, 
        AVG(running_power) AS avg_power_per_activity 
    FROM Telemetry_Data 
    GROUP BY activity_id 
) tt 
    ON a.activity_id = tt.activity_id 
WHERE EXTRACT(YEAR FROM a.activity_date) = 2026   
  AND r.sex = 'Male' 
  AND r.weight_kg < 90 
  AND r.join_date > (SYSDATE - 100) 
  AND ro.difficulty_level >= 3 
GROUP BY   
    r.runner_id, 
    r.full_name 
HAVING SUM(ro.distance_km) > (   
    SELECT AVG(total_distance)   
    FROM (   
        SELECT  
            SUM(ro2.distance_km) AS total_distance 
        FROM Activities a2   
        JOIN Routes ro2  
            ON a2.route_id = ro2.route_id   
        JOIN Runners r2  
            ON a2.runner_id = r2.runner_id 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity, 
                AVG(pace) AS avg_pace_per_activity, 
                AVG(running_power) AS avg_power_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt2 
            ON a2.activity_id = tt2.activity_id 
        WHERE EXTRACT(YEAR FROM a2.activity_date) = 2026  
          AND r2.sex = 'Male' 
          AND r2.weight_kg < 90 
        GROUP BY a2.runner_id 
    ) dist_sub 
) 
AND AVG(tt.avg_hr_per_activity) < ( 
    SELECT AVG(runner_avg_hr) 
    FROM ( 
        SELECT 
            a3.runner_id, 
            AVG(tt3.avg_hr_per_activity) AS runner_avg_hr 
        FROM Activities a3 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt3 
            ON a3.activity_id = tt3.activity_id 
        WHERE EXTRACT(YEAR FROM a3.activity_date) = 2026 
        GROUP BY a3.runner_id 
    ) hr_sub 
) 
AND AVG(tt.avg_power_per_activity) > ( 
    SELECT AVG(runner_avg_power) 
    FROM ( 
        SELECT 
            a4.runner_id, 
            AVG(tt4.avg_power_per_activity) AS runner_avg_power 
        FROM Activities a4 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(running_power) AS avg_power_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt4 
            ON a4.activity_id = tt4.activity_id 
        WHERE EXTRACT(YEAR FROM a4.activity_date) = 2026 
        GROUP BY a4.runner_id 
    ) power_sub 
) 
ORDER BY total_distance_km DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q1', 'TYPICAL'));

PROMPT --- EXECUTION 1 ---

SET TIMING ON

SELECT    
    r.runner_id, 
    r.full_name, 
    SUM(ro.distance_km) AS total_distance_km, 
    ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate, 
    ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace, 
    ROUND(AVG(tt.avg_power_per_activity), 2) AS avg_running_power, 
    COUNT(a.activity_id) AS total_activities 
FROM Runners r   
JOIN Activities a  
    ON r.runner_id = a.runner_id   
JOIN Routes ro  
    ON a.route_id = ro.route_id 
JOIN ( 
    SELECT 
        activity_id, 
        AVG(heart_rate_bpm) AS avg_hr_per_activity, 
        AVG(pace) AS avg_pace_per_activity, 
        AVG(running_power) AS avg_power_per_activity 
    FROM Telemetry_Data 
    GROUP BY activity_id 
) tt 
    ON a.activity_id = tt.activity_id 
WHERE EXTRACT(YEAR FROM a.activity_date) = 2026   
  AND r.sex = 'Male' 
  AND r.weight_kg < 90 
  AND r.join_date > (SYSDATE - 100) 
  AND ro.difficulty_level >= 3 
GROUP BY   
    r.runner_id, 
    r.full_name 
HAVING SUM(ro.distance_km) > (   
    SELECT AVG(total_distance)   
    FROM (   
        SELECT  
            SUM(ro2.distance_km) AS total_distance 
        FROM Activities a2   
        JOIN Routes ro2  
            ON a2.route_id = ro2.route_id   
        JOIN Runners r2  
            ON a2.runner_id = r2.runner_id 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity, 
                AVG(pace) AS avg_pace_per_activity, 
                AVG(running_power) AS avg_power_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt2 
            ON a2.activity_id = tt2.activity_id 
        WHERE EXTRACT(YEAR FROM a2.activity_date) = 2026  
          AND r2.sex = 'Male' 
          AND r2.weight_kg < 90 
        GROUP BY a2.runner_id 
    ) dist_sub 
) 
AND AVG(tt.avg_hr_per_activity) < ( 
    SELECT AVG(runner_avg_hr) 
    FROM ( 
        SELECT 
            a3.runner_id, 
            AVG(tt3.avg_hr_per_activity) AS runner_avg_hr 
        FROM Activities a3 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt3 
            ON a3.activity_id = tt3.activity_id 
        WHERE EXTRACT(YEAR FROM a3.activity_date) = 2026 
        GROUP BY a3.runner_id 
    ) hr_sub 
) 
AND AVG(tt.avg_power_per_activity) > ( 
    SELECT AVG(runner_avg_power) 
    FROM ( 
        SELECT 
            a4.runner_id, 
            AVG(tt4.avg_power_per_activity) AS runner_avg_power 
        FROM Activities a4 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(running_power) AS avg_power_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt4 
            ON a4.activity_id = tt4.activity_id 
        WHERE EXTRACT(YEAR FROM a4.activity_date) = 2026 
        GROUP BY a4.runner_id 
    ) power_sub 
) 
ORDER BY total_distance_km DESC;

SET TIMING OFF


-- ==========================================
-- QUERY 2
-- ==========================================
PROMPT --- QUERY PLAN 2 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q2' FOR

SELECT     
    r.runner_id,  
    r.full_name,    
    SUM(ro.distance_km) AS total_distance_km,    
    COUNT(DISTINCT ra.runner_achievement_id) AS total_achievements, 
    ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate, 
    ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace 
FROM Runners r    
JOIN Activities a   
    ON r.runner_id = a.runner_id    
JOIN Routes ro   
    ON a.route_id = ro.route_id    
LEFT JOIN Runner_Achievements ra   
    ON r.runner_id = ra.runner_id    
LEFT JOIN Shoes s   
    ON a.runner_id = s.runner_id 
JOIN ( 
    SELECT 
        activity_id, 
        AVG(heart_rate_bpm) AS avg_hr_per_activity, 
        AVG(pace) AS avg_pace_per_activity 
    FROM Telemetry_Data 
    GROUP BY activity_id 
) tt 
    ON a.activity_id = tt.activity_id 
WHERE EXTRACT(YEAR FROM a.activity_date) = 2026    
  AND r.height > 175  
  AND s.model LIKE 'Nike%'  
  AND ro.elevation_gain > 10  
GROUP BY    
    r.runner_id,  
    r.full_name    
HAVING SUM(ro.distance_km) > (    
    SELECT AVG(total_distance)    
    FROM (    
        SELECT  
            SUM(ro2.distance_km) AS total_distance    
        FROM Activities a2    
        JOIN Routes ro2   
            ON a2.route_id = ro2.route_id 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity, 
                AVG(pace) AS avg_pace_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt2 
            ON a2.activity_id = tt2.activity_id 
        WHERE EXTRACT(YEAR FROM a2.activity_date) = 2026    
        GROUP BY a2.runner_id    
    ) dist_sub 
)    
AND AVG(tt.avg_hr_per_activity) < ( 
    SELECT AVG(runner_avg_hr) 
    FROM ( 
        SELECT 
            a3.runner_id, 
            AVG(tt3.avg_hr_per_activity) AS runner_avg_hr 
        FROM Activities a3 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt3 
            ON a3.activity_id = tt3.activity_id 
        WHERE EXTRACT(YEAR FROM a3.activity_date) = 2026 
        GROUP BY a3.runner_id 
    ) hr_sub 
) 
ORDER BY total_distance_km DESC 
FETCH FIRST 10 ROWS ONLY;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q2', 'TYPICAL'));

PROMPT --- EXECUTION 2 ---

SET TIMING ON

SELECT     
    r.runner_id,  
    r.full_name,    
    SUM(ro.distance_km) AS total_distance_km,    
    COUNT(DISTINCT ra.runner_achievement_id) AS total_achievements, 
    ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate, 
    ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace 
FROM Runners r    
JOIN Activities a   
    ON r.runner_id = a.runner_id    
JOIN Routes ro   
    ON a.route_id = ro.route_id    
LEFT JOIN Runner_Achievements ra   
    ON r.runner_id = ra.runner_id    
LEFT JOIN Shoes s   
    ON a.runner_id = s.runner_id 
JOIN ( 
    SELECT 
        activity_id, 
        AVG(heart_rate_bpm) AS avg_hr_per_activity, 
        AVG(pace) AS avg_pace_per_activity 
    FROM Telemetry_Data 
    GROUP BY activity_id 
) tt 
    ON a.activity_id = tt.activity_id 
WHERE EXTRACT(YEAR FROM a.activity_date) = 2026    
  AND r.height > 175  
  AND s.model LIKE 'Nike%'  
  AND ro.elevation_gain > 10  
GROUP BY    
    r.runner_id,  
    r.full_name    
HAVING SUM(ro.distance_km) > (    
    SELECT AVG(total_distance)    
    FROM (    
        SELECT  
            SUM(ro2.distance_km) AS total_distance    
        FROM Activities a2    
        JOIN Routes ro2   
            ON a2.route_id = ro2.route_id 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity, 
                AVG(pace) AS avg_pace_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt2 
            ON a2.activity_id = tt2.activity_id 
        WHERE EXTRACT(YEAR FROM a2.activity_date) = 2026    
        GROUP BY a2.runner_id    
    ) dist_sub 
)    
AND AVG(tt.avg_hr_per_activity) < ( 
    SELECT AVG(runner_avg_hr) 
    FROM ( 
        SELECT 
            a3.runner_id, 
            AVG(tt3.avg_hr_per_activity) AS runner_avg_hr 
        FROM Activities a3 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt3 
            ON a3.activity_id = tt3.activity_id 
        WHERE EXTRACT(YEAR FROM a3.activity_date) = 2026 
        GROUP BY a3.runner_id 
    ) hr_sub 
) 
ORDER BY total_distance_km DESC 
FETCH FIRST 10 ROWS ONLY;

SET TIMING OFF

-- ==========================================
-- QUERY 3
-- ==========================================
PROMPT --- QUERY PLAN 3 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q3' FOR

SELECT *
FROM (
    SELECT      
        r.runner_id,   
        r.full_name,     
        SUM(ro.distance_km) AS total_distance_km,     
        COUNT(DISTINCT ra.runner_achievement_id) AS total_achievements,  
        ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate,  
        ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace,
        ROUND(AVG(tt.avg_power_per_activity), 2) AS avg_running_power,
        DENSE_RANK() OVER (ORDER BY SUM(ro.distance_km) DESC) AS distance_rank
    FROM Runners r     
    JOIN Activities a    
        ON r.runner_id = a.runner_id     
    JOIN Routes ro    
        ON a.route_id = ro.route_id     
    LEFT JOIN Runner_Achievements ra    
        ON r.runner_id = ra.runner_id     
    LEFT JOIN Shoes s    
        ON a.runner_id = s.runner_id  
    JOIN (  
        SELECT  
            activity_id,  
            AVG(heart_rate_bpm) AS avg_hr_per_activity,  
            AVG(pace) AS avg_pace_per_activity,
            AVG(running_power) AS avg_power_per_activity
        FROM Telemetry_Data  
        GROUP BY activity_id  
    ) tt  
        ON a.activity_id = tt.activity_id  
    WHERE EXTRACT(YEAR FROM a.activity_date) = 2026     
      AND r.height > 175   
      AND s.model LIKE 'Nike%'   
      AND ro.elevation_gain > 10   
    GROUP BY     
        r.runner_id,   
        r.full_name     
) ranked
WHERE distance_rank <= 10
  AND avg_heart_rate > (
      SELECT AVG(avg_hr_per_activity)
      FROM (
          SELECT AVG(heart_rate_bpm) AS avg_hr_per_activity
          FROM Telemetry_Data
          GROUP BY activity_id
      ) hr_avg_sub
  )
  AND avg_running_power > (
      SELECT AVG(avg_power_per_activity)
      FROM (
          SELECT AVG(running_power) AS avg_power_per_activity
          FROM Telemetry_Data
          GROUP BY activity_id
      ) power_avg_sub
  )
ORDER BY total_distance_km DESC, avg_running_power DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q3', 'TYPICAL'));

PROMPT --- EXECUTION 3 ---

SET TIMING ON

SELECT *
FROM (
    SELECT      
        r.runner_id,   
        r.full_name,     
        SUM(ro.distance_km) AS total_distance_km,     
        COUNT(DISTINCT ra.runner_achievement_id) AS total_achievements,  
        ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate,  
        ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace,
        ROUND(AVG(tt.avg_power_per_activity), 2) AS avg_running_power,
        DENSE_RANK() OVER (ORDER BY SUM(ro.distance_km) DESC) AS distance_rank
    FROM Runners r     
    JOIN Activities a    
        ON r.runner_id = a.runner_id     
    JOIN Routes ro    
        ON a.route_id = ro.route_id     
    LEFT JOIN Runner_Achievements ra    
        ON r.runner_id = ra.runner_id     
    LEFT JOIN Shoes s    
        ON a.runner_id = s.runner_id  
    JOIN (  
        SELECT  
            activity_id,  
            AVG(heart_rate_bpm) AS avg_hr_per_activity,  
            AVG(pace) AS avg_pace_per_activity,
            AVG(running_power) AS avg_power_per_activity
        FROM Telemetry_Data  
        GROUP BY activity_id  
    ) tt  
        ON a.activity_id = tt.activity_id  
    WHERE EXTRACT(YEAR FROM a.activity_date) = 2026     
      AND r.height > 175   
      AND s.model LIKE 'Nike%'   
      AND ro.elevation_gain > 10   
    GROUP BY     
        r.runner_id,   
        r.full_name     
) ranked
WHERE distance_rank <= 10
  AND avg_heart_rate > (
      SELECT AVG(avg_hr_per_activity)
      FROM (
          SELECT AVG(heart_rate_bpm) AS avg_hr_per_activity
          FROM Telemetry_Data
          GROUP BY activity_id
      ) hr_avg_sub
  )
  AND avg_running_power > (
      SELECT AVG(avg_power_per_activity)
      FROM (
          SELECT AVG(running_power) AS avg_power_per_activity
          FROM Telemetry_Data
          GROUP BY activity_id
      ) power_avg_sub
  )
ORDER BY total_distance_km DESC, avg_running_power DESC;

SET TIMING OFF


-- ==========================================
-- QUERY 4
-- ==========================================
PROMPT --- QUERY PLAN 4 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q4' FOR

INSERT INTO Activities ( 
    activity_id, runner_id, route_id, activity_type,  
    duration_min, activity_date, avg_bpm, max_bpm, min_bpm 
) 
SELECT  
    -- 1. Generujemy nowe ID na podstawie aktualnego MAX + licznik wierszy 
    (SELECT MAX(activity_id) FROM Activities) + ROWNUM, 
    501,  
    10,  
    'Smartwatch Sync',  
    45,  
    CURRENT_DATE, 
    -- 2. Wchodzimy do bazy Telemetry_data i zmuszamy ja 
    -- Do grupowania i agregacje na dużej tabeli ~1 sekund 
    stats.avg_hr, 
    stats.max_hr, 
    stats.min_hr 
FROM ( 
    SELECT  
        ROUND(AVG(heart_rate_bpm)) as avg_hr, 
        MAX(heart_rate_bpm) as max_hr, 
        MIN(heart_rate_bpm) as min_hr 
    FROM Telemetry_Data 
    -- Brak indeksu na tym warunku lub wymuszenie skanowania dużej części tabeli 
    WHERE activity_id IS NOT NULL  
    GROUP BY TRUNC(heart_rate_bpm / 10) -- Sztuczne pogrupowanie co 10 jednostek  
    HAVING COUNT(*) > 100 
    ORDER BY 1 DESC 
) stats 
-- 3. Ograniczenie do 21 wierszy, które zostaną wstawione (grupy sa co 10 wiec nawet wiecej grup nie bedzie) 
-- Jest to dodatkowe zabezpieczenie przed błędnymi danymi jakby np tetno wynosilo 400 
WHERE ROWNUM <= 21;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q4', 'TYPICAL'));

PROMPT --- EXECUTION 4 ---

SET TIMING ON

INSERT INTO Activities ( 
    activity_id, runner_id, route_id, activity_type,  
    duration_min, activity_date, avg_bpm, max_bpm, min_bpm 
) 
SELECT  
    -- 1. Generujemy nowe ID na podstawie aktualnego MAX + licznik wierszy 
    (SELECT MAX(activity_id) FROM Activities) + ROWNUM, 
    501,  
    10,  
    'Smartwatch Sync',  
    45,  
    CURRENT_DATE, 
    -- 2. Wchodzimy do bazy Telemetry_data i zmuszamy ja 
    -- Do grupowania i agregacje na dużej tabeli ~1 sekund 
    stats.avg_hr, 
    stats.max_hr, 
    stats.min_hr 
FROM ( 
    SELECT  
        ROUND(AVG(heart_rate_bpm)) as avg_hr, 
        MAX(heart_rate_bpm) as max_hr, 
        MIN(heart_rate_bpm) as min_hr 
    FROM Telemetry_Data 
    -- Brak indeksu na tym warunku lub wymuszenie skanowania dużej części tabeli 
    WHERE activity_id IS NOT NULL  
    GROUP BY TRUNC(heart_rate_bpm / 10) -- Sztuczne pogrupowanie co 10 jednostek  
    HAVING COUNT(*) > 100 
    ORDER BY 1 DESC 
) stats 
-- 3. Ograniczenie do 21 wierszy, które zostaną wstawione (grupy sa co 10 wiec nawet wiecej grup nie bedzie) 
-- Jest to dodatkowe zabezpieczenie przed błędnymi danymi jakby np tetno wynosilo 400 
WHERE ROWNUM <= 21;

SET TIMING OFF

-- ==========================================
-- QUERY 5
-- ==========================================
PROMPT --- QUERY PLAN 5 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q5' FOR

UPDATE Training_Goals tg
SET 
    tg.current_value = (
        SELECT SUM(ro.distance_km)
        FROM Activities a
        JOIN Routes ro 
            ON a.route_id = ro.route_id
        WHERE a.runner_id = tg.runner_id
          AND a.activity_date BETWEEN (tg.deadline - 30) AND tg.deadline
          AND (
              SELECT AVG(SQRT(heart_rate_bpm))
              FROM Telemetry_Data
              WHERE ROWNUM < 500
          ) > 0
    ),
    tg.status = CASE
        WHEN (
            SELECT SUM(ro2.distance_km)
            FROM Activities a2
            JOIN Routes ro2 
                ON a2.route_id = ro2.route_id
            WHERE a2.runner_id = tg.runner_id
              AND a2.activity_date BETWEEN (tg.deadline - 30) AND tg.deadline
              AND (
                  SELECT COUNT(LOG(10, footsteps))
                  FROM Telemetry_Data
                  WHERE ROWNUM < 1000
              ) >= 0
        ) >= tg.target_value
        THEN 1
        ELSE 0
    END
WHERE tg.runner_id IN (
    SELECT r.runner_id
    FROM Runners r
    WHERE r.join_date < SYSDATE
      AND (
          SELECT SUM(a3.duration_min)
          FROM Activities a3
          WHERE a3.runner_id = r.runner_id
      ) > 0
);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q5', 'TYPICAL'));

PROMPT --- EXECUTION 5 ---

SET TIMING ON

UPDATE Training_Goals tg
SET 
    tg.current_value = (
        SELECT SUM(ro.distance_km)
        FROM Activities a
        JOIN Routes ro 
            ON a.route_id = ro.route_id
        WHERE a.runner_id = tg.runner_id
          AND a.activity_date BETWEEN (tg.deadline - 30) AND tg.deadline
          AND (
              SELECT AVG(SQRT(heart_rate_bpm))
              FROM Telemetry_Data
              WHERE ROWNUM < 500
          ) > 0
    ),
    tg.status = CASE
        WHEN (
            SELECT SUM(ro2.distance_km)
            FROM Activities a2
            JOIN Routes ro2 
                ON a2.route_id = ro2.route_id
            WHERE a2.runner_id = tg.runner_id
              AND a2.activity_date BETWEEN (tg.deadline - 30) AND tg.deadline
              AND (
                  SELECT COUNT(LOG(10, footsteps))
                  FROM Telemetry_Data
                  WHERE ROWNUM < 1000
              ) >= 0
        ) >= tg.target_value
        THEN 1
        ELSE 0
    END
WHERE tg.runner_id IN (
    SELECT r.runner_id
    FROM Runners r
    WHERE r.join_date < SYSDATE
      AND (
          SELECT SUM(a3.duration_min)
          FROM Activities a3
          WHERE a3.runner_id = r.runner_id
      ) > 0
);
SET TIMING OFF

-- ==========================================
-- QUERY 6
-- ==========================================
PROMPT --- QUERY PLAN 6 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q6' FOR

DELETE FROM Telemetry_Data
WHERE activity_id IN (
    WITH telemetry_agg AS (
        SELECT
            td.activity_id,
            AVG(td.heart_rate_bpm) AS avg_hr,
            AVG(td.pace) AS avg_pace,
            AVG(td.running_power) AS avg_power
        FROM Telemetry_Data td
        GROUP BY td.activity_id
    ),
    candidate_activities AS (
        SELECT
            a.activity_id
        FROM Activities a
        JOIN Runners r
            ON a.runner_id = r.runner_id
        JOIN Routes ro
            ON a.route_id = ro.route_id
        JOIN telemetry_agg ta
            ON a.activity_id = ta.activity_id
        WHERE EXTRACT(YEAR FROM a.activity_date) = 2026
          AND r.sex = 'Male'
          AND r.weight_kg < 90
          AND ro.difficulty_level >= 3
          AND ta.avg_hr > (SELECT AVG(avg_hr) FROM telemetry_agg)
          AND ta.avg_power > (SELECT AVG(avg_power) FROM telemetry_agg)
    )
    SELECT activity_id
    FROM candidate_activities
);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q6', 'TYPICAL'));

PROMPT --- EXECUTION 6 ---

SET TIMING ON

DELETE FROM Telemetry_Data
WHERE activity_id IN (
    WITH telemetry_agg AS (
        SELECT
            td.activity_id,
            AVG(td.heart_rate_bpm) AS avg_hr,
            AVG(td.pace) AS avg_pace,
            AVG(td.running_power) AS avg_power
        FROM Telemetry_Data td
        GROUP BY td.activity_id
    ),
    candidate_activities AS (
        SELECT
            a.activity_id
        FROM Activities a
        JOIN Runners r
            ON a.runner_id = r.runner_id
        JOIN Routes ro
            ON a.route_id = ro.route_id
        JOIN telemetry_agg ta
            ON a.activity_id = ta.activity_id
        WHERE EXTRACT(YEAR FROM a.activity_date) = 2026
          AND r.sex = 'Male'
          AND r.weight_kg < 90
          AND ro.difficulty_level >= 3
          AND ta.avg_hr > (SELECT AVG(avg_hr) FROM telemetry_agg)
          AND ta.avg_power > (SELECT AVG(avg_power) FROM telemetry_agg)
    )
    SELECT activity_id
    FROM candidate_activities
);

SET TIMING OFF

ROLLBACK;

PROMPT
PROMPT ==========================================
PROMPT ============== RUN 3 START ================
PROMPT ==========================================
PROMPT

-- ==========================================
-- FLUSH CACHE BEFORE WORKLOAD
-- ==========================================
PROMPT --- FLUSH CACHE ---

ALTER SYSTEM FLUSH BUFFER_CACHE;
ALTER SYSTEM FLUSH SHARED_POOL;

-- ==========================================
-- QUERY 1
-- ==========================================
PROMPT --- QUERY PLAN 1 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q1' FOR

SELECT    
    r.runner_id, 
    r.full_name, 
    SUM(ro.distance_km) AS total_distance_km, 
    ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate, 
    ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace, 
    ROUND(AVG(tt.avg_power_per_activity), 2) AS avg_running_power, 
    COUNT(a.activity_id) AS total_activities 
FROM Runners r   
JOIN Activities a  
    ON r.runner_id = a.runner_id   
JOIN Routes ro  
    ON a.route_id = ro.route_id 
JOIN ( 
    SELECT 
        activity_id, 
        AVG(heart_rate_bpm) AS avg_hr_per_activity, 
        AVG(pace) AS avg_pace_per_activity, 
        AVG(running_power) AS avg_power_per_activity 
    FROM Telemetry_Data 
    GROUP BY activity_id 
) tt 
    ON a.activity_id = tt.activity_id 
WHERE EXTRACT(YEAR FROM a.activity_date) = 2026   
  AND r.sex = 'Male' 
  AND r.weight_kg < 90 
  AND r.join_date > (SYSDATE - 100) 
  AND ro.difficulty_level >= 3 
GROUP BY   
    r.runner_id, 
    r.full_name 
HAVING SUM(ro.distance_km) > (   
    SELECT AVG(total_distance)   
    FROM (   
        SELECT  
            SUM(ro2.distance_km) AS total_distance 
        FROM Activities a2   
        JOIN Routes ro2  
            ON a2.route_id = ro2.route_id   
        JOIN Runners r2  
            ON a2.runner_id = r2.runner_id 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity, 
                AVG(pace) AS avg_pace_per_activity, 
                AVG(running_power) AS avg_power_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt2 
            ON a2.activity_id = tt2.activity_id 
        WHERE EXTRACT(YEAR FROM a2.activity_date) = 2026  
          AND r2.sex = 'Male' 
          AND r2.weight_kg < 90 
        GROUP BY a2.runner_id 
    ) dist_sub 
) 
AND AVG(tt.avg_hr_per_activity) < ( 
    SELECT AVG(runner_avg_hr) 
    FROM ( 
        SELECT 
            a3.runner_id, 
            AVG(tt3.avg_hr_per_activity) AS runner_avg_hr 
        FROM Activities a3 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt3 
            ON a3.activity_id = tt3.activity_id 
        WHERE EXTRACT(YEAR FROM a3.activity_date) = 2026 
        GROUP BY a3.runner_id 
    ) hr_sub 
) 
AND AVG(tt.avg_power_per_activity) > ( 
    SELECT AVG(runner_avg_power) 
    FROM ( 
        SELECT 
            a4.runner_id, 
            AVG(tt4.avg_power_per_activity) AS runner_avg_power 
        FROM Activities a4 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(running_power) AS avg_power_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt4 
            ON a4.activity_id = tt4.activity_id 
        WHERE EXTRACT(YEAR FROM a4.activity_date) = 2026 
        GROUP BY a4.runner_id 
    ) power_sub 
) 
ORDER BY total_distance_km DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q1', 'TYPICAL'));

PROMPT --- EXECUTION 1 ---

SET TIMING ON

SELECT    
    r.runner_id, 
    r.full_name, 
    SUM(ro.distance_km) AS total_distance_km, 
    ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate, 
    ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace, 
    ROUND(AVG(tt.avg_power_per_activity), 2) AS avg_running_power, 
    COUNT(a.activity_id) AS total_activities 
FROM Runners r   
JOIN Activities a  
    ON r.runner_id = a.runner_id   
JOIN Routes ro  
    ON a.route_id = ro.route_id 
JOIN ( 
    SELECT 
        activity_id, 
        AVG(heart_rate_bpm) AS avg_hr_per_activity, 
        AVG(pace) AS avg_pace_per_activity, 
        AVG(running_power) AS avg_power_per_activity 
    FROM Telemetry_Data 
    GROUP BY activity_id 
) tt 
    ON a.activity_id = tt.activity_id 
WHERE EXTRACT(YEAR FROM a.activity_date) = 2026   
  AND r.sex = 'Male' 
  AND r.weight_kg < 90 
  AND r.join_date > (SYSDATE - 100) 
  AND ro.difficulty_level >= 3 
GROUP BY   
    r.runner_id, 
    r.full_name 
HAVING SUM(ro.distance_km) > (   
    SELECT AVG(total_distance)   
    FROM (   
        SELECT  
            SUM(ro2.distance_km) AS total_distance 
        FROM Activities a2   
        JOIN Routes ro2  
            ON a2.route_id = ro2.route_id   
        JOIN Runners r2  
            ON a2.runner_id = r2.runner_id 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity, 
                AVG(pace) AS avg_pace_per_activity, 
                AVG(running_power) AS avg_power_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt2 
            ON a2.activity_id = tt2.activity_id 
        WHERE EXTRACT(YEAR FROM a2.activity_date) = 2026  
          AND r2.sex = 'Male' 
          AND r2.weight_kg < 90 
        GROUP BY a2.runner_id 
    ) dist_sub 
) 
AND AVG(tt.avg_hr_per_activity) < ( 
    SELECT AVG(runner_avg_hr) 
    FROM ( 
        SELECT 
            a3.runner_id, 
            AVG(tt3.avg_hr_per_activity) AS runner_avg_hr 
        FROM Activities a3 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt3 
            ON a3.activity_id = tt3.activity_id 
        WHERE EXTRACT(YEAR FROM a3.activity_date) = 2026 
        GROUP BY a3.runner_id 
    ) hr_sub 
) 
AND AVG(tt.avg_power_per_activity) > ( 
    SELECT AVG(runner_avg_power) 
    FROM ( 
        SELECT 
            a4.runner_id, 
            AVG(tt4.avg_power_per_activity) AS runner_avg_power 
        FROM Activities a4 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(running_power) AS avg_power_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt4 
            ON a4.activity_id = tt4.activity_id 
        WHERE EXTRACT(YEAR FROM a4.activity_date) = 2026 
        GROUP BY a4.runner_id 
    ) power_sub 
) 
ORDER BY total_distance_km DESC;

SET TIMING OFF


-- ==========================================
-- QUERY 2
-- ==========================================
PROMPT --- QUERY PLAN 2 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q2' FOR

SELECT     
    r.runner_id,  
    r.full_name,    
    SUM(ro.distance_km) AS total_distance_km,    
    COUNT(DISTINCT ra.runner_achievement_id) AS total_achievements, 
    ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate, 
    ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace 
FROM Runners r    
JOIN Activities a   
    ON r.runner_id = a.runner_id    
JOIN Routes ro   
    ON a.route_id = ro.route_id    
LEFT JOIN Runner_Achievements ra   
    ON r.runner_id = ra.runner_id    
LEFT JOIN Shoes s   
    ON a.runner_id = s.runner_id 
JOIN ( 
    SELECT 
        activity_id, 
        AVG(heart_rate_bpm) AS avg_hr_per_activity, 
        AVG(pace) AS avg_pace_per_activity 
    FROM Telemetry_Data 
    GROUP BY activity_id 
) tt 
    ON a.activity_id = tt.activity_id 
WHERE EXTRACT(YEAR FROM a.activity_date) = 2026    
  AND r.height > 175  
  AND s.model LIKE 'Nike%'  
  AND ro.elevation_gain > 10  
GROUP BY    
    r.runner_id,  
    r.full_name    
HAVING SUM(ro.distance_km) > (    
    SELECT AVG(total_distance)    
    FROM (    
        SELECT  
            SUM(ro2.distance_km) AS total_distance    
        FROM Activities a2    
        JOIN Routes ro2   
            ON a2.route_id = ro2.route_id 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity, 
                AVG(pace) AS avg_pace_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt2 
            ON a2.activity_id = tt2.activity_id 
        WHERE EXTRACT(YEAR FROM a2.activity_date) = 2026    
        GROUP BY a2.runner_id    
    ) dist_sub 
)    
AND AVG(tt.avg_hr_per_activity) < ( 
    SELECT AVG(runner_avg_hr) 
    FROM ( 
        SELECT 
            a3.runner_id, 
            AVG(tt3.avg_hr_per_activity) AS runner_avg_hr 
        FROM Activities a3 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt3 
            ON a3.activity_id = tt3.activity_id 
        WHERE EXTRACT(YEAR FROM a3.activity_date) = 2026 
        GROUP BY a3.runner_id 
    ) hr_sub 
) 
ORDER BY total_distance_km DESC 
FETCH FIRST 10 ROWS ONLY;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q2', 'TYPICAL'));

PROMPT --- EXECUTION 2 ---

SET TIMING ON

SELECT     
    r.runner_id,  
    r.full_name,    
    SUM(ro.distance_km) AS total_distance_km,    
    COUNT(DISTINCT ra.runner_achievement_id) AS total_achievements, 
    ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate, 
    ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace 
FROM Runners r    
JOIN Activities a   
    ON r.runner_id = a.runner_id    
JOIN Routes ro   
    ON a.route_id = ro.route_id    
LEFT JOIN Runner_Achievements ra   
    ON r.runner_id = ra.runner_id    
LEFT JOIN Shoes s   
    ON a.runner_id = s.runner_id 
JOIN ( 
    SELECT 
        activity_id, 
        AVG(heart_rate_bpm) AS avg_hr_per_activity, 
        AVG(pace) AS avg_pace_per_activity 
    FROM Telemetry_Data 
    GROUP BY activity_id 
) tt 
    ON a.activity_id = tt.activity_id 
WHERE EXTRACT(YEAR FROM a.activity_date) = 2026    
  AND r.height > 175  
  AND s.model LIKE 'Nike%'  
  AND ro.elevation_gain > 10  
GROUP BY    
    r.runner_id,  
    r.full_name    
HAVING SUM(ro.distance_km) > (    
    SELECT AVG(total_distance)    
    FROM (    
        SELECT  
            SUM(ro2.distance_km) AS total_distance    
        FROM Activities a2    
        JOIN Routes ro2   
            ON a2.route_id = ro2.route_id 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity, 
                AVG(pace) AS avg_pace_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt2 
            ON a2.activity_id = tt2.activity_id 
        WHERE EXTRACT(YEAR FROM a2.activity_date) = 2026    
        GROUP BY a2.runner_id    
    ) dist_sub 
)    
AND AVG(tt.avg_hr_per_activity) < ( 
    SELECT AVG(runner_avg_hr) 
    FROM ( 
        SELECT 
            a3.runner_id, 
            AVG(tt3.avg_hr_per_activity) AS runner_avg_hr 
        FROM Activities a3 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt3 
            ON a3.activity_id = tt3.activity_id 
        WHERE EXTRACT(YEAR FROM a3.activity_date) = 2026 
        GROUP BY a3.runner_id 
    ) hr_sub 
) 
ORDER BY total_distance_km DESC 
FETCH FIRST 10 ROWS ONLY;

SET TIMING OFF

-- ==========================================
-- QUERY 3
-- ==========================================
PROMPT --- QUERY PLAN 3 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q3' FOR

SELECT *
FROM (
    SELECT      
        r.runner_id,   
        r.full_name,     
        SUM(ro.distance_km) AS total_distance_km,     
        COUNT(DISTINCT ra.runner_achievement_id) AS total_achievements,  
        ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate,  
        ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace,
        ROUND(AVG(tt.avg_power_per_activity), 2) AS avg_running_power,
        DENSE_RANK() OVER (ORDER BY SUM(ro.distance_km) DESC) AS distance_rank
    FROM Runners r     
    JOIN Activities a    
        ON r.runner_id = a.runner_id     
    JOIN Routes ro    
        ON a.route_id = ro.route_id     
    LEFT JOIN Runner_Achievements ra    
        ON r.runner_id = ra.runner_id     
    LEFT JOIN Shoes s    
        ON a.runner_id = s.runner_id  
    JOIN (  
        SELECT  
            activity_id,  
            AVG(heart_rate_bpm) AS avg_hr_per_activity,  
            AVG(pace) AS avg_pace_per_activity,
            AVG(running_power) AS avg_power_per_activity
        FROM Telemetry_Data  
        GROUP BY activity_id  
    ) tt  
        ON a.activity_id = tt.activity_id  
    WHERE EXTRACT(YEAR FROM a.activity_date) = 2026     
      AND r.height > 175   
      AND s.model LIKE 'Nike%'   
      AND ro.elevation_gain > 10   
    GROUP BY     
        r.runner_id,   
        r.full_name     
) ranked
WHERE distance_rank <= 10
  AND avg_heart_rate > (
      SELECT AVG(avg_hr_per_activity)
      FROM (
          SELECT AVG(heart_rate_bpm) AS avg_hr_per_activity
          FROM Telemetry_Data
          GROUP BY activity_id
      ) hr_avg_sub
  )
  AND avg_running_power > (
      SELECT AVG(avg_power_per_activity)
      FROM (
          SELECT AVG(running_power) AS avg_power_per_activity
          FROM Telemetry_Data
          GROUP BY activity_id
      ) power_avg_sub
  )
ORDER BY total_distance_km DESC, avg_running_power DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q3', 'TYPICAL'));

PROMPT --- EXECUTION 3 ---

SET TIMING ON

SELECT *
FROM (
    SELECT      
        r.runner_id,   
        r.full_name,     
        SUM(ro.distance_km) AS total_distance_km,     
        COUNT(DISTINCT ra.runner_achievement_id) AS total_achievements,  
        ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate,  
        ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace,
        ROUND(AVG(tt.avg_power_per_activity), 2) AS avg_running_power,
        DENSE_RANK() OVER (ORDER BY SUM(ro.distance_km) DESC) AS distance_rank
    FROM Runners r     
    JOIN Activities a    
        ON r.runner_id = a.runner_id     
    JOIN Routes ro    
        ON a.route_id = ro.route_id     
    LEFT JOIN Runner_Achievements ra    
        ON r.runner_id = ra.runner_id     
    LEFT JOIN Shoes s    
        ON a.runner_id = s.runner_id  
    JOIN (  
        SELECT  
            activity_id,  
            AVG(heart_rate_bpm) AS avg_hr_per_activity,  
            AVG(pace) AS avg_pace_per_activity,
            AVG(running_power) AS avg_power_per_activity
        FROM Telemetry_Data  
        GROUP BY activity_id  
    ) tt  
        ON a.activity_id = tt.activity_id  
    WHERE EXTRACT(YEAR FROM a.activity_date) = 2026     
      AND r.height > 175   
      AND s.model LIKE 'Nike%'   
      AND ro.elevation_gain > 10   
    GROUP BY     
        r.runner_id,   
        r.full_name     
) ranked
WHERE distance_rank <= 10
  AND avg_heart_rate > (
      SELECT AVG(avg_hr_per_activity)
      FROM (
          SELECT AVG(heart_rate_bpm) AS avg_hr_per_activity
          FROM Telemetry_Data
          GROUP BY activity_id
      ) hr_avg_sub
  )
  AND avg_running_power > (
      SELECT AVG(avg_power_per_activity)
      FROM (
          SELECT AVG(running_power) AS avg_power_per_activity
          FROM Telemetry_Data
          GROUP BY activity_id
      ) power_avg_sub
  )
ORDER BY total_distance_km DESC, avg_running_power DESC;

SET TIMING OFF


-- ==========================================
-- QUERY 4
-- ==========================================
PROMPT --- QUERY PLAN 4 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q4' FOR

INSERT INTO Activities ( 
    activity_id, runner_id, route_id, activity_type,  
    duration_min, activity_date, avg_bpm, max_bpm, min_bpm 
) 
SELECT  
    -- 1. Generujemy nowe ID na podstawie aktualnego MAX + licznik wierszy 
    (SELECT MAX(activity_id) FROM Activities) + ROWNUM, 
    501,  
    10,  
    'Smartwatch Sync',  
    45,  
    CURRENT_DATE, 
    -- 2. Wchodzimy do bazy Telemetry_data i zmuszamy ja 
    -- Do grupowania i agregacje na dużej tabeli ~1 sekund 
    stats.avg_hr, 
    stats.max_hr, 
    stats.min_hr 
FROM ( 
    SELECT  
        ROUND(AVG(heart_rate_bpm)) as avg_hr, 
        MAX(heart_rate_bpm) as max_hr, 
        MIN(heart_rate_bpm) as min_hr 
    FROM Telemetry_Data 
    -- Brak indeksu na tym warunku lub wymuszenie skanowania dużej części tabeli 
    WHERE activity_id IS NOT NULL  
    GROUP BY TRUNC(heart_rate_bpm / 10) -- Sztuczne pogrupowanie co 10 jednostek  
    HAVING COUNT(*) > 100 
    ORDER BY 1 DESC 
) stats 
-- 3. Ograniczenie do 21 wierszy, które zostaną wstawione (grupy sa co 10 wiec nawet wiecej grup nie bedzie) 
-- Jest to dodatkowe zabezpieczenie przed błędnymi danymi jakby np tetno wynosilo 400 
WHERE ROWNUM <= 21;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q4', 'TYPICAL'));

PROMPT --- EXECUTION 4 ---

SET TIMING ON

INSERT INTO Activities ( 
    activity_id, runner_id, route_id, activity_type,  
    duration_min, activity_date, avg_bpm, max_bpm, min_bpm 
) 
SELECT  
    -- 1. Generujemy nowe ID na podstawie aktualnego MAX + licznik wierszy 
    (SELECT MAX(activity_id) FROM Activities) + ROWNUM, 
    501,  
    10,  
    'Smartwatch Sync',  
    45,  
    CURRENT_DATE, 
    -- 2. Wchodzimy do bazy Telemetry_data i zmuszamy ja 
    -- Do grupowania i agregacje na dużej tabeli ~1 sekund 
    stats.avg_hr, 
    stats.max_hr, 
    stats.min_hr 
FROM ( 
    SELECT  
        ROUND(AVG(heart_rate_bpm)) as avg_hr, 
        MAX(heart_rate_bpm) as max_hr, 
        MIN(heart_rate_bpm) as min_hr 
    FROM Telemetry_Data 
    -- Brak indeksu na tym warunku lub wymuszenie skanowania dużej części tabeli 
    WHERE activity_id IS NOT NULL  
    GROUP BY TRUNC(heart_rate_bpm / 10) -- Sztuczne pogrupowanie co 10 jednostek  
    HAVING COUNT(*) > 100 
    ORDER BY 1 DESC 
) stats 
-- 3. Ograniczenie do 21 wierszy, które zostaną wstawione (grupy sa co 10 wiec nawet wiecej grup nie bedzie) 
-- Jest to dodatkowe zabezpieczenie przed błędnymi danymi jakby np tetno wynosilo 400 
WHERE ROWNUM <= 21;

SET TIMING OFF

-- ==========================================
-- QUERY 5
-- ==========================================
PROMPT --- QUERY PLAN 5 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q5' FOR

UPDATE Training_Goals tg
SET 
    tg.current_value = (
        SELECT SUM(ro.distance_km)
        FROM Activities a
        JOIN Routes ro 
            ON a.route_id = ro.route_id
        WHERE a.runner_id = tg.runner_id
          AND a.activity_date BETWEEN (tg.deadline - 30) AND tg.deadline
          AND (
              SELECT AVG(SQRT(heart_rate_bpm))
              FROM Telemetry_Data
              WHERE ROWNUM < 500
          ) > 0
    ),
    tg.status = CASE
        WHEN (
            SELECT SUM(ro2.distance_km)
            FROM Activities a2
            JOIN Routes ro2 
                ON a2.route_id = ro2.route_id
            WHERE a2.runner_id = tg.runner_id
              AND a2.activity_date BETWEEN (tg.deadline - 30) AND tg.deadline
              AND (
                  SELECT COUNT(LOG(10, footsteps))
                  FROM Telemetry_Data
                  WHERE ROWNUM < 1000
              ) >= 0
        ) >= tg.target_value
        THEN 1
        ELSE 0
    END
WHERE tg.runner_id IN (
    SELECT r.runner_id
    FROM Runners r
    WHERE r.join_date < SYSDATE
      AND (
          SELECT SUM(a3.duration_min)
          FROM Activities a3
          WHERE a3.runner_id = r.runner_id
      ) > 0
);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q5', 'TYPICAL'));

PROMPT --- EXECUTION 5 ---

SET TIMING ON

UPDATE Training_Goals tg
SET 
    tg.current_value = (
        SELECT SUM(ro.distance_km)
        FROM Activities a
        JOIN Routes ro 
            ON a.route_id = ro.route_id
        WHERE a.runner_id = tg.runner_id
          AND a.activity_date BETWEEN (tg.deadline - 30) AND tg.deadline
          AND (
              SELECT AVG(SQRT(heart_rate_bpm))
              FROM Telemetry_Data
              WHERE ROWNUM < 500
          ) > 0
    ),
    tg.status = CASE
        WHEN (
            SELECT SUM(ro2.distance_km)
            FROM Activities a2
            JOIN Routes ro2 
                ON a2.route_id = ro2.route_id
            WHERE a2.runner_id = tg.runner_id
              AND a2.activity_date BETWEEN (tg.deadline - 30) AND tg.deadline
              AND (
                  SELECT COUNT(LOG(10, footsteps))
                  FROM Telemetry_Data
                  WHERE ROWNUM < 1000
              ) >= 0
        ) >= tg.target_value
        THEN 1
        ELSE 0
    END
WHERE tg.runner_id IN (
    SELECT r.runner_id
    FROM Runners r
    WHERE r.join_date < SYSDATE
      AND (
          SELECT SUM(a3.duration_min)
          FROM Activities a3
          WHERE a3.runner_id = r.runner_id
      ) > 0
);
SET TIMING OFF

-- ==========================================
-- QUERY 6
-- ==========================================
PROMPT --- QUERY PLAN 6 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q6' FOR

DELETE FROM Telemetry_Data
WHERE activity_id IN (
    WITH telemetry_agg AS (
        SELECT
            td.activity_id,
            AVG(td.heart_rate_bpm) AS avg_hr,
            AVG(td.pace) AS avg_pace,
            AVG(td.running_power) AS avg_power
        FROM Telemetry_Data td
        GROUP BY td.activity_id
    ),
    candidate_activities AS (
        SELECT
            a.activity_id
        FROM Activities a
        JOIN Runners r
            ON a.runner_id = r.runner_id
        JOIN Routes ro
            ON a.route_id = ro.route_id
        JOIN telemetry_agg ta
            ON a.activity_id = ta.activity_id
        WHERE EXTRACT(YEAR FROM a.activity_date) = 2026
          AND r.sex = 'Male'
          AND r.weight_kg < 90
          AND ro.difficulty_level >= 3
          AND ta.avg_hr > (SELECT AVG(avg_hr) FROM telemetry_agg)
          AND ta.avg_power > (SELECT AVG(avg_power) FROM telemetry_agg)
    )
    SELECT activity_id
    FROM candidate_activities
);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q6', 'TYPICAL'));

PROMPT --- EXECUTION 6 ---

SET TIMING ON

DELETE FROM Telemetry_Data
WHERE activity_id IN (
    WITH telemetry_agg AS (
        SELECT
            td.activity_id,
            AVG(td.heart_rate_bpm) AS avg_hr,
            AVG(td.pace) AS avg_pace,
            AVG(td.running_power) AS avg_power
        FROM Telemetry_Data td
        GROUP BY td.activity_id
    ),
    candidate_activities AS (
        SELECT
            a.activity_id
        FROM Activities a
        JOIN Runners r
            ON a.runner_id = r.runner_id
        JOIN Routes ro
            ON a.route_id = ro.route_id
        JOIN telemetry_agg ta
            ON a.activity_id = ta.activity_id
        WHERE EXTRACT(YEAR FROM a.activity_date) = 2026
          AND r.sex = 'Male'
          AND r.weight_kg < 90
          AND ro.difficulty_level >= 3
          AND ta.avg_hr > (SELECT AVG(avg_hr) FROM telemetry_agg)
          AND ta.avg_power > (SELECT AVG(avg_power) FROM telemetry_agg)
    )
    SELECT activity_id
    FROM candidate_activities
);

SET TIMING OFF

ROLLBACK;

PROMPT
PROMPT ==========================================
PROMPT ============== RUN 4 START ================
PROMPT ==========================================
PROMPT

-- ==========================================
-- FLUSH CACHE BEFORE WORKLOAD
-- ==========================================
PROMPT --- FLUSH CACHE ---

ALTER SYSTEM FLUSH BUFFER_CACHE;
ALTER SYSTEM FLUSH SHARED_POOL;

-- ==========================================
-- QUERY 1
-- ==========================================
PROMPT --- QUERY PLAN 1 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q1' FOR

SELECT    
    r.runner_id, 
    r.full_name, 
    SUM(ro.distance_km) AS total_distance_km, 
    ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate, 
    ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace, 
    ROUND(AVG(tt.avg_power_per_activity), 2) AS avg_running_power, 
    COUNT(a.activity_id) AS total_activities 
FROM Runners r   
JOIN Activities a  
    ON r.runner_id = a.runner_id   
JOIN Routes ro  
    ON a.route_id = ro.route_id 
JOIN ( 
    SELECT 
        activity_id, 
        AVG(heart_rate_bpm) AS avg_hr_per_activity, 
        AVG(pace) AS avg_pace_per_activity, 
        AVG(running_power) AS avg_power_per_activity 
    FROM Telemetry_Data 
    GROUP BY activity_id 
) tt 
    ON a.activity_id = tt.activity_id 
WHERE EXTRACT(YEAR FROM a.activity_date) = 2026   
  AND r.sex = 'Male' 
  AND r.weight_kg < 90 
  AND r.join_date > (SYSDATE - 100) 
  AND ro.difficulty_level >= 3 
GROUP BY   
    r.runner_id, 
    r.full_name 
HAVING SUM(ro.distance_km) > (   
    SELECT AVG(total_distance)   
    FROM (   
        SELECT  
            SUM(ro2.distance_km) AS total_distance 
        FROM Activities a2   
        JOIN Routes ro2  
            ON a2.route_id = ro2.route_id   
        JOIN Runners r2  
            ON a2.runner_id = r2.runner_id 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity, 
                AVG(pace) AS avg_pace_per_activity, 
                AVG(running_power) AS avg_power_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt2 
            ON a2.activity_id = tt2.activity_id 
        WHERE EXTRACT(YEAR FROM a2.activity_date) = 2026  
          AND r2.sex = 'Male' 
          AND r2.weight_kg < 90 
        GROUP BY a2.runner_id 
    ) dist_sub 
) 
AND AVG(tt.avg_hr_per_activity) < ( 
    SELECT AVG(runner_avg_hr) 
    FROM ( 
        SELECT 
            a3.runner_id, 
            AVG(tt3.avg_hr_per_activity) AS runner_avg_hr 
        FROM Activities a3 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt3 
            ON a3.activity_id = tt3.activity_id 
        WHERE EXTRACT(YEAR FROM a3.activity_date) = 2026 
        GROUP BY a3.runner_id 
    ) hr_sub 
) 
AND AVG(tt.avg_power_per_activity) > ( 
    SELECT AVG(runner_avg_power) 
    FROM ( 
        SELECT 
            a4.runner_id, 
            AVG(tt4.avg_power_per_activity) AS runner_avg_power 
        FROM Activities a4 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(running_power) AS avg_power_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt4 
            ON a4.activity_id = tt4.activity_id 
        WHERE EXTRACT(YEAR FROM a4.activity_date) = 2026 
        GROUP BY a4.runner_id 
    ) power_sub 
) 
ORDER BY total_distance_km DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q1', 'TYPICAL'));

PROMPT --- EXECUTION 1 ---

SET TIMING ON

SELECT    
    r.runner_id, 
    r.full_name, 
    SUM(ro.distance_km) AS total_distance_km, 
    ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate, 
    ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace, 
    ROUND(AVG(tt.avg_power_per_activity), 2) AS avg_running_power, 
    COUNT(a.activity_id) AS total_activities 
FROM Runners r   
JOIN Activities a  
    ON r.runner_id = a.runner_id   
JOIN Routes ro  
    ON a.route_id = ro.route_id 
JOIN ( 
    SELECT 
        activity_id, 
        AVG(heart_rate_bpm) AS avg_hr_per_activity, 
        AVG(pace) AS avg_pace_per_activity, 
        AVG(running_power) AS avg_power_per_activity 
    FROM Telemetry_Data 
    GROUP BY activity_id 
) tt 
    ON a.activity_id = tt.activity_id 
WHERE EXTRACT(YEAR FROM a.activity_date) = 2026   
  AND r.sex = 'Male' 
  AND r.weight_kg < 90 
  AND r.join_date > (SYSDATE - 100) 
  AND ro.difficulty_level >= 3 
GROUP BY   
    r.runner_id, 
    r.full_name 
HAVING SUM(ro.distance_km) > (   
    SELECT AVG(total_distance)   
    FROM (   
        SELECT  
            SUM(ro2.distance_km) AS total_distance 
        FROM Activities a2   
        JOIN Routes ro2  
            ON a2.route_id = ro2.route_id   
        JOIN Runners r2  
            ON a2.runner_id = r2.runner_id 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity, 
                AVG(pace) AS avg_pace_per_activity, 
                AVG(running_power) AS avg_power_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt2 
            ON a2.activity_id = tt2.activity_id 
        WHERE EXTRACT(YEAR FROM a2.activity_date) = 2026  
          AND r2.sex = 'Male' 
          AND r2.weight_kg < 90 
        GROUP BY a2.runner_id 
    ) dist_sub 
) 
AND AVG(tt.avg_hr_per_activity) < ( 
    SELECT AVG(runner_avg_hr) 
    FROM ( 
        SELECT 
            a3.runner_id, 
            AVG(tt3.avg_hr_per_activity) AS runner_avg_hr 
        FROM Activities a3 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt3 
            ON a3.activity_id = tt3.activity_id 
        WHERE EXTRACT(YEAR FROM a3.activity_date) = 2026 
        GROUP BY a3.runner_id 
    ) hr_sub 
) 
AND AVG(tt.avg_power_per_activity) > ( 
    SELECT AVG(runner_avg_power) 
    FROM ( 
        SELECT 
            a4.runner_id, 
            AVG(tt4.avg_power_per_activity) AS runner_avg_power 
        FROM Activities a4 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(running_power) AS avg_power_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt4 
            ON a4.activity_id = tt4.activity_id 
        WHERE EXTRACT(YEAR FROM a4.activity_date) = 2026 
        GROUP BY a4.runner_id 
    ) power_sub 
) 
ORDER BY total_distance_km DESC;

SET TIMING OFF


-- ==========================================
-- QUERY 2
-- ==========================================
PROMPT --- QUERY PLAN 2 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q2' FOR

SELECT     
    r.runner_id,  
    r.full_name,    
    SUM(ro.distance_km) AS total_distance_km,    
    COUNT(DISTINCT ra.runner_achievement_id) AS total_achievements, 
    ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate, 
    ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace 
FROM Runners r    
JOIN Activities a   
    ON r.runner_id = a.runner_id    
JOIN Routes ro   
    ON a.route_id = ro.route_id    
LEFT JOIN Runner_Achievements ra   
    ON r.runner_id = ra.runner_id    
LEFT JOIN Shoes s   
    ON a.runner_id = s.runner_id 
JOIN ( 
    SELECT 
        activity_id, 
        AVG(heart_rate_bpm) AS avg_hr_per_activity, 
        AVG(pace) AS avg_pace_per_activity 
    FROM Telemetry_Data 
    GROUP BY activity_id 
) tt 
    ON a.activity_id = tt.activity_id 
WHERE EXTRACT(YEAR FROM a.activity_date) = 2026    
  AND r.height > 175  
  AND s.model LIKE 'Nike%'  
  AND ro.elevation_gain > 10  
GROUP BY    
    r.runner_id,  
    r.full_name    
HAVING SUM(ro.distance_km) > (    
    SELECT AVG(total_distance)    
    FROM (    
        SELECT  
            SUM(ro2.distance_km) AS total_distance    
        FROM Activities a2    
        JOIN Routes ro2   
            ON a2.route_id = ro2.route_id 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity, 
                AVG(pace) AS avg_pace_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt2 
            ON a2.activity_id = tt2.activity_id 
        WHERE EXTRACT(YEAR FROM a2.activity_date) = 2026    
        GROUP BY a2.runner_id    
    ) dist_sub 
)    
AND AVG(tt.avg_hr_per_activity) < ( 
    SELECT AVG(runner_avg_hr) 
    FROM ( 
        SELECT 
            a3.runner_id, 
            AVG(tt3.avg_hr_per_activity) AS runner_avg_hr 
        FROM Activities a3 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt3 
            ON a3.activity_id = tt3.activity_id 
        WHERE EXTRACT(YEAR FROM a3.activity_date) = 2026 
        GROUP BY a3.runner_id 
    ) hr_sub 
) 
ORDER BY total_distance_km DESC 
FETCH FIRST 10 ROWS ONLY;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q2', 'TYPICAL'));

PROMPT --- EXECUTION 2 ---

SET TIMING ON

SELECT     
    r.runner_id,  
    r.full_name,    
    SUM(ro.distance_km) AS total_distance_km,    
    COUNT(DISTINCT ra.runner_achievement_id) AS total_achievements, 
    ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate, 
    ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace 
FROM Runners r    
JOIN Activities a   
    ON r.runner_id = a.runner_id    
JOIN Routes ro   
    ON a.route_id = ro.route_id    
LEFT JOIN Runner_Achievements ra   
    ON r.runner_id = ra.runner_id    
LEFT JOIN Shoes s   
    ON a.runner_id = s.runner_id 
JOIN ( 
    SELECT 
        activity_id, 
        AVG(heart_rate_bpm) AS avg_hr_per_activity, 
        AVG(pace) AS avg_pace_per_activity 
    FROM Telemetry_Data 
    GROUP BY activity_id 
) tt 
    ON a.activity_id = tt.activity_id 
WHERE EXTRACT(YEAR FROM a.activity_date) = 2026    
  AND r.height > 175  
  AND s.model LIKE 'Nike%'  
  AND ro.elevation_gain > 10  
GROUP BY    
    r.runner_id,  
    r.full_name    
HAVING SUM(ro.distance_km) > (    
    SELECT AVG(total_distance)    
    FROM (    
        SELECT  
            SUM(ro2.distance_km) AS total_distance    
        FROM Activities a2    
        JOIN Routes ro2   
            ON a2.route_id = ro2.route_id 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity, 
                AVG(pace) AS avg_pace_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt2 
            ON a2.activity_id = tt2.activity_id 
        WHERE EXTRACT(YEAR FROM a2.activity_date) = 2026    
        GROUP BY a2.runner_id    
    ) dist_sub 
)    
AND AVG(tt.avg_hr_per_activity) < ( 
    SELECT AVG(runner_avg_hr) 
    FROM ( 
        SELECT 
            a3.runner_id, 
            AVG(tt3.avg_hr_per_activity) AS runner_avg_hr 
        FROM Activities a3 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt3 
            ON a3.activity_id = tt3.activity_id 
        WHERE EXTRACT(YEAR FROM a3.activity_date) = 2026 
        GROUP BY a3.runner_id 
    ) hr_sub 
) 
ORDER BY total_distance_km DESC 
FETCH FIRST 10 ROWS ONLY;

SET TIMING OFF

-- ==========================================
-- QUERY 3
-- ==========================================
PROMPT --- QUERY PLAN 3 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q3' FOR

SELECT *
FROM (
    SELECT      
        r.runner_id,   
        r.full_name,     
        SUM(ro.distance_km) AS total_distance_km,     
        COUNT(DISTINCT ra.runner_achievement_id) AS total_achievements,  
        ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate,  
        ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace,
        ROUND(AVG(tt.avg_power_per_activity), 2) AS avg_running_power,
        DENSE_RANK() OVER (ORDER BY SUM(ro.distance_km) DESC) AS distance_rank
    FROM Runners r     
    JOIN Activities a    
        ON r.runner_id = a.runner_id     
    JOIN Routes ro    
        ON a.route_id = ro.route_id     
    LEFT JOIN Runner_Achievements ra    
        ON r.runner_id = ra.runner_id     
    LEFT JOIN Shoes s    
        ON a.runner_id = s.runner_id  
    JOIN (  
        SELECT  
            activity_id,  
            AVG(heart_rate_bpm) AS avg_hr_per_activity,  
            AVG(pace) AS avg_pace_per_activity,
            AVG(running_power) AS avg_power_per_activity
        FROM Telemetry_Data  
        GROUP BY activity_id  
    ) tt  
        ON a.activity_id = tt.activity_id  
    WHERE EXTRACT(YEAR FROM a.activity_date) = 2026     
      AND r.height > 175   
      AND s.model LIKE 'Nike%'   
      AND ro.elevation_gain > 10   
    GROUP BY     
        r.runner_id,   
        r.full_name     
) ranked
WHERE distance_rank <= 10
  AND avg_heart_rate > (
      SELECT AVG(avg_hr_per_activity)
      FROM (
          SELECT AVG(heart_rate_bpm) AS avg_hr_per_activity
          FROM Telemetry_Data
          GROUP BY activity_id
      ) hr_avg_sub
  )
  AND avg_running_power > (
      SELECT AVG(avg_power_per_activity)
      FROM (
          SELECT AVG(running_power) AS avg_power_per_activity
          FROM Telemetry_Data
          GROUP BY activity_id
      ) power_avg_sub
  )
ORDER BY total_distance_km DESC, avg_running_power DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q3', 'TYPICAL'));

PROMPT --- EXECUTION 3 ---

SET TIMING ON

SELECT *
FROM (
    SELECT      
        r.runner_id,   
        r.full_name,     
        SUM(ro.distance_km) AS total_distance_km,     
        COUNT(DISTINCT ra.runner_achievement_id) AS total_achievements,  
        ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate,  
        ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace,
        ROUND(AVG(tt.avg_power_per_activity), 2) AS avg_running_power,
        DENSE_RANK() OVER (ORDER BY SUM(ro.distance_km) DESC) AS distance_rank
    FROM Runners r     
    JOIN Activities a    
        ON r.runner_id = a.runner_id     
    JOIN Routes ro    
        ON a.route_id = ro.route_id     
    LEFT JOIN Runner_Achievements ra    
        ON r.runner_id = ra.runner_id     
    LEFT JOIN Shoes s    
        ON a.runner_id = s.runner_id  
    JOIN (  
        SELECT  
            activity_id,  
            AVG(heart_rate_bpm) AS avg_hr_per_activity,  
            AVG(pace) AS avg_pace_per_activity,
            AVG(running_power) AS avg_power_per_activity
        FROM Telemetry_Data  
        GROUP BY activity_id  
    ) tt  
        ON a.activity_id = tt.activity_id  
    WHERE EXTRACT(YEAR FROM a.activity_date) = 2026     
      AND r.height > 175   
      AND s.model LIKE 'Nike%'   
      AND ro.elevation_gain > 10   
    GROUP BY     
        r.runner_id,   
        r.full_name     
) ranked
WHERE distance_rank <= 10
  AND avg_heart_rate > (
      SELECT AVG(avg_hr_per_activity)
      FROM (
          SELECT AVG(heart_rate_bpm) AS avg_hr_per_activity
          FROM Telemetry_Data
          GROUP BY activity_id
      ) hr_avg_sub
  )
  AND avg_running_power > (
      SELECT AVG(avg_power_per_activity)
      FROM (
          SELECT AVG(running_power) AS avg_power_per_activity
          FROM Telemetry_Data
          GROUP BY activity_id
      ) power_avg_sub
  )
ORDER BY total_distance_km DESC, avg_running_power DESC;

SET TIMING OFF


-- ==========================================
-- QUERY 4
-- ==========================================
PROMPT --- QUERY PLAN 4 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q4' FOR

INSERT INTO Activities ( 
    activity_id, runner_id, route_id, activity_type,  
    duration_min, activity_date, avg_bpm, max_bpm, min_bpm 
) 
SELECT  
    -- 1. Generujemy nowe ID na podstawie aktualnego MAX + licznik wierszy 
    (SELECT MAX(activity_id) FROM Activities) + ROWNUM, 
    501,  
    10,  
    'Smartwatch Sync',  
    45,  
    CURRENT_DATE, 
    -- 2. Wchodzimy do bazy Telemetry_data i zmuszamy ja 
    -- Do grupowania i agregacje na dużej tabeli ~1 sekund 
    stats.avg_hr, 
    stats.max_hr, 
    stats.min_hr 
FROM ( 
    SELECT  
        ROUND(AVG(heart_rate_bpm)) as avg_hr, 
        MAX(heart_rate_bpm) as max_hr, 
        MIN(heart_rate_bpm) as min_hr 
    FROM Telemetry_Data 
    -- Brak indeksu na tym warunku lub wymuszenie skanowania dużej części tabeli 
    WHERE activity_id IS NOT NULL  
    GROUP BY TRUNC(heart_rate_bpm / 10) -- Sztuczne pogrupowanie co 10 jednostek  
    HAVING COUNT(*) > 100 
    ORDER BY 1 DESC 
) stats 
-- 3. Ograniczenie do 21 wierszy, które zostaną wstawione (grupy sa co 10 wiec nawet wiecej grup nie bedzie) 
-- Jest to dodatkowe zabezpieczenie przed błędnymi danymi jakby np tetno wynosilo 400 
WHERE ROWNUM <= 21;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q4', 'TYPICAL'));

PROMPT --- EXECUTION 4 ---

SET TIMING ON

INSERT INTO Activities ( 
    activity_id, runner_id, route_id, activity_type,  
    duration_min, activity_date, avg_bpm, max_bpm, min_bpm 
) 
SELECT  
    -- 1. Generujemy nowe ID na podstawie aktualnego MAX + licznik wierszy 
    (SELECT MAX(activity_id) FROM Activities) + ROWNUM, 
    501,  
    10,  
    'Smartwatch Sync',  
    45,  
    CURRENT_DATE, 
    -- 2. Wchodzimy do bazy Telemetry_data i zmuszamy ja 
    -- Do grupowania i agregacje na dużej tabeli ~1 sekund 
    stats.avg_hr, 
    stats.max_hr, 
    stats.min_hr 
FROM ( 
    SELECT  
        ROUND(AVG(heart_rate_bpm)) as avg_hr, 
        MAX(heart_rate_bpm) as max_hr, 
        MIN(heart_rate_bpm) as min_hr 
    FROM Telemetry_Data 
    -- Brak indeksu na tym warunku lub wymuszenie skanowania dużej części tabeli 
    WHERE activity_id IS NOT NULL  
    GROUP BY TRUNC(heart_rate_bpm / 10) -- Sztuczne pogrupowanie co 10 jednostek  
    HAVING COUNT(*) > 100 
    ORDER BY 1 DESC 
) stats 
-- 3. Ograniczenie do 21 wierszy, które zostaną wstawione (grupy sa co 10 wiec nawet wiecej grup nie bedzie) 
-- Jest to dodatkowe zabezpieczenie przed błędnymi danymi jakby np tetno wynosilo 400 
WHERE ROWNUM <= 21;

SET TIMING OFF

-- ==========================================
-- QUERY 5
-- ==========================================
PROMPT --- QUERY PLAN 5 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q5' FOR

UPDATE Training_Goals tg
SET 
    tg.current_value = (
        SELECT SUM(ro.distance_km)
        FROM Activities a
        JOIN Routes ro 
            ON a.route_id = ro.route_id
        WHERE a.runner_id = tg.runner_id
          AND a.activity_date BETWEEN (tg.deadline - 30) AND tg.deadline
          AND (
              SELECT AVG(SQRT(heart_rate_bpm))
              FROM Telemetry_Data
              WHERE ROWNUM < 500
          ) > 0
    ),
    tg.status = CASE
        WHEN (
            SELECT SUM(ro2.distance_km)
            FROM Activities a2
            JOIN Routes ro2 
                ON a2.route_id = ro2.route_id
            WHERE a2.runner_id = tg.runner_id
              AND a2.activity_date BETWEEN (tg.deadline - 30) AND tg.deadline
              AND (
                  SELECT COUNT(LOG(10, footsteps))
                  FROM Telemetry_Data
                  WHERE ROWNUM < 1000
              ) >= 0
        ) >= tg.target_value
        THEN 1
        ELSE 0
    END
WHERE tg.runner_id IN (
    SELECT r.runner_id
    FROM Runners r
    WHERE r.join_date < SYSDATE
      AND (
          SELECT SUM(a3.duration_min)
          FROM Activities a3
          WHERE a3.runner_id = r.runner_id
      ) > 0
);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q5', 'TYPICAL'));

PROMPT --- EXECUTION 5 ---

SET TIMING ON

UPDATE Training_Goals tg
SET 
    tg.current_value = (
        SELECT SUM(ro.distance_km)
        FROM Activities a
        JOIN Routes ro 
            ON a.route_id = ro.route_id
        WHERE a.runner_id = tg.runner_id
          AND a.activity_date BETWEEN (tg.deadline - 30) AND tg.deadline
          AND (
              SELECT AVG(SQRT(heart_rate_bpm))
              FROM Telemetry_Data
              WHERE ROWNUM < 500
          ) > 0
    ),
    tg.status = CASE
        WHEN (
            SELECT SUM(ro2.distance_km)
            FROM Activities a2
            JOIN Routes ro2 
                ON a2.route_id = ro2.route_id
            WHERE a2.runner_id = tg.runner_id
              AND a2.activity_date BETWEEN (tg.deadline - 30) AND tg.deadline
              AND (
                  SELECT COUNT(LOG(10, footsteps))
                  FROM Telemetry_Data
                  WHERE ROWNUM < 1000
              ) >= 0
        ) >= tg.target_value
        THEN 1
        ELSE 0
    END
WHERE tg.runner_id IN (
    SELECT r.runner_id
    FROM Runners r
    WHERE r.join_date < SYSDATE
      AND (
          SELECT SUM(a3.duration_min)
          FROM Activities a3
          WHERE a3.runner_id = r.runner_id
      ) > 0
);
SET TIMING OFF

-- ==========================================
-- QUERY 6
-- ==========================================
PROMPT --- QUERY PLAN 6 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q6' FOR

DELETE FROM Telemetry_Data
WHERE activity_id IN (
    WITH telemetry_agg AS (
        SELECT
            td.activity_id,
            AVG(td.heart_rate_bpm) AS avg_hr,
            AVG(td.pace) AS avg_pace,
            AVG(td.running_power) AS avg_power
        FROM Telemetry_Data td
        GROUP BY td.activity_id
    ),
    candidate_activities AS (
        SELECT
            a.activity_id
        FROM Activities a
        JOIN Runners r
            ON a.runner_id = r.runner_id
        JOIN Routes ro
            ON a.route_id = ro.route_id
        JOIN telemetry_agg ta
            ON a.activity_id = ta.activity_id
        WHERE EXTRACT(YEAR FROM a.activity_date) = 2026
          AND r.sex = 'Male'
          AND r.weight_kg < 90
          AND ro.difficulty_level >= 3
          AND ta.avg_hr > (SELECT AVG(avg_hr) FROM telemetry_agg)
          AND ta.avg_power > (SELECT AVG(avg_power) FROM telemetry_agg)
    )
    SELECT activity_id
    FROM candidate_activities
);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q6', 'TYPICAL'));

PROMPT --- EXECUTION 6 ---

SET TIMING ON

DELETE FROM Telemetry_Data
WHERE activity_id IN (
    WITH telemetry_agg AS (
        SELECT
            td.activity_id,
            AVG(td.heart_rate_bpm) AS avg_hr,
            AVG(td.pace) AS avg_pace,
            AVG(td.running_power) AS avg_power
        FROM Telemetry_Data td
        GROUP BY td.activity_id
    ),
    candidate_activities AS (
        SELECT
            a.activity_id
        FROM Activities a
        JOIN Runners r
            ON a.runner_id = r.runner_id
        JOIN Routes ro
            ON a.route_id = ro.route_id
        JOIN telemetry_agg ta
            ON a.activity_id = ta.activity_id
        WHERE EXTRACT(YEAR FROM a.activity_date) = 2026
          AND r.sex = 'Male'
          AND r.weight_kg < 90
          AND ro.difficulty_level >= 3
          AND ta.avg_hr > (SELECT AVG(avg_hr) FROM telemetry_agg)
          AND ta.avg_power > (SELECT AVG(avg_power) FROM telemetry_agg)
    )
    SELECT activity_id
    FROM candidate_activities
);

SET TIMING OFF

ROLLBACK;

PROMPT
PROMPT ==========================================
PROMPT ============== RUN 5 START ================
PROMPT ==========================================
PROMPT
-- ==========================================
-- FLUSH CACHE BEFORE WORKLOAD
-- ==========================================
PROMPT --- FLUSH CACHE ---

ALTER SYSTEM FLUSH BUFFER_CACHE;
ALTER SYSTEM FLUSH SHARED_POOL;

-- ==========================================
-- QUERY 1
-- ==========================================
PROMPT --- QUERY PLAN 1 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q1' FOR

SELECT    
    r.runner_id, 
    r.full_name, 
    SUM(ro.distance_km) AS total_distance_km, 
    ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate, 
    ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace, 
    ROUND(AVG(tt.avg_power_per_activity), 2) AS avg_running_power, 
    COUNT(a.activity_id) AS total_activities 
FROM Runners r   
JOIN Activities a  
    ON r.runner_id = a.runner_id   
JOIN Routes ro  
    ON a.route_id = ro.route_id 
JOIN ( 
    SELECT 
        activity_id, 
        AVG(heart_rate_bpm) AS avg_hr_per_activity, 
        AVG(pace) AS avg_pace_per_activity, 
        AVG(running_power) AS avg_power_per_activity 
    FROM Telemetry_Data 
    GROUP BY activity_id 
) tt 
    ON a.activity_id = tt.activity_id 
WHERE EXTRACT(YEAR FROM a.activity_date) = 2026   
  AND r.sex = 'Male' 
  AND r.weight_kg < 90 
  AND r.join_date > (SYSDATE - 100) 
  AND ro.difficulty_level >= 3 
GROUP BY   
    r.runner_id, 
    r.full_name 
HAVING SUM(ro.distance_km) > (   
    SELECT AVG(total_distance)   
    FROM (   
        SELECT  
            SUM(ro2.distance_km) AS total_distance 
        FROM Activities a2   
        JOIN Routes ro2  
            ON a2.route_id = ro2.route_id   
        JOIN Runners r2  
            ON a2.runner_id = r2.runner_id 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity, 
                AVG(pace) AS avg_pace_per_activity, 
                AVG(running_power) AS avg_power_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt2 
            ON a2.activity_id = tt2.activity_id 
        WHERE EXTRACT(YEAR FROM a2.activity_date) = 2026  
          AND r2.sex = 'Male' 
          AND r2.weight_kg < 90 
        GROUP BY a2.runner_id 
    ) dist_sub 
) 
AND AVG(tt.avg_hr_per_activity) < ( 
    SELECT AVG(runner_avg_hr) 
    FROM ( 
        SELECT 
            a3.runner_id, 
            AVG(tt3.avg_hr_per_activity) AS runner_avg_hr 
        FROM Activities a3 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt3 
            ON a3.activity_id = tt3.activity_id 
        WHERE EXTRACT(YEAR FROM a3.activity_date) = 2026 
        GROUP BY a3.runner_id 
    ) hr_sub 
) 
AND AVG(tt.avg_power_per_activity) > ( 
    SELECT AVG(runner_avg_power) 
    FROM ( 
        SELECT 
            a4.runner_id, 
            AVG(tt4.avg_power_per_activity) AS runner_avg_power 
        FROM Activities a4 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(running_power) AS avg_power_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt4 
            ON a4.activity_id = tt4.activity_id 
        WHERE EXTRACT(YEAR FROM a4.activity_date) = 2026 
        GROUP BY a4.runner_id 
    ) power_sub 
) 
ORDER BY total_distance_km DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q1', 'TYPICAL'));

PROMPT --- EXECUTION 1 ---

SET TIMING ON

SELECT    
    r.runner_id, 
    r.full_name, 
    SUM(ro.distance_km) AS total_distance_km, 
    ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate, 
    ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace, 
    ROUND(AVG(tt.avg_power_per_activity), 2) AS avg_running_power, 
    COUNT(a.activity_id) AS total_activities 
FROM Runners r   
JOIN Activities a  
    ON r.runner_id = a.runner_id   
JOIN Routes ro  
    ON a.route_id = ro.route_id 
JOIN ( 
    SELECT 
        activity_id, 
        AVG(heart_rate_bpm) AS avg_hr_per_activity, 
        AVG(pace) AS avg_pace_per_activity, 
        AVG(running_power) AS avg_power_per_activity 
    FROM Telemetry_Data 
    GROUP BY activity_id 
) tt 
    ON a.activity_id = tt.activity_id 
WHERE EXTRACT(YEAR FROM a.activity_date) = 2026   
  AND r.sex = 'Male' 
  AND r.weight_kg < 90 
  AND r.join_date > (SYSDATE - 100) 
  AND ro.difficulty_level >= 3 
GROUP BY   
    r.runner_id, 
    r.full_name 
HAVING SUM(ro.distance_km) > (   
    SELECT AVG(total_distance)   
    FROM (   
        SELECT  
            SUM(ro2.distance_km) AS total_distance 
        FROM Activities a2   
        JOIN Routes ro2  
            ON a2.route_id = ro2.route_id   
        JOIN Runners r2  
            ON a2.runner_id = r2.runner_id 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity, 
                AVG(pace) AS avg_pace_per_activity, 
                AVG(running_power) AS avg_power_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt2 
            ON a2.activity_id = tt2.activity_id 
        WHERE EXTRACT(YEAR FROM a2.activity_date) = 2026  
          AND r2.sex = 'Male' 
          AND r2.weight_kg < 90 
        GROUP BY a2.runner_id 
    ) dist_sub 
) 
AND AVG(tt.avg_hr_per_activity) < ( 
    SELECT AVG(runner_avg_hr) 
    FROM ( 
        SELECT 
            a3.runner_id, 
            AVG(tt3.avg_hr_per_activity) AS runner_avg_hr 
        FROM Activities a3 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt3 
            ON a3.activity_id = tt3.activity_id 
        WHERE EXTRACT(YEAR FROM a3.activity_date) = 2026 
        GROUP BY a3.runner_id 
    ) hr_sub 
) 
AND AVG(tt.avg_power_per_activity) > ( 
    SELECT AVG(runner_avg_power) 
    FROM ( 
        SELECT 
            a4.runner_id, 
            AVG(tt4.avg_power_per_activity) AS runner_avg_power 
        FROM Activities a4 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(running_power) AS avg_power_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt4 
            ON a4.activity_id = tt4.activity_id 
        WHERE EXTRACT(YEAR FROM a4.activity_date) = 2026 
        GROUP BY a4.runner_id 
    ) power_sub 
) 
ORDER BY total_distance_km DESC;

SET TIMING OFF


-- ==========================================
-- QUERY 2
-- ==========================================
PROMPT --- QUERY PLAN 2 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q2' FOR

SELECT     
    r.runner_id,  
    r.full_name,    
    SUM(ro.distance_km) AS total_distance_km,    
    COUNT(DISTINCT ra.runner_achievement_id) AS total_achievements, 
    ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate, 
    ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace 
FROM Runners r    
JOIN Activities a   
    ON r.runner_id = a.runner_id    
JOIN Routes ro   
    ON a.route_id = ro.route_id    
LEFT JOIN Runner_Achievements ra   
    ON r.runner_id = ra.runner_id    
LEFT JOIN Shoes s   
    ON a.runner_id = s.runner_id 
JOIN ( 
    SELECT 
        activity_id, 
        AVG(heart_rate_bpm) AS avg_hr_per_activity, 
        AVG(pace) AS avg_pace_per_activity 
    FROM Telemetry_Data 
    GROUP BY activity_id 
) tt 
    ON a.activity_id = tt.activity_id 
WHERE EXTRACT(YEAR FROM a.activity_date) = 2026    
  AND r.height > 175  
  AND s.model LIKE 'Nike%'  
  AND ro.elevation_gain > 10  
GROUP BY    
    r.runner_id,  
    r.full_name    
HAVING SUM(ro.distance_km) > (    
    SELECT AVG(total_distance)    
    FROM (    
        SELECT  
            SUM(ro2.distance_km) AS total_distance    
        FROM Activities a2    
        JOIN Routes ro2   
            ON a2.route_id = ro2.route_id 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity, 
                AVG(pace) AS avg_pace_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt2 
            ON a2.activity_id = tt2.activity_id 
        WHERE EXTRACT(YEAR FROM a2.activity_date) = 2026    
        GROUP BY a2.runner_id    
    ) dist_sub 
)    
AND AVG(tt.avg_hr_per_activity) < ( 
    SELECT AVG(runner_avg_hr) 
    FROM ( 
        SELECT 
            a3.runner_id, 
            AVG(tt3.avg_hr_per_activity) AS runner_avg_hr 
        FROM Activities a3 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt3 
            ON a3.activity_id = tt3.activity_id 
        WHERE EXTRACT(YEAR FROM a3.activity_date) = 2026 
        GROUP BY a3.runner_id 
    ) hr_sub 
) 
ORDER BY total_distance_km DESC 
FETCH FIRST 10 ROWS ONLY;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q2', 'TYPICAL'));

PROMPT --- EXECUTION 2 ---

SET TIMING ON

SELECT     
    r.runner_id,  
    r.full_name,    
    SUM(ro.distance_km) AS total_distance_km,    
    COUNT(DISTINCT ra.runner_achievement_id) AS total_achievements, 
    ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate, 
    ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace 
FROM Runners r    
JOIN Activities a   
    ON r.runner_id = a.runner_id    
JOIN Routes ro   
    ON a.route_id = ro.route_id    
LEFT JOIN Runner_Achievements ra   
    ON r.runner_id = ra.runner_id    
LEFT JOIN Shoes s   
    ON a.runner_id = s.runner_id 
JOIN ( 
    SELECT 
        activity_id, 
        AVG(heart_rate_bpm) AS avg_hr_per_activity, 
        AVG(pace) AS avg_pace_per_activity 
    FROM Telemetry_Data 
    GROUP BY activity_id 
) tt 
    ON a.activity_id = tt.activity_id 
WHERE EXTRACT(YEAR FROM a.activity_date) = 2026    
  AND r.height > 175  
  AND s.model LIKE 'Nike%'  
  AND ro.elevation_gain > 10  
GROUP BY    
    r.runner_id,  
    r.full_name    
HAVING SUM(ro.distance_km) > (    
    SELECT AVG(total_distance)    
    FROM (    
        SELECT  
            SUM(ro2.distance_km) AS total_distance    
        FROM Activities a2    
        JOIN Routes ro2   
            ON a2.route_id = ro2.route_id 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity, 
                AVG(pace) AS avg_pace_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt2 
            ON a2.activity_id = tt2.activity_id 
        WHERE EXTRACT(YEAR FROM a2.activity_date) = 2026    
        GROUP BY a2.runner_id    
    ) dist_sub 
)    
AND AVG(tt.avg_hr_per_activity) < ( 
    SELECT AVG(runner_avg_hr) 
    FROM ( 
        SELECT 
            a3.runner_id, 
            AVG(tt3.avg_hr_per_activity) AS runner_avg_hr 
        FROM Activities a3 
        JOIN ( 
            SELECT 
                activity_id, 
                AVG(heart_rate_bpm) AS avg_hr_per_activity 
            FROM Telemetry_Data 
            GROUP BY activity_id 
        ) tt3 
            ON a3.activity_id = tt3.activity_id 
        WHERE EXTRACT(YEAR FROM a3.activity_date) = 2026 
        GROUP BY a3.runner_id 
    ) hr_sub 
) 
ORDER BY total_distance_km DESC 
FETCH FIRST 10 ROWS ONLY;

SET TIMING OFF

-- ==========================================
-- QUERY 3
-- ==========================================
PROMPT --- QUERY PLAN 3 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q3' FOR

SELECT *
FROM (
    SELECT      
        r.runner_id,   
        r.full_name,     
        SUM(ro.distance_km) AS total_distance_km,     
        COUNT(DISTINCT ra.runner_achievement_id) AS total_achievements,  
        ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate,  
        ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace,
        ROUND(AVG(tt.avg_power_per_activity), 2) AS avg_running_power,
        DENSE_RANK() OVER (ORDER BY SUM(ro.distance_km) DESC) AS distance_rank
    FROM Runners r     
    JOIN Activities a    
        ON r.runner_id = a.runner_id     
    JOIN Routes ro    
        ON a.route_id = ro.route_id     
    LEFT JOIN Runner_Achievements ra    
        ON r.runner_id = ra.runner_id     
    LEFT JOIN Shoes s    
        ON a.runner_id = s.runner_id  
    JOIN (  
        SELECT  
            activity_id,  
            AVG(heart_rate_bpm) AS avg_hr_per_activity,  
            AVG(pace) AS avg_pace_per_activity,
            AVG(running_power) AS avg_power_per_activity
        FROM Telemetry_Data  
        GROUP BY activity_id  
    ) tt  
        ON a.activity_id = tt.activity_id  
    WHERE EXTRACT(YEAR FROM a.activity_date) = 2026     
      AND r.height > 175   
      AND s.model LIKE 'Nike%'   
      AND ro.elevation_gain > 10   
    GROUP BY     
        r.runner_id,   
        r.full_name     
) ranked
WHERE distance_rank <= 10
  AND avg_heart_rate > (
      SELECT AVG(avg_hr_per_activity)
      FROM (
          SELECT AVG(heart_rate_bpm) AS avg_hr_per_activity
          FROM Telemetry_Data
          GROUP BY activity_id
      ) hr_avg_sub
  )
  AND avg_running_power > (
      SELECT AVG(avg_power_per_activity)
      FROM (
          SELECT AVG(running_power) AS avg_power_per_activity
          FROM Telemetry_Data
          GROUP BY activity_id
      ) power_avg_sub
  )
ORDER BY total_distance_km DESC, avg_running_power DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q3', 'TYPICAL'));

PROMPT --- EXECUTION 3 ---

SET TIMING ON

SELECT *
FROM (
    SELECT      
        r.runner_id,   
        r.full_name,     
        SUM(ro.distance_km) AS total_distance_km,     
        COUNT(DISTINCT ra.runner_achievement_id) AS total_achievements,  
        ROUND(AVG(tt.avg_hr_per_activity), 2) AS avg_heart_rate,  
        ROUND(AVG(tt.avg_pace_per_activity), 2) AS avg_pace,
        ROUND(AVG(tt.avg_power_per_activity), 2) AS avg_running_power,
        DENSE_RANK() OVER (ORDER BY SUM(ro.distance_km) DESC) AS distance_rank
    FROM Runners r     
    JOIN Activities a    
        ON r.runner_id = a.runner_id     
    JOIN Routes ro    
        ON a.route_id = ro.route_id     
    LEFT JOIN Runner_Achievements ra    
        ON r.runner_id = ra.runner_id     
    LEFT JOIN Shoes s    
        ON a.runner_id = s.runner_id  
    JOIN (  
        SELECT  
            activity_id,  
            AVG(heart_rate_bpm) AS avg_hr_per_activity,  
            AVG(pace) AS avg_pace_per_activity,
            AVG(running_power) AS avg_power_per_activity
        FROM Telemetry_Data  
        GROUP BY activity_id  
    ) tt  
        ON a.activity_id = tt.activity_id  
    WHERE EXTRACT(YEAR FROM a.activity_date) = 2026     
      AND r.height > 175   
      AND s.model LIKE 'Nike%'   
      AND ro.elevation_gain > 10   
    GROUP BY     
        r.runner_id,   
        r.full_name     
) ranked
WHERE distance_rank <= 10
  AND avg_heart_rate > (
      SELECT AVG(avg_hr_per_activity)
      FROM (
          SELECT AVG(heart_rate_bpm) AS avg_hr_per_activity
          FROM Telemetry_Data
          GROUP BY activity_id
      ) hr_avg_sub
  )
  AND avg_running_power > (
      SELECT AVG(avg_power_per_activity)
      FROM (
          SELECT AVG(running_power) AS avg_power_per_activity
          FROM Telemetry_Data
          GROUP BY activity_id
      ) power_avg_sub
  )
ORDER BY total_distance_km DESC, avg_running_power DESC;

SET TIMING OFF


-- ==========================================
-- QUERY 4
-- ==========================================
PROMPT --- QUERY PLAN 4 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q4' FOR

INSERT INTO Activities ( 
    activity_id, runner_id, route_id, activity_type,  
    duration_min, activity_date, avg_bpm, max_bpm, min_bpm 
) 
SELECT  
    -- 1. Generujemy nowe ID na podstawie aktualnego MAX + licznik wierszy 
    (SELECT MAX(activity_id) FROM Activities) + ROWNUM, 
    501,  
    10,  
    'Smartwatch Sync',  
    45,  
    CURRENT_DATE, 
    -- 2. Wchodzimy do bazy Telemetry_data i zmuszamy ja 
    -- Do grupowania i agregacje na dużej tabeli ~1 sekund 
    stats.avg_hr, 
    stats.max_hr, 
    stats.min_hr 
FROM ( 
    SELECT  
        ROUND(AVG(heart_rate_bpm)) as avg_hr, 
        MAX(heart_rate_bpm) as max_hr, 
        MIN(heart_rate_bpm) as min_hr 
    FROM Telemetry_Data 
    -- Brak indeksu na tym warunku lub wymuszenie skanowania dużej części tabeli 
    WHERE activity_id IS NOT NULL  
    GROUP BY TRUNC(heart_rate_bpm / 10) -- Sztuczne pogrupowanie co 10 jednostek  
    HAVING COUNT(*) > 100 
    ORDER BY 1 DESC 
) stats 
-- 3. Ograniczenie do 21 wierszy, które zostaną wstawione (grupy sa co 10 wiec nawet wiecej grup nie bedzie) 
-- Jest to dodatkowe zabezpieczenie przed błędnymi danymi jakby np tetno wynosilo 400 
WHERE ROWNUM <= 21;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q4', 'TYPICAL'));

PROMPT --- EXECUTION 4 ---

SET TIMING ON

INSERT INTO Activities ( 
    activity_id, runner_id, route_id, activity_type,  
    duration_min, activity_date, avg_bpm, max_bpm, min_bpm 
) 
SELECT  
    -- 1. Generujemy nowe ID na podstawie aktualnego MAX + licznik wierszy 
    (SELECT MAX(activity_id) FROM Activities) + ROWNUM, 
    501,  
    10,  
    'Smartwatch Sync',  
    45,  
    CURRENT_DATE, 
    -- 2. Wchodzimy do bazy Telemetry_data i zmuszamy ja 
    -- Do grupowania i agregacje na dużej tabeli ~1 sekund 
    stats.avg_hr, 
    stats.max_hr, 
    stats.min_hr 
FROM ( 
    SELECT  
        ROUND(AVG(heart_rate_bpm)) as avg_hr, 
        MAX(heart_rate_bpm) as max_hr, 
        MIN(heart_rate_bpm) as min_hr 
    FROM Telemetry_Data 
    -- Brak indeksu na tym warunku lub wymuszenie skanowania dużej części tabeli 
    WHERE activity_id IS NOT NULL  
    GROUP BY TRUNC(heart_rate_bpm / 10) -- Sztuczne pogrupowanie co 10 jednostek  
    HAVING COUNT(*) > 100 
    ORDER BY 1 DESC 
) stats 
-- 3. Ograniczenie do 21 wierszy, które zostaną wstawione (grupy sa co 10 wiec nawet wiecej grup nie bedzie) 
-- Jest to dodatkowe zabezpieczenie przed błędnymi danymi jakby np tetno wynosilo 400 
WHERE ROWNUM <= 21;

SET TIMING OFF

-- ==========================================
-- QUERY 5
-- ==========================================
PROMPT --- QUERY PLAN 5 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q5' FOR

UPDATE Training_Goals tg
SET 
    tg.current_value = (
        SELECT SUM(ro.distance_km)
        FROM Activities a
        JOIN Routes ro 
            ON a.route_id = ro.route_id
        WHERE a.runner_id = tg.runner_id
          AND a.activity_date BETWEEN (tg.deadline - 30) AND tg.deadline
          AND (
              SELECT AVG(SQRT(heart_rate_bpm))
              FROM Telemetry_Data
              WHERE ROWNUM < 500
          ) > 0
    ),
    tg.status = CASE
        WHEN (
            SELECT SUM(ro2.distance_km)
            FROM Activities a2
            JOIN Routes ro2 
                ON a2.route_id = ro2.route_id
            WHERE a2.runner_id = tg.runner_id
              AND a2.activity_date BETWEEN (tg.deadline - 30) AND tg.deadline
              AND (
                  SELECT COUNT(LOG(10, footsteps))
                  FROM Telemetry_Data
                  WHERE ROWNUM < 1000
              ) >= 0
        ) >= tg.target_value
        THEN 1
        ELSE 0
    END
WHERE tg.runner_id IN (
    SELECT r.runner_id
    FROM Runners r
    WHERE r.join_date < SYSDATE
      AND (
          SELECT SUM(a3.duration_min)
          FROM Activities a3
          WHERE a3.runner_id = r.runner_id
      ) > 0
);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q5', 'TYPICAL'));

PROMPT --- EXECUTION 5 ---

SET TIMING ON

UPDATE Training_Goals tg
SET 
    tg.current_value = (
        SELECT SUM(ro.distance_km)
        FROM Activities a
        JOIN Routes ro 
            ON a.route_id = ro.route_id
        WHERE a.runner_id = tg.runner_id
          AND a.activity_date BETWEEN (tg.deadline - 30) AND tg.deadline
          AND (
              SELECT AVG(SQRT(heart_rate_bpm))
              FROM Telemetry_Data
              WHERE ROWNUM < 500
          ) > 0
    ),
    tg.status = CASE
        WHEN (
            SELECT SUM(ro2.distance_km)
            FROM Activities a2
            JOIN Routes ro2 
                ON a2.route_id = ro2.route_id
            WHERE a2.runner_id = tg.runner_id
              AND a2.activity_date BETWEEN (tg.deadline - 30) AND tg.deadline
              AND (
                  SELECT COUNT(LOG(10, footsteps))
                  FROM Telemetry_Data
                  WHERE ROWNUM < 1000
              ) >= 0
        ) >= tg.target_value
        THEN 1
        ELSE 0
    END
WHERE tg.runner_id IN (
    SELECT r.runner_id
    FROM Runners r
    WHERE r.join_date < SYSDATE
      AND (
          SELECT SUM(a3.duration_min)
          FROM Activities a3
          WHERE a3.runner_id = r.runner_id
      ) > 0
);
SET TIMING OFF

-- ==========================================
-- QUERY 6
-- ==========================================
PROMPT --- QUERY PLAN 6 ---

EXPLAIN PLAN SET STATEMENT_ID = 'Q6' FOR

DELETE FROM Telemetry_Data
WHERE activity_id IN (
    WITH telemetry_agg AS (
        SELECT
            td.activity_id,
            AVG(td.heart_rate_bpm) AS avg_hr,
            AVG(td.pace) AS avg_pace,
            AVG(td.running_power) AS avg_power
        FROM Telemetry_Data td
        GROUP BY td.activity_id
    ),
    candidate_activities AS (
        SELECT
            a.activity_id
        FROM Activities a
        JOIN Runners r
            ON a.runner_id = r.runner_id
        JOIN Routes ro
            ON a.route_id = ro.route_id
        JOIN telemetry_agg ta
            ON a.activity_id = ta.activity_id
        WHERE EXTRACT(YEAR FROM a.activity_date) = 2026
          AND r.sex = 'Male'
          AND r.weight_kg < 90
          AND ro.difficulty_level >= 3
          AND ta.avg_hr > (SELECT AVG(avg_hr) FROM telemetry_agg)
          AND ta.avg_power > (SELECT AVG(avg_power) FROM telemetry_agg)
    )
    SELECT activity_id
    FROM candidate_activities
);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'Q6', 'TYPICAL'));

PROMPT --- EXECUTION 6 ---

SET TIMING ON

DELETE FROM Telemetry_Data
WHERE activity_id IN (
    WITH telemetry_agg AS (
        SELECT
            td.activity_id,
            AVG(td.heart_rate_bpm) AS avg_hr,
            AVG(td.pace) AS avg_pace,
            AVG(td.running_power) AS avg_power
        FROM Telemetry_Data td
        GROUP BY td.activity_id
    ),
    candidate_activities AS (
        SELECT
            a.activity_id
        FROM Activities a
        JOIN Runners r
            ON a.runner_id = r.runner_id
        JOIN Routes ro
            ON a.route_id = ro.route_id
        JOIN telemetry_agg ta
            ON a.activity_id = ta.activity_id
        WHERE EXTRACT(YEAR FROM a.activity_date) = 2026
          AND r.sex = 'Male'
          AND r.weight_kg < 90
          AND ro.difficulty_level >= 3
          AND ta.avg_hr > (SELECT AVG(avg_hr) FROM telemetry_agg)
          AND ta.avg_power > (SELECT AVG(avg_power) FROM telemetry_agg)
    )
    SELECT activity_id
    FROM candidate_activities
);

SET TIMING OFF

ROLLBACK;

PROMPT ==========================================
PROMPT WORKLOAD BENCHMARK END
PROMPT ==========================================

SPOOL OFF

