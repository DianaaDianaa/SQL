/*
Create a database storing data about several Zoos. You will manage zoos, animals, food, visitors and visits.
Each zoo has an id, an administrator, a name and several animals. An animal has an id, a name and date of birth; it can eat various foods, 
the latter consisting of an id and a name. The system stores the daily quota (integer number) for each animal and food, e.g., 
animal Al <food F1, 10; food F2, 5>; animal A2 <food F2, 1; food F5, 2>. 
A visitor is characterized by a personal number (an id), name and age. A visitor can visit several zoos. 
Such a visit is defined by a unique identifier, a day, the paid price, the visitor's personal number and the zoo id.
Requirements:
1. Write an SQL script that creates the corresponding relational data model.
2. Implement a stored procedure that receives an animal and deletes all the data about the food quotas for that animal.
3. Create a view that shows the ids of the zoos with the smallest number of visits. 
4. Implement a function that lists the ids of the visitors who went to zoos that have at least N animals where N=1 is a function parameter.
*/

USE Zoo

CREATE TABLE Zoos
(
ZooID INT PRIMARY KEY,
Administrator VARCHAR(50),
ZooName VARCHAR(50)
)

CREATE TABLE Animals
(
AnimalID INT PRIMARY KEY,
AnimalName VARCHAR(50),
DateOfBirth DATE,
ZooID INT FOREIGN KEY REFERENCES Zoos(ZooID)
)

CREATE TABLE Foods
(
FoodID INT PRIMARY KEY,
FoodName VARCHAR(50)
)

CREATE TABLE AnimalsFoods
(
AnimalID INT FOREIGN KEY REFERENCES Animals(AnimalID),
FoodID INT FOREIGN KEY REFERENCES Foods(FoodID),
Quota INT,
CONSTRAINT PK_AnimalsFoods PRIMARY KEY(AnimalID, FoodID)
)

CREATE TABLE Visitors
(
VisitorID INT PRIMARY KEY,
VisitorName VARCHAR(50),
Age INT
)

CREATE TABLE VisitorsZoos
(
ZooID INT FOREIGN KEY REFERENCES Zoos(ZooID),
VisitorID INT FOREIGN KEY REFERENCES Visitors(VisitorID),
VisitDay DATE,
PaidPrice INT,
CONSTRAINT PK_VisitorsZoos PRIMARY KEY(ZooID, VisitorID)
)

INSERT INTO Animals(AnimalID, AnimalName, ZooID) Values
(1,'a1',1),
(2,'a2',1),
(3,'a3',1),
(4,'a4',2),
(5,'a5',3)

INSERT INTO Foods Values
(1,'f1'),
(2,'f2'),
(3,'f3'),
(4,'f4'),
(5,'f5')

Insert into AnimalsFoods Values
(1,1,3),
(1,2,23),
(3,3,34),
(3,4,7),
(5,4,9)


INSERT INTO Zoos Values
(1,'A1','Zoo1'),
(2,'A2','Zoo2'),
(3,'A3','Zoo3'),
(4,'A4','Zoo4')

INSERT INTO Visitors Values
(1,'Visitor1',30),
(2,'Visitor2',18),
(3,'Visitor3',24),
(4,'Visitor4',32),
(5,'Visitor5',23)

INSERT INTO VisitorsZoos(ZooID,VisitorID) Values
(3,3),
(1,1),
(1,2),
(1,3),
(2,4),
(4,4),
(4,5)


GO
CREATE OR ALTER PROCEDURE deleteFoodForAnimal(@animalID INT) AS
BEGIN
    IF NOT EXISTS(SELECT * FROM Animals A WHERE A.AnimalID = @animalID)
	BEGIN
	    PRINT 'There is no animal with the given id.'
		RETURN
	END

	DELETE FROM AnimalsFoods
	WHERE AnimalID = @animalID
END

select * from AnimalsFoods
EXEC deleteFoodForAnimal 1

GO 
CREATE OR ALTER VIEW zoosSmallestNoOfVist 
AS
  SELECT Z.ZooID, COUNT(*) AS NoOfVisits
  FROM Zoos Z
  INNER JOIN VisitorsZoos VZ ON VZ.ZooID = Z.ZooID
  GROUP BY Z.ZooID
  HAVING COUNT(*) <= ALL (SELECT Z2.ZooID
                          FROM Zoos Z2
                          INNER JOIN VisitorsZoos VZ2 ON VZ2.ZooID = Z2.ZooID
                          GROUP BY Z2.ZooID)


SELECT * FROM Zoos
SELECT * FROM Animals

SELECT COUNT(*) AS AnimalsPerZoo
FROM Zoos Z
INNER JOIN ANIMALS A ON A.ZooID = Z.ZooID
GROUP BY Z.ZooID

SELECT V.VisitorID
FROM Visitors V
INNER JOIN VisitorsZoos VZ ON VZ.VisitorID = V.VisitorID
WHERE VZ.ZooID IN (SELECT Z.ZooID
                   FROM Zoos Z
                   INNER JOIN ANIMALS A ON A.ZooID = Z.ZooID
                   GROUP BY Z.ZooID)
	

SELECT DISTINCT V.VisitorID
FROM Visitors V
INNER JOIN VisitorsZoos VZ ON VZ.VisitorID = V.VisitorID
GROUP BY V.VisitorID, VZ.ZooID
HAVING 2 <= (SELECT count(A.ZooID) as nrOfAnimals
					FROM Animals A inner join VisitorsZoos V2 ON V2.ZooID = A.ZooID inner join Visitors VV2 ON V2.VisitorID = VV2.VisitorID
					WHERE A.ZooID = VZ.VisitorID and V2.ZooID = VZ.ZooID AND V2.VisitorID = V.VisitorID and VV2.VisitorID = V.VisitorID
					GROUP BY V2.ZooID)
