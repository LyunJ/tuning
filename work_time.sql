-- 2022년 1월에 달 160시간을 채우지 않은 사람 사번 구하기
-- 1 분 20 초
-- primary index인 (user_id, work_date) 사용
-- work_date 2022년 1월인 사용자를 찾기 위해 index full scan
-- 비효율 발생
-- work_date 인덱스의 필요성 or primary key (user_id) 로 변경, work_date로 파티셔닝
explain analyze
select user.id, work_time as time
from (select user_id, hour(sum(TIMEDIFF(out_time, in_time))) as work_time
      from work_time
      where work_date between '2022-01-01' and '2022-01-31'
      group by user_id
      having work_time < 160) wt
         inner join user on user.id = wt.user_id;

-- foreign key와 primary key 삭제
alter table work_time
    drop foreign key FK_user_TO_work_time_1;

alter table work_time
    drop primary key;

-- 8.52s
alter table work_time partition by range (TO_DAYS(work_date))(
    partition p0 values less than (TO_DAYS('2018-02-01')),
    partition p1 values less than (TO_DAYS('2018-03-01')),
    partition p2 values less than (TO_DAYS('2018-04-01')),
    partition p3 values less than (TO_DAYS('2018-05-01')),
    partition p4 values less than (TO_DAYS('2018-06-01')),
    partition p5 values less than (TO_DAYS('2018-07-01')),
    partition p6 values less than (TO_DAYS('2018-08-01')),
    partition p7 values less than (TO_DAYS('2018-09-01')),
    partition p8 values less than (TO_DAYS('2018-10-01')),
    partition p9 values less than (TO_DAYS('2018-11-01')),
    partition p10 values less than (TO_DAYS('2018-12-01')),
    partition p11 values less than (TO_DAYS('2019-01-01')),
    partition p12 values less than (TO_DAYS('2019-02-01')),
    partition p13 values less than (TO_DAYS('2019-03-01')),
    partition p14 values less than (TO_DAYS('2019-04-01')),
    partition p15 values less than (TO_DAYS('2019-05-01')),
    partition p16 values less than (TO_DAYS('2019-06-01')),
    partition p17 values less than (TO_DAYS('2019-07-01')),
    partition p18 values less than (TO_DAYS('2019-08-01')),
    partition p19 values less than (TO_DAYS('2019-09-01')),
    partition p20 values less than (TO_DAYS('2019-10-01')),
    partition p21 values less than (TO_DAYS('2019-11-01')),
    partition p22 values less than (TO_DAYS('2019-12-01')),
    partition p23 values less than (TO_DAYS('2020-01-01')),
    partition p24 values less than (TO_DAYS('2020-02-01')),
    partition p25 values less than (TO_DAYS('2020-03-01')),
    partition p26 values less than (TO_DAYS('2020-04-01')),
    partition p27 values less than (TO_DAYS('2020-05-01')),
    partition p28 values less than (TO_DAYS('2020-06-01')),
    partition p29 values less than (TO_DAYS('2020-07-01')),
    partition p30 values less than (TO_DAYS('2020-08-01')),
    partition p31 values less than (TO_DAYS('2020-09-01')),
    partition p32 values less than (TO_DAYS('2020-10-01')),
    partition p33 values less than (TO_DAYS('2020-11-01')),
    partition p34 values less than (TO_DAYS('2020-12-01')),
    partition p35 values less than (TO_DAYS('2021-01-01')),
    partition p36 values less than (TO_DAYS('2021-02-01')),
    partition p37 values less than (TO_DAYS('2021-03-01')),
    partition p38 values less than (TO_DAYS('2021-04-01')),
    partition p39 values less than (TO_DAYS('2021-05-01')),
    partition p40 values less than (TO_DAYS('2021-06-01')),
    partition p41 values less than (TO_DAYS('2021-07-01')),
    partition p42 values less than (TO_DAYS('2021-08-01')),
    partition p43 values less than (TO_DAYS('2021-09-01')),
    partition p44 values less than (TO_DAYS('2021-10-01')),
    partition p45 values less than (TO_DAYS('2021-11-01')),
    partition p46 values less than (TO_DAYS('2021-12-01')),
    partition p47 values less than (TO_DAYS('2022-01-01')),
    partition p48 values less than (TO_DAYS('2022-02-01')),
    partition p49 values less than (TO_DAYS('2022-03-01')),
    partition p50 values less than (TO_DAYS('2022-04-01')),
    partition p51 values less than (TO_DAYS('2022-05-01')),
    partition p52 values less than (TO_DAYS('2022-06-01')),
    partition p53 values less than (TO_DAYS('2022-07-01')),
    partition p54 values less than (TO_DAYS('2022-08-01')),
    partition p55 values less than (TO_DAYS('2022-09-01')),
    partition p56 values less than (TO_DAYS('2022-10-01')),
    partition p57 values less than (TO_DAYS('2022-11-01')),
    partition p58 values less than (TO_DAYS('2022-12-01')),
    partition p59 values less than (TO_DAYS('2023-01-01')),
    partition p60 values less than (MAXVALUE)
    );

