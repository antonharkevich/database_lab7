alter session set nls_date_language='AMERICAN';
DROP TABLE DIM_DATE PURGE;
CREATE TABLE DIM_DATE
(DATE_KEY NUMBER
,DATE_FULL_NUMBER VARCHAR2(20)
,DATE_FULL_STRING VARCHAR2(50)
,DATE_WEEKDAY_FL NUMBER
,DATE_US_CIVIL_HOLIDAY_FL NUMBER
,DATE_LAST_DAY_OF_WEEK_FL NUMBER
,DATE_LAST_DAY_OF_MONTH_FL NUMBER
,DATE_LAST_DAY_OF_QTR_FL NUMBER
,DATE_LAST_DAY_OF_YR_FL NUMBER
,DATE_DAY_OF_WEEK_NAME VARCHAR2(20)
,DATE_DAY_OF_WEEK_ABBR VARCHAR2(20)
,DATE_MONTH_NAME VARCHAR2(20)
,DATE_MONTH_NAME_ABBR VARCHAR2(20)
,DATE_DAY_NUMBER_OF_WEEK NUMBER
,DATE_DAY_NUMBER_OF_MONTH NUMBER
,DATE_DAY_NUMBER_OF_QTR NUMBER
,DATE_DAY_NUMBER_OF_YR NUMBER
,DATE_WEEK_NUMBER_OF_MONTH NUMBER
,DATE_WEEK_NUMBER_OF_QTR NUMBER
,DATE_WEEK_NUMBER_OF_YR NUMBER
,DATE_MONTH_NUMBER_OF_YR NUMBER
,DATE_QTR_NUMBER_OF_YR NUMBER
,DATE_YEAR_NUMBER NUMBER
,DATE_WEEK_BEGIN_DT DATE
,DATE_WEEK_END_DT DATE
,DATE_MONTH_BEGIN_DT DATE
,DATE_MONTH_END_DT DATE
,DATE_QTR_BEGIN_DT DATE
,DATE_QTR_END_DT DATE
,DATE_YR_BEGIN_DT DATE
,DATE_YR_END_DT DATE
,CONSTRAINT PK_DIM_DATE PRIMARY KEY (DATE_KEY)
);

CREATE INDEX IDX_DIM_DATE_01 ON DIM_DATE(SUBSTR(DATE_KEY,5,4)) NOLOGGING COMPUTE STATISTICS;

