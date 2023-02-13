/*
Create a database to manage the activity of a confectionery store,
• The entities of interest to the problem domain are: Cakes, Cake Types, Orders, and Confectionary Chefs.
• Each chef has a name, gender, and date of birth.
• Each cake has a name, shape, weight, price, and belongs to a type.
• Each cake type has a name, a description, and can correspond to several cakes.
• A chef can specialize in the preparation of several cakes.
• An order can include several cakes and has a date; a cake can be included in several orders. For every cake
purchased on an order, the system stores the number of ordered pieces, e.g.
<order 1: 3 Diplomat Cakes and 2 Cheesecakes>, <order 2: 3 Cheesecakes>
1. Write an SQL script that creates the corresponding relational data model.
2. Implement a stored procedure that receives an order ID, a cake name, and a positive number P representing the number of ordered pieces, 
and adds the cake to the order. If the cake is already on the order, the number of ordered pieces is set to P.
3. Implement a function that lists the names of the chefs who are specialized in the preparation of all the cakes.
*/
USE Cakes


CREATE TABLE Chefs
(
ChefID INT PRIMARY KEY,
ChefName VARCHAR(50),
Gender Varchar(10),
DateOfBirth Date
)


CREATE TABLE CakeTypes
(
CakeTypeID INT PRIMARY KEY,
CakeTypeName Varchar(50),
CakeTypeDescription Varchar(50)
)


CREATE TABLE Orders
(
OrderID INT PRIMARY KEY,
OrderDate DATE
)

CREATE TABLE Cakes
(
CakeID INT PRIMARY KEY,
CakeName VARCHAR(50),
Shape Varchar(50),
CWeight INT,
Price INT,
CakeTypeID INT FOREIGN KEY REFERENCES CakeTypes(CakeTypeID)
)

CREATE TABLE OrderCakes
(
OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
CakeID INT FOREIGN KEY REFERENCES Cakes(CakeID),
NoOfPieces INT,
CONSTRAINT PK_OrderCakes PRIMARY KEY(OrderID, CakeID)
)

CREATE TABLE ChefsCakes
(
ChefID INT FOREIGN KEY REFERENCES Chefs(ChefID),
CakeID INT FOREIGN KEY REFERENCES Cakes(CakeID),
CONSTRAINT PK_ChefsCakes PRIMARY KEY(ChefID, CakeID)
)

Insert into Orders values
(1, '2022-11-11'),
(2, '2021-10-09'),
(3, '2022-01-12')

Insert into Chefs(ChefID, ChefName) Values
(1, 'John'),
(2, 'Anna'),
(3, 'Matt'),
(4, 'Allan'),
(5, 'Rebeka')

Insert into CakeTypes(CakeTypeID, CakeTypeName) Values
(1, 'CakeType1'),
(2, 'CakeType2'),
(3, 'CakeType3'),
(4, 'CakeType4')

Insert into Cakes(CakeID,CakeName,CakeTypeID) Values
(1,'Cheesecake',1),
(2,'Lavacake',3),
(3,'Diplomat Cake',4),
(4,'Televizor',2),
(5,'Cookizza',1)

Insert into ChefsCakes values
(5,1),
(5,2),
(5,3),
(5,4),
(5,5),
(2,1),
(2,2),
(3,4)


SELECT TABLE_NAME,
       CONSTRAINT_TYPE,CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME='Cakes'

ALTER TABLE Cakes
DROP COLUMN ChefID



GO
CREATE OR ALTER PROCEDURE addCakeToOrder(@orderID INT, @cakeName VARCHAR(50), @P INT) AS
BEGIN
   IF NOT EXISTS (SELECT * FROM Orders WHERE OrderID = @orderID)
   BEGIN 
       PRINT 'No order has the given order.'
	   RETURN
   END

   DECLARE @cakeID INT
   SET @cakeID = (SELECT CakeID FROM Cakes WHERE CakeName = @cakeName)

   IF @cakeID IS NULL
   BEGIN
       PRINT 'No cake with the given name was found.' 
	   RETURN 
   END

   IF EXISTS (SELECT * FROM OrderCakes OC WHERE OC.CakeID = @cakeID AND OC.OrderID = @orderID)
   BEGIN
       UPDATE OrderCakes 
	   SET NoOfPieces = @P
	   WHERE CakeID = @cakeID AND OrderID = @orderID 
   END

   ELSE
   BEGIN
       INSERT INTO OrderCakes Values(@orderID, @cakeID, @P)
   END
END

SELECT * FROM Orders
SELECT * FROM Cakes
SELECT * FROM OrderCakes

EXEC addCakeToOrder 1, 'Diplomat Cake', 4

GO
CREATE OR ALTER FUNCTION chefsSpcInAllCakes()
RETURNS TABLE
AS
RETURN
     SELECT C.ChefName
     FROM Chefs C
     INNER JOIN ChefsCakes CC ON CC.ChefID = C.ChefID
     GROUP BY C.ChefName
     HAVING COUNT(*) = (SELECT COUNT(CakeID) From Cakes)


SELECT * FROM chefsSpcInAllCakes()
