'''ADVANCE SQL'''

--Appointment and Patient Data


--1.Can we see a list of all our patients along with the date of their last appointment?
  
SELECT P.Patientid, MAX(A.Appointmentdate) as Last_appointment
FROM Patients P
LEFT JOIN 
Appointmentdetails A
ON P.Patientid = A.Patientid
GROUP BY P.Patientid
ORDER BY P.Patientid ASC
  
--2.What's the total amount we've charged each patient?"
  
SELECT Patientid, SUM(Amountcharged) as Total_amount
FROM Transactions
GROUP BY Patientid
ORDER BY Total_amount DESC

  
--3. "Which medication do we prescribe the most, and how often?"
  
SELECT Medicationname, COUNT(*) AS no_time_prescribed, instructions
FROM Medicationsprescribed
GROUP BY Medicationname, Instructions
ORDER BY COUNT(*) DESC
LIMIT 1

  
--4. "How do we rank our patients by the number of their appointments?"
  
SELECT Patientid, count_appointment,
ROW_NUMBER () OVER(ORDER BY Patientid) AS rank
FROM (
SELECT Patientid,
 COUNT(*) AS count_appointment
 FROM AppointmentDetails
 GROUP BY Patientid
)

  
--5. Who are our patients that haven't booked any appointments yet?"
  
SELECT A.Appointmentid,
COALESCE(P.Fullname,'no_data') AS full_name
FROM Patients P
LEFT JOIN Appointmentdetails A
ON P.Patientid = A.Patientid
WHERE A.Appointmentid IS NULL

  
--6."Can we track the next appointment date for each patient?"
  
SELECT Patientid, 
LAG(Appointmentdate) OVER(PARTITION BY Patientid)
FROM AppointmentDetails

  
--7."Which healthcare professionals haven't seen any patients?"
  
SELECT A.Patientid,H.Name
FROM HealthcareProfessionals H
RIGHT JOIN Appointmentdetails A
ON H.Name = A.Healthcareprofessional
WHERE A.Appointmentdate IS NULL

  
--8."Can we identify patients who had back-to-back appointments within a 30-day period?"
  
SELECT Patientid, Appointmentdate AS current_appointment,
LEAD(Appointmentdate) OVER(PARTITION BY Patientid) AS next_appointment
FROM AppointmentDetails
WHERE DATE_TRUNC(Appointmentdate, INTERVAL MONTH)

  
--9. "What's the average charge per appointment for each healthcare professional?"
  
SELECT H.Name AS doctor, ROUND(AVG(T.Amountcharged)) AS 
Averagecharges
FROM HealthcareProfessionals H
INNER JOIN AppointmentDetails A
ON H.Name = A.Healthcareprofessional
LEFT JOIN Transactions T
ON A.Patientid = T.Patientid GROUP BY doctor



---Medication and Revenue Analysis
  
--10. Who's the last patient each healthcare professional saw, and when?"
  
SELECT Healthcareprofessional, Patientid, Appointmentdate AS 
last_appointment_date
FROM (
 SELECT 
 Healthcareprofessional, Patientid, Appointmentdate,
DENSE_RANK() OVER (PARTITION BY Healthcareprofessional ORDER BY 
Appointmentdate DESC) AS rank
 FROM 
 AppointmentDetails
) AS ranked_appointments
WHERE rank = 1;

  
--11. Which of our patients have been prescribed insulin?"
  
SELECT P.Patientid, M.Medicationname
FROM MedicationsPrescribed M
INNER JOIN
AppointmentDetails A
ON M.Appointmentid = A.Appointmentid
LEFT JOIN Patients P
ON A.Patientid = P.Patientid
WHERE M.Medicationname lIKE '%Insulin%'
GROUP BY P.Patientid, M.Medicationname

  
--12. How can we calculate the total amount charged and the number of appointments for each patient?"
  
SELECT T.Patientid, SUM(T.Amountcharged) AS total_amoount_charged,
COUNT(S.Patientid) AS number_of_appiontment
FROM Transactions T
INNER JOIN
Transactions S
ON T.Patientid = S.Patientid
GROUP BY T.Patientid

  
--13.Can we rank our healthcare professionals by the number of unique patients they've seen?"
  
SELECT Healthcareprofessional, COUNT(DISTINCT(Patientid)),
DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT(Patientid))) AS RANK
FROM AppointmentDetails
GROUP BY Healthcareprofessional


--Advanced Analysis with Subqueries and CTEs

  
--14. How does each patient's appointment count compare to the clinic's average?"

