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
DECLARE lv_year_current INT; -- current year
DECLARE lv_py_inputdate DATE; -- input date in previous year
DECLARE lv_py_monday_current_week DATE; -- PY Monday current week
DECLARE lv_last_day_current_month DATE; -- last day of current month
DECLARE lv_1st_current_year DATE; -- first day of current year
DECLARE lv_1st_py_year DATE; -- first day of previous year
DECLARE lv_last_day_current_year DATE; -- last day of current year


/** find the date in the previous year **/
lv_py_inputdate =
CASE
    WHEN YEAR(:INPUTDATE) > 2000
        THEN ADD_DAYS(:INPUTDATE, -364)
        ELSE :INPUTDATE
END;
/** find the date in the previous year **/

/** first day of current year **/
lv_1st_current_year = ADD_DAYS(:INPUTDATE, 1 - DAYOFYEAR(:INPUTDATE));
/** first day of current year **/

/** find first day of current month **/
lv_1st_current_month = ADD_DAYS(:INPUTDATE, 1 - DAYOFMONTH(:INPUTDATE));
-- we subtract 1 day less than DAYOFMONTH from INPUTDATE to get the 1st day
/** find first day of current month **/

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

/** PERIODKEY 3: Previous Day **/

lt_periodKey_3 = 
SELECT
    :inputdate                      AS "InputDate",
    3                               AS "PeriodKey", -- PeriodKey: previous day
    "GENERATED_PERIOD_START"        AS "ResultDate",
    TO_NVARCHAR("GENERATED_PERIOD_START",
                    'YYYYMMDD') AS "ResultDateStr"
FROM SERIES_GENERATE_DATE('INTERVAL 1 DAY',
                    ADD_DAYS(:INPUTDATE, -1), :INPUTDATE);
/** END PERIODKEY 3: Previous Day **/

/** PERIODKEY 4: Previous Year Day **/
lv_year_current = YEAR(:INPUTDATE);
lt_periodKey_4 = 
SELECT
    :inputdate                      AS "InputDate",
    4                               AS "PeriodKey", -- PeriodKey: previous day
    "GENERATED_PERIOD_START" AS "ResultDate",
    TO_NVARCHAR("GENERATED_PERIOD_START", 'YYYYMMDD') AS "ResultDateStr"
FROM SERIES_GENERATE_DATE('INTERVAL 1 DAY',
                    lv_py_inputdate,
                    ADD_DAYS(lv_py_inputdate, 1));
/** END PERIODKEY 4: Previous Year Day **/

/** PERIODKEY 13: Current Week to Date **/
lt_periodKey_13 = 
SELECT
    :inputdate                      AS "InputDate",
    13                              AS "PeriodKey", -- PeriodKey: previous day
    "GENERATED_PERIOD_START"        AS "ResultDate",
    TO_NVARCHAR("GENERATED_PERIOD_START",
                    'YYYYMMDD') AS "ResultDateStr"
FROM SERIES_GENERATE_DATE('INTERVAL 1 DAY',
                    lv_monday_current, ADD_DAYS(:INPUTDATE, 1));
/** END PERIODKEY 13: Current Week to Date **/

/** PeriodKey 14: PY Current week to date **/
lv_py_monday_current_week = ADD_DAYS(:lv_py_inputdate, -WEEKDAY(lv_py_inputdate));
lt_periodKey_14 = 
SELECT
    :inputdate                      AS "InputDate",
    14                               AS "PeriodKey", -- PeriodKey: previous day
    "GENERATED_PERIOD_START" AS "ResultDate",
    TO_NVARCHAR("GENERATED_PERIOD_START", 'YYYYMMDD') AS "ResultDateStr"
FROM SERIES_GENERATE_DATE('INTERVAL 1 DAY',
                    lv_py_monday_current_week,
                    ADD_DAYS(lv_py_inputdate, 1));
/** PeriodKey 14: PY Current week to date **/

/** PERIODKEY 23: current full week **/
lt_periodKey_23 = 
SELECT
    :inputdate                      AS "InputDate",
    23                              AS "PeriodKey", -- PeriodKey: previous day
    "GENERATED_PERIOD_START"        AS "ResultDate",
    TO_NVARCHAR("GENERATED_PERIOD_START",
                    'YYYYMMDD') AS "ResultDateStr"
FROM SERIES_GENERATE_DATE('INTERVAL 1 DAY',
                    lv_monday_current,
                    ADD_DAYS(lv_monday_current, 7));
/** END PERIODKEY 23: current full week **/

/** PeriodKey 34: PY Current month to date **/
lv_1st_current_month = ADD_DAYS(:INPUTDATE, 1 - DAYOFMONTH(:INPUTDATE));
lt_periodKey_34 = 
SELECT
    :inputdate                      AS "InputDate",
    34                              AS "PeriodKey", -- PeriodKey: previous day
    "GENERATED_PERIOD_START"        AS "ResultDate",
    TO_NVARCHAR("GENERATED_PERIOD_START",
                    'YYYYMMDD') AS "ResultDateStr"