INSERT INTO DIM_DATE
select to_number(to_char(mydate, 'yyyymmdd')) DATE_KEY
,to_char(mydate, 'yyyy-mm-dd') DATE_FULL_NUMBER
,to_char(mydate, 'fmMonth dd, yyyy') DATE_FULL_STRING
,case
when to_number(to_char(mydate, 'D')) in (6, 7)
then 0
else 1
end DATE_WEEKDAY_FL
,0 DATE_US_CIVIL_HOLIDAY_FL
,case
when to_char(mydate, 'fmDay') = 'Saturday'
then 1
else 0
end DATE_LAST_DAY_OF_WEEK_FL
,case
when mydate = last_day(trunc(mydate,'MM'))
then 1
else 0
end DATE_LAST_DAY_OF_MONTH_FL
,case to_number(to_char(mydate, 'mmdd'))
when 331 then 1
when 630 then 1
when 930 then 1
when 1231 then 1
else 0
end DATE_LAST_DAY_OF_QTR_FL
,decode(to_number(to_char(mydate, 'mmdd')),1231,1,0) DATE_LAST_DAY_OF_YR_FL
,to_char(mydate, 'fmDay') DATE_DAY_OF_WEEK_NAME
,to_char(mydate, 'fmDy') DATE_DAY_OF_WEEK_ABBR
,to_char(mydate,'fmMonth') DATE_MONTH_NAME
,to_char(mydate,'Mon') DATE_MONTH_NAME_ABBR
,case to_number(to_char(mydate, 'D'))
when 7 then 1
else to_number(to_char(mydate, 'D')) + 1
end DATE_DAY_NUMBER_OF_WEEK
,to_number(to_char(mydate, 'DD')) DATE_DAY_NUMBER_OF_MONTH
,trunc(mydate) - trunc(mydate,'Q') + 1 DATE_DAY_NUMBER_OF_QTR
,to_number(to_char(mydate,'ddd')) DATE_DAY_NUMBER_OF_YR
,to_number(to_char(mydate,'W')) DATE_WEEK_NUMBER_OF_MONTH
,(7 + TRUNC(mydate + 1,'IW') -
TRUNC(TRUNC(mydate,'Q')+1,'IW'))/7 DATE_WEEK_NUMBER_OF_QTR
,case
when TO_CHAR(mydate,'D') < TO_CHAR(TO_DATE(to_char(mydate,'yyyy')||'0101' ,'YYYYMMDD'),'D') THEN TO_CHAR(mydate,'WW') + 1 ELSE TO_CHAR(mydate,'WW') + 0 end DATE_WEEK_NUMBER_OF_YR
,to_number(to_char(mydate,'mm')) DATE_MONTH_NUMBER_OF_YR
,to_number(to_char(mydate,'Q')) DATE_QTR_NUMBER_OF_YR
,to_number(to_char(mydate,'YYYY')) DATE_YEAR_NUMBER
,decode(to_char(mydate, 'fmDay'),'Sunday',trunc(mydate)
,next_day(trunc(mydate-7,'DD'), 'sun')) DATE_OF_WEEK_BEGIN_DT
,decode(to_char(mydate, 'fmDay'),'Saturday',trunc(mydate)
,next_day(trunc(mydate,'DD'), 'sat')) DATE_OF_WEEK_END_DT
,TO_DATE(TO_CHAR(mydate,'YYYYMM')||'01','YYYYMMDD') DATE_OF_MONTH_BEGIN_DT
,trunc(last_day(mydate)) DATE_OF_MONTH_END_DT
,case to_number(to_char(mydate,'Q'))
when 1 then TO_DATE(TO_CHAR(mydate,'YYYY')||'0101','YYYYMMDD')
when 2 then TO_DATE(TO_CHAR(mydate,'YYYY')||'0401','YYYYMMDD')
when 3 then TO_DATE(TO_CHAR(mydate,'YYYY')||'0701','YYYYMMDD')
when 4 then TO_DATE(TO_CHAR(mydate,'YYYY')||'1001','YYYYMMDD')
else null
end DATE_QTR_BEGIN_DTF
,case to_number(to_char(mydate,'Q'))
when 1 then TO_DATE(TO_CHAR(mydate,'YYYY')||'0331','YYYYMMDD')
when 2 then TO_DATE(TO_CHAR(mydate,'YYYY')||'0630','YYYYMMDD')
when 3 then TO_DATE(TO_CHAR(mydate,'YYYY')||'0930','YYYYMMDD')
when 4 then TO_DATE(TO_CHAR(mydate,'YYYY')||'1231','YYYYMMDD')
else null
end DATE_QTR_END_DT
,TO_DATE(TO_CHAR(mydate,'YYYY')||'0101','YYYYMMDD') DATE_YEAR_BEGIN_DT
,TO_DATE(TO_CHAR(mydate,'YYYY')||'1231','YYYYMMDD') DATE_YEAR_END_DT
from (select trunc(add_months(sysdate, -60),'YY') - 1 + LEVEL mydate from dual connect by level <= (select trunc(add_months(sysdate,132),'YY') -trunc(add_months(sysdate,-60),'YY') from dual) order by 1); COMMIT; Update dim_date set DATE_US_CIVIL_HOLIDAY_FL = 1 where date_key in ( SELECT DATE_KEY FROM DIM_DATE WHERE DATE_KEY IN (SELECT * FROM (SELECT DISTINCT TO_NUMBER(TO_CHAR(NEXT_DAY('14-Jan-'||DATE_YEAR_NUMBER,'Monday'),'YYYYMMDD')) FROM DIM_DATE UNION SELECT DISTINCT TO_NUMBER(TO_CHAR(NEXT_DAY('14-Feb-'||DATE_YEAR_NUMBER,'Monday'),'YYYYMMDD')) FROM DIM_DATE UNION SELECT DISTINCT TO_NUMBER(TO_CHAR(NEXT_DAY('23-May-'||DATE_YEAR_NUMBER,'Monday'),'YYYYMMDD')) FROM DIM_DATE UNION SELECT DISTINCT TO_NUMBER(TO_CHAR(NEXT_DAY('31-Aug-'||DATE_YEAR_NUMBER,'Monday'),'YYYYMMDD')) FROM DIM_DATE UNION SELECT DISTINCT TO_NUMBER(TO_CHAR(NEXT_DAY( '7-Oct-'||DATE_YEAR_NUMBER,'Monday'),'YYYYMMDD')) FROM DIM_DATE UNION SELECT DISTINCT TO_NUMBER(TO_CHAR(NEXT_DAY('21-Nov-'||DATE_YEAR_NUMBER,'Thursday'),'YYYYMMDD')) FROM DIM_DATE UNION SELECT DECODE(DATE_DAY_OF_WEEK_NAME,'Sunday',DATE_KEY+1,DATE_KEY) FROM DIM_DATE WHERE SUBSTR(DATE_KEY,5,4) = '0120' AND MOD(DATE_YEAR_NUMBER,4) = 1 UNION SELECT DECODE(DATE_DAY_OF_WEEK_NAME, 'Saturday',DATE_KEY-1, 'Sunday',DATE_KEY+1, DATE_KEY) FROM DIM_DATE WHERE SUBSTR(DATE_KEY,5,4) = '0101' OR SUBSTR(DATE_KEY,5,4) = '0704' OR SUBSTR(DATE_KEY,5,4) = '1111' OR SUBSTR(DATE_KEY,5,4) = '1225' ) ) ); COMMIT; SELECT * FROM DIM_DATE where sysdate between DATE_WEEK_BEGIN_DT and DATE_WEEK_END_DT order by date_key; SELECT * FROM DIM_DATE WHERE DATE_YEAR_NUMBER = 2017 AND DATE_US_CIVIL_HOLIDAY_FL = 1 ORDER BY DATE_KEY; SELECT * FROM DIM_DATE where trunc(sysdate) between DATE_WEEK_BEGIN_DT and DATE_WEEK_END_DT; select sysdate from dual;