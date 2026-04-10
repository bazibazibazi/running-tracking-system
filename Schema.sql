--------------------------------------------------------
--  File created - Friday-April-10-2026   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table ACHIEVEMENTS_TYPES
--------------------------------------------------------

  CREATE TABLE "FITNESS"."ACHIEVEMENTS_TYPES" ("ACHIEVEMENT_TYPE_ID" NUMBER, "NAME" VARCHAR2(255 BYTE), "DESCRIPTION" VARCHAR2(255 BYTE), "CONDITION_TYPE" VARCHAR2(255 BYTE), "VALUE" NUMBER) ;
--------------------------------------------------------
--  DDL for Table ACTIVITIES
--------------------------------------------------------

  CREATE TABLE "FITNESS"."ACTIVITIES" ("ACTIVITY_ID" NUMBER, "RUNNER_ID" NUMBER, "ROUTE_ID" NUMBER, "ACTIVITY_TYPE" VARCHAR2(255 BYTE), "DURATION_MIN" NUMBER, "ACTIVITY_DATE" DATE, "AVG_BPM" NUMBER, "MAX_BPM" NUMBER, "MIN_BPM" NUMBER) ;
--------------------------------------------------------
--  DDL for Table ROUTES
--------------------------------------------------------

  CREATE TABLE "FITNESS"."ROUTES" ("ROUTE_ID" NUMBER, "DISTANCE_KM" NUMBER, "CREATION_DATE" DATE, "ELEVATION_GAIN" NUMBER, "SURFACE_TYPE" VARCHAR2(255 BYTE), "DIFFICULTY_LEVEL" NUMBER) ;
--------------------------------------------------------
--  DDL for Table RUNNERS
--------------------------------------------------------

  CREATE TABLE "FITNESS"."RUNNERS" ("RUNNER_ID" NUMBER, "FULL_NAME" VARCHAR2(255 BYTE), "SEX" VARCHAR2(255 BYTE), "WEIGHT_KG" NUMBER, "HEIGHT" NUMBER, "JOIN_DATE" DATE, "BIRTHDAY_DATE" DATE) ;
--------------------------------------------------------
--  DDL for Table RUNNER_ACHIEVEMENTS
--------------------------------------------------------

  CREATE TABLE "FITNESS"."RUNNER_ACHIEVEMENTS" ("RUNNER_ACHIEVEMENT_ID" NUMBER, "RUNNER_ID" NUMBER, "ACHIEVEMENT_TYPE_ID" NUMBER, "DATE_EARNED" DATE, "ACTIVITY_ID" NUMBER) ;
--------------------------------------------------------
--  DDL for Table SHOES
--------------------------------------------------------

  CREATE TABLE "FITNESS"."SHOES" ("SHOE_ID" NUMBER, "RUNNER_ID" NUMBER, "SHOE_USES" NUMBER, "PURCHASE_DATE" DATE, "MODEL" VARCHAR2(255 BYTE), "SHOE_SIZE" NUMBER, "RECOMMENDED_USAGE" NUMBER) ;
--------------------------------------------------------
--  DDL for Table TELEMETRY_DATA
--------------------------------------------------------

  CREATE TABLE "FITNESS"."TELEMETRY_DATA" ("TELEMETRY_ID" NUMBER, "ACTIVITY_ID" NUMBER, "HEART_RATE_BPM" NUMBER, "GPS_LOCATION" VARCHAR2(255 BYTE), "RECORDED_TIME" DATE, "PACE" NUMBER, "RUNNING_POWER" NUMBER, "FOOTSTEPS" NUMBER) ;
--------------------------------------------------------
--  DDL for Table TRAINING_GOALS
--------------------------------------------------------

  CREATE TABLE "FITNESS"."TRAINING_GOALS" ("GOAL_ID" NUMBER, "RUNNER_ID" NUMBER, "GOAL_NAME" VARCHAR2(255 BYTE), "TARGET_VALUE" NUMBER, "CURRENT_VALUE" NUMBER, "DEADLINE" DATE, "STATUS" NUMBER, "GOAL_DESCRIPTION" VARCHAR2(255 BYTE)) ;