FROM SERIES_GENERATE_DATE('INTERVAL 1 DAY',
                    lv_1st_current_month,
                    ADD_DAYS(:INPUTDATE, 1));
/** END PeriodKey 34: PY Current month to date **/

/** PeriodKey 53: Current month **/
lv_last_day_current_month = LAST_DAY(:INPUTDATE);
lt_periodKey_53 =
SELECT
    :inputdate                      AS "InputDate",
    53                              AS "PeriodKey", -- PeriodKey: previous day
    "GENERATED_PERIOD_START"        AS "ResultDate",
    TO_NVARCHAR("GENERATED_PERIOD_START",
                    'YYYYMMDD') AS "ResultDateStr"
FROM SERIES_GENERATE_DATE('INTERVAL 1 DAY',
                    lv_1st_current_month,
                    ADD_DAYS(lv_last_day_current_month,1));
/** END PeriodKey 53: Current month **/

/** PeriodKey 73: Current Year to date **/
lt_periodKey_73 =
SELECT
    :inputdate                      AS "InputDate",
    73                              AS "PeriodKey", -- PeriodKey: previous day
    "GENERATED_PERIOD_START"        AS "ResultDate",
    TO_NVARCHAR("GENERATED_PERIOD_START",
                    'YYYYMMDD') AS "ResultDateStr"
FROM SERIES_GENERATE_DATE('INTERVAL 1 DAY',
                    lv_1st_current_year,
                    ADD_DAYS(:INPUTDATE,1));
/** END PeriodKey 73: Current Year to date **/


/** PeriodKey 74: PY Current Year to date **/
lv_1st_py_year = ADD_DAYS(:lv_py_inputdate, 1 - DAYOFYEAR(:lv_py_inputdate));
lt_periodKey_74 =
SELECT
    :inputdate                      AS "InputDate",
    74                              AS "PeriodKey", -- PeriodKey: previous day
    "GENERATED_PERIOD_START"        AS "ResultDate",
    TO_NVARCHAR("GENERATED_PERIOD_START",
                    'YYYYMMDD') AS "ResultDateStr"
FROM SERIES_GENERATE_DATE('INTERVAL 1 DAY',
                    lv_1st_py_year,
                    ADD_DAYS(:lv_py_inputdate,1));
/** END PeriodKey 74: PY Current Year to date **/

/** PeriodKey 93: Current Year **/
lv_last_day_current_year = CONCAT(YEAR(:INPUTDATE), '-12-31');
lt_periodKey_93 =
SELECT
    :inputdate                      AS "InputDate",
    93                              AS "PeriodKey", -- PeriodKey: previous day
    "GENERATED_PERIOD_START"        AS "ResultDate",
    TO_NVARCHAR("GENERATED_PERIOD_START",
                    'YYYYMMDD') AS "ResultDateStr"
FROM SERIES_GENERATE_DATE('INTERVAL 1 DAY',
                    lv_1st_current_year,
                    ADD_DAYS(:lv_last_day_current_year,1));
/** END PeriodKey 93: Current Year **/

/** PeriodKey 113: Previous week **/

/** END PeriodKey 113: Previous week **/


/** PeriodKey 123: Previous 4 weeks **/
/** END PeriodKey 123: Previous 4 weeks **/

/** PeriodKey 133: Previous 8 weeks **/
/** END PeriodKey 133: Previous 8 weeks **/

/** PeriodKey 143: Previous 52 weeks **/
/** END PeriodKey 143: Previous 52 weeks **/

/** PeriodKey 153: Previous month **/
/** END PeriodKey 153: Previous month **/

/** PeriodKey 183: Current year closed months **/
/** END PeriodKey 183: Current year closed months **/

/** PeriodKey 203: Previous 13 weeks **/
/** END PeriodKey 203: Previous 13 weeks **/

-- result will be returned here
lt_union = 
SELECT *
FROM
:lt_previous_week -- PK: 1
UNION ALL
SELECT *
FROM
:lt_previous_month -- PK 2
UNION ALL
SELECT *
FROM
:lt_periodKey_3 -- previous day
UNION ALL
SELECT *
FROM
:lt_periodKey_4 -- previous year day
UNION ALL
SELECT *
FROM
:lt_periodKey_13 -- current week to date
UNION ALL
SELECT *
FROM
:lt_periodKey_14 -- PY day
UNION ALL
SELECT *
FROM
:lt_periodKey_23 -- current full week
UNION ALL
SELECT *
FROM
:lt_periodKey_34 -- PY current month date
UNION ALL
SELECT *
FROM
:lt_periodKey_53 -- current full month
UNION ALL
SELECT *
FROM
:lt_periodKey_73 -- year to date
UNION ALL
SELECT *
FROM
:lt_periodKey_74 -- previous year: year to date
UNION ALL
SELECT *
FROM
:lt_periodKey_93; -- previous year: year to date
RETURN
SELECT
    "InputDate" AS "InputDate",
    "PeriodKey" AS "PeriodKey",
    "ResultDate" AS "ResultDate",
    "ResultDateStr" AS "ResultDateStr"
FROM :lt_union;
END;