WITH Patient_Count AS (
SELECT 
Patientid, COUNT(*) AS Appointmentdetails
FROM 
Appointmentdetails
GROUP BY Patientid
),
Clinic_Count AS (
SELECT AVG(Appointmentdetails) AS average_appointment_count
FROM Patient_count
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
FROM Patient_Count P
CROSS JOIN 
Clinic_Count C

  
--15.For patients without transactions, can we ensure their total charged amount shows up as zero instead of NULL?"
  
WITH Totalcharges AS (
SELECT Patientid, COALESCE(SUM(Amountcharged), '0') AS 
total_amount_charged
FROM Transactions 
GROUP BY Patientid
)
SELECT Patientid, total_amount_charged
from Totalcharges

  
--16.What's the most common medication for each type of diabetes we treat?"
  
WITH DiabetesPatients AS (
 SELECT Patientid, Medicalhistorysummary
 FROM Patients
 WHERE Medicalhistorysummary LIKE '%Diabetes%'
),
MedicationCounts AS (
 SELECT DP.Medicalhistorysummary, MP.Medicationname,
 COUNT(*) AS Medication_count
 FROM DiabetesPatients DP
 JOIN 
 AppointmentDetails AD ON DP.Patientid = AD.Patientid
 JOIN 
 MedicationsPrescribed MP 
 ON AD.Appointmentid = MP.Appointmentid
 GROUP BY DP.Medicalhistorysummary, MP.Medicationname
),
RankedMedications AS (
 SELECT *, RANK() OVER (PARTITION BY MC.Medicalhistorysummary ORDER 
 BY MC.Medication_count DESC) AS rank
 FROM MedicationCounts MC
)
SELECT Medicalhistorysummary, Medicationname, Medication_count
FROM RankedMedications
WHERE rank = 1;


--17. Can we see the growth in appointment numbers from month to month?"

WITH MonthlyAppointmentCounts AS (
 SELECT EXTRACT(MONTH FROM Appointmentdate) AS month,
 COUNT(*) AS Appointment_count
 FROM Appointmentdetails
 GROUP BY EXTRACT(MONTH FROM Appointmentdate)
)
SELECT Month, Appointment_count,
Appointment_count - LAG(Appointment_count) OVER (ORDER BY Month) AS 
Growth
FROM MonthlyAppointmentCounts
ORDER BY Month;


--18. How do healthcare professionals' appointments and revenue compare?"

WITH AppointmentCounts AS (
 SELECT HealthcareProfessional as Doctor_name, COUNT(*) AS 
 num_appointments
 FROM AppointmentDetails
 GROUP BY HealthcareProfessional
),
ProfessionalRevenue AS (
 SELECT A.HealthcareProfessional, SUM(T.AmountCharged) AS total_revenue
 FROM AppointmentDetails A
 INNER JOIN 
 Transactions T 
 ON A.Patientid = T.Patientid
 GROUP BY A.HealthcareProfessional
) 
SELECT AC.Doctor_name, AC.num_appointments, PR.total_revenue
FROM AppointmentCounts AC
LEFT JOIN 
ProfessionalRevenue PR
ON AC.Doctor_name = PR.HealthcareProfessional;


--19. Which medications have seen a change in their prescribing rank from month to month?"

WITH MedicationRanks AS (
 SELECT MedicationName,
 EXTRACT(MONTH FROM AppointmentDate) AS Month,
 COUNT(*) AS PrescriptionCount,
 RANK() OVER (PARTITION BY EXTRACT(MONTH FROM 
 AppointmentDate ORDER BY COUNT(*) DESC)) AS Rank
 FROM MedicationsPrescribed
 JOIN 
 AppointmentDetails 
 ON MedicationsPrescribed.AppointmentID = 
 AppointmentDetails.AppointmentID
 GROUP BY 
 MedicationName, Month
)
SELECT 
 *,
 LAG(Rank) OVER (PARTITION BY MedicationName ORDER BY Rank) AS 
 PreviousRank
FROM 
 MedicationRanks;

--20. Can we identify our top 3 most expensive services for each patient?"

WITH RankedServices AS (
 SELECT 
 TransactionID,
 PatientID,
 ServiceProvided,
 AmountCharged,
 dense_RANK() OVER (PARTITION BY PatientID ORDER BY AmountCharged 
 DESC) AS ServiceRank
 FROM 
 Transactions
)
SELECT 
 ServiceProvided,
 max(AmountCharged) as max_amount
FROM 
 RankedServices
WHERE 
 ServiceRank <= 3
group by ServiceProvided
order by max_amount desc
limit 3;


--21. Who is our most frequently seen patient in terms of prescriptions, and what medications have they been prescribed?"

WITH PatientPrescriptionCounts AS (
 SELECT 
 AppointmentID,
 COUNT(*) AS PrescriptionCount
 FROM 
 MedicationsPrescribed
 GROUP BY 
 AppointmentID
),
RankedPatients AS (
 SELECT 
 AppointmentID,
 PrescriptionCount,
 RANK() OVER (ORDER BY PrescriptionCount DESC) AS PatientRank
 FROM 
 PatientPrescriptionCounts
)
SELECT 
 Patients.FullName AS MostFrequentPatient,
 MedicationsPrescribed.MedicationName
FROM 
 RankedPatients
JOIN 
 MedicationsPrescribed ON RankedPatients.AppointmentID = 
MedicationsPrescribed.AppointmentID
JOIN 
 Patients ON RankedPatients.AppointmentID = Patients.PatientID
WHERE 
 PatientRank = 1;


--22.How does our monthly revenue compare to the previous month?"

WITH MonthlyRevenue AS (
 SELECT 
 DATE_TRUNC('month', TransactionDate) AS Month,
 SUM(AmountCharged) AS Revenue
 FROM Transactions
 GROUP BY DATE_TRUNC('month', TransactionDate)
 ORDER BY Month
),
RevenueComparison AS (
 SELECT 
 Month,
 Revenue,
 LAG(Revenue) OVER (ORDER BY Month) AS PreviousMonthRevenue
 FROM MonthlyRevenue
)
SELECT 
 Month,
 Revenue,
 COALESCE(Revenue - PreviousMonthRevenue, 0) AS RevenueChange
FROM RevenueComparison
