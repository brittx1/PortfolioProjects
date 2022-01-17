--- What state has highest sales 
SELECT distinct(state), sum(sales) over(partition by state) StateSales
 FROM `practice-project-319020.CoffeeChain.Q4`
 order by StateSales desc ; 

--- California highest/ lowest sales New hampshire 


 --- profits by state 
 select distinct(state) , sum(profit) over(partition by state) as Profits
 from `practice-project-319020.CoffeeChain.Q4`
 order by profits desc 

 --- new hampshire and new mexico lowest profiting states ** research drink habits 

--- profits by market 
select distinct(market), sum(Target_Profit) over(partition by Market) as TargetProfits, 
sum(Profit) over(partition by market) as ActualProfits,
sum(Difference_Between_Actual_and_Target_Profit) over(partition by Market) as FinalProfits
FROM `practice-project-319020.CoffeeChain.Q4`
order by FinalProfits desc;


--- target sales vs actual sales by market 
select distinct(market), sum(Target_Sales) over(partition by Market) as TargetSales, 
sum(Sales) over(partition by market) as TotalSales
FROM `practice-project-319020.CoffeeChain.Q4`;

--- sales exceeding targets/ south still lowest 


---Look at marketing of each market
select distinct(market), sum(Marketing) over(partition by Market) MarketingAds
FROM `practice-project-319020.CoffeeChain.Q4`;

--- south has least marketing ads which may contribute to them being the lowest in sales/ profits*
--- increasing espresso inventory in south may increase profits because that it is the highest selling product
--type the data shows that regualr Tea products arent bought in south so to increase profit and decrease 
--- expenses limit Tea buying 


select distinct(market), Product_Type, count(product_type) as TotalProductSold
FROM `practice-project-319020.CoffeeChain.Q4`
group by market, Product_type
order by Product_Type;


--- highest/ lowest  sales month 

with monthly as (select extract(month from date ) as month,marketing, sales
from `practice-project-319020.CoffeeChain.Q4`)

select month , sum(marketing) as MarketingAds
from monthly 
group by month


select distinct(month), sum(sales) over(partition by month) sales
from monthly 

--- November has lowest # of sales/ lowest amount of marketing ads during november 

---product information

select Product_Type, count(product_type) as TotalProductSold
FROM `practice-project-319020.CoffeeChain.Q4`
group by Product_Type