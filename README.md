
# Healthcare dataset
## Objective

This project presents an in-depth analysis of a healthcare dataset, focusing on patient visits to hospitals, the amount charged for services, the doctors consulted, and the precautions advised for various diseases. The primary goal is to extract meaningful insights and patterns from the data, which can inform better decision-making in the healthcare sector. The analysis leverages a variety of SQL functionalities to handle complex queries and large datasets efficiently.

## Operation Conducted
- [Appointment and Patient Data].(Appointment and Patient Data(Query Questions)

## Key Features:

- Aggregate Functions: Calculating summary statistics such as averages, sums, counts, and more to understand data distributions and trends.
- Subqueries: Using nested queries to perform complex filtering and data manipulation.
- Joins: Combining data from multiple tables to provide a comprehensive view of the dataset.
- Window Functions: Implementing advanced analytics like running totals, moving averages, and ranking without collapsing the dataset.
- Common Table Expressions (CTEs): Simplifying and organizing complex queries for better readability and maintainability.

## Key Takeaways:

- Enhanced Data Understanding: By integrating multiple data sources, we achieved a comprehensive view of the healthcare dataset, enabling a deeper understanding of patient demographics, treatment patterns, and healthcare outcomes.
- Efficient Data Processing: The use of SQL's powerful querying capabilities allowed for efficient handling of large datasets, ensuring accurate and timely analysis.
- Insightful Analytics: The application of aggregate and window functions facilitated the calculation of essential metrics and the identification of key trends, such as patient flow, billing patterns, and doctor consultation frequencies.
- Readable and Maintainable Queries: The implementation of CTEs improved the readability and maintainability of complex queries, making the analysis process more straightforward and accessible.
- Precautionary Measures: Analyzing the precautions advised for various diseases provided valuable insights into preventive healthcare practices and their effectiveness.

## Conclusion
This project has successfully demonstrated the application of advanced SQL techniques to analyze a healthcare dataset focusing on patient visits, billing, doctor consultations, and disease precautions. Through the use of joins, subqueries, aggregate functions, window functions, and common table expressions (CTEs), we have been able to uncover significant insights and trends within the data.

## Appointment and Patient Data(Query Questions)


- Can we see a list of all our patients along with the date of their last appointment?
```sql  
SELECT 
	P.Patientid, 
	MAX(A.Appointmentdate) 
AS 
	Last_appointment
FROM 
	Patients P
LEFT JOIN 
	Appointmentdetails A
ON 
	P.Patientid = A.Patientid
GROUP BY 
	P.Patientid
ORDER BY 
	P.Patientid 
ASC

```
  
- What's the total amount we've charged each patient?
```sql  
SELECT 
	Patientid, 
	SUM(Amountcharged) 
AS
	Total_amount
FROM 
	Transactions
GROUP BY 
	Patientid
ORDER BY 
	Total_amount 
DESC
```
  
- Which medication do we prescribe the most, and how often?
```sql  
SELECT 
	Medicationname, 
	COUNT(*) 
AS 
	no_time_prescribed, 
	instructions
FROM 
	Medicationsprescribed
GROUP BY 
	Medicationname, 
	Instructions
ORDER BY 
	COUNT(*) 
DESC
LIMIT 1
```
  
- How do we rank our patients by the number of their appointments?
```sql 
SELECT 
	Patientid, 
	count_appointment,
	ROW_NUMBER () OVER(ORDER BY Patientid)
AS 
	rank
FROM (
	SELECT 
		Patientid,
		COUNT(*) 
	AS 
		count_appointment
	FROM 
		AppointmentDetails
	GROUP BY 
		Patientid
)
```
  
- Who are our patients that haven't booked any appointments yet?
```sql 
SELECT 
	A.Appointmentid,
	COALESCE(P.Fullname,'no_data') 
AS 
	full_name
FROM 
	Patients P
LEFT JOIN 
	Appointmentdetails A
ON 
	P.Patientid = A.Patientid
WHERE 
	A.Appointmentid IS NULL
```
  
- Can we track the next appointment date for each patient?
```sql
SELECT 
	Patientid, 
	LAG(Appointmentdate) OVER(PARTITION BY Patientid)
FROM 
	AppointmentDetails
```
  
- Which healthcare professionals haven't seen any patients?
```sql 
SELECT 
	A.Patientid,
	H.Name
FROM 
	HealthcareProfessionals H
RIGHT JOIN 
	Appointmentdetails A
ON 
	H.Name = A.Healthcareprofessional
WHERE 
	A.Appointmentdate IS NULL
```
  
- Can we identify patients who had back-to-back appointments within a 30-day period?
```sql 
SELECT 
	Patientid, 
	Appointmentdate
AS 
	current_appointment,
	LEAD(Appointmentdate) OVER(PARTITION BY Patientid)
AS
	next_appointment
FROM 
	AppointmentDetails
WHERE 
	DATE_TRUNC(Appointmentdate, INTERVAL MONTH)
```
  
- What's the average charge per appointment for each healthcare professional?
```sql 
SELECT 
	H.Name 
AS 
	doctor, 
	ROUND(AVG(T.Amountcharged)) 
AS 
	Averagecharges
FROM 
	HealthcareProfessionals H
INNER JOIN 
	AppointmentDetails A
ON 
	H.Name = A.Healthcareprofessional
LEFT JOIN 
	Transactions T
ON 
	A.Patientid = T.Patientid 
GROUP BY 
	doctor
```

## Medication and Revenue Analysis(Query Questions)
  
- Who's the last patient each healthcare professional saw, and when?
```sql 
SELECT 
	Healthcareprofessional, 
	Patientid, 
	Appointmentdate 
AS 
	last_appointment_date
FROM (
	SELECT 
		Healthcareprofessional, 
		Patientid, 
		Appointmentdate,
		DENSE_RANK() OVER (PARTITION BY Healthcareprofessional ORDER BY Appointmentdate DESC)
	AS 
		rank
	FROM 
		AppointmentDetails
) 
AS 
	ranked_appointments
WHERE 
	rank = 1
```
  
- Which of our patients have been prescribed insulin?
```sql 
SELECT 
	P.Patientid, 
	M.Medicationname
FROM 
	MedicationsPrescribed M
INNER JOIN
	AppointmentDetails A
ON 
	M.Appointmentid = A.Appointmentid
LEFT JOIN 
	Patients P
ON 
	A.Patientid = P.Patientid
WHERE 
	M.Medicationname lIKE '%Insulin%'
GROUP BY 
	P.Patientid, 
	M.Medicationname
```
  
- How can we calculate the total amount charged and the number of appointments for each patient?
```sql 
SELECT 
	T.Patientid, 
	SUM(T.Amountcharged) 
AS 
	total_amoount_charged,
	COUNT(S.Patientid) 
AS 
	number_of_appiontment
FROM 
	Transactions T
INNER JOIN
	Transactions S
ON 
	T.Patientid = S.Patientid
GROUP BY 
	T.Patientid
```
  
- Can we rank our healthcare professionals by the number of unique patients they've seen?
```sql 
SELECT 
	Healthcareprofessional, 
	COUNT(DISTINCT(Patientid)),
	DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT(Patientid))) 
AS 
	RANK
FROM 
	AppointmentDetails
GROUP BY 
	Healthcareprofessional
```

## Advanced Analysis with Subqueries and CTEs(Query Questions)

  
- How does each patient's appointment count compare to the clinic's average?
```sql
WITH Patient_Count AS (
	SELECT 
		Patientid, 
		COUNT(*)
	AS 
		Appointmentdetails
	FROM 
		Appointmentdetails
	GROUP BY 
		Patientid
),

Clinic_Count AS (
	SELECT 
		AVG(Appointmentdetails) 
	AS 
		average_appointment_count
	FROM 
		Patient_count
)

SELECT 
	P.Patientid,
	P.Appointmentdetails,
	C.Average_appointment_count,
CASE
	WHEN P.Appointmentdetails > C.Average_appointment_count 
	THEN 'above average'
	WHEN P.Appointmentdetails < C.Average_appointment_count 
	THEN 'below average'
	WHEN P.Appointmentdetails > C.Average_appointment_count 
	THEN 'equal to average'
END AS Comparisoin
FROM 
	Patient_Count P
CROSS JOIN 
	Clinic_Count C
```
  
- For patients without transactions, can we ensure their total charged amount shows up as zero instead of NULL?
```sql  
WITH Totalcharges AS (
	SELECT 
		Patientid, 
		COALESCE(SUM(Amountcharged), '0') 
	AS 
		total_amount_charged
	FROM 
		Transactions 
	GROUP BY 
		Patientid
)
SELECT 
	Patientid, 
	total_amount_charged
FROM 
	Totalcharges
```
  
- What's the most common medication for each type of diabetes we treat?
```sql 
WITH DiabetesPatients AS (
	SELECT 
		Patientid, 
		Medicalhistorysummary
	FROM 
		Patients
	WHERE 
		Medicalhistorysummary LIKE '%Diabetes%'
),

MedicationCounts AS (
	SELECT 
		DP.Medicalhistorysummary, 
		MP.Medicationname,
 		COUNT(*) 
	AS 
		Medication_count
 	FROM 
		DiabetesPatients DP
 	JOIN 
 		AppointmentDetails AD 
	ON DP.Patientid = AD.Patientid
 	JOIN 
 		MedicationsPrescribed MP 
 	ON 
		AD.Appointmentid = MP.Appointmentid
 	GROUP BY 
		DP.Medicalhistorysummary, MP.Medicationname
),

RankedMedications AS (
	SELECT *, 
	RANK() OVER (PARTITION BY MC.Medicalhistorysummary ORDER BY MC.Medication_count DESC) 
AS 
	RANK
FROM 
	MedicationCounts MC
)

SELECT 
	Medicalhistorysummary, 
	Medicationname, 
	Medication_count
FROM 
	RankedMedications
WHERE rank = 1;
```

- Can we see the growth in appointment numbers from month to month?
```sql
WITH MonthlyAppointmentCounts AS (
	SELECT 
		EXTRACT(MONTH FROM Appointmentdate) 
	AS 
		month,
		COUNT(*) 
	AS 
		Appointment_count
	FROM 
		Appointmentdetails
	GROUP BY 
		EXTRACT(MONTH FROM Appointmentdate)
)

SELECT 
	Month, 
	Appointment_count,
	Appointment_count - LAG(Appointment_count) OVER (ORDER BY Month) AS Growth
FROM 
	MonthlyAppointmentCounts
ORDER BY 
	Month;
```

- How do healthcare professionals' appointments and revenue compare?
```sql
WITH AppointmentCounts AS (
	SELECT 
		HealthcareProfessional 
	AS 
		Doctor_name, 
		COUNT(*) 
	AS 
		num_appointments
	FROM 
		AppointmentDetails
	GROUP BY 
		HealthcareProfessional
),

ProfessionalRevenue AS (
	SELECT 
		A.HealthcareProfessional, 
		SUM(T.AmountCharged) 
	AS 
		total_revenue
	FROM 
		AppointmentDetails A
 	INNER JOIN 
 		Transactions T 
	ON 
		A.Patientid = T.Patientid
	GROUP BY 
		A.HealthcareProfessional
) 

SELECT 
	AC.Doctor_name, 
	AC.num_appointments, 
	PR.total_revenue
FROM 
	AppointmentCounts AC
LEFT JOIN 
	ProfessionalRevenue PR
ON 
	AC.Doctor_name = PR.HealthcareProfessional
```

- Which medications have seen a change in their prescribing rank from month to month?
```sql
WITH MedicationRanks AS (
	SELECT 
		MedicationName,
		EXTRACT(MONTH FROM AppointmentDate) 
	AS 
		Month,
		COUNT(*) 
	AS 
		PrescriptionCount,
 		RANK() OVER (PARTITION BY EXTRACT(MONTH FROM AppointmentDate ORDER BY COUNT(*) DESC)) 
	AS 
		Rank
	FROM 
		MedicationsPrescribed
 	JOIN 
		AppointmentDetails 
	ON 
		MedicationsPrescribed.AppointmentID = AppointmentDetails.AppointmentID
	GROUP BY 
		MedicationName, 
		Month
)

SELECT 
	*,
	LAG(Rank) OVER (PARTITION BY MedicationName ORDER BY Rank) 
AS 
	PreviousRank
FROM 
	MedicationRanks
```
- Can we identify our top 3 most expensive services for each patient?
```sql
WITH RankedServices AS (
	SELECT 
		TransactionID,
		PatientID,
		ServiceProvided,
		AmountCharged,
		dense_RANK() OVER (PARTITION BY PatientID ORDER BY AmountCharged DESC) 
	AS 
		ServiceRank
	FROM 
		Transactions
)

SELECT 
	ServiceProvided,
	MAX(AmountCharged) 
AS 
	max_amount
FROM 
	RankedServices
WHERE 
	ServiceRank <= 3
GROUP BY
	ServiceProvided
ORDER BY
	max_amount 
DESC
limit 3;
```

- Who is our most frequently seen patient in terms of prescriptions, and what medications have they been prescribed?
```sql
WITH PatientPrescriptionCounts AS (
	SELECT 
		AppointmentID,
		COUNT(*) 
	AS 
		PrescriptionCount
	FROM 
		MedicationsPrescribed
	GROUP BY 
	AppointmentID
),

RankedPatients AS (
	SELECT 
		AppointmentID,
		PrescriptionCount,
		RANK() OVER (ORDER BY PrescriptionCount DESC) 	  AS 
		PatientRank
	FROM 
		PatientPrescriptionCounts
)

SELECT 
	Patients.FullName 
AS 
	MostFrequentPatient,
	MedicationsPrescribed.MedicationName
FROM 
	RankedPatients
JOIN 
	MedicationsPrescribed 
ON 
	RankedPatients.AppointmentID = MedicationsPrescribed.AppointmentID
JOIN 
	Patients 
ON 
	RankedPatients.AppointmentID = Patients.PatientID
WHERE 
	PatientRank = 1;
```

- How does our monthly revenue compare to the previous month?
```sql
WITH MonthlyRevenue AS (
	SELECT 
		DATE_TRUNC('month', TransactionDate) 
	AS 
		Month,
		SUM(AmountCharged) 
	AS 
		Revenue
	FROM 
		Transactions
	GROUP BY 
		DATE_TRUNC('month', TransactionDate)
	ORDER BY Month
),

RevenueComparison AS (
	SELECT 
		Month,
		Revenue,
		LAG(Revenue) OVER (ORDER BY Month) 
	AS 
		PreviousMonthRevenue
 	FROM 
		MonthlyRevenue
)

SELECT 
	Month,
	Revenue,
	COALESCE(Revenue - PreviousMonthRevenue, 0) 
AS 
	RevenueChange
FROM 
	RevenueComparison
```
------------- End of Query ----------------
