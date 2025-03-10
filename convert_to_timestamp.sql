-- replace FieldDateTime with field to be checked
-- verify else-branch if error value matches expectation
-- 100-year and 400-year rule in leap year rules are ignored

CASE
    WHEN SUBSTRING(TO_VARCHAR(FieldDateTime), 5, 2) BETWEEN '01' AND '12'
    AND SUBSTRING(TO_VARCHAR(FieldDateTime), 7, 2) BETWEEN '01' AND
        CASE
            WHEN SUBSTRING(TO_VARCHAR(FieldDateTime), 5, 2) IN ('01', '03', '05', '07', '08', '10', '12') THEN '31'
            WHEN SUBSTRING(TO_VARCHAR(FieldDateTime), 5, 2) IN ('04', '06', '09', '11') THEN '30'
            WHEN SUBSTRING(TO_VARCHAR(FieldDateTime), 5, 2) = '02' THEN
                CASE
                    WHEN MOD(TO_INT(SUBSTRING(TO_VARCHAR(FieldDateTime), 1, 4)), 4) = 0 THEN '29'
                    ELSE '28'
                END
        END
    AND SUBSTRING(TO_VARCHAR(FieldDateTime), 9, 2) BETWEEN '00' AND '23'
    AND SUBSTRING(TO_VARCHAR(FieldDateTime), 11, 2) BETWEEN '00' AND '59'
    AND SUBSTRING(TO_VARCHAR(FieldDateTime), 13, 2) BETWEEN '00' AND '59'
    THEN TO_TIMESTAMP(TO_VARCHAR(FieldDateTime))
    ELSE TO_TIMESTAMP('1970-01-01 00:00:00')
END 	 				
