/* Analysis using Big Query SQL */ 


--- how many recruits did we get from the diversity fair ? 
SELECT *
 FROM `practice-project-319020.HR.Employee`
 where FromDiversityJobFairID = 1

---- 29 were recruited from the fair/ all were black/ African American Descent 

SELECT *
 FROM `practice-project-319020.HR.Employee`
 where FromDiversityJobFairID = 1 and DateofTermination != 'Still Employed'
 --- of the 29, 16 left the company 

Select RecruitmentSource, count(RecruitmentSource) as SourceCount
FROM `practice-project-319020.HR.Employee`
where racedesc != 'White'and RecruitmentSource != 'Diversity Job Fair'
group by RecruitmentSource

--Indeed(33) and Linkedin(29) are the next best recruitment sources other 
--than a diversity fair to ensure the company is being diverse


--- top 3 recruitment sources 
Select RecruitmentSource, count(RecruitmentSource) as SourceCount
FROM `practice-project-319020.HR.Employee`
group by RecruitmentSource
order by SourceCount desc
limit 3


---recruitment source that has the most people who leave/terminated 
Select RecruitmentSource, count(RecruitmentSource) as SourceCount
FROM `practice-project-319020.HR.Employee`
where Termd = 1
group by RecruitmentSource
order by SourceCount desc
--- google search 



--- is performancescore an indicator on who will leave 

select e2.empid, e1.performancescore
from `practice-project-319020.HR.Employee` as e2
join `practice-project-319020.HR.Emp_Score_Satisfaction` as e1
on e2.empid = e1.empid
where e2.termd = 1
--- not really most fully meet 

select  managername, count(*) EmployeesLeft
from `practice-project-319020.HR.Employee`
where termd = 1
group by  ManagerName
order by EmployeesLeft desc

---Amy D, Webster B., Kissy S. all have more than 10 employees that quit under them 


select distinct department
from `practice-project-319020.HR.Employee`
where ManagerName like 'Amy%'or ManagerName like 'Kissy%' or managername like 'Webster%'
---production 



select distinct department, count(EmpID) over (partition by department)
from`practice-project-319020.HR.Employee`
group by department,empid
--- production has most employees 



--- Avg months employees tend to stay  

update `practice-project-319020.HR.Employee`
set dateoftermination = replace(DateofTermination, '/','-')
where DateofTermination !='Still Employed'

with TermMonth as (select empid,
case 
when (DateofTermination='Still Employed') then NULL 
else dateoftermination 
end as TermTime
from `practice-project-319020.HR.Employee`),

dates as (Select empid,
SPLIT(Termtime, '-')[OFFSET(0)] as month, 
SPLIT(termtime, '-')[OFFSET(1)] as day,
SPLIT(Termtime, '-')[offset(2)] as year
FROM TermMonth ),
         

UpdatedHT as (select e2.empid, 
e2.dateofhire, 
cast(concat(d.year,'-', d.month, '-', d.day) as date) as TermDate 
from `practice-project-319020.HR.Employee` as e2 
join dates as d 
on d.empid= e2.empid),

MonthsEmp as (select empid, format_date('%m-%Y',dateofhire) as Hired, 
format_date('%m-%Y',(cast(TermDate as date))) as Depature,
date_diff(TermDate, dateofhire, month) as EmpLength
from UpdatedHT 
where TermDate is not null)

select round(avg(EmpLength))
from MonthsEmp 

---41 months/ almost 3.5 years 



--- what are the top 3 reasons people leave 


select DeptReason, count(*) as ReasonCount
from (select
(case 
when TermReason like '%position%' or TermReason like '%change%' then 'Position/Career Change'
else Termreason 
end) as DeptReason
from `practice-project-319020.HR.Employee`
where termd = 1)
group by DeptReason
order by ReasonCount desc 
limit 3

---unhappy, position/career change, want more money 

--- "more money"
select avg(salary)
from `practice-project-319020.HR.Employee`
where SpecialProjectsCount >= 1

---92,697.80 avg salary of those who get special projects


