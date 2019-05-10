/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT facid, name, membercost
FROM Facilities
WHERE membercost > 0

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT( membercost ) AS free_membership_count
FROM Facilities
WHERE membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost >0
AND membercost < ( 0.20 * monthlymaintenance )


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid IN (1,5) 

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT `name`, `monthlymaintenance`,
CASE 
WHEN `monthlymaintenance` < 100 THEN "CHEAP"
ELSE "EXPENSIVE" END AS cheap_expensive
FROM Facilities
ORDER BY 2

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT memid, surname, firstname, joindate
FROM Members
ORDER BY 4 DESC

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT b.memid, m.surname, m.firstname, f.name, COUNT(b.facid) AS number_times_booked
FROM Bookings b
JOIN Members m ON m.memid = b.memid
JOIN Facilities f ON f.facid = b.facid
WHERE f.facid IN (0,1)
GROUP BY b.memid, b.facid
ORDER BY m.surname, b.facid

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT b.memid, 'GUEST' as name, b.facid, f.name, f.membercost, f.guestcost,b.slots,f.guestcost*b.slots as total
FROM Bookings b
JOIN Facilities f ON f.facid = b.facid
JOIN Members m ON m.memid = b.memid
WHERE DATE(b.starttime) = '2012-09-14'
AND b.memid = 0

UNION

SELECT b.memid, CONCAT(m.firstname, ' ', m.surname) as name,b.facid, f.name, f.membercost, f.guestcost,b.slots,SUM(f.membercost*b.slots) as total
FROM Bookings b
JOIN Facilities f ON f.facid = b.facid
JOIN Members m ON m.memid = b.memid
WHERE DATE(b.starttime) = '2012-09-14'
AND b.memid != 0
GROUP BY b.memid
HAVING SUM(f.membercost*b.slots) >30
ORDER BY total DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT	g.name,g.memid, g.facid,g.membercost, g.guestcost,g.slots, m.surname AS member,
		g.total
		FROM Members m
		JOIN (SELECT b.memid, f.name, f.facid, f.membercost, f.guestcost, b.slots, b.slots*f.guestcost as total
              FROM Bookings b
              JOIN Facilities f
					ON b.facid = f.facid
 				WHERE DATE(starttime) = '2012-09-14'
			 	AND memid = 0) g            
			ON m.memid = g.memid
		WHERE total > 30

UNION

SELECT  mem.name,mem.memid, mem.facid,mem.membercost, mem.guestcost,mem.slots, concat(m.firstname, ' ', m.surname) AS member,
		mem.total
		FROM Members m
		JOIN(SELECT b.memid, f.name, f.facid, f.membercost,f.guestcost, b.slots, SUM(f.membercost*b.slots) AS total
        FROM Bookings b
		JOIN Facilities f
			ON b.facid = f.facid
		JOIN Members m
			ON m.memid = b.memid
		WHERE DATE(starttime) = '2012-09-14'
		AND m.memid != 0
		GROUP BY m.memid) mem
		ON m.memid = mem.memid
		WHERE total > 30

		ORDER BY total DESC


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT b.facid, f.name,
CASE WHEN b.memid = 0 THEN 'Guest'
ELSE 'Member' END AS boolean_guest,SUM(b.slots) AS total_bookings, f.guestcost, f.membercost,
CASE WHEN b.memid =0 THEN SUM(b.slots)*f.guestcost 
ELSE SUM(b.slots)*f.membercost END AS total_revenue
FROM Bookings b
JOIN Facilities f ON f.facid = b.facid
GROUP BY facid,boolean_guest
HAVING total_revenue < 1000
ORDER BY total_revenue