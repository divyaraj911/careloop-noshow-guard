# Part 2 results (SQL)

All queries are in `queries.sql`. Database: `noshowguard` on a local MySQL 8 server.

## Task 2.1: build and load

- Row counts after running `load_data.sql`: 8 clinics, 990 appointments, 218 no-shows. These match the Python numbers from Part 1.
- Inserting a second row with `appointment_id = 'A0001'` failed with:
  `Error Code: 1062. Duplicate entry 'A0001' for key 'appointments.PRIMARY'`
- The primary key on `appointment_id` is doing its job: the database refuses a second booking with the same ID.

## Task 2.2: no-show rate by clinic

With `HAVING COUNT(*) >= 95` (6 clinics):

| clinic_name | city | appointments | no_shows | no_show_pct |
|---|---|---|---|---|
| Hadapsar Care Centre | Pune | 143 | 39 | 27.3 |
| Malviya Nagar Clinic | Jaipur | 142 | 38 | 26.8 |
| Kothrud Family Clinic | Pune | 160 | 36 | 22.5 |
| Vijay Nagar Clinic | Indore | 101 | 21 | 20.8 |
| Edappally Medical Centre | Kochi | 142 | 23 | 16.2 |
| Vaishali Nagar Clinic | Jaipur | 130 | 18 | 13.8 |

- Without the `HAVING` line, Gomti Nagar Care Point (Lucknow) comes out on top at 33.3%, but it has only 90 appointments. Sitabuldi Health Point (Nagpur) also appears, with 82 appointments at 15.9%.
- Why the filter matters: a rate on a small number of appointments swings a lot with just a few extra no-shows, so Gomti Nagar's 33.3% is less trustworthy than Hadapsar's 27.3% on 143 appointments.
- Python check: the `groupby` counts in pandas match the SQL counts. (Confirm this yourself after running the check cell and edit this line if anything differs.)

## Task 2.3: does booking far ahead matter?

| lead_band | appointments | no_shows | no_show_pct |
|---|---|---|---|
| 1-7 | 390 | 63 | 16.2 |
| 8-14 | 304 | 53 | 17.4 |
| 15-30 | 253 | 76 | 30.0 |
| 31+ | 43 | 26 | 60.5 |

- The longer the gap between booking and visit, the more likely the patient is to miss it. Up to 14 days the rate stays around 16-17%, it jumps to 30% for 15-30 days, and 60.5% for bookings made 31+ days ahead.
- The 31+ band is small (43 appointments), but the pattern is very strong.

## Task 2.4: month-by-month trend

| month | appointments | no_show_pct | change (pp) |
|---|---|---|---|
| 2025-01 | 157 | 24.8 | blank |
| 2025-02 | 151 | 20.5 | -4.3 |
| 2025-03 | 142 | 20.4 | -0.1 |
| 2025-04 | 177 | 20.9 | +0.5 |
| 2025-05 | 198 | 23.7 | +2.8 |
| 2025-06 | 165 | 21.2 | -2.5 |

- The monthly rate stays in a fairly narrow band (about 20-25%), with no steady upward or downward trend. January was the highest and the spring months were the lowest.

## Task 2.5: clinics ranked inside each city

The overall no-show rate is 22.02%.

| clinic | city | no_show_pct | rank_in_city | vs_overall |
|---|---|---|---|---|
| Vijay Nagar Clinic | Indore | 20.8 | 1 | below |
| Malviya Nagar Clinic | Jaipur | 26.8 | 1 | above |
| Vaishali Nagar Clinic | Jaipur | 13.8 | 2 | below |
| Edappally Medical Centre | Kochi | 16.2 | 1 | below |
| Gomti Nagar Care Point | Lucknow | 33.3 | 1 | above |
| Sitabuldi Health Point | Nagpur | 15.9 | 1 | below |
| Hadapsar Care Centre | Pune | 27.3 | 1 | above |
| Kothrud Family Clinic | Pune | 22.5 | 2 | above |

- Four clinics are above the overall rate (Malviya Nagar, Gomti Nagar, Hadapsar, Kothrud) and four are below it.
- Jaipur has the widest gap between its two clinics: 26.8% vs 13.8%.
