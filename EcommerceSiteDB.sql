USE EcommerceSite
GO

--- Create Customers Table
CREATE TABLE Customers 
(CustomerID INT Primary Key,
FirstName NVARCHAR(255),
LastName NVARCHAR(255),
Address NVARCHAR(255),
City NVARCHAR(50),
State NVARCHAR(10),)

---Create Orders Table
CREATE TABLE Orders 
(OrderID INT Primary Key ,
CustomerID INT,
Quantity INT, 
OrderTotal Decimal(18,2),
OrderDate Date,
DeliveryDate Date) 

---Insert Data into tables 

INSERT INTO [dbo].[Customers]  
 ([CustomerID], [FirstName], [LastName], [Address],  [City], [State]) 
 VALUES 
 (16245, 'Jewel', 'Williams', '1414 David Throughway', 'Port Jackson', 'OH'),
 (16327, 'Peter', 'Dickson', '860 Lee Key West', 'Debra', 'SD'),
 (16192, 'Dana', 'Whitfield', '5277 Patel Brook', 'East Audrey', 'NJ'),
 (16440, 'Cynthia', 'James', '9135 Rodriguez Dam', 'Ramirezberg', 'MS'),
 (16789, 'Carissa', 'Walker', '049 Matthew Terrace', 'Lake Matthew', 'MS'),
 (16992, 'Cassie', 'Heart', '861 Annette Stream', 'North Miguel', 'CA'),
 (16112, 'Lily', 'White', '044 Riggs Expressway', 'Lake Stevenchester', 'AL'),
 (16342, 'Destiny', 'Harris', '3132 Willie Harbor', 'Kaylafurt', 'FL'),
 (16815, 'Hazel', 'Lopez', '15810 Karl Plain', 'Davidville', 'TX'),
 (16999, 'Haliey', 'Lewis', '08079 Thompson Village North', 'Lukeborough', 'AL')

Select *
from Customers

 INSERT INTO [dbo].[Orders] 
 ([OrderID],[CustomerID], [Quantity], [OrderTotal], [OrderDate], [DeliveryDate]) 
 VALUES 
(0021,16245, 4, 121.00 , CAST('12/01/2019' as date), CAST('12/08/2019' as date)),
(0052,16327, 9, 272.50 , CAST('11/12/2020' as date),CAST('11/19/2020' as date)),
(0083,16192, 1, 55.00 , CAST('05/22/2020' as date),CAST('05/29/2020' as date)),
(0026,16440, 3, 99.50 ,CAST('05/12/2020' as date),CAST('05/17/2020' as date)),
(0079,16789, 3, 79.00 ,CAST('07/05/2020' as date),CAST('07/10/2020' as date)),
(0091,16992, 4, 100.50 ,CAST('07/10/2020' as date),CAST('07/17/2020' as date)),
(0011,16112, 5, 120.00 ,CAST('07/06/2020' as date),CAST('07/11/2020' as date)),
(0012,16342, 6, 140.00 ,CAST('07/06/2020' as date),CAST('07/11/2020' as date)),
(0042,16815, 2, 45.50 ,CAST('09/22/2020' as date),CAST('09/27/2020' as date)),
(0061,16999, 3, 66.00 ,CAST('10/01/2020' as date),CAST('09/06/2020' as date))

Select *
from Orders

---Create stored procedure and parameters to insert new entry or update an existing one

Use EcommerceSite
GO

Create Proc CustomersInsertORUpdate 
				(@CustomerID INT, 
				@FirstName NVARCHAR(255),  
				@LastName NVARCHAR(255),  
				@Address NVARCHAR(255), 
				@City NVARCHAR(50),       
				@State NVARCHAR(10),
				@StatementType NVARCHAR(20) = ' ')
AS
     Begin 
	IF @StatementType = 'Insert'
	Begin 
		Insert into
		Customers (CustomerID,
				   FirstName,
				   LastName,
				   Address,
				   City,
				   State)

		VALUES (@CustomerID, 
	     	    @FirstName,  
	     		@LastName,  
	     		@Address, 
	            @City,       
	     		@State) 
                             END 

