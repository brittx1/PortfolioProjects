/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [Ordered]
      ,[Brand]
      ,[Sneaker]
      ,[Sale_Price]
      ,[Retail_Price]
      ,[Released]
      ,[Size]
      ,[Buyer_Region]
  FROM [StockX].[dbo].['StockX-Data-2019$']

  /* Questions: 

What shoes are most popular?
Which shoes have the best/worst profit margins?
What factors affect profit margin?


Yeezy 350 vs Off Whites- Nike */ 


---Most popular shoe b/w Yeezy 350 and Off Whites 

SELECT distinct(Brand), count(*)
FROM [StockX].[dbo].['StockX-Data-2019$']
group by Brand
--- Yeezy's are more popular/ Probably because the resale is cheaper  

--- Highest selling sneaker 
SELECT distinct(Sneaker), count(*) as Snkr_Purc_Count
FROM [StockX].[dbo].['StockX-Data-2019$']
group by Sneaker
order by Snkr_Purc_Count desc
--- Yeezy 350 top 3: Butter, Beluga, and Zebra/ Lowest selling snkr Off white AF100 

--- top 3 Most Popular sneaker: Off White 

SELECT distinct(Sneaker), count(*) as Snkr_Purc_Count
FROM [StockX].[dbo].['StockX-Data-2019$'] 
where Brand = 'Off-White'
group by Sneaker
order by Snkr_Purc_Count desc  

--- Air Jordan Univ Blue, Presto Black, Presto White

With Profits as (Select Sneaker, Sale_Price, Retail_Price,
(Sale_Price - Retail_Price) as Net_Income
FROM [StockX].[dbo].['StockX-Data-2019$']),

Margins as (select *, concat(round((Net_Income/ Sale_Price) * 100 ,0),'%') as Profit_Margin
from Profits 
)

Select Sneaker, count(*) as Sold
from Margins 
where Profit_Margin > '90%' --- 95% is the best profit margin 
group by Sneaker
order by Sold desc 

--- Nike Presto Off white 
--- Jord 1 high off white white
--- Jord 1 off white Chicago / Top 3 highest Profit margins


With Profits as (Select Sneaker, Sale_Price, Retail_Price,
(Sale_Price - Retail_Price) as Net_Income
FROM [StockX].[dbo].['StockX-Data-2019$']),

Margins as (select *, concat(round((Net_Income/ Sale_Price) * 100 ,0),'%') as Profit_Margin
from Profits) 

Select Sneaker, count(*) as Sold
from Margins 
where Profit_Margin < '0%' --- -0% is the worst profit margin 
group by Sneaker
order by Sold desc

--- Yeezy butter and Cream- white have worst profit margins 

--- does getting an order before the release date effect profit margins ? 


With Time_Ordered_from_Release as 
(Select Sneaker, 
Sale_Price,
Released,
Ordered,
DATEDIFF(day, Released, Ordered) as Release_Ord_diff
FROM [StockX].[dbo].['StockX-Data-2019$']),

Profits as (Select Sneaker, Sale_Price, Retail_Price,
(Sale_Price - Retail_Price) as Net_Income
FROM [StockX].[dbo].['StockX-Data-2019$']),

Margins as (select *, round((Net_Income/ Sale_Price) * 100,0 ) as Profit_Margin
from Profits 
),

----Ordered Before Release Date 
select  
count(case when M.Profit_Margin >= -18 and M.Profit_Margin <= 20 then 1 end) as [low (-18% - 20%)],
count(case when M.Profit_Margin >= 21 and M.Profit_Margin <= 40 then 1 end) as [low-mid (21% - 40%) ],
count(case when M.Profit_Margin >= 41 and M.Profit_Margin <= 60 then 1 end) as [mid-high (41% - 60%) ],
count(case when M.Profit_Margin >= 61 and M.Profit_Margin <= 80 then 1 end) as [high (61% - 80%) ],
count(case when M.Profit_Margin >= 81 and M.Profit_Margin <= 100 then 1 end) as [Top (81% - 100%) ] --- going to 100 even thought top Margin is 95%
from Margins as M 
Inner join Time_Ordered_from_Release as TR 
on M.Sneaker = TR.Sneaker 
Where TR.Release_Ord_diff like '-%'  
--- Those ordered before release sell mostly in the high(61% - 80%) 

