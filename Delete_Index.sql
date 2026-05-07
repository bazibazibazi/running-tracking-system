PROMPT =========================================
PROMPT DROPPING INDEXES
PROMPT =========================================

DROP INDEX idx_activities_runner_id;
DROP INDEX idx_telemetry_activity_id;
DROP INDEX idx_activities_type;
DROP INDEX idx_activity_year;

BEGIN
    DBMS_STATS.GATHER_SCHEMA_STATS(USER);
END;
/