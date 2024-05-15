﻿CREATE TABLE USERS(
Email Varchar(50) PRIMARY KEY NOT NULL,
[Name - first] Varchar(20) NOT NULL,
[Name - second] Varchar(20) NOT NULL,
[Password] Varchar(20) NULL,
[Phone Number] Varchar(13) NULL
)

CREATE TABLE PRODUCTS(
Barcode Varchar(20) PRIMARY KEY NOT NULL,
[Name] Varchar(30) NOT NULL,
Category Varchar(20) NOT NULL, 
[Description] Varchar(300) NULL,
Dimension Varchar (20) NULL,
[Weight] Int NULL,
[Price] Money NOT NULL
)

CREATE TABLE CUSTOMIZATIONS (
DesignID Varchar(20) NOT NULL,
Barcode Varchar (20) NOT NULL,
Color Varchar (10) NULL,
PriceCust Money NULL,	
PRIMARY KEY (DesignID ,Barcode),
CONSTRAINT FK_Barcode FOREIGN KEY (Barcode) REFERENCES PRODUCTS(Barcode)
)

CREATE TABLE CREDITCARDS (
[CC Number]  Varchar (20) PRIMARY KEY NOT NULL, 
[CC IDOwner] Varchar (10) NOT NULL,
[CC Expired date] Date NOT NULL, 
[CC CVC] Int NOT NULL,
[Type] Varchar (20) NOT NULL,
Email Varchar(50) NOT NULL,
CONSTRAINT FK_Email FOREIGN KEY (Email) REFERENCES USERS(Email)
)

CREATE TABLE ORDERS (
[ID Order] Varchar(20) PRIMARY KEY NOT NULL,
[CC Number] Varchar(20) NOT NULL,
[Date] Date NOT NULL,
[Address - ZIP Code] Varchar (10) NOT NULL, 
[Address - Country] Varchar(20) NOT NULL,
[Address - City] Varchar(20) NOT NULL,
[Address - Street] Varchar(20) NOT NULL,
CONSTRAINT FK_CCNumber FOREIGN KEY ([CC Number]) REFERENCES CREDITCARDS([CC Number])
)

CREATE TABLE BELONGING (
[ID Order] Varchar(20) NOT NULL,
DesignID Varchar(20) NOT NULL,
Barcode Varchar (20) NOT NULL,
Quantity Varchar (20) NULL,
[Coupon Code] Varchar(10) NULL,
PRIMARY KEY (DesignID, Barcode, [ID Order] ),
CONSTRAINT FK_Custom FOREIGN KEY (DesignID, Barcode) REFERENCES CUSTOMIZATIONS (DesignID ,Barcode),
CONSTRAINT FK_IDorder2 FOREIGN KEY ([ID Order]) REFERENCES ORDERS([ID Order])
)


CREATE TABLE ORDERNOTES (
[ID Order] Varchar (20) NOT NULL,
[Order Note] Varchar (200) NOT NULL,
PRIMARY KEY([ID Order],[Order Note]),
CONSTRAINT FK_IDOrder FOREIGN KEY ([ID Order]) REFERENCES ORDERS([ID Order])
)

CREATE TABLE SEARCHES (
[IP address] Varchar(20) NOT NULL,
[Search DT] DATETIME NOT NULL,
Email Varchar(50)  NOT NULL
PRIMARY KEY ([IP Address],[Search DT])
CONSTRAINT FK_Email2 FOREIGN KEY (Email) REFERENCES USERS(Email)
)


CREATE TABLE SEARCHSTRINGS (
[IP address] Varchar(20) NOT NULL,
[Search DT] DATETIME NOT NULL,
[Search Strings] Varchar (200) NOT NULL,
PRIMARY KEY ([IP address],[Search DT],[Search Strings]),
CONSTRAINT FK_Searchstrings FOREIGN KEY ([IP address],[Search DT]) REFERENCES SEARCHES([IP address],[Search DT])
)