Joint_TRM as (select TR.Sneaker,TR.Sale_Price, TR.Released, TR.Ordered, TR.Release_Ord_diff, M.Profit_Margin
from Time_Ordered_from_Release as TR
INNER JOIN Margins as M
on TR.Sneaker = M.Sneaker
)


select avg(Profit_Margin) as Margin_Avg 
from Joint_TRM
where Release_Ord_Diff like '-%' 
--- Avg Profit Margin order before release is about 46% 


select avg(Profit_Margin) as Margin_Avg 
from Joint_TRM
where Release_Ord_Diff not like '-%' 

--- Avg profit Margin for those ordered on or after release is about 33% 

select  
count(case when M.Profit_Margin >= -18 and M.Profit_Margin <= 20 then 1 end) as [low (-18% - 20%)],
count(case when M.Profit_Margin >= 21 and M.Profit_Margin <= 40 then 1 end) as [low-mid (21% - 40%) ],
count(case when M.Profit_Margin >= 41 and M.Profit_Margin <= 60 then 1 end) as [mid-high (41% - 60%) ],
count(case when M.Profit_Margin >= 61 and M.Profit_Margin <= 80 then 1 end) as [high (61% - 80%) ],
count(case when M.Profit_Margin >= 81 and M.Profit_Margin <= 100 then 1 end) as [Top (81% - 100%) ] --- going to 100 even thought top Margin is 95%
from Margins as M 
Inner join Time_Ordered_from_Release as TR 
on M.Sneaker = TR.Sneaker 
Where TR.Release_Ord_diff not like '-%'
--- After release most sell in -18% - 20% profit Margin Range 

---Does Buyer Region affect profit margins 

select Buyer_Region, count(*) as Sold 
FROM [StockX].[dbo].['StockX-Data-2019$']
group by Buyer_Region
order by Sold Desc

--- If you are in California or New York you have the best chance at making a sale 

/* Regions: 
NorthEast: 'Connecticut', 'Maine', 'Massachusetts' , 'New Hampshire' , 'Rhode Island' , 'Vermont' , 'New Jersey' , 'New York' , 'Pennslyvania'
Midwest: 'Illinois', 'Indiana', 'Michigan', 'Ohio', 'Wisconsin', 'Iowa', 'Kansas' , 'Minnesota', 'Missouri', 'Nebraska' , 'North Dakota', 'South Dakota' 
South: 'Delaware' , 'Florida' , 'Georgia' , 'Maryland', 'North Carolina', 'South Carolina' , 'Virginia', 'West Virginia', 'Alabama', 'Kentucky', 'Mississippi', 'Tennessee' , 'Arkansas', 'Louisiana', 'Oklahoma', 'Texas', 'District of Columbia'
West: 'Arizona', 'Colorado', 'Nevada', 'New Mexico', 'Utah', 'Wyoming', 'Alaska', 'California', 'Hawaii', 'Oregon', 'Washington' */ 

With Profits as (Select Buyer_Region, Sneaker, Sale_Price, Retail_Price,
(Sale_Price - Retail_Price) as Net_Income
FROM [StockX].[dbo].['StockX-Data-2019$']),

Margins as (select *, round((Net_Income/ Sale_Price) * 100,0 ) as Profit_Margin
from Profits 
)

select Distinct(Buyer_Region), round(avg(Profit_Margin),0) as Avg_Profit_Margins 
from Margins
group by Buyer_Region
order by Avg_Profit_Margins Desc

---- sellers selling to those from Delaware, Hawaii, Oregon have the highest Profit Margins from the sale and Wyoming has the lowest 