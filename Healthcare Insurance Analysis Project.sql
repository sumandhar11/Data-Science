create schema healthcare;
show databases;
use healthcare;

# get table data from csv

select * from hosp
limit 10;

select * from medic
limit 10;

select `Customer ID` , count(*) as ct from hosp
group by `Customer ID`
order by ct desc;

# remove rows where customer id = ?

SET SQL_SAFE_UPDATES = 0;

delete from hosp
where `Customer ID` = "?";

# making customer id not null

alter table hosp
modify `Customer ID` varchar(10) not null;

# making customer id a primary key

alter table hosp
add primary key (`Customer ID`);

# repeating with medic table

select `Customer ID` , count(*) as ct from medic
group by `Customer ID`
order by ct desc;

alter table medic
modify `Customer ID` varchar(10) not null;

alter table medic
add primary key (`Customer ID`);

SET SQL_SAFE_UPDATES = 1;

select `Customer ID`, count(*) as ct from hosp
group by `Customer ID`
order by ct desc;

create view merged as
(
select h.*, m.`BMI`, m.`HBA1C`, m.`Heart Issues`, m.`Any Transplants`, m.`Cancer history`, m.`NumberOfMajorSurgeries`, m.`smoker`
from hosp h inner join medic m
on h.`Customer ID` = m.`Customer ID`
);

select * from merged
limit 10;

/* 2. Retrieve information about people who are diabetic and have heart problems with their average age, the average number of dependent children, 
	  average BMI, and average hospitalization costs. */
 
SELECT 
    m.diabetes,
    m.`Heart Issues`,
    round(AVG(h.age),0) AS avg_age,
    round(AVG(h.children),0) AS avg_child_dep,
    round(AVG(m.BMI),2) AS avg_bmi,
    round(AVG(h.charges),2) AS avg_charges
FROM
    (select *, 2025 - year AS age
    from hosp) h,
    (SELECT 
        *,
            CASE
                WHEN HBA1C > 6.5 THEN 'Yes'
                ELSE 'No'
            END AS diabetes
    FROM
        medic) m
	where h.`Customer ID` = m.`Customer ID`
GROUP BY m.diabetes, m.`Heart Issues`;

/* 3. Find the average hospitalization cost for each hospital tier and each city level */
/* Replace "?" in City tier and hospital tier with mode value. */

select `Hospital tier`, count(*) as ct
from hosp
group by `Hospital tier`
order by ct;

select `City tier`, count(*) as ct
from hosp
group by `City tier`
order by ct;

# Replace "?" with mode value

SET SQL_SAFE_UPDATES = 0;

update hosp
set `Hospital tier` = "tier - 2"
where `Hospital tier` = "?";

update hosp
set `City tier` = "tier - 2"
where `City tier` = "?";

SET SQL_SAFE_UPDATES = 1;

select `Hospital tier`, `City tier` , avg(charges) as avg_charges
from  hosp
group by `Hospital tier`, `City tier`;

/* 4. Determine the number of people who have had major surgery with a history of cancer. */

select `Cancer history`, surgery, count(*) as count_pat
from 
(
select *, 
	case 
		when NumberOfMajorSurgeries >= 1 then "Yes"
		else "No"
	end as surgery
from  medic) m
group by `Cancer history`, surgery
having `Cancer history` = "yes";

/* 6. Determine the number of tier-1 hospitals in each state. */

# Replace "?" in state id with mode value

select * from hosp ;

select `State ID`, count(*) as ct
from hosp
group by `State ID`
order by ct desc;

SET SQL_SAFE_UPDATES = 0;

update hosp
set `Hospital tier` = "tier - 2"
where `Hospital tier` = "?";

select `State ID`, `Hospital tier`, count(*) as hosp_count
from hosp
group by `State ID`, `Hospital tier`
having `Hospital tier` = "tier - 1";