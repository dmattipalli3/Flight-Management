-- CS4400: Introduction to Database Systems: Wednesday, March 8, 2023
-- Flight Management Course Project Mechanics (v1.0) STARTING SHELL
-- Views, Functions & Stored Procedures

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;
set @thisDatabase = 'flight_management';

use flight_management;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [1] add_airplane()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airplane.  A new airplane must be sponsored
by an existing airline, and must have a unique tail number for that airline.
username.  An airplane must also have a non-zero seat capacity and speed. An airplane
might also have other factors depending on it's type, like skids or some number
of engines.  Finally, an airplane must have a database-wide unique location if
it will be used to carry passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airplane;
delimiter //
create procedure add_airplane (in ip_airlineID varchar(50), 
	in ip_tail_num varchar(50),
	in ip_seat_capacity integer, 
    in ip_speed integer, 
    in ip_locationID varchar(50),
    in ip_plane_type varchar(100), 
    in ip_skids boolean, 
    in ip_propellers integer,
    in ip_jet_engines integer)
sp_main: begin
	IF ip_airlineID IN (SELECT airlineID FROM airline) AND
		CONCAT(ip_airlineID, ' ', ip_tail_num) NOT IN (SELECT CONCAT(airlineID, ' ', tail_num) FROM airplane) AND 
		ip_seat_capacity > 0 AND 
		ip_speed > 0 AND 
		(ip_locationID IN (SELECT locationID FROM location) OR ip_locationID IS NULL) AND 
			((ip_plane_type = 'jet' AND ip_skids IS NULL AND ip_propellers IS NULL AND ip_jet_engines > 0) OR
            (ip_plane_type = 'prop' AND ip_skids >= 0 AND ip_propellers > 0 AND ip_jet_engines IS NULL) OR
            (ip_plane_type IS NULL AND ip_skids IS NULL AND ip_propellers IS NULL AND ip_jet_engines IS NULL))
    THEN
		INSERT INTO airplane VALUES
        (ip_airlineID, ip_tail_num, ip_seat_capacity, ip_speed, ip_locationID, ip_plane_type, ip_skids, ip_propellers, ip_jet_engines);
	END IF;
end //
delimiter ;

-- [2] add_airport()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airport.  A new airport must have a unique
identifier along with a database-wide unique location if it will be used to support
airplane takeoffs and landings.  An airport may have a longer, more descriptive
name.  An airport must also have a city and state designation. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airport;
delimiter //
create procedure add_airport (in ip_airportID char(3), 
	in ip_airport_name varchar(200),
    in ip_city varchar(100), 
    in ip_state char(2), 
    in ip_locationID varchar(50))
sp_main: begin
	IF ip_airportID IS NOT NULL AND ip_airportID NOT IN (SELECT airportID FROM airport) AND
		ip_airport_name IS NOT NULL AND
		ip_city IS NOT NULL AND 
		ip_state IS NOT NULL AND
        (ip_locationID IS NULL OR 
			(ip_locationID IS NOT NULL AND 
            ip_locationID IN (SELECT locationID FROM location))) # make sure it's a valid location
            -- AND ip_locationID NOT IN (SELECT locationID FROM airport))) # make sure it's a unique location
	THEN
		INSERT INTO airport VALUES
		(ip_airportID, ip_airport_name, ip_city, ip_state, ip_locationID);
	END IF;
end //
delimiter ;

-- [3] add_person()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new person.  A new person must reference a unique
identifier along with a database-wide unique location used to determine where the
person is currently located: either at an airport, or on an airplane, at any given
time.  A person may have a first and last name as well.

Also, a person can hold a pilot role, a passenger role, or both roles.  As a pilot,
a person must have a tax identifier to receive pay, and an experience level.  Also,
a pilot might be assigned to a specific airplane as part of the flight crew.  As a
passenger, a person will have some amount of frequent flyer miles. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_person;
delimiter //
create procedure add_person (in ip_personID varchar(50), 
	in ip_first_name varchar(100),
    in ip_last_name varchar(100), 
    in ip_locationID varchar(50), 
    in ip_taxID varchar(50),
    in ip_experience integer, 
    in ip_flying_airline varchar(50), 
    in ip_flying_tail varchar(50),
    in ip_miles integer)
sp_main: begin
	IF ip_personID IS NOT NULL AND ip_personID NOT IN (SELECT personID FROM person) AND 
		ip_first_name IS NOT NULL AND
		ip_locationID IN (SELECT locationID FROM location)
    THEN
        INSERT INTO person VALUES (ip_personID, ip_first_name, ip_last_name, ip_locationID);
        
		IF ip_taxID IS NOT NULL AND 
			ip_taxID NOT IN (SELECT taxID FROM pilot) AND 
            ip_experience >= 0 AND
			CONCAT(ip_flying_airline, ' ', ip_flying_tail) IN (SELECT CONCAT(airlineID, ' ', tail_num) FROM airplane) 
        THEN
			INSERT INTO pilot VALUES (ip_personID, ip_taxID, ip_experience, ip_flying_airline, ip_flying_tail);
        END IF; 
	
        IF ip_miles > 0 
        THEN
			INSERT INTO passenger VALUES (ip_personID, ip_miles);
		END IF;

	END IF;
end //
delimiter ;

-- [4] grant_pilot_license()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new pilot license.  The license must reference
a valid pilot, and must be a new/unique type of license for that pilot. */
-- -----------------------------------------------------------------------------
drop procedure if exists grant_pilot_license;
delimiter //
create procedure grant_pilot_license (in ip_personID varchar(50), in ip_license varchar(100))
sp_main: begin
	IF ip_personID IN (SELECT personID FROM pilot) AND (CONCAT(ip_personID, ' ', ip_license) NOT IN
    (SELECT CONCAT(personID, ' ', license) FROM pilot_licenses)) AND ip_license IN ('jet', 'prop', 'testing')
    THEN
			INSERT INTO pilot_licenses VALUES (ip_personID, ip_license);
	END IF;