--------------------------------------------------------
--  Constraints for Table ACTIVITIES
--------------------------------------------------------

  ALTER TABLE "FITNESS"."ACTIVITIES" ADD PRIMARY KEY ("ACTIVITY_ID") USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table ACHIEVEMENTS_TYPES
--------------------------------------------------------

  ALTER TABLE "FITNESS"."ACHIEVEMENTS_TYPES" ADD PRIMARY KEY ("ACHIEVEMENT_TYPE_ID") USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table RUNNER_ACHIEVEMENTS
--------------------------------------------------------

  ALTER TABLE "FITNESS"."RUNNER_ACHIEVEMENTS" ADD PRIMARY KEY ("RUNNER_ACHIEVEMENT_ID") USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table TRAINING_GOALS
--------------------------------------------------------

  ALTER TABLE "FITNESS"."TRAINING_GOALS" ADD PRIMARY KEY ("GOAL_ID") USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table RUNNERS
--------------------------------------------------------

  ALTER TABLE "FITNESS"."RUNNERS" ADD PRIMARY KEY ("RUNNER_ID") USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table TELEMETRY_DATA
--------------------------------------------------------

  ALTER TABLE "FITNESS"."TELEMETRY_DATA" ADD PRIMARY KEY ("TELEMETRY_ID") USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table ROUTES
--------------------------------------------------------

  ALTER TABLE "FITNESS"."ROUTES" ADD PRIMARY KEY ("ROUTE_ID") USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table SHOES
--------------------------------------------------------

  ALTER TABLE "FITNESS"."SHOES" ADD PRIMARY KEY ("SHOE_ID") USING INDEX  ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table ACTIVITIES
--------------------------------------------------------

  ALTER TABLE "FITNESS"."ACTIVITIES" ADD CONSTRAINT "FK_ACTIVITIES_RUNNER" FOREIGN KEY ("RUNNER_ID") REFERENCES "FITNESS"."RUNNERS" ("RUNNER_ID") ENABLE;
  ALTER TABLE "FITNESS"."ACTIVITIES" ADD CONSTRAINT "FK_ACTIVITIES_ROUTE" FOREIGN KEY ("ROUTE_ID") REFERENCES "FITNESS"."ROUTES" ("ROUTE_ID") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table RUNNER_ACHIEVEMENTS
--------------------------------------------------------

  ALTER TABLE "FITNESS"."RUNNER_ACHIEVEMENTS" ADD CONSTRAINT "FK_RUNNER_ACH_RUNNER" FOREIGN KEY ("RUNNER_ID") REFERENCES "FITNESS"."RUNNERS" ("RUNNER_ID") ENABLE;
  ALTER TABLE "FITNESS"."RUNNER_ACHIEVEMENTS" ADD CONSTRAINT "FK_RUNNER_ACH_TYPE" FOREIGN KEY ("ACHIEVEMENT_TYPE_ID") REFERENCES "FITNESS"."ACHIEVEMENTS_TYPES" ("ACHIEVEMENT_TYPE_ID") ENABLE;
  ALTER TABLE "FITNESS"."RUNNER_ACHIEVEMENTS" ADD CONSTRAINT "FK_RUNNER_ACH_ACTIVITY" FOREIGN KEY ("ACTIVITY_ID") REFERENCES "FITNESS"."ACTIVITIES" ("ACTIVITY_ID") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table SHOES
--------------------------------------------------------

  ALTER TABLE "FITNESS"."SHOES" ADD CONSTRAINT "FK_SHOES_RUNNER" FOREIGN KEY ("RUNNER_ID") REFERENCES "FITNESS"."RUNNERS" ("RUNNER_ID") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table TELEMETRY_DATA
--------------------------------------------------------

  ALTER TABLE "FITNESS"."TELEMETRY_DATA" ADD CONSTRAINT "FK_TELEMETRY_ACTIVITY" FOREIGN KEY ("ACTIVITY_ID") REFERENCES "FITNESS"."ACTIVITIES" ("ACTIVITY_ID") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table TRAINING_GOALS
--------------------------------------------------------

  ALTER TABLE "FITNESS"."TRAINING_GOALS" ADD CONSTRAINT "FK_GOALS_RUNNER" FOREIGN KEY ("RUNNER_ID") REFERENCES "FITNESS"."RUNNERS" ("RUNNER_ID") ENABLE;