-- local index 생성
alter table work_time
    add index idx1_work_test (user_id);
alter table work_time
    add index idx2_work_test (user_id, work_date);
alter table work_time
    add index idx3_work_test (work_date, user_id);


-- 2022년 1월에 달 160시간을 채우지 않은 사람 사번과 일한 시간 구하기
-- primary index인 (user_id, work_date) 사용
-- work_date 2022년 1월인 사용자를 찾기 위해 index full scan
-- 비효율 발생
-- 파티셔닝 후 1m 20s -> 1s 940ms
-- Index scan on work_time using PRIMARY
explain analyze
select user.id, work_time as time
from (select user_id, hour(sum(TIMEDIFF(out_time, in_time))) as work_time
      from work_time
      where work_date between '2022-01-01' and '2022-01-31'
      group by user_id
      having work_time < 160) wt
         inner join user on user.id = wt.user_id;



-- 2022년 1월에 한 번이라도 지각하지 않은 사람 이름 구하기
-- 출근 시간 10시
-- left join where is null
-- 1s 294ms
explain analyze
select u.name
from user u
         left join (select distinct user_id
                     from work_time
                     where hour(in_time) > 10 and work_date between '2022-01-01' and '2022-01-31') wt
                    on u.id = wt.user_id
where wt.user_id is null
;

-- anti semi join 으로 변경
-- 1s 294ms -> 400ms
explain ANALYZE
select u.name
from user u
where not exists(select 1
                 from work_time wt
                 where work_date between '2022-01-01' and '2022-01-31'
                   and hour(in_time) > 10
                   and u.id = wt.user_id
                 );

-- 2022년 1월에 10번 이상 지각한 사람 이름 구하기
-- 47ms
explain analyze
select u.name
from user u inner join work_time wt on u.id = wt.user_id
where work_date between '2022-01-01' and '2022-01-31'
                   and hour(in_time) > 10
group by user_id
having count(*) >= 10;

-- 47ms -> 42ms
-- 별 차이가 없다.
-- inner join 후 group by 한 번 수행, filtering 한 번 수행
-- user record마다 group by, filtering 한 번 수행 loops=90001
-- 무엇이 효율적인가?
explain analyze
select u.name
from user u
where exists(select 1
                 from work_time wt
                 where work_date between '2022-01-01' and '2022-01-31'
                   and hour(in_time) > 10
                   and u.id = wt.user_id
                 group by user_id
                 having count(*) >= 10);




-- 1번 사원의 1달 근무 시간
-- 66ms -> 33ms
explain analyze
select hour(sum(TIMEDIFF(out_time, in_time))) as time
from work_time
where work_date between '2022-01-01' and '2022-01-31'
  and user_id = 1;