end //
delimiter ;

-- [5] offer_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new flight.  The flight can be defined before
an airplane has been assigned for support, but it must have a valid route.  Once
an airplane has been assigned, we must also track where the airplane is along
the route, whether it is in flight or on the ground, and when the next action -
takeoff or landing - will occur. */
-- -----------------------------------------------------------------------------
drop procedure if exists offer_flight;
delimiter //
create procedure offer_flight (in ip_flightID varchar(50), in ip_routeID varchar(50),
    in ip_support_airline varchar(50), in ip_support_tail varchar(50), in ip_progress integer,
    in ip_airplane_status varchar(100), in ip_next_time time)
sp_main: begin
	IF ip_flightID NOT IN (SELECT flightID FROM flight) AND ip_flightID IS NOT NULL AND ip_routeID IN
    (SELECT routeID FROM route) AND (CONCAT(ip_support_airline, ' ', ip_support_tail) IN (SELECT CONCAT(airlineID, ' ', tail_num) FROM airplane)
    OR CONCAT(ip_support_airline, ' ', ip_support_tail) IS NULL) AND ip_progress >= 0 AND ip_airplane_status IN (NULL, 'in_flight', 'on_ground')
    THEN
			INSERT INTO flight VALUES (ip_flightID, ip_routeID, ip_support_airline, ip_support_tail, ip_progress, ip_airplane_status, ip_next_time);
	END IF;
end //
delimiter ;

-- [6] purchase_ticket_and_seat()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new ticket.  The cost of the flight is optional
since it might have been a gift, purchased with frequent flyer miles, etc.  Each
flight must be tied to a valid person for a valid flight.  Also, we will make the
(hopefully simplifying) assumption that the departure airport for the ticket will
be the airport at which the traveler is currently located.  The ticket must also
explicitly list the destination airport, which can be an airport before the final
airport on the route.  Finally, the seat must be unoccupied. */
-- -----------------------------------------------------------------------------
drop procedure if exists purchase_ticket_and_seat;
delimiter //
create procedure purchase_ticket_and_seat (in ip_ticketID varchar(50), in ip_cost integer,
	in ip_carrier varchar(50), in ip_customer varchar(50), in ip_deplane_at char(3),
    in ip_seat_number varchar(50))
sp_main: begin
	IF (CONCAT(ip_ticketID, ' ', ip_seat_number) NOT IN (SELECT CONCAT(ticketID, ' ', seat_number) FROM ticket_seats)) AND
    ip_ticketID IS NOT NULL AND ip_seat_number IS NOT NULL AND ip_cost >= 0 AND ip_carrier IN (SELECT flightID FROM flight) AND 
    ip_customer IN (SELECT personID FROM person) AND ip_deplane_at IN (SELECT airportID FROM airport)
	THEN 
		INSERT INTO ticket VALUES (ip_ticketID, ip_cost, ip_carrier, ip_customer, ip_deplane_at);
        INSERT INTO ticket_seats VALUES (ip_ticketID, ip_seat_number);
	END IF;
end //
delimiter ;

-- [7] add_update_leg()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new leg as specified.  However, if a leg from
the departure airport to the arrival airport already exists, then don't create a
new leg - instead, update the existence of the current leg while keeping the existing
identifier.  Also, all legs must be symmetric.  If a leg in the opposite direction
exists, then update the distance to ensure that it is equivalent.   */
-- -----------------------------------------------------------------------------
drop procedure if exists add_update_leg;
delimiter //
create procedure add_update_leg (in ip_legID varchar(50), in ip_distance integer,
    in ip_departure char(3), in ip_arrival char(3))
sp_main: begin
	IF ip_distance > 0 AND ip_departure IN (SELECT airportID FROM airport) AND ip_arrival IN (SELECT airportID FROM airport) THEN
		IF CONCAT(ip_departure, ' ', ip_arrival) IN (SELECT CONCAT(departure, ' ', arrival) FROM leg) THEN
			UPDATE leg SET distance = ip_distance WHERE CONCAT(departure, ' ', arrival) LIKE CONCAT(ip_departure, ' ', ip_arrival);
            IF CONCAT(ip_arrival, ' ', ip_departure) IN (SELECT CONCAT(arrival, ' ', departure) FROM leg) THEN
				UPDATE leg SET distance = ip_distance WHERE CONCAT(arrival, ' ', departure) LIKE CONCAT(ip_arrival, ' ', ip_departure);
			END IF;
		ELSE 
			IF ip_legID IS NOT NULL AND ip_legID NOT IN (SELECT legID FROM leg) THEN
				INSERT INTO leg VALUES (ip_legID, ip_distance, ip_departure, ip_arrival);
			END IF;
		END IF;
    END IF;
end //
delimiter ;

-- [8] start_route()
-- -----------------------------------------------------------------------------
/* This stored procedure creates the first leg of a new route.  Routes in our
system must be created in the sequential order of the legs.  The first leg of
the route can be any valid leg. */
-- -----------------------------------------------------------------------------
drop procedure if exists start_route;
delimiter //
create procedure start_route (in ip_routeID varchar(50), in ip_legID varchar(50))
sp_main: begin
	IF ip_routeID NOT IN (SELECT routeID FROM route) AND ip_routeID IS NOT NULL AND ip_legID IS NOT NULL AND 
    ip_legID IN (SELECT legID FROM leg) THEN
		INSERT INTO route VALUES (ip_routeID);
        INSERT INTO route_path VALUES (ip_routeID, ip_legID, 1);
	END IF;
end //
delimiter ;

