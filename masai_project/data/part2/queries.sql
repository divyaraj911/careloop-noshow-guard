-- ============================================================
-- CareLoop Clinics - Part 2: SQL
-- Database: noshowguard (MySQL 8)
-- Tip: run one query at a time (select it, then Ctrl + Enter).
-- ============================================================


-- ------------------------------------------------------------
-- Task 2.1: build the database and load Part 1's clean data
-- ------------------------------------------------------------
CREATE DATABASE noshowguard;
USE noshowguard;

CREATE TABLE clinics (
  clinic_id VARCHAR(5) PRIMARY KEY, clinic_name VARCHAR(40) NOT NULL, city VARCHAR(20) NOT NULL,
  tier VARCHAR(10), latitude DECIMAL(8,4), longitude DECIMAL(8,4), temp_c DECIMAL(5,1));

CREATE TABLE appointments (
  appointment_id VARCHAR(8) PRIMARY KEY, patient_id VARCHAR(8) NOT NULL, clinic_id VARCHAR(5) NOT NULL,
  booked_on DATE, appt_date DATE, age INT, gender VARCHAR(1), distance_km DECIMAL(5,1), fee_inr INT,
  booking_channel VARCHAR(10), visit_type VARCHAR(12), reminder_sent VARCHAR(3), prior_no_shows INT,
  status VARCHAR(10), lead_days INT, no_show INT,
  FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id));

-- Now run load_data.sql (File -> Open SQL Script -> Execute).
-- Clinics are inserted first, so the foreign key is happy.

-- Sanity check: expect 8 clinics, 990 appointments, 218 no-shows
SELECT COUNT(*) AS clinics FROM clinics;
SELECT COUNT(*) AS appointments, SUM(no_show) AS no_shows FROM appointments;

-- Duplicate key test: A0001 already exists, so this MUST fail.
-- Result: Error Code: 1062. Duplicate entry 'A0001' for key 'appointments.PRIMARY'
INSERT INTO appointments VALUES
('A0001','P196','C05','2025-01-01','2025-01-22',30,'F',5.0,500,'App','Consultation','Yes',0,'Completed',21,0);


-- ------------------------------------------------------------
-- Task 2.2a: no-show rate by clinic (only clinics with >= 95 appointments)
-- ------------------------------------------------------------
SELECT c.clinic_name, c.city,
       COUNT(*) AS appointments,
       SUM(a.no_show) AS no_shows,
       ROUND(100.0 * SUM(a.no_show) / COUNT(*), 1) AS no_show_pct
FROM appointments a
JOIN clinics c ON a.clinic_id = c.clinic_id
GROUP BY c.clinic_id, c.clinic_name, c.city
HAVING COUNT(*) >= 95
ORDER BY no_show_pct DESC;


-- ------------------------------------------------------------
-- Task 2.2b: same query without the HAVING line (all 8 clinics)
-- Gomti Nagar jumps to the top with 33.3%, but on only 90 appointments.
-- ------------------------------------------------------------
SELECT c.clinic_name, c.city,
       COUNT(*) AS appointments,
       SUM(a.no_show) AS no_shows,
       ROUND(100.0 * SUM(a.no_show) / COUNT(*), 1) AS no_show_pct
FROM appointments a
JOIN clinics c ON a.clinic_id = c.clinic_id
GROUP BY c.clinic_id, c.clinic_name, c.city
ORDER BY no_show_pct DESC;


-- ------------------------------------------------------------
-- Task 2.3: does booking far ahead matter?
-- Band labels come from CASE WHEN. Upper limits are inclusive,
-- so 7, 14 and 30 fall in the lower band.
-- ORDER BY MIN(lead_days) keeps bands in lead-time order
-- (sorting by label text would put '15-30' before '8-14').
-- ------------------------------------------------------------
SELECT CASE
         WHEN lead_days <= 7  THEN '1-7'
         WHEN lead_days <= 14 THEN '8-14'
         WHEN lead_days <= 30 THEN '15-30'
         ELSE '31+'
       END AS lead_band,
       COUNT(*) AS appointments,
       SUM(no_show) AS no_shows,
       ROUND(100.0 * SUM(no_show) / COUNT(*), 1) AS no_show_pct
FROM appointments
GROUP BY lead_band
ORDER BY MIN(lead_days);


-- ------------------------------------------------------------
-- Task 2.4: month-by-month trend
-- monthly CTE, then LAG() for the change vs the previous month
-- (blank for January because there is no earlier month).
-- ------------------------------------------------------------
WITH monthly AS (
  SELECT SUBSTR(appt_date, 1, 7) AS month,
         COUNT(*) AS appointments,
         ROUND(100.0 * SUM(no_show) / COUNT(*), 1) AS no_show_pct
  FROM appointments
  GROUP BY SUBSTR(appt_date, 1, 7)
)
SELECT month, appointments, no_show_pct,
       ROUND(no_show_pct - LAG(no_show_pct) OVER (ORDER BY month), 1) AS change_pp
FROM monthly
ORDER BY month;


-- ------------------------------------------------------------
-- Task 2.5: rank clinics inside each city
-- vs_overall compares each clinic with the overall rate (22.02%)
-- computed in a scalar subquery.
-- ------------------------------------------------------------
WITH clinic_rates AS (
  SELECT c.clinic_name AS clinic, c.city,
         ROUND(100.0 * SUM(a.no_show) / COUNT(*), 1) AS no_show_pct
  FROM appointments a
  JOIN clinics c ON a.clinic_id = c.clinic_id
  GROUP BY c.clinic_id, c.clinic_name, c.city
)
SELECT clinic, city, no_show_pct,
       RANK() OVER (PARTITION BY city ORDER BY no_show_pct DESC) AS rank_in_city,
       CASE
         WHEN no_show_pct > (SELECT 100.0 * SUM(no_show) / COUNT(*) FROM appointments) THEN 'above'
         WHEN no_show_pct < (SELECT 100.0 * SUM(no_show) / COUNT(*) FROM appointments) THEN 'below'
         ELSE 'equal'
       END AS vs_overall
FROM clinic_rates
ORDER BY city, rank_in_city;