select avg(salary)
from `practice-project-319020.HR.Employee`
where SpecialProjectsCount = 0
-- about 62,143.51 avg salary for those who have no special projects

select salary, SpecialProjectsCount
from `practice-project-319020.HR.Employee`
where termd= 1 and termreason like '%money%'

--- of those needing more money none had special projects/ they have higher avg salaries 

select e2.empid, e1.performancescore
from `practice-project-319020.HR.Employee` as e2
join `practice-project-319020.HR.Emp_Score_Satisfaction` as e1
on e2.empid = e1.empid
where e2.termd= 1 and e2.termreason like '%money%'

---even though they all fully meets or exceeds standards 
--- how long was their length of employment 

with TermMonth as (select empid,
case 
when (DateofTermination='Still Employed') then NULL 
else dateoftermination 
end as TermTime
from `practice-project-319020.HR.Employee`),

dates as (Select empid,
SPLIT(Termtime, '-')[OFFSET(0)] as month, 
SPLIT(termtime, '-')[OFFSET(1)] as day,
SPLIT(Termtime, '-')[offset(2)] as year
FROM TermMonth ),
         

UpdatedHT as (select e2.empid, 
e2.dateofhire, 
cast(concat(d.year,'-', d.month, '-', d.day) as date) as TermDate 
from `practice-project-319020.HR.Employee` as e2 
join dates as d 
on d.empid= e2.empid),

MonthsEmp as (select empid, format_date('%m-%Y',dateofhire) as Hired, 
format_date('%m-%Y',(cast(TermDate as date))) as Depature,
date_diff(TermDate, dateofhire, month) as EmpLength
from UpdatedHT 
where TermDate is not null)

select avg(Emplength)
from MonthsEmp
where empid in (select EmpID
from `practice-project-319020.HR.Employee`
where termd= 1 and TermReason like '%money%')

---avg 40/ about 3 yrs  no one stayed under a year!!

select position, SpecialProjectsCount
from `practice-project-319020.HR.Employee`
where termreason like '%money%'



select position,count(*)
from `practice-project-319020.HR.Employee`
group by Position
--- production technicians has greatest amount of employees 

--- "position change/career change"

select position,count(*)
from `practice-project-319020.HR.Employee`
where TermReason like '%career%' or TermReason like '%position%'
group by Position

---product technicians 1 and 2 are more likely to leave for a career change/another position

select round(avg(e1.empsatisfaction))
from `practice-project-319020.HR.Emp_Score_Satisfaction` as e1
join `practice-project-319020.HR.Employee` as e2
on e1.empid = e2.empid
where e2.position like 'Production Technician%'

--generally satisfied avg rating a 4 

with TermMonth as (select empid,
case 
when (DateofTermination='Still Employed') then NULL 
else dateoftermination 
end as TermTime
from `practice-project-319020.HR.Employee`),

dates as (Select empid,
SPLIT(Termtime, '-')[OFFSET(0)] as month, 
SPLIT(termtime, '-')[OFFSET(1)] as day,
SPLIT(Termtime, '-')[offset(2)] as year
FROM TermMonth ),
         

UpdatedHT as (select e2.empid, 
e2.dateofhire, 
cast(concat(d.year,'-', d.month, '-', d.day) as date) as TermDate 
from `practice-project-319020.HR.Employee` as e2 
join dates as d 
on d.empid= e2.empid),

MonthsEmp as (select empid, format_date('%m-%Y',dateofhire) as Hired, 
format_date('%m-%Y',(cast(TermDate as date))) as Depature,
date_diff(TermDate, dateofhire, month) as EmpLength
from UpdatedHT 
where TermDate is not null)

select round(avg(Emplength))
from MonthsEmp
where empid in (select EmpID
from `practice-project-319020.HR.Employee`
where termd= 1 and TermReason like '%career%' or TermReason like '%position%')

---42 months/3.5 years (no promotions??)

--- "unhappy"

select position, salary, sex, maritaldesc, racedesc,ManagerName
from `practice-project-319020.HR.Employee`
where termreason like 'unhappy'
--- product technicians are most unhappy 
