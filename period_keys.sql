BEGIN
/** function wide structure definition 

result_table:
    "InputDate" date,
    "PeriodKey" int,
    "ResultDate" date,
    "ResultDateStr" nvarchar(8)

**/
DECLARE lv_monday_current  DATE; -- Monday of current week
DECLARE lv_monday_previous DATE; -- Monday of previous week
DECLARE lv_1st_day_last_month DATE; -- first day of previous month
DECLARE lv_1st_current_month DATE; -- first day of the current month


/** PERIODKEY 1: Previous Week **/
lv_monday_current = ADD_DAYS(:INPUTDATE, -WEEKDAY(:INPUTDATE));
-- Weekday delivers the current weekday

lv_monday_previous = ADD_DAYS(:lv_monday_current, -7);

lt_previous_week =
SELECT
    :inputdate                      AS "InputDate",
    1                               AS "PeriodKey", -- PeriodKey: previous week
    "GENERATED_PERIOD_START"        AS "ResultDate",
    to_nvarchar("GENERATED_PERIOD_START",
                    'YYYYMMDD') AS "ResultDateStr"
FROM SERIES_GENERATE_DATE('INTERVAL 1 DAY',
                    :lv_monday_previous, :lv_monday_current);
                    /** we use :monday_current as end date because
                     * GENERATED_PERIOD_START date does not contain the final
                     * date itself, hence we go 1 day further **/
/** END PERIODKEY 1: Previous Week **/
/** PERIODKEY 2: Previous Month **/
lv_1st_day_last_month = ADD_DAYS(LAST_DAY(ADD_MONTHS(:INPUTDATE, -2)), 1);
-- we subtract to the last day of two months ago and add 1 day

lv_1st_current_month = ADD_DAYS(:INPUTDATE, 1 - DAYOFMONTH(:INPUTDATE));
-- we subtract 1 day less than DAYOFMONTH from INPUTDATE to get the 1st day

lt_previous_month =
SELECT
    :inputdate                      AS "InputDate",
    2                               AS "PeriodKey", -- PeriodKey: previous week
    "GENERATED_PERIOD_START"        AS "ResultDate",
    to_nvarchar("GENERATED_PERIOD_START",
                    'YYYYMMDD') AS "ResultDateStr"
FROM SERIES_GENERATE_DATE('INTERVAL 1 DAY',
                    :lv_1st_day_last_month, :lv_1st_current_month);
/** END PERIODKEY 2: Previous Month **/

-- result will be returned here
RETURN
SELECT
    "InputDate" AS "InputDate",
    "PeriodKey" AS "PeriodKey",
    "ResultDate" AS "ResultDate",
    "ResultDateStr" AS "ResultDateStr"
FROM :lt_previous_week
UNION ALL
SELECT
    "InputDate" AS "InputDate",
    "PeriodKey" AS "PeriodKey",
    "ResultDate" AS "ResultDate",
    "ResultDateStr" AS "ResultDateStr"
FROM :lt_previous_month;
END;