-- [9] extend_route()
-- -----------------------------------------------------------------------------
/* This stored procedure adds another leg to the end of an existing route.  Routes
in our system must be created in the sequential order of the legs, and the route
must be contiguous: the departure airport of this leg must be the same as the
arrival airport of the previous leg. */
-- -----------------------------------------------------------------------------
drop procedure if exists extend_route;
delimiter //
create procedure extend_route (in ip_routeID varchar(50), in ip_legID varchar(50))
sp_main: begin
	IF ip_routeID IS NOT NULL AND ip_routeID IN (SELECT routeID FROM route) AND ip_legID IS NOT NULL AND 
    ip_legID IN (SELECT legID FROM leg) THEN
		SET @MAX = (SELECT MAX(sequence) FROM route_path WHERE routeID LIKE ip_routeID);
        SET @PREVIOUS_LEG = (SELECT legID FROM route_path WHERE sequence = @MAX AND routeID LIKE ip_routeID);
        SET @PREVIOUS_ARRIVAL = (SELECT arrival FROM leg WHERE legID = @PREVIOUS_LEG);
        SET @CURRENT_DEPARTURE = (SELECT departure FROM leg WHERE legID LIKE ip_legID);
		IF (@PREVIOUS_ARRIVAL = @CURRENT_DEPARTURE) THEN
			INSERT INTO route_path VALUES (ip_routeID, ip_legID, 1 + @MAX);
		END IF;
	END IF;
end //
delimiter ;

-- [10] flight_landing()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight landing at the next airport
along it's route.  The time for the flight should be moved one hour into the future
to allow for the flight to be checked, refueled, restocked, etc. for the next leg
of travel.  Also, the pilots of the flight should receive increased experience, and
the passengers should have their frequent flyer miles updated. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_landing;
delimiter //
create procedure flight_landing (in ip_flightID varchar(50))
sp_main: begin
	IF ip_flightID IS NOT NULL AND ip_flightID IN (SELECT flightID FROM flight) AND ((SELECT airplane_status 
    FROM flight WHERE flightID LIKE ip_flightID) LIKE 'in_flight') THEN
        
			SET @CURR_LEG = (SELECT legID FROM route_path WHERE CONCAT(routeID, ' ', sequence) LIKE
				(SELECT CONCAT(routeID, ' ', progress) FROM flight WHERE flightID LIKE ip_flightID));
            SET @DISTANCE = (SELECT distance FROM leg WHERE legID LIKE @CURR_LEG);
            SET @PLANE = (SELECT CONCAT(support_airline, ' ', support_tail) FROM flight WHERE flightID LIKE ip_flightID);
            SET @PLANE_LOCATION = (SELECT locationID FROM airplane WHERE CONCAT(airlineID, ' ', tail_num) LIKE @PLANE);
            -- SET @AIRPORT = (SELECT arrival FROM leg WHERE legID = @CURR_LEG);
--             SET @AIRPORT_LOCATION = (SELECT locationID FROM airport WHERE airportID = @AIRPORT);
            
            UPDATE pilot SET experience = (experience + 1) WHERE personID IN (SELECT personID FROM person WHERE locationID 
				LIKE (@PLANE_LOCATION));
            UPDATE passenger SET miles = (miles + @DISTANCE) WHERE personID IN (SELECT personID FROM person WHERE locationID 
				LIKE (@PLANE_LOCATION));
			-- UPDATE person SET locationID = @AIRPORT_LOCATION WHERE locationID = @PLANE_LOCATION;
            UPDATE flight SET airplane_status = 'on_ground', next_time = ADDTIME(next_time, '01:00:00') WHERE flightID LIKE ip_flightID;
		
	END IF; 
end //
delimiter ;

-- [11] flight_takeoff()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight taking off from its current
airport towards the next airport along it's route.  The time for the next leg of
the flight must be calculated based on the distance and the speed of the airplane.
And we must also ensure that propeller driven planes have at least one pilot
assigned, while jets must have a minimum of two pilots. If the flight cannot take
off because of a pilot shortage, then the flight must be delayed for 30 minutes. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_takeoff;
delimiter //
create procedure flight_takeoff (in ip_flightID varchar(50))
sp_main: begin
	IF ip_flightID IS NOT NULL AND ip_flightID IN (SELECT flightID FROM flight) AND (SELECT airplane_status 
 	    FROM flight WHERE flightID LIKE ip_flightID) LIKE 'on_ground' THEN
 			SET @PLANE = (SELECT CONCAT(support_airline, ' ', support_tail) FROM flight WHERE flightID = ip_flightID);
             SET @PLANE_LOCATION = (SELECT locationID FROM airplane WHERE CONCAT(airlineID, ' ', tail_num) = @PLANE);
             SET @PLANE_TYPE = (SELECT plane_type FROM airplane WHERE CONCAT(airlineID, ' ', tail_num) = @PLANE);
 			SET @CURR_LEG = (SELECT legID FROM route_path WHERE CONCAT(routeID, ' ', sequence) LIKE 
             (SELECT CONCAT(routeID, ' ', progress + 1) FROM flight WHERE flightID = ip_flightID));
             SET @NUM_PILOTS = (SELECT COUNT(*) FROM person WHERE personID IN (SELECT personID FROM pilot) 
 				GROUP BY locationID HAVING locationID LIKE (@PLANE_LOCATION));
 			
             IF ((@PLANE_TYPE LIKE 'prop') AND (@NUM_PILOTS < 1)) OR ((@PLANE_TYPE LIKE 'jet') AND (@NUM_PILOTS) < 2) THEN
 				UPDATE flight SET next_time = ADDTIME(next_time, '00:30:00') WHERE flightID LIKE ip_flightID;
 			ELSE 
 				SET @DISTANCE = (SELECT distance FROM leg WHERE legID = @CURR_LEG);
				SET @SPEED = (SELECT speed FROM airplane WHERE CONCAT(airlineID, ' ', tail_num) = @PLANE);
			SET @HR = FLOOR(@DISTANCE / @SPEED);
               SET @MIN = FLOOR(((@DISTANCE / @SPEED) % 1) * 60);
                SET @SEC = FLOOR(((((@DISTANCE / @SPEED) % 1) * 60) % 1) * 60);
                SET @TIME_LEG = REPLACE(TRIM(TRAILING '0'  FROM (TIME(CONCAT(@HR, ':', @MIN, ':', @SEC)))),'.','');
			UPDATE flight SET progress = (progress + 1), next_time = ADDTIME(next_time, @TIME_LEG), airplane_status = 'in_flight'
					WHERE flightID = ip_flightID;
            END IF;
	END IF;
