 -- object store offers only limited date and timestamp sql functions from HANA
 -- this conversion is a workaround
CASE
    WHEN SUBSTRING(CAST(PerformancePeriodStartDate as STRING), 5, 2) BETWEEN '01' AND '12'
    AND SUBSTRING(CAST(PerformancePeriodStartDate as STRING), 7, 2) BETWEEN '01' AND
        CASE
            WHEN SUBSTRING(CAST(PerformancePeriodStartDate as STRING), 5, 2) IN ('01', '03', '05', '07', '08', '10', '12') THEN '31'
            WHEN SUBSTRING(CAST(PerformancePeriodStartDate as STRING), 5, 2) IN ('04', '06', '09', '11') THEN '30'
            WHEN SUBSTRING(CAST(PerformancePeriodStartDate as STRING), 5, 2) = '02' THEN
                CASE
                    WHEN MOD(CAST(SUBSTRING(CAST(PerformancePeriodStartDate as STRING), 1, 4) as INTEGER), 4) = 0 THEN '29'
                    ELSE '28'
                END
        END
    THEN Cast(PerformancePeriodStartDate as DATE)
    ELSE Cast('19700101' as DATE)
END