CREATE TABLE ADDITIONAL
(
DesignID Varchar (20) NOT NULL,
Barcode Varchar (20) NOT NULL,
Additional Varchar (200) NOT NULL,
PRIMARY KEY (DesignID, Barcode, Additional),
CONSTRAINT FK_DesignID FOREIGN KEY (DesignID, Barcode) REFERENCES CUSTOMIZATIONS(DesignID, Barcode)
)


CREATE TABLE RETRIVING  
(
Barcode Varchar (20) NOT NULL,
[IP address] Varchar (20) NOT NULL,
[Search DT] DATETIME NOT NULL,
PRIMARY KEY (Barcode,[IP address]),
CONSTRAINT FK_Barcode2 FOREIGN KEY (Barcode) REFERENCES PRODUCTS(Barcode),
CONSTRAINT FK_IPaddress FOREIGN KEY ([IP address],[Search DT]) REFERENCES SEARCHES([IP address], [Search DT])
)



ALTER TABLE USERS
ADD CONSTRAINT CK_Email3 CHECK (Email LIKE '%@%.%'), 
CONSTRAINT CK_Phone1 CHECK ([Phone Number] NOT LIKE '%[^0-9 ]%') 


ALTER TABLE BELONGING
ADD CONSTRAINT CK_Quantity1 CHECK (Quantity>0)


ALTER TABLE PRODUCTS
ADD CONSTRAINT CK_Wei CHECK (Weight>0),
CONSTRAINT CK_Pric CHECK (Price>0)


ALTER TABLE CREDITCARDS
ADD CONSTRAINT CK_CCnumber CHECK ([CC Number] NOT LIKE '%[^0-9]%'), 
CONSTRAINT CK_CCcvc CHECK ([CC CVC] LIKE '[0-9][0-9][0-9]'),
CONSTRAINT CK_IDowner CHECK ([CC IDOwner] NOT LIKE '%[^0-9]%'), 
CONSTRAINT CK_ExpiredDate CHECK (YEAR([CC Expired date])>2023 
AND MONTH ([CC Expired date])<= 12
AND DAY([CC Expired date])<= DAY(EOMONTH([CC Expired date])))


CREATE TABLE CREDITTYPES
(
[Type] Varchar (20) PRIMARY KEY NOT NULL
)

INSERT INTO CREDITTYPES VALUES ('visa'),('mastercard'),('americanexpress')

ALTER TABLE CREDITCARDS
ADD CONSTRAINT FK_Type FOREIGN KEY ([Type]) REFERENCES CREDITTYPES ([Type])


ALTER TABLE ORDERS
ADD CONSTRAINT CK_ZIPcod CHECK ([Address - ZIP Code] NOT LIKE '%[^0-9 ]%') 

ALTER TABLE SEARCHES
ADD CONSTRAINT CK_IPaddress CHECK (ParseName([IP address],1) BETWEEN 0 AND 255
AND ParseName([IP address],2) BETWEEN 0 AND 255
AND ParseName([IP address],3) BETWEEN 0 AND 255
AND ParseName([IP address],4) BETWEEN 0 AND 255
)

ALTER TABLE CUSTOMIZATIONS
ADD CONSTRAINT CK_Price2 CHECK (PriceCust>=0)


CREATE TABLE CATEGORIES
(
Category Varchar (20) PRIMARY KEY NOT NULL
)

INSERT INTO CATEGORIES VALUES ('Plate Loaded'),('Racks'),('Dumbbells & Plates'),('Benches'),('Gym Stations'),('Functional') 

ALTER TABLE PRODUCTS ADD CONSTRAINT FK_Category FOREIGN KEY (Category) REFERENCES CATEGORIES (Category)


ALTER TABLE USERS DROP CONSTRAINT [CK_Email3],[CK_Phone1]
ALTER TABLE BELONGING DROP CONSTRAINT [CK_Quantity1]
ALTER TABLE SEARCHES DROP CONSTRAINT [CK_IPaddress]
ALTER TABLE PRODUCTS DROP CONSTRAINT [CK_Wei],[CK_Pric],[FK_Category]
ALTER TABLE CREDITCARDS  DROP CONSTRAINT  [CK_CCnumber],[CK_IDowner],[CK_ExpiredDate],[CK_CCcvc],[FK_Type]
ALTER TABLE ORDERS DROP CONSTRAINT [CK_ZIPcod] 
ALTER TABLE CUSTOMIZATIONS DROP CONSTRAINT [CK_Price2]
ALTER TABLE BELONGING ALTER COLUMN [Coupon Code] varchar(15)

