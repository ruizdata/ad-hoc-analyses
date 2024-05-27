SELECT 
    Therapist_id, 
    COUNT(*) AS Cancellation_Count
FROM 
    Appointments
WHERE 
    EMR_status IN ('cancelled_by_patient', 'no_show_by_patient', 'no_show_by_therapist', 'cancelled_by_therapist')
GROUP BY 
    Therapist_id
ORDER BY 
    Cancellation_Count DESC
LIMIT 10;