IF @StatementType = 'Update'
   Begin 
	Update Customers 
	SET     
	FirstName = @FirstName,
    LastName = @LastName,
    Address = @Address,
    City = @City,
    State = @State
	Where CustomerID = @CustomerID
     END 
END


USE EcommerceSite
GO

Create Proc OrdersInsertORUpdate 
				(@OrderID INT,
				 @CustomerID INT,
				 @Quantity INT, 
				 @OrderTotal Decimal(18,2),
				 @OrderDate Date,
				 @DeliveryDate Date,
				@StatementType NVARCHAR(20) = ' ')
AS
     Begin 
	IF @StatementType = 'Insert'
	Begin 
		Insert into
		Orders(OrderID,
			   CustomerID,
			   Quantity,
			   OrderTotal,
			   OrderDate,
			   DeliveryDate)

		VALUES (@OrderID,
				 @CustomerID,
				 @Quantity, 
				 @OrderTotal,
				 @OrderDate,
				 @DeliveryDate) 
                             END 

IF @StatementType = 'Update'
   Begin 
	Update Orders
	SET     
	OrderID = @OrderID,
    CustomerID = @CustomerID,
    Quantity = @Quantity,
    OrderTotal = @OrderTotal,
    OrderDate = @OrderDate
	Where OrderID = @OrderID
     END 
END


--- New Order (OrderID: 0098, CustomerID: 16330, Quantity:3, OrderTotal: 65.00, OrderDate: 12/01/2020, hasn't Shipped)
--- Customer info for OrderID: 0098 ( Brittany, Parker, 988 Treasures Rd, Savannah, GA) 

Exec CustomersInsertORUpdate @CustomerID = 16330, @FirstName = 'Brittany', @LastName = 'Parker', @Address = '988 Treasures Rd', @City = 'Savannah', @State = 'GA', @StatementType = 'Insert'

Exec OrdersInsertORUpdate @OrderID = 0098, @CustomerID = 16330, @Quantity = 3, @OrderTotal = 65.00, @OrderDate = '2020-12-01', @DeliveryDate = NULL, @StatementType = 'Insert'



--- Customer Changed Address and Last Name: CustomerID: 16327, new address: 4021 Appletree Drive, Marietta, GA) 

Exec CustomersInsertORUpdate @CustomerID = 16327, @FirstName = 'Peter', @LastName = 'Wallis', @Address = '4021 Appletree Drive', @City = 'Marietta', @State = 'GA', @StatementType = 'Update'

Select *
From Orders


--- How many orders were made during 2020
USE EcommerceSite
GO


Create Proc OrderCNTbyYear

(@Year As INT) 
As 

Begin
	Select 
	OrderID

	From 
	Orders
	Where 
	Year(OrderDate) = @Year

	Return @@ROWCOUNT
END

Declare @Count INT 

EXEC @Count = OrderCNTbyYear @Year = 2020

Select @Count AS [Number of Orders]

--- 10 orders made in 2020 
--- Check order count for 2019
Declare @Count INT 

EXEC @Count = OrderCNTbyYear @Year = 2019

Select @Count AS [Number of Orders]

--- 1 Order for 2019

--- What orders had an order quantity between 3 and 6 

Create Proc OrderQuantity
(@MinQuantity As INT =NULL
,@MaxQuantity As INT = NULL) 

As 

Begin
	Select 
	*
	From 
	Orders
	Where 
	(@MinQuantity is NULL OR Quantity >= @MinQuantity) AND 
	(@MaxQuantity is NULL OR Quantity <= @MaxQuantity)

End

Exec OrderQuantity @MinQuantity = 3, @MaxQuantity = 6

--- 9 Orders had an order quantity between 3 and 6 


--- What orders had an order quantity between 0 and 3 

Exec OrderQuantity @MaxQuantity = 3
---6 orders had an order quantity between 0 amd 3