DROP TABLE CATEGORIES
DROP TABLE CREDITTYPES
DROP TABLE RETRIVING
DROP TABLE ADDITIONAL
DROP TABLE SEARCHSTRINGS
DROP TABLE SEARCHES
DROP TABLE ORDERNOTES
DROP TABLE BELONGING
DROP TABLE ORDERS
DROP TABLE CREDITCARDS
DROP TABLE CUSTOMIZATIONS
DROP TABLE PRODUCTS
DROP TABLE USERS



SELECT TOP 1 P.Category ,total = COUNT(*)
FROM PRODUCTS as P JOIN BELONGING as B on P.Barcode=B.Barcode
JOIN ORDERS as O on O.[ID Order] = B.[ID Order]
WHERE YEAR(O.Date)=2023
GROUP BY P.Category
ORDER BY total DESC



SELECT B.Barcode, [Total Price] = SUM ((P.Price + C.PriceCust)*B.Quantity)
FROM ORDERS as O JOIN BELONGING as B on O.[ID Order] = B.[ID Order] JOIN CUSTOMIZATIONS as C on C.DesignID=B.DesignID AND C.Barcode=B.Barcode
JOIN PRODUCTS as P on P.Barcode=B.Barcode
WHERE P.Price < 500
GROUP BY B.Barcode
HAVING SUM (P.Price + C.PriceCust) > 2500
order by [Total Price] DESC




SELECT AVG([Total Price]) AS Average
FROM (
	SELECT O.[ID Order],[Total Price] = SUM((P.Price + C.PriceCust)*B.Quantity)
    FROM ORDERS AS O
    JOIN BELONGING AS B ON O.[ID Order]= B.[ID Order]
    JOIN CUSTOMIZATIONS AS C ON C.DesignID=B.DesignID AND C.Barcode=B.Barcode
	JOIN PRODUCTS AS P ON P.Barcode=C.Barcode
	GROUP BY O.[ID Order]
    ) 
	AS TotalOrderPrice
  


SELECT O.[Address - Country], [Country Total] = SUM((B.Quantity*(P.Price+C.PriceCust))),
Precent = SUM((B.Quantity*(P.Price+C.PriceCust))/ T.Total)
FROM ORDERS AS O
JOIN BELONGING AS B ON O.[ID Order] = B.[ID Order]
JOIN CUSTOMIZATIONS AS C ON C.DesignID = B.DesignID AND C.Barcode = B.Barcode
JOIN PRODUCTS AS P ON C.Barcode = P.Barcode
CROSS JOIN (
  SELECT Total = SUM(B.Quantity*(P.Price+C.PriceCust))
  FROM ORDERS AS O
  JOIN BELONGING AS B ON O.[ID Order] = B.[ID Order]
  JOIN CUSTOMIZATIONS AS C ON C.DesignID = B.DesignID AND C.Barcode = B.Barcode
  JOIN PRODUCTS AS P ON C.Barcode = P.Barcode
) AS T
GROUP BY T.Total, O.[Address - Country]
ORDER BY Precent DESC


UPDATE PRODUCTS
SET PRICE =Price * 1.1
WHERE Barcode IN (
    SELECT Top 5 Barcode
    FROM (
        SELECT TOP 5 P.Barcode, P.Price, SUM(CAST(B.Quantity AS INT)) AS Total_Quantity
        FROM BELONGING AS B
        JOIN CUSTOMIZATIONS AS C ON C.DesignID = B.DesignID AND C.Barcode = B.Barcode
        JOIN PRODUCTS AS P ON C.Barcode = P.Barcode    
        GROUP BY P.Barcode, P.Price
		ORDER BY Total_Quantity DESC
    ) AS Top_Products
))

