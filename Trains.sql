/*
Create a database to manage train schedules. The database will store data about the routes of all the trains. 
The entities of interest to the problem domain are: Trains, Train Types, Stations, and Routes. 
Each train has a name and belongs to a type. The train type has only a description.
Each station has a name. Station names are unique. Each route has a name, an associated train, 
and a list of stations with arrival and departure times in each station. Route names are unique.
The arrival and departure times are represented as hour:minute pairs, e.g., train arrives at 5pm and leaves at 5:10pm.
1) Write an SQL script that creates the corresponding relational data model.
(2) Implement a stored procedure that receives a route, a station, arrival and departure times, and adds the station to the route. 
If the station is already on the route, the arrival and departure times are updated
3) Create a view that shows the names of the routes that pass through all the stations.
4) Implement a function that lists the names of the stations with more than R routes, where R>=1 is a function parameter.
*/

CREATE TABLE TrainTypes
(
TypeID INT PRIMARY KEY,
TypeDescription VARCHAR(100)
)

INSERT INTO TrainTypes VALUES
(1,'Type1'),
(2,'Type2'),
(3,'Type3'),
(4,'Type4'),
(5,'Type5')

CREATE TABLE Trains
(
TrainID INT PRIMARY KEY,
TrainName VARCHAR(50),
TypeID INT FOREIGN KEY REFERENCES TrainTypes(TypeID)
)

INSERT INTO TRAINS VALUES
(1,'Train1',2),
(2,'Train2',5),
(3,'Train3',4),
(4,'Train4',2),
(5,'Train5',1)

CREATE TABLE Stations
(
StationID INT PRIMARY KEY,
StationName VARCHAR(50) UNIQUE
)

INSERT INTO Stations VALUES
(1,'Station1'),
(2,'Station2'),
(3,'Station3'),
(4,'Station4'),
(5,'Station5')

CREATE TABLE Routes
(
RouteID INT PRIMARY KEY,
RouteName VARCHAR(50) UNIQUE,
TrainID INT FOREIGN KEY REFERENCES Trains(TrainID)
)

INSERT INTO Routes VALUES
(1,'Route1',1),
(2,'Route2',1),
(3,'Route3',5),
(4,'Route4',3),
(5,'Route5',5)

CREATE TABLE Stops
(
RouteID INT FOREIGN KEY REFERENCES Routes(RouteID),
StationID INT FOREIGN KEY REFERENCES Stations(StationID),
Arrival TIME,
Departure TIME,
CONSTRAINT PK_Stops PRIMARY KEY(RouteID,StationID)
)

INSERT INTO Stops Values
(2,4,'19:00','12:00')


GO
CREATE OR ALTER PROCEDURE addStop(@routeID INT, @stationID INT, @arrival TIME, @departure TIME) AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Routes R WHERE R.RouteID = @routeID)
	   BEGIN
	       PRINT 'There is no such route.'
		   RETURN
	   END

	IF NOT EXISTS (SELECT * FROM Stations S WHERE S.StationID = @stationID)
	   BEGIN
	       PRINT 'There is no such station.'
		   RETURN
	   END

    IF EXISTS (SELECT * FROM Stops S WHERE S.RouteID = @routeID AND S.StationID = @stationID)
	   BEGIN
	      UPDATE Stops 
		  SET Arrival = @arrival, Departure = @departure
		  WHERE RouteID = @routeID AND StationID = @stationID
	   END
	ELSE
	   BEGIN
	      INSERT INTO Stops VALUES(@routeID,@stationID,@arrival,@departure)
	   END
END


SELECT * FROM Stations
SELECT * FROM Routes
SELECT * FROM Stops

GO
CREATE OR ALTER VIEW showRoutes AS
   SELECT R.RouteName
   FROM Routes R
   INNER JOIN Stops S ON S.RouteID = R.RouteID
   GROUP BY R.RouteName
   HAVING COUNT(*) = (SELECT COUNT(SS.StationID) FROM Stations SS)


SELECT * FROM Stops

CREATE FUNCTION showStations(@R INT)
RETURNS TABLE
AS
RETURN
    SELECT S.StationName, COUNT(S.StationName) AS NoOfRoutes
    FROM Stations S
    INNER JOIN Stops SS ON SS.StationID = S.StationID
    GROUP BY (S.StationName)
    HAVING COUNT(*) > @R

SELECT * FROM showStations(2)