end //
delimiter ;

-- [12] passengers_board()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting on a flight at
its current airport.  The passengers must be at the airport and hold a valid ticket
for the flight. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_board;
delimiter //
create procedure passengers_board (in ip_flightID varchar(50))
sp_main: begin
	IF (ip_flightID IS NOT NULL) AND (ip_flightID IN (SELECT flightID FROM flight)) AND ((SELECT
    airplane_status FROM flight WHERE flightID = ip_flightID) LIKE 'on_ground') THEN
		SET @PLANE = (SELECT CONCAT(support_airline, ' ', support_tail) FROM flight WHERE flightID LIKE ip_flightID);
		SET @PLANE_LOCATION = (SELECT locationID FROM airplane WHERE CONCAT(airlineID, ' ', tail_num) = @PLANE);
        SET @CURR_LEG = (SELECT legID FROM route_path WHERE CONCAT(routeID, ' ', sequence) LIKE 
            (SELECT CONCAT(routeID, ' ', progress) FROM flight WHERE flightID LIKE ip_flightID));
        
        IF ((SELECT progress FROM flight WHERE flightID = ip_flightID) = 0) THEN 
			SET @AIRPORT = (SELECT departure FROM leg WHERE legID = @CURR_LEG);
        ELSE
			SET @AIRPORT = (SELECT arrival FROM leg WHERE legID = @CURR_LEG);
		END IF;
        
        SET @AIRPORT_LOCATION = (SELECT locationID FROM airport WHERE airportID = @AIRPORT);
        SET @PASSENGERS = (SELECT personID FROM person WHERE personID IN (SELECT customer FROM ticket WHERE 
        carrier = ip_flightID) AND locationID LIKE @AIRPORT_LOCATION);
        UPDATE person SET locationID = @PLANE_LOCATION WHERE personID IN (@PASSENGERS);
    END IF;
end //
delimiter ;

-- [13] passengers_disembark()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting off of a flight
at its current airport.  The passengers must be on that flight, and the flight must
be located at the destination airport as referenced by the ticket. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_disembark;
delimiter //
create procedure passengers_disembark (in ip_flightID varchar(50))
sp_main: begin
	 IF (ip_flightID IS NOT NULL) AND (ip_flightID IN (SELECT flightID FROM flight)) AND ((SELECT progress FROM flight 
 		WHERE flightID = ip_flightID) > 0) AND ((SELECT airplane_status FROM flight WHERE flightID = ip_flightID) LIKE 'on_ground') THEN
  		SET @PLANE = (SELECT CONCAT(support_airline, ' ', support_tail) FROM flight WHERE flightID = ip_flightID);
 		SET @PLANE_LOCATION = (SELECT locationID FROM airplane WHERE CONCAT(airlineID, ' ', tail_num) = @PLANE);
   
 		SET @CURR_LEG = (SELECT legID FROM route_path WHERE CONCAT(routeID, ' ', sequence) LIKE 
              (SELECT CONCAT(routeID, ' ', progress + 1) FROM flight WHERE flightID = ip_flightID));
          SET @ARRIVAL_AIRPORT = (SELECT departure FROM leg WHERE legID = @CURR_LEG);
           SET @AIRPORT_LOCATION = (SELECT locationID FROM airport WHERE airportID = @ARRIVAL_AIRPORT);
           SET @PASSENGERS = (SELECT personID FROM person JOIN ticket ON (personID = customer) WHERE
           (deplane_at LIKE @ARRIVAL_AIRPORT) AND (carrier = ip_flightID));
    		(SELECT personID  FROM person WHERE locationID LIKE @PLANE_LOCATION AND personID IN (SELECT customer FROM ticket WHERE 
  			deplane_at = @ARRIVAL_AIRPORT AND carrier = ip_flightID ) );
         UPDATE person SET locationID = @AIRPORT_LOCATION WHERE personID IN (@PASSENGERS);
 	 END IF;
end //
delimiter ;
 -- (locationID LIKE @PLANE_LOCATION) AND 
