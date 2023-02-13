/*
Create a database for tracking operations within a bank.
You will manage customers, bank accounts, cards, ATMs and transactions.
Each customer has a name, the date of birth and may have multiple bank accounts.
For each bank account consider the following: the IBAN code, the current balance, the holder and the cards associated with that bank account.
Each card has a number, a CVV code (Inst 3 digits of the card number) and is associated with a bank account, An ATM has an address.
A transaction involves withdrawing. from an ATM, a sum of money using a card at a certain time (consider both date and time).
Of course, a card can be used in several transactions at the same ATM or at different ATMs and at an ATM multiple transactions can be done with multiple cards
Requirements:
1. Write an SOL script that creates the corresponding relational data model.
2. Implement a stored procedure that receives a card and deletes all the transactions related 10 that card. 
3. Create a view that shows the card numbers which were used in transactions at all the ATMs.
4. Implement a function that lists the cards (number and CVV code) that have the total transactions sum greater than 2000 lei. 
*/

DROP TABLE Customers
DROP TABLE BankAccounts
DROP TABLE Cards
DROP TABLE ATMs
DROP TABLE Transactions

USE ATMs

CREATE TABLE Customers
(
CustomerID INT PRIMARY KEY,
CustomerName VARCHAR(100),
DateOfBirth DATE
)

CREATE TABLE BankAccounts
(
BankID INT PRIMARY KEY,
CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
IBAN INT,
CurrentBalance INT,
Holder VARCHAR(100)
)

CREATE TABLE Cards
(
CardID INT PRIMARY KEY,
BankAccountID INT FOREIGN KEY REFERENCES BankAccounts(BankID),
Number INT,
CVV INT
)

CREATE TABLE ATMs
(
ATMid INT PRIMARY KEY,
AddressOfAtm INT
)

CREATE TABLE Transactions
(
CardID INT FOREIGN KEY REFERENCES Cards(CardID),
ATMid INT FOREIGN KEY REFERENCES ATMs(ATMid),
SumOfMoney INT,
DateTimeOfTr DATETIME
)


GO
CREATE OR ALTER PROCEDURE deleteTrOfCard(@cardID INT) AS
BEGIN
    DELETE FROM Transactions
	WHERE CardID = @cardID 
END

SELECT * FROM ATMs
SELECT * FROM Transactions
SELECT * FROM Cards
SELECT * FROM Transactions
INSERT INTO Transactions(CardID, ATMid, SumOfMoney) Values
(5,1,2254),
(4,5,34),
(5,5,23),
(3,4,155),
(5,5,890)


GO
CREATE VIEW cardsUsedAllATMs AS 
	SELECT C.Number, COUNT(T.ATMid) AS NoOfATMs
	FROM CARDS C
	INNER JOIN Transactions T ON C.CardID = T.CardID
	GROUP BY C.Number
	HAVING COUNT(T.ATMid) = (SELECT COUNT(ATMid) FROM ATMs)

SELECT * FROM cardsUsedAllATMs

SELECT * FROM Transactions


SELECT * FROM Cards

SELECT C.Number, C.CVV
FROM Cards C
INNER JOIN Transactions T ON T.CardID = C.CardID
GROUP BY C.Number, C.CVV
HAVING SUM(T.SumOfMoney) > 2000

GO
CREATE OR ALTER FUNCTION listCards()
RETURNS TABLE 
AS
RETURN
  SELECT C.Number, C.CVV, SUM(T.SumOfMoney) AS SumOfMoney
  FROM Cards C
  INNER JOIN Transactions T ON T.CardID = C.CardID
  GROUP BY C.Number, C.CVV
  HAVING SUM(T.SumOfMoney) > 2000

SELECT * FROM listCards()
