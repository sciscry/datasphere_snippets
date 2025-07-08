 -- object store offers only limited date and timestamp sql functions from HANA
 -- this conversion is a workaround
CASE
    WHEN SUBSTRING(TO_VARCHAR(PostingDate), 5, 2) BETWEEN '01' AND '12'
    AND SUBSTRING(TO_VARCHAR(PostingDate), 7, 2) BETWEEN '01' AND
        CASE
            WHEN SUBSTRING(TO_VARCHAR(PostingDate), 5, 2) IN ('01', '03', '05', '07', '08', '10', '12') THEN '31'
            WHEN SUBSTRING(TO_VARCHAR(PostingDate), 5, 2) IN ('04', '06', '09', '11') THEN '30'
            WHEN SUBSTRING(TO_VARCHAR(PostingDate), 5, 2) = '02' THEN
                CASE
                    WHEN MOD(TO_INT(SUBSTRING(TO_VARCHAR(PostingDate), 1, 4)), 4) = 0 THEN '29'
                    ELSE '28'
                END
        END
    THEN TO_VARCHAR(PostingDate)
    ELSE TO_VARCHAR('19700101')
END 	