-- [14] assign_pilot()
-- -----------------------------------------------------------------------------
/* This stored procedure assigns a pilot as part of the flight crew for a given
airplane.  The pilot being assigned must have a license for that type of airplane,
and must be at the same location as the flight.  Also, a pilot can only support
one flight (i.e. one airplane) at a time.  The pilot must be assigned to the flight
and have their location updated for the appropriate airplane. */
-- -----------------------------------------------------------------------------
drop procedure if exists assign_pilot;
delimiter //
create procedure assign_pilot (in ip_flightID varchar(50), ip_personID varchar(50))
sp_main: begin
	IF ip_personID IS NOT NULL AND ip_personID IN (SELECT personID FROM pilot) AND ip_flightID 
    IS NOT NULL AND ip_flightID IN (SELECT flightID FROM flight) AND ((SELECT
    airplane_status FROM flight WHERE flightID = ip_flightID) LIKE 'on_ground') THEN
		SET @PLANE = (SELECT CONCAT(support_airline, ' ', support_tail) FROM flight WHERE flightID = ip_flightID);
		SET @PLANE_LOCATION = (SELECT locationID FROM airplane WHERE CONCAT(airlineID, ' ', tail_num) = @PLANE);
        SET @CURR_LEG = (SELECT legID FROM route_path WHERE CONCAT(routeID, ' ', sequence) LIKE 
            (SELECT CONCAT(routeID, ' ', progress) FROM flight WHERE flightID = ip_flightID));
		SET @PROGRESS = (SELECT progress FROM flight WHERE flightID = ip_flightID);
        
        IF (@PROGRESS = 0) THEN 
			SET @AIRPORT = (SELECT departure FROM leg WHERE legID = @CURR_LEG);
        ELSE
			SET @AIRPORT = (SELECT arrival FROM leg WHERE legID = @CURR_LEG);
		END IF;

        SET @AIRPORT_LOCATION = (SELECT locationID FROM airport WHERE airportID = @AIRPORT);
        SET @PLANE_TYPE = (SELECT plane_type FROM airplane WHERE CONCAT(airlineID, ' ', tail_num) = @PLANE);
        SET @PILOT_LICENSES = (SELECT license FROM pilot_licenses WHERE personID = ip_personID);
        SET @PILOT_LOCATION = (SELECT locationID FROM person WHERE personID = ip_personID);
        SET @PILOT_FLIGHT_ASSIGNMENT = (SELECT CONCAT(flying_airline, ' ',flying_tail) FROM pilot WHERE personID = ip_personID);
        SET @AIRLINE = (SELECT support_airline FROM flight WHERE flightID = ip_flightID);
        SET @TAIL = (SELECT support_tail FROM flight WHERE flightID = ip_flightID);
        
        IF (@PLANE_TYPE IN (@PILOT_LICENSES) AND (@PILOT_LOCATION LIKE @AIRPORT_LOCATION) AND ((@PILOT_FLIGHT_ASSIGNMENT) IS NULL)) THEN
			UPDATE person SET locationID = @PLANE_LOCATION WHERE personID = ip_personID;
			UPDATE pilot SET flying_airline = (@AIRLINE), flying_tail = (@TAIL) WHERE personID = ip_personID;
        END IF;
	END IF;
end //
delimiter ;

-- [15] recycle_crew()
-- -----------------------------------------------------------------------------
/* This stored procedure releases the assignments for a given flight crew.  The
flight must have ended, and all passengers must have disembarked. */
-- -----------------------------------------------------------------------------
drop procedure if exists recycle_crew;
delimiter //
create procedure recycle_crew (in ip_flightID varchar(50))
sp_main: begin

     IF (ip_flightID IS NOT NULL) AND (ip_flightID IN (SELECT flightID FROM flight)) AND ((SELECT airplane_status 
     FROM flight WHERE flightID = ip_flightID) LIKE 'on_ground') THEN
        SET @PLANE = (SELECT CONCAT(support_airline, ' ', support_tail) FROM flight WHERE flightID = ip_flightID);
        SET @PLANE_LOCATION = (SELECT locationID FROM airplane WHERE CONCAT(airlineID, ' ', tail_num) = @PLANE);

        SET @FLIGHT_ROUTE = (SELECT routeID FROM flight WHERE flightID = ip_flightID);
        SET @FLIGHT_PROGRESS = (SELECT progress FROM flight WHERE flightID = ip_flightID);
        SET @TOTAL_LEGS_IN_ROUTE = (SELECT MAX(sequence) FROM route_path GROUP BY routeID HAVING routeID = (@FLIGHT_ROUTE));
        SET @NUM_PASSENGERS = (SELECT COUNT(*) FROM person WHERE personID NOT IN (SELECT personID FROM pilot WHERE 
        CONCAT(flying_airline, ' ', flying_tail) LIKE @PLANE) GROUP BY locationID HAVING (locationID LIKE @PLANE_LOCATION));
        
        
        IF (@FLIGHT_PROGRESS = @TOTAL_LEGS_IN_ROUTE) THEN
            SET @CURR_LEG = (SELECT legID FROM route_path WHERE CONCAT(routeID, ' ', sequence) LIKE 
                    (SELECT CONCAT(routeID, ' ', progress) FROM flight WHERE flightID = ip_flightID));
            SET @ARRIVAL_AIRPORT = (SELECT arrival FROM leg WHERE legID = @CURR_LEG);
            SET @AIRPORT_LOCATION = (SELECT locationID FROM airport WHERE airportID = @ARRIVAL_AIRPORT);

            SET @PILOTS = (
    SELECT GROUP_CONCAT(pilot.personID)
    FROM pilot
    INNER JOIN flight
        ON CONCAT(pilot.flying_airline, ' ', pilot.flying_tail) = CONCAT(flight.support_airline, ' ', flight.support_tail)
    WHERE flight.flightID = ip_flightID
        AND pilot.flying_airline IS NOT NULL
        AND pilot.flying_tail IS NOT NULL
);

UPDATE person 
SET locationID = @AIRPORT_LOCATION 
WHERE personID IN (
    SELECT personID 
    FROM (
        SELECT p.personID 
        FROM pilot p 
        INNER JOIN flight f ON CONCAT(p.flying_airline, ' ', p.flying_tail) = CONCAT(f.support_airline, ' ', f.support_tail)
        WHERE f.flightID = ip_flightID
        AND p.flying_airline IS NOT NULL
        AND p.flying_tail IS NOT NULL
    ) AS temp
);

UPDATE pilot p
INNER JOIN (
    SELECT personID 
    FROM (
        SELECT p.personID 
        FROM pilot p 
        INNER JOIN flight f ON CONCAT(p.flying_airline, ' ', p.flying_tail) = CONCAT(f.support_airline, ' ', f.support_tail)
        WHERE f.flightID = ip_flightID
        AND p.flying_airline IS NOT NULL
        AND p.flying_tail IS NOT NULL
    ) AS temp
) AS temp2 ON p.personID = temp2.personID 
SET p.flying_airline = NULL, p.flying_tail = NULL;


        END IF;
    END IF;
