CREATE OR REPLACE PROCEDURE AnalyzeRating IS
BEGIN
    FOR rec IN (SELECT mess_id, day,
                       COUNT(*) AS total_feedback,
                       AVG(rating) AS avg_rating,
                       MAX(rating) AS max_rating,
                       MIN(rating) AS min_rating
                FROM Feedback
                GROUP BY mess_id, day)
    LOOP
        -- Display results for each mess ID and day combination
        DBMS_OUTPUT.PUT_LINE('Mess ID: ' || rec.mess_id || ', Day: ' || rec.day);
        DBMS_OUTPUT.PUT_LINE('Total Feedback: ' || rec.total_feedback);
        DBMS_OUTPUT.PUT_LINE('Average Rating: ' || rec.avg_rating);
        DBMS_OUTPUT.PUT_LINE('Maximum Rating: ' || rec.max_rating);
        DBMS_OUTPUT.PUT_LINE('Minimum Rating: ' || rec.min_rating);
        DBMS_OUTPUT.PUT_LINE('------------------------');
    END LOOP;
END;

CREATE OR REPLACE PROCEDURE Check_Student_Vehicle (
    student_rollno IN Stud_Info.rollno%TYPE
)
IS
    v_vehicle_details Vehicle%ROWTYPE;
BEGIN
    SELECT *
    INTO v_vehicle_details
    FROM Vehicle
    WHERE rollno = student_rollno;

    -- If a vehicle is found for the student, print the details
    IF v_vehicle_details.vl_id IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Student has a vehicle with the following details:');
        DBMS_OUTPUT.PUT_LINE('Vehicle ID: ' || v_vehicle_details.vl_id);
        DBMS_OUTPUT.PUT_LINE('Roll Number: ' || v_vehicle_details.rollno);
        DBMS_OUTPUT.PUT_LINE('Registration Number: ' || v_vehicle_details.reg_no);
        DBMS_OUTPUT.PUT_LINE('Vehicle Type: ' || v_vehicle_details.vl_type);
    ELSE
        -- If no vehicle is found for the student, print a message
        DBMS_OUTPUT.PUT_LINE('Student does not have a vehicle.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Student does not have a vehicle.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;