SELECT U.Email, U.[Name - first], U.[Name - second]
FROM USERS AS U JOIN CREDITCARDS AS C ON U.Email = C.Email
		JOIN ORDERS AS O ON C.[CC Number]=O.[CC Number]
WHERE YEAR (O.Date) < 2022
GROUP BY U.Email, U.[Name - first], U.[Name - second]

EXCEPT

SELECT U.Email, U.[Name - first], U.[Name - second]
FROM USERS AS U JOIN CREDITCARDS AS C ON U.Email = C.Email
		JOIN ORDERS AS O ON C.[CC Number]=O.[CC Number]
WHERE YEAR (O.Date) >=2022
GROUP BY U.Email, U.[Name - first], U.[Name - second] 


CREATE VIEW V_RevenuePerDay AS
SELECT O.[Address - Country], Revenue = SUM((P.Price + C.PriceCust)*B.Quantity), [Day]=Day(O.[Date])
FROM CUSTOMIZATIONS AS C JOIN PRODUCTS AS P ON C.Barcode=P.Barcode
JOIN BELONGING AS B ON B.DesignID=C.DesignID AND B.Barcode=C.Barcode
JOIN ORDERS AS O ON O.[ID Order]=B.[ID Order]
GROUP BY O.[Address - Country], Day(O.[Date])


SELECT R.[Address - Country], R.Revenue
FROM V_RevenuePerDay AS R
WHERE Day=1
GROUP BY [Address - Country], Revenue
ORDER BY Revenue DESC



DROP FUNCTION PriceForOrder

CREATE FUNCTION PriceForOrder (@INPUT1 Varchar(20))
RETURNS INT
AS BEGIN 
       DECLARE @OUTPUT_Price  INT
	          SELECT @OUTPUT_Price = B.Quantity*(P.Price+C.PriceCust)
			  FROM ORDERS AS O
              JOIN BELONGING AS B ON O.[ID Order] = B.[ID Order]
              JOIN CUSTOMIZATIONS AS C ON C.DesignID = B.DesignID AND 
              C.Barcode = B.Barcode
              JOIN PRODUCTS AS P ON C.Barcode = P.Barcode
			  WHERE O.[ID order] = @INPUT1 
	   RETURN @OUTPUT_Price
	   END

SELECT  Price = dbo.PriceForOrder('0mHmsp093')




DROP FUNCTION OrdersByPerson
CREATE FUNCTION OrdersByPerson (@Email Varchar(50))
RETURNS TABLE
AS RETURN
SELECT U.Email, O.Date, O.[ID Order]
FROM ORDERS AS O JOIN CREDITCARDS AS C ON O.[CC Number]=C.[CC Number]
JOIN USERS AS U ON U.Email=C.Email
WHERE U.Email= @Email

SELECT *
FROM dbo.OrdersByPerson('pdavion5j@histats.com')


ALTER TABLE ORDERS 
ADD Total_Amount MONEY NULL

UPDATE ORDERS
    SET Total_Amount = dbo.PriceForOrder(ORDERS.[ID Order])
    WHERE [ID Order] IN (SELECT DISTINCT [ID Order] FROM ORDERS)

CREATE TRIGGER Orders_Amount 
ON BELONGING
FOR INSERT 
AS 
UPDATE ORDERS 
SET Total_Amount = (dbo.PriceForOrder(ORDERS.[ID Order]))
WHERE [ID Order] IN (SELECT DISTINCT [ID Order] FROM INSERTED)

