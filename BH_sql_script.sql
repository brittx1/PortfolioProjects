/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [questionid]
      ,[question]
  FROM [DataAnalystPT].[dbo].[q_lookup$]

  SELECT *
  FROM [DataAnalystPT].[dbo].[question_responsedata$]

  --- single row of survery answers and grades for students 

  --survey answers 

with surv as ( SELECT studentid, 
    questionid1 = SUM(CASE WHEN [questionid] = 1 then [response] END)
    , questionid2 = SUM(CASE WHEN [questionid] = 2 then [response] END)
    , questionid3 = SUM(CASE WHEN [questionid] = 3 then [response] END)
    , questionid4 = SUM(CASE WHEN [questionid] = 4 then [response] END)
FROM [DataAnalystPT].[dbo].[question_responsedata$]
GROUP BY studentid),


--- course grades 
 grades as (SELECT studentid, 
    Course_LessonPlanning = SUM(CASE WHEN [courseid] = 1 then [coursegrade] END)
    , Course_ClassroomCulture = SUM(CASE WHEN [courseid] = 2 then [coursegrade] END)
    , Course_Instruction = SUM(CASE WHEN [courseid] = 3 then [coursegrade] END)
    , Course_AssessingStudentLearning = SUM(CASE WHEN [courseid] = 4 then [coursegrade] END)
FROM [DataAnalystPT].[dbo].[course_gradedata$]
GROUP BY studentid),


--- Create single table of neccesary data 
complete as (select d. studentid, 
d.degree,
d.campus,
d.sex, 
d.age, 
d.personofcolor as race_ethnicty,
g.Course_LessonPlanning,
g.Course_ClassroomCulture,
g.Course_Instruction,
g.Course_AssessingStudentLearning,
s.questionid1,
s.questionid2,
s.questionid3,
s.questionid4
From [DataAnalystPT].[dbo].[student_data$] as d 
join grades as g on d.studentid = g.studentid
join surv as s on d.studentid = s.studentid)

select * 
into full_table
from complete


--- % and total of student satisfaction for program instruction 


with tt as (select  r.response, count(f.questionid1) as TotalResponses, 
convert(int,count(f.questionid1) * 100.0 / 649) as Perc
FROM [DataAnalystPT].[dbo].[response_lookup$] as r
join [DataAnalystPT].[dbo].[full_table] as f
on r.responseid = f.questionid1
group by  r.response)

select response,TotalResponses, concat(Perc, '%') AS percentage
from tt


















