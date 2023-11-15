/**
  유저 수 : 10만 명
  */
set cte_max_recursion_depth = 100000000;

INSERT INTO user (name, user_login_id, user_login_pw, user_delete_dt)
with recursive tb as (select 10001 as num
                      union all
                      select num + 1
                      from tb
                      where num < 90000)
select concat('TEST', num),
       concat('login_id', num),
       md5(concat('PW', num)),
       case when round(rand() * 20) = 1 then now() end
from tb;

truncate table user;

-- 2018년부터 5년간 출퇴근 기록
-- 10만 사원 * 365 일 * 5년 = 180,250,000건
-- 랜덤으로 넣어도 insert ignore로 넣기 때문에 200,000,000건 삽입
DELIMITER ;;
CREATE PROCEDURE cd_work_time(IN dummy_count INTEGER)
BEGIN
    DECLARE i INTEGER DEFAULT 1;
    DECLARE BULK_INSERT_NUMBER INTEGER DEFAULT 1000000;
    DECLARE USER_COUNT INTEGER DEFAULT 100000;
    DECLARE FIVE_YEAR INTEGER DEFAULT 157680000;
    WHILE i < dummy_count + 1
        DO
            START TRANSACTION ;
            INSERT ignore INTO work_time (user_id, in_time, out_time, work_date)
            with recursive tb as (select 0                                              as num,
                                         FROM_UNIXTIME(UNIX_TIMESTAMP('2018-01-01') +
                                                       FLOOR(1 + (RAND() * FIVE_YEAR))) as d
                                  union all
                                  select num + 1,
                                         FROM_UNIXTIME(UNIX_TIMESTAMP('2018-01-01') +
                                                       FLOOR(1 + (RAND() * FIVE_YEAR))) as d
                                  from tb
                                  where num < BULK_INSERT_NUMBER)
            select rand() * USER_COUNT,
                   d,
                   case
                       when round(rand() * 200000) = 1 then null
                       else date_add(d, interval (hour(d) + ceil(rand() * (24 - hour(d)))) hour) end,
                   date(d)
            from tb;
            COMMIT;
            SELECT CONCAT(i*BULK_INSERT_NUMBER, 'row insert complete');
            SET i = i + 1;
        end while;
    COMMIT;
end;;
DELIMITER ;

DROP PROCEDURE cd_work_time;

-- 200,000,000건 삽입
call cd_work_time(200);

truncate table work_time;

-- 1100만건을 넣는데 50분이 걸림
-- 확인해보니 BUFFER POOL SIZE가 125MB로 잡혀 있었음
-- BUFFER POOL SIZE를 4GB로 늘려 다시 시도
SET GLOBAL innodb_log_buffer_size = 4*1024*1024*1024;
SET GLOBAL sort_buffer_size=1*1024*1024*1024;
set session cte_max_recursion_depth = 100000000;
SET AUTOCOMMIT = FALSE;
SET foreign_key_checks = 0;
SET sql_log_bin = OFF;
truncate table work_time;
call cd_work_time(200);