end //
delimiter ;

-- [16] retire_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a flight that has ended from the system.  The
flight must be on the ground, and either be at the start its route, or at the
end of its route.  */
-- -----------------------------------------------------------------------------
drop procedure if exists retire_flight;
delimiter //
create procedure retire_flight (in ip_flightID varchar(50))
sp_main: begin
	IF ip_flightID IS NOT NULL AND ip_flightID IN (SELECT flightID FROM flight) AND ((SELECT airplane_status FROM flight
    WHERE flightID = ip_flightID) = 'on_ground') THEN 
		-- AND ((SELECT COUNT(*) FROM ticket GROUP BY carrier HAVING carrier = ip_flightID) = 0)
		SET @FLIGHT_ROUTE = (SELECT routeID FROM flight WHERE flightID = ip_flightID);
        SET @FLIGHT_PROGRESS = (SELECT progress FROM flight WHERE flightID = ip_flightID);
        IF ((@FLIGHT_PROGRESS = 0) OR (@FLIGHT_PROGRESS = (SELECT MAX(sequence) FROM route_path GROUP BY routeID HAVING 
        routeID = (@FLIGHT_ROUTE)))) THEN
			DELETE FROM flight WHERE flightID = ip_flightID;
        END IF;
	END IF;
end //
delimiter ;

-- [17] remove_passenger_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes the passenger role from person.  The passenger
must be on the ground at the time; and, if they are on a flight, then they must
disembark the flight at the current airport.  If the person had both a pilot role
and a passenger role, then the person and pilot role data should not be affected.
If the person only had a passenger role, then all associated person data must be
removed as well. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_passenger_role;
delimiter //
create procedure remove_passenger_role (in ip_personID varchar(50))
sp_main: begin
	IF (ip_personID IS NOT NULL) AND (ip_personID IN (SELECT personID FROM passenger)) THEN
		IF ((SELECT locationID FROM person WHERE personID = ip_personID) LIKE ('port_%')) THEN
			IF (ip_personID NOT IN (SELECT personID FROM pilot)) THEN
				DELETE FROM passenger WHERE personID = ip_personID;
                DELETE FROM person WHERE personID = ip_personID;
			END IF;
			IF (ip_personID IN (SELECT personID FROM pilot)) THEN
				DELETE FROM passenger WHERE personID = ip_personID;
			END IF;
		END IF;
        IF ((SELECT locationID FROM person WHERE personID = ip_personID) LIKE ('plane_%')) THEN
			SET @PLANE_LOCATION = (SELECT locationID FROM person WHERE personID = ip_personID);
			SET @PLANE = (SELECT CONCAT(flying_airline, ' ', flying_tail) FROM airplane WHERE locationID LIKE (@PLANE_LOCATION));
            SET @FLIGHT = (SELECT flightID FROM flight WHERE CONCAT(support_airline, ' ', support_tail) LIKE @PLANE);
            SET @CURR_LEG = (SELECT legID FROM route_path WHERE CONCAT(routeID, ' ', sequence) LIKE 
				(SELECT CONCAT(routeID, ' ', progress) FROM flight WHERE flightID = @FLIGHT));
            SET @ARRIVAL_AIRPORT = (SELECT arrival FROM leg WHERE legID = @CURR_LEG);
            SET @AIRPORT_LOCATION = (SELECT locationID FROM airport WHERE airportID = @ARRIVAL_AIRPORT);
            IF ((SELECT airplane_status FROM flight WHERE flightID LIKE (@FLIGHT)) LIKE 'on_ground') THEN
				UPDATE person SET locationID = @AIRPORT_LOCATION WHERE personID = ip_personID;
                IF (ip_personID NOT IN (SELECT personID FROM pilot)) THEN
					DELETE FROM passenger WHERE personID = ip_personID;
					DELETE FROM person WHERE personID = ip_personID;
				END IF;
				IF (ip_personID IN (SELECT personID FROM pilot)) THEN
					DELETE FROM passenger WHERE personID = ip_personID;
				END IF;
			END IF;
		END IF;
	END IF;
end //
delimiter ;

-- [18] remove_pilot_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes the pilot role from person.  The pilot must not
be assigned to a flight; or, if they are assigned to a flight, then that flight
must either be at the start or end of its route.  If the person had both a pilot
role and a passenger role, then the person and passenger role data should not be
affected.  If the person only had a pilot role, then all associated person data
must be removed as well. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_pilot_role;
delimiter //
create procedure remove_pilot_role (in ip_personID varchar(50))
sp_main: begin
	IF (ip_personID IS NOT NULL) AND (ip_personID IN (SELECT personID FROM pilot)) THEN
		SET @PLANE = (SELECT CONCAT(flying_airline, ' ', flying_tail) FROM pilot WHERE personID = ip_personID);
        
        IF (@PLANE IS NULL) THEN
			IF (ip_personID NOT IN (SELECT personID FROM passenger)) THEN
				DELETE FROM pilot_licenses WHERE personID = ip_personID;
				DELETE FROM pilot WHERE personID = ip_personID;
                DELETE FROM person WHERE personID = ip_personID;
                -- remove ticket and seat ?? 
			END IF;
            IF (ip_personID IN (SELECT personID FROM passenger)) THEN
				DELETE FROM pilot_licenses WHERE personID = ip_personID;
                DELETE FROM pilot WHERE personID = ip_personID;
            END IF;
		END IF;
        IF (@PLANE IS NOT NULL) THEN
			SET @FLIGHT = (SELECT flightID FROM flight WHERE CONCAT(support_airline, ' ', support_tail) LIKE @PLANE);
			SET @FLIGHT_ROUTE = (SELECT routeID FROM flight WHERE flightID = @FLIGHT);
			SET @FLIGHT_PROGRESS = (SELECT progress FROM flight WHERE flightID = @FLIGHT);
			SET @TOTAL_LEGS_IN_ROUTE = (SELECT MAX(sequence) FROM route_path GROUP BY routeID HAVING routeID = (@FLIGHT_ROUTE));

			IF (@FLIGHT_PROGRESS = 0) OR (@FLIGHT_PROGRESS = @TOTAL_LEGS_IN_ROUTE) THEN
				IF (ip_personID NOT IN (SELECT personID FROM passenger)) THEN
					DELETE FROM pilot_licenses WHERE personID = ip_personID;
					DELETE FROM pilot WHERE personID = ip_personID;
					DELETE FROM person WHERE personID = ip_personID;
					-- remove ticket and seat ?? 
				END IF;
				IF (ip_personID IN (SELECT personID FROM passenger)) THEN
					DELETE FROM pilot_licenses WHERE personID = ip_personID;
					DELETE FROM pilot WHERE personID = ip_personID;
				END IF;
			END IF;
        END IF;
	END IF;
