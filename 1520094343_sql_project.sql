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
FROM `Facilities` 
WHERE membercost > 0
ORDER BY membercost DESC

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT( facid ) AS CountofFreeFacilities
FROM `Facilities`
WHERE membercost =0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM `Facilities` 
WHERE membercost > 0 AND (membercost / monthlymaintenance) * 100 < 20


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT * FROM `Facilities` 
WHERE facid IN (1,2,3,4,5)
ORDER BY facid

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance > 100 THEN 'Expensive'
ELSE 'Cheap' END AS Cost
FROM `Facilities` 

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname, surname FROM `Members` 

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT (
CONCAT( mem.firstname, " ", mem.surname )
), fac.name
FROM `Bookings` book
JOIN `Facilities` fac ON book.facid = fac.facid
JOIN `Members` mem ON book.memid = mem.memid
WHERE book.facid
IN ( 0, 1 )
ORDER BY mem.firstname, fac.name

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT CONCAT( mem.firstname, " ", mem.surname ) AS Full_Name, fac.name,
CASE WHEN (
book.memid >0
AND fac.membercost * book.slots >30
)
THEN fac.membercost * book.slots
WHEN (
book.memid =0
AND fac.guestcost * book.slots >30
)
THEN fac.guestcost * book.slots
ELSE NULL
END AS cost
FROM Bookings book
JOIN Facilities fac ON book.facid = fac.facid
JOIN Members mem ON book.memid = mem.memid
WHERE book.starttime LIKE '2012-09-14%'
ORDER BY cost DESC

/* LAE comment - results show NULL values as well - not sure what I need to do to filter these out */

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT CONCAT( mem.firstname, " ", mem.surname ) AS full_name, costtotal.name, costtotal.cost
FROM Members mem
INNER JOIN (

SELECT book.memid, fac.name,
CASE WHEN (
book.memid >0
AND fac.membercost * book.slots >30
)
THEN fac.membercost * book.slots
WHEN (
book.memid =0
AND fac.guestcost * book.slots >30
)
THEN fac.guestcost * book.slots
ELSE NULL
END AS cost
FROM Bookings book
JOIN Facilities fac ON book.facid = fac.facid
WHERE book.starttime LIKE '2012-09-14%'
ORDER BY cost DESC
) AS costtotal ON mem.memid = costtotal.memid

/* LAE comment - results show NULL values as well - not sure what I need to do to filter these out */

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT sub.name, SUM( sub.revenue ) AS total_rev
FROM (

SELECT fac.name,
CASE WHEN book.memid >0
THEN book.slots * membercost
ELSE book.slots * guestcost
END AS revenue
FROM Bookings book
JOIN Facilities fac ON book.facid = fac.facid
) AS sub
GROUP BY sub.name
HAVING SUM( sub.revenue ) <1000
ORDER BY total_rev