INSERT INTO CUSTOMIZATIONS VALUES('10382','8cncfsYAi','yellow',62.0000)
INSERT INTO ORDERS VALUES ('07cfgjpghvF7','4017950952321350','2023-01-29','5919841','Israel','Azor','tlalim',null)
INSERT INTO BELONGING VALUES('07cfgjpghvF7','10382','8cncfsYAi',7,'T2kfa7uJ1jg'


CREATE PROCEDURE sp_changePassword 
    @email VARCHAR(50),
    @newPassword VARCHAR(20)
AS
BEGIN
    DECLARE @currentPassword VARCHAR(20)
    SELECT @currentPassword = [Password]
    FROM USERS
    WHERE Email = @email
    IF @newPassword <> @currentPassword
    BEGIN
        UPDATE USERS
        SET [Password] = @newPassword
        WHERE Email = @email
        PRINT 'Password changed successfully'
    END
    ELSE
    BEGIN
        PRINT 'The new password cannot be the same as the current password'
    END
END

execute sp_changePassword 'aguilliland55@earthlink.net','grydhtrkNhr'




DROP VIEW V_1
CREATE VIEW V_1
AS
SELECT  Country = O.[Address - Country], [Year] = Year(O.Date), P.Category,[Total Orders] = COUNT (O.[ID Order]), 
[Total Quantity Per Category] = SUM (CAST(B.Quantity AS Int)) ,[Total Revenue Per Category] = SUM (B.Quantity*(P.Price + CU.PriceCust))
FROM
PRODUCTS AS P JOIN CUSTOMIZATIONS AS CU ON P.Barcode=CU.Barcode
JOIN BELONGING AS B ON B.Barcode=CU.Barcode AND B.DesignID=CU.DesignID
JOIN ORDERS AS O ON O.[ID Order]=B.[ID Order]
JOIN ORDERNOTES AS ORN ON ORN.[ID Order] = O.[ID Order]
JOIN CREDITCARDS AS CC ON CC.[CC Number]=O.[CC Number]
GROUP BY  P.Category, O.[Address - Country], Year(O.Date)

SELECT * FROM V_1

DROP VIEW V_2
CREATE VIEW V_2
AS
SELECT  TotalPaidBy = Count (Distinct O.[ID Order]), cc.Type
FROM
ORDERS AS O JOIN CREDITCARDS AS CC ON O.[CC Number] = CC.[CC Number]
GROUP BY  cc.Type

SELECT * FROM V_2
--פר לקוח
DROP VIEW V_3
CREATE VIEW V_3
AS
SELECT U.Email, O.[Date], O.[Address - Country], CC.Type, P.Category,  B.Quantity ,TotalPriceProduct =( P.Price + CU.PriceCust), [TotalExpenses] = SUM (B.Quantity*(P.Price + CU.PriceCust))
FROM	
PRODUCTS AS P JOIN CUSTOMIZATIONS AS CU ON P.Barcode=CU.Barcode
JOIN BELONGING AS B ON B.Barcode=CU.Barcode AND B.DesignID=CU.DesignID
JOIN ORDERS AS O ON O.[ID Order]=B.[ID Order]
JOIN ORDERNOTES AS ORN ON ORN.[ID Order] = O.[ID Order]
JOIN CREDITCARDS AS CC ON CC.[CC Number]=O.[CC Number]
JOIN USERS AS U ON U.Email=CC.Email
GROUP BY U.Email, O.[Date], O.[Address - Country], CC.Type, P.Category, B.Quantity,P.Price, CU.PriceCust
SELECT * FROM V_3

CREATE VIEW V_4 AS
SELECT O.[Date], [Year] = Year (O.[Date]) ,O.[ID Order], U.Email ,P.[Name] ,CU.DesignID, P.Barcode ,B.Quantity ,Total = (P.Price + CU.PriceCust) , O.[Address - Country] ,
TotalRevenue = B.Quantity * (P.Price + CU.PriceCust)
FROM PRODUCTS AS P JOIN CUSTOMIZATIONS AS CU ON P.Barcode=CU.Barcode
JOIN BELONGING AS B ON B.Barcode=CU.Barcode AND B.DesignID=CU.DesignID
JOIN ORDERS AS O ON O.[ID Order]=B.[ID Order]
JOIN CREDITCARDS AS CC ON CC.[CC Number]=O.[CC Number]
JOIN USERS AS U ON U.Email=CC.Email
GROUP BY O.[Date], O.[ID Order], U.Email ,P.[Name] ,CU.DesignID, P.Barcode ,B.Quantity, P.Price, CU.PriceCust, O.[Address - Country]




SELECT [Year], TotalRevenue, LastYearRevenue, LastYearGrowth,
YearRank = RANK () OVER (ORDER BY LastYearGrowth DESC)
FROM (
     SELECT *, 
     LastYearGrowth = (ROUND((TotalRevenue)/ (LastYearRevenue) ,2)-1 )
     FROM
	  (SELECT *,
	  LastYearRevenue = ROUND( LAG(TotalRevenue , 1) OVER (ORDER BY [Year]),2)
	  FROM 
	     (SELECT [Year] = Year(O.Date),
	      TotalRevenue = ROUND( SUM(B.Quantity*(P.Price + C.PriceCust)),2) 
	      FROM ORDERS AS O JOIN BELONGING AS B ON O.[ID Order] = B.[ID Order] 
JOIN CUSTOMIZATIONS AS C ON C.DesignID = B.DesignID AND C.Barcode = B.Barcode
	      JOIN PRODUCTS AS P ON P.Barcode = C.Barcode
	      GROUP BY Year (O.Date)
	      ) AS YR
	  ) AS LYG
	) AS Final
ORDER BY [Year] DESC



DROP VIEW V_AllUsersOrders

CREATE VIEW V_AllUsersOrders 
AS
SELECT FullName = U.[Name - first] +' '+ U.[Name - second], P.Category, OrderPrice =SUM ( B.Quantity*(P.Price+C.PriceCust)), YearOrder = Year(O.[Date])
FROM ORDERS AS O JOIN BELONGING AS B ON O.[ID Order] = B.[ID Order] 
JOIN CUSTOMIZATIONS AS C ON C.DesignID=B.DesignID AND C.Barcode= B.Barcode
JOIN PRODUCTS AS P ON P.Barcode = C.Barcode
JOIN CREDITCARDS AS CC ON CC.[CC Number]= O.[CC Number]
JOIN USERS AS U ON U.Email=CC.Email
GROUP BY U.[Name - first],U.[Name - second],Year(O.[Date]) ,P.Category

SELECT * FROM V_AllUsersOrders 


SELECT *
FROM (
	SELECT FullName, Category, OrderPrice,
	MaxSalePerCategory = MAX(OrderPrice) OVER(PARTITION BY Category),
	AveragePerCategory = AVG(OrderPrice) OVER(PARTITION BY Category),
	RankInCategory = DENSE_RANK() OVER(PARTITION BY Category ORDER BY OrderPrice)
	,YearOrder
	FROM V_AllUsersOrders
	)AS X
WHERE YearOrder= 2022 AND RankInCategory <= 1

DROP FUNCTION getProfit
CREATE FUNCTION getProfit(@email varchar(50))
RETURNS INT 
AS BEGIN
   DECLARE @OUTPUT_Profit INT
   SELECT @OUTPUT_Profit = SUM(dbo.PriceForOrder(O.[ID Order]))
   FROM USERS AS U JOIN CREDITCARDS AS C ON U.Email=C.Email JOIN ORDERS AS O ON O.[CC Number]=C.[CC Number]
   WHERE U.Email=@email
   RETURN @OUTPUT_Profit
END

SELECT Profit = dbo.getProfit('aapplebeec@buzzfeed.com')
 

ALTER TABLE USERS ADD Credit_points INT NULL
 

CREATE PROCEDURE sp_getCredit_points
AS
BEGIN
	UPDATE USERS
	SET Credit_points=dbo.getProfit(Email) * 0.01
    SELECT Email, dbo.getProfit(Email) * 0.01 AS Credit_points
    FROM USERS
    WHERE dbo.getProfit(Email) > 10000
    GROUP BY Email, dbo.getProfit(Email) * 0.02
    ORDER BY dbo.getProfit(Email) * 0.02 DESC
END
DROP PROCEDURE sp_getCredit_points

execute sp_getCredit_points


CREATE TABLE REFUNDS (
Email Varchar(50) not null,
RefundAmount Money ,
[Date] Date not null
Primary Key(Email)
)
DROP TABLE REFUNDS

הטריגר:
CREATE TRIGGER UpdateRefunds
ON USERS
FOR INSERT,UPDATE,DELETE
AS BEGIN
     INSERT INTO REFUNDS
     SELECT DISTINCT U.Email,U.Credit_points,GETDATE()
     FROM DELETED cross join INSERTED as U
     WHERE U.Credit_points IS NOT NULL
END

SELECT SUM(RefundAmount) As Total_Depth
FROM REFUNDS





ALTER TABLE PRODUCTS DROP COLUMN CostProduct

ALTER TABLE PRODUCTS ADD  CostProduct real
UPDATE PRODUCTS SET CostProduct = Price*0.62 --...כמה עולה המוצר

WITH
ListProducts AS (
	SELECT ProductBarcode = P.Barcode, TotalRevenue = SUM(B.Quantity *(P.Price + C.PriceCust)),
	AveragePrice = AVG(P.Price + C.PriceCust), 
	TotalBenefit = SUM(B.Quantity * (P.Price + C.PriceCust)) - SUM(P.CostProduct * B.Quantity), Contribution = SUM(B.Quantity * (P.Price + C.PriceCust)) / COUNT(DISTINCT U.Email)
	FROM ORDERS AS O JOIN BELONGING AS B ON O.[ID Order] = B.[ID Order] 
	JOIN CUSTOMIZATIONS AS C ON C.DesignID=B.DesignID AND C.Barcode= B.Barcode
	JOIN PRODUCTS AS P ON P.Barcode = C.Barcode
	JOIN CREDITCARDS AS CC ON CC.[CC Number]= O.[CC Number]
	JOIN USERS AS U ON U.Email=CC.Email
	GROUP BY P.Barcode
),
ListOfOrders AS (
	SELECT  ProductBarcode = P.Barcode, TotalOrders = COUNT(DISTINCT O.[ID Order]), [Conversion Rate] = Cast(COUNT(DISTINCT O.[ID Order]) as real) / COUNT(DISTINCT R.[Search DT])
	FROM ORDERS AS O JOIN BELONGING AS B ON O.[ID Order] = B.[ID Order] 
	JOIN CUSTOMIZATIONS AS C ON C.DesignID=B.DesignID AND C.Barcode= B.Barcode
	JOIN PRODUCTS AS P ON P.Barcode = C.Barcode
	JOIN RETRIVING AS R ON R.Barcode = P.Barcode
	GROUP BY P.Barcode
),
ListSearches AS (
	SELECT R.Barcode, TotalSearches = COUNT(*)
	FROM RETRIVING as R
	GROUP BY R.Barcode
),
RatioOrdersSearches AS (
SELECT LO.ProductBarcode, [Search Order Ratio] = CAST(LS.TotalSearches as FLOAT)/LO.TotalOrders
FROM ListOfOrders AS LO
JOIN ListSearches AS LS ON LO.ProductBarcode =  LS.Barcode
)
,
TypeToPay AS(
	SELECT B.Barcode, O.[ID Order], CC.Type
	FROM ORDERS AS O
	JOIN BELONGING AS B ON O.[ID Order] = B.[ID Order]
	JOIN CREDITCARDS AS CC ON CC.[CC Number] = O.[CC Number]
	GROUP BY B.Barcode, O.[ID Order], CC.Type
)
SELECT TOP 10 LP.ProductBarcode, LO.TotalOrders, [Total Sales] = round(LP.TotalRevenue, 2), [Average Price] = round(LP.AveragePrice, 2), [Search Order Ratio] = round(ros.[Search Order Ratio], 4), LO.[Conversion Rate], Profit = round(LP.TotalBenefit, 2), Contribution = round(LP.Contribution, 2)
FROM ListProducts as LP
JOIN ListOfOrders as LO ON LP.ProductBarcode = LO.ProductBarcode
JOIN ListSearches as LS ON LS.Barcode = LP.ProductBarcode
JOIN RatioOrdersSearches as ROS ON ROS.ProductBarcode = LP.ProductBarcode
GROUP BY LP.ProductBarcode, LO.TotalOrders, LP.TotalRevenue,ROS.[Search Order Ratio], LP.AveragePrice, LO.[Conversion Rate],LP.TotalBenefit, LP.Contribution
ORDER BY LO.TotalOrders DESC, LP.Contribution DESC