end //
delimiter ;

-- [19] flights_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_in_the_air (departing_from, arriving_at, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as
select l.departure AS departing_from,
  l.arrival AS arriving_at,
  COUNT(*) AS num_flights,
  GROUP_CONCAT(DISTINCT f.flightID) AS flight_list,
  MIN(f.next_time) AS earliest_arrival,
  MAX(f.next_time) AS latest_arrival,
  GROUP_CONCAT(DISTINCT a.locationID) AS airplane_list
FROM flight f
JOIN route_path rc ON f.routeID = rc.routeID and f.progress = rc.sequence 
JOIN leg l ON rc.legID = l.legID
JOIN airplane a ON f.support_airline = a.airlineID and f.support_tail = a.tail_num
WHERE f.airplane_status = 'in_flight'  
GROUP BY l.departure, l.arrival, a.airlineID, a.tail_num;


-- [20] flights_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_on_the_ground (departing_from, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as 
select l.departure AS departing_from,
COUNT(*) AS num_flights,
GROUP_CONCAT(DISTINCT f.flightID) AS flight_list,
MIN(f.next_time) AS earliest_arrival,
MAX(f.next_time) AS latest_arrival,
GROUP_CONCAT(DISTINCT a.locationID) AS airplane_list
FROM flight f
JOIN route_path rc ON f.routeID = rc.routeID
JOIN leg l ON rc.legID = l.legID
JOIN airplane a ON f.support_airline = a.airlineID and f.support_tail = a.tail_num
WHERE f.airplane_status = 'on_ground' and f.progress + 1 = rc.sequence 
GROUP BY l.departure, l.arrival, a.airlineID, a.tail_num;


-- [21] people_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently airborne are located. */
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW people_in_the_air (departing_from, arriving_at, num_airplanes,
    airplane_list, flight_list, earliest_arrival, latest_arrival, num_pilots,
    num_passengers, joint_pilots_passengers, person_list) AS
 SELECT
  l.departure AS departing_from,
  l.arrival AS arriving_at,
  COUNT(DISTINCT a.locationID) AS num_airplanes,
  GROUP_CONCAT(DISTINCT a.locationID) AS airplane_list,
  GROUP_CONCAT(DISTINCT f.flightID) AS flight_list,
  MIN(f.next_time) AS earliest_arrival,
  MAX(f.next_time) AS latest_arrival,
  COUNT(DISTINCT pi.personID) AS num_pilots,
  COUNT(DISTINCT ps.personID) AS num_passengers,
  COUNT(DISTINCT pi.personID) + COUNT(DISTINCT ps.personID) AS joint_pilots_passengers,
(SELECT GROUP_CONCAT(DISTINCT personID) FROM (
    SELECT pi.personID FROM pilot pi 
    WHERE pi.flying_airline = f.support_airline AND pi.flying_tail = f.support_tail
    UNION 
    SELECT ps.personID FROM passenger ps 
    JOIN ticket t ON t.customer = ps.personID AND t.carrier = f.flightID
    JOIN airplane a ON f.support_airline = a.airlineID AND f.support_tail = a.tail_num
    JOIN person p ON p.personID = ps.personID
    WHERE a.locationID LIKE 'plane%' AND p.locationID LIKE 'plane%'
) subquery) AS person_list
FROM flight f
JOIN route_path rc ON f.routeID = rc.routeID 
JOIN leg l ON rc.legID = l.legID
JOIN airplane a ON f.support_airline = a.airlineID AND f.support_tail = a.tail_num
JOIN ticket t ON t.carrier = f.flightID AND f.progress = rc.sequence
JOIN pilot pi ON pi.flying_airline = f.support_airline AND pi.flying_tail = f.support_tail AND t.carrier = f.flightID 
JOIN person p ON p.personID = t.customer AND p.locationID LIKE ('plane%')
JOIN passenger ps ON ps.personID = p.personID 
WHERE f.airplane_status = 'in_flight' 
GROUP BY l.departure, l.arrival, a.airlineID, a.tail_num, f.flightID;
    
-- [22] people_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently on the ground are located. */
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW people_on_the_ground (
    departing_from, airport, airport_name, city, state, 
    num_pilots, num_passengers, joint_pilots_passengers, person_list
) AS
SELECT  
    Distinct ap.airportID AS departing_from,
    ap.locationID AS location_id,
    ap.airport_name AS airport_name,
    ap.city,
    ap.state,
    COUNT(DISTINCT pi.personID) AS num_pilots,
    COUNT(DISTINCT ps.personID) AS num_passengers,
    COUNT(DISTINCT p.personID) AS joint_pilots_passengers,
GROUP_CONCAT(DISTINCT p.personID SEPARATOR ',') as person_list

FROM 
person p 
JOIN airport ap on ap.locationID = p.locationID and ap.locationID like ('port%')
LEFT JOIN pilot pi ON pi.personID = p.personID 
LEFT JOIN passenger ps ON ps.personID = p.personID     
WHERE 
    p.locationID like ('port%') 
GROUP BY 
    ap.airportID;

-- [23] route_summary()
-- -----------------------------------------------------------------------------
/* This view describes how the routes are being utilized by different flights. */
-- -----------------------------------------------------------------------------
create or replace view route_summary (route, num_legs, leg_sequence, route_length,
	num_flights, flight_list, airport_sequence) as
SELECT 
    r.routeID AS route,
    COUNT(DISTINCT l.legID) AS num_legs,
    GROUP_CONCAT(DISTINCT l.legID ORDER BY rc.sequence ASC SEPARATOR ',') AS leg_sequence,
    -- SUM(l.distance) AS route_length,
      (
        SELECT SUM(distance)
        FROM leg
        WHERE legID IN (SELECT legID FROM route_path WHERE routeID = r.routeID)
    ) AS route_length,
    COUNT(DISTINCT f.flightID) AS num_flights,
    GROUP_CONCAT(DISTINCT f.flightID SEPARATOR ',') AS flight_list,
    GROUP_CONCAT(DISTINCT CONCAT(l.departure,'->', l.arrival)  ORDER BY rc.sequence ASC SEPARATOR ',') AS airport_sequence
FROM 
    route r
    JOIN route_path rc ON r.routeID = rc.routeID
    JOIN leg l ON l.legID = rc.legID
    JOIN airport ap ON ap.airportID = l.departure OR ap.airportID = l.arrival
    LEFT JOIN flight f ON f.routeID = r.routeID
GROUP BY 
    r.routeID;

-- [24] alternative_airports()
-- -----------------------------------------------------------------------------
/* This view displays airports that share the same city and state. */
-- -----------------------------------------------------------------------------
create or replace view alternative_airports (city, state, num_airports,
	airport_code_list, airport_name_list) as
select a1.city,
  a1.state,
  COUNT(*) AS num_airports,
  GROUP_CONCAT(DISTINCT a1.airportID ORDER BY a1.airportID SEPARATOR ',') AS airport_code_list,
  GROUP_CONCAT(DISTINCT a1.airport_name ORDER BY a1.airportID SEPARATOR ',') AS airport_name_list
FROM
  airport a1
  INNER JOIN airport a2 ON a1.city = a2.city AND a1.state = a2.state AND a1.airportID != a2.airportID
GROUP BY
  a1.city,
  a1.state;

-- [25] simulation_cycle()
-- -----------------------------------------------------------------------------
/* This stored procedure executes the next step in the simulation cycle.  The flight
with the smallest next time in chronological order must be identified and selected.
If multiple flights have the same time, then flights that are landing should be
preferred over flights that are taking off.  Similarly, flights with the lowest
identifier in alphabetical order should also be preferred.

If an airplane is in flight and waiting to land, then the flight should be allowed
to land, passengers allowed to disembark, and the time advanced by one hour until
the next takeoff to allow for preparations.

If an airplane is on the ground and waiting to takeoff, then the passengers should
be allowed to board, and the time should be advanced to represent when the airplane
will land at its next location based on the leg distance and airplane speed.

If an airplane is on the ground and has reached the end of its route, then the
flight crew should be recycled to allow rest, and the flight itself should be
retired from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists simulation_cycle;
delimiter //
create procedure simulation_cycle ()
sp_main: begin
SET @MIN = (SELECT MIN(next_time) FROM flight);
SET @FLIGHT = (SELECT flightID FROM flight WHERE next_time IN (@MIN));
SET @COUNT = (SELECT COUNT(*) FROM flight WHERE  flightID IN (@FLIGHT) GROUP BY flightID );

IF ( @COUNT > 1) THEN
     IF ((SELECT flightID from flight WHERE airplane_status = 'in_flight' AND flightID IN (@FLIGHT)) IS NOT NULL) THEN
     SET @FLIGHT = (SELECT flightID from flight WHERE airplane_status = 'in_flight' AND flightID IN (@FLIGHT));
	END IF;

SET @MIN_IDENTIFIER = (SELECT MIN(CONCAT(support_airline, ' ', support_tail)) FROM flight);
SET @FLIGHT = (SELECT flightID from flight WHERE CONCAT(support_airline, ' ', support_tail) LIKE @MIN_IDENTIFIER AND flightID IN (@FLIGHT));
END IF;

IF (SELECT airplane_status FROM flight WHERE flightID in (@FLIGHT) AND airplane_status LIKE 'in_flight') THEN
    CALL flight_landing(@FLIGHT);
	CALL passengers_disembark(@FLIGHT);
ELSE
      SET @FLIGHT_ROUTE = (SELECT routeID FROM flight WHERE flightID IN (@FLIGHT));
	  SET @FLIGHT_PROGRESS = (SELECT progress FROM flight WHERE flightID IN (@FLIGHT));
      SET @TOTAL_LEGS_IN_ROUTE = (SELECT MAX(sequence) FROM route_path GROUP BY routeID HAVING routeID = (@FLIGHT_ROUTE));
                 IF (@FLIGHT_PROGRESS = @TOTAL_LEGS_IN_ROUTE) THEN
						CALL recycle_crew(@FLIGHT);
						CALL retire_flight(@FLIGHT);
                  ELSE
						CALL flight_takeoff(@FLIGHT);
                        CALL passengers_board(@FLIGHT);
                 END IF;
END IF;
end //
delimiter ;
