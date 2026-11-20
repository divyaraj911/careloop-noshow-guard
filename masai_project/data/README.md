# CareLoop Clinics: no-show analysis

**GitHub repo:** <https://github.com/divyaraj911/careloop-noshow-guard/tree/main>

## Summary (one finding per Part)
- **Part 1:** 1,020 raw rows were cleaned to 990 rows (duplicates and rows with missing date or status removed); the no-show rate is 22.0% (218 of 990 bookings).
- **Part 2:** <one finding from your SQL/groupby, e.g. the clinic with the highest no-show % and that number>.
- **Part 3:** On the test set, logistic regression at a threshold of 0.35 has ROC-AUC about 0.79 and precision and recall about 0.57, against a "always Attended" baseline accuracy of 75.25%.
- **Part 4:** Of the first 10 call-centre notes, <X> were valid, <Y> invalid and 1 skipped as blank; <Z> of the 9 non-blank notes gave forgot_or_no_reminder, and both of those appointments had reminder_sent = No.

## Recommendation
<ONE paragraph. Use at least four numbers from YOUR outputs. Example structure: I recommend that the front desk phone the patients our model flags each evening. We chose logistic regression because it had the best cross-validated ROC-AUC (about 0.77 in CV, 0.79 on the test set) and is the simplest model. At the chosen threshold of 0.35 it caught about 57% of real no-shows with precision of about 57%, flagging about 49 of 198 test bookings. Appointments with a reminder had about 69% lower odds of a no-show, and in the notes 5 of 10 belonged to appointments with no reminder, so make sure every booking gets a reminder first. Clinics with less phone capacity can raise the threshold.>

## Limitations
1. The 10 notes are an illustration and cannot show the real reasons clinic-wide.
2. The cleaning statistics (medians and outlier fences) were calculated on all rows before the train/test split, so test rows had a small indirect influence.
3. The same patient can appear in several bookings, so a random split can put one patient in both train and test; the data is also observational, so associations are not causes.

## Files
<list every file from the Submission section>
