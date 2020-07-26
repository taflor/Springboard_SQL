/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name
FROM Facilities
WHERE membercost > 0;

RESULT:
Tennis Court 1
Tennis Court 2
Massage Room 1
Massage Room 2
Squash Court



/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(*)
FROM Facilities
WHERE membercost = 0;

RESULT: 4



/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost < .2*monthlymaintenance;

RESULT:
0 Tennis Court 1 5.0 200
1 Tennis Court 2 5.0 200
2 Badminton Court 0.0 50
3 Table Tennis 0.0 10
4 Massage Room 1 9.9 3000
5 Massage Room 2 9.9 3000
6 Squash Court 3.5 80
7 Snooker Table 0.0 15
8 Pool Table 0.0 15



/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid IN (1,5);

RESULT:
1 Tennis Court 2 5.0 25.0 8000 200
5 Massage Room 2 9.9 80.0 4000 3000



/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
CASE
    WHEN monthlymaintenance > 100 THEN 'expensive'
    ELSE 'cheap' END AS cost
FROM Facilities;

RESULT:
Tennis Court 1   200   expensive
Tennis Court 2   200   expensive
Badminton Court  50    cheap
Table Tennis     10    cheap
Massage Room 1   3000  expensive
Massage Room 2   3000  expensive
Squash Court     80    cheap
Snooker Table    15    cheap
Pool Table       15    cheap



/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
ORDER BY joindate DESC
LIMIT 0,18446744073709551615;

Used LIMIT with the bigint max value to ensure all rows were listed and the automatically appended LIMIT of 0,30 was not applied.

RESULT: 31 first and last names from most recent date to oldest date.



/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT f.name AS facility, CONCAT(mem_book.firstname, ' ', mem_book.surname) AS member_name
FROM (SELECT firstname, surname, facid
      FROM Members
      INNER JOIN Bookings AS b ON Members.memid = b.memid
      WHERE surname <> 'GUEST') AS mem_book
INNER JOIN Facilities AS f ON mem_book.facid = f.facid
WHERE f.name LIKE 'Tennis%'
ORDER BY member_name;




/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

# COULD NOT GET THIS TO ONLY LIST COSTS GREATER THAN 30 -- PUT THESE AS NULL
SELECT f.name, CONCAT(m.firstname, ' ', m.surname) AS mem_name,
	CASE WHEN b.facid <>0 AND f.membercost * b.slots * 2 > 30
	THEN f.membercost * b.slots * 2
	WHEN b.facid = 0 AND f.guestcost * b.slots * 2 > 30
	THEN f.guestcost * b.slots * 2
	ELSE NULL
	END AS cost
FROM Facilities AS f
INNER JOIN Bookings AS b ON f.facid = b.facid AND b.starttime LIKE '2012-09-14%'
INNER JOIN Members AS m ON b.memid = m.memid
ORDER BY cost DESC
LIMIT 0 , 30

# WITHOUT NULL AND LISTING ALL COSTS
SELECT f.name, CONCAT(m.firstname, ' ', m.surname) AS mem_name,
	CASE WHEN b.facid <>0
	THEN f.membercost * b.slots * 2
	ELSE f.guestcost * b.slots * 2
	END AS cost
FROM Facilities AS f
INNER JOIN Bookings AS b ON f.facid = b.facid AND b.starttime LIKE '2012-09-14%'
INNER JOIN Members AS m ON b.memid = m.memid
ORDER BY cost DESC
LIMIT 0 , 30


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT mem_book.facility, CONCAT(m.firstname, ' ', m.surname) AS mem_name, mem_book.cost
FROM (SELECT b.facid, b.memid, f.name AS facility,
	CASE WHEN b.facid <>0
	THEN f.membercost * b.slots * 2
	ELSE f.guestcost * b.slots * 2
	END AS cost
      FROM Facilities as f
      INNER JOIN Bookings as b ON f.facid = b.facid AND b.starttime LIKE '2012-09-14%') AS mem_book
INNER JOIN Members AS m ON mem_book.memid = m.memid
WHERE cost > 30
ORDER BY cost DESC;



/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT 	book_fac.name AS facility_name,
		sum(book_fac.revenue) AS total_rev
FROM 	(SELECT b.memid, b.facid, f.name, 
         		CASE WHEN b.memid <> 0 
         			THEN f.membercost * b.slots * 2
         		ELSE f.guestcost * b.slots * 2
         			END AS revenue
         FROM Bookings as b
         INNER JOIN Facilities AS f ON b.facid = f.facid) AS book_fac
GROUP BY facility_name
HAVING total_rev < 1000
ORDER BY total_rev;



/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT CONCAT(m.surname,', ', m.firstname) AS Member,
       CONCAT(r.surname, ', ', r.firstname) AS Recommender
FROM Members AS m
INNER JOIN Members AS r ON m.recommendedby = r.memid
WHERE m.memid <> 0 AND r.memid <> 0
ORDER BY m.surname, m.firstname;


/* Q12: Find the facilities with their usage by member, but not guests */

SELECT f.name AS 'Facility', (COUNT(*)*b.slots) AS 'Usage'
FROM Bookings AS b
INNER JOIN Facilities AS f ON b.facid = f.facid
WHERE memid <> 0
GROUP BY f.name;


/* Q13: Find the facilities usage by month, but not guests */
# MYSQL ON PHP MYADMIN
SELECT f.name AS 'Facility', MONTH(b.starttime) AS 'Month', (COUNT(*)*b.slots) AS 'Usage'
FROM Bookings AS b
INNER JOIN Facilities AS f ON b.facid = f.facid
WHERE memid <> 0
GROUP BY MONTH(b.starttime), f.name
ORDER BY f.name, MONTH(b.starttime);

# SQLITE ON LOCAL COMPUTER
SELECT  f.name AS 'Facility',
        strftime('%m',starttime) as 'Month',
        (COUNT(*)*b.slots) AS 'Usage'
FROM Bookings AS b
INNER JOIN Facilities AS f ON b.facid = f.facid
WHERE memid <> 0
GROUP BY strftime('%m',starttime), f.name
ORDER BY f.name, strftime('%m',starttome);
