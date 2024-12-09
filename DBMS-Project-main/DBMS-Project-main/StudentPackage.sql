-- Specification
CREATE OR REPLACE PACKAGE student_pkg AS
  FUNCTION student_login (
    username IN Stud_Password.semail%TYPE,
    password IN Stud_Password.spass%TYPE
  ) RETURN BOOLEAN;

  FUNCTION get_student_details (
    v_rollno IN Stud_Info.rollno%TYPE
  ) RETURN CURSOR;

  FUNCTION get_student_leave_details (
    v_rollno IN Stud_Info.rollno%TYPE
  ) RETURN CURSOR;

  FUNCTION get_room_details (
    v_rollno IN Stud_Info.rollno%TYPE
  ) RETURN CURSOR;

  FUNCTION get_feedback_details (
    v_rollno IN Stud_Info.rollno%TYPE
  ) RETURN CURSOR;

  FUNCTION get_complain_details (
    v_rollno IN Stud_Info.rollno%TYPE
  ) RETURN CURSOR;

  -- Procedures
  PROCEDURE new_student_registration(
    p_name      IN Stud_Info.sname%TYPE,
    p_email     IN Stud_Password.semail%TYPE,
    p_password  IN Stud_Password.spass%TYPE,
    p_dob       IN Stud_Info.sdob%TYPE,
    p_address   IN Stud_Info.saddress%TYPE,
    p_phone     IN Stud_Info.sphoneno%TYPE,
    p_course    IN Stud_Info.course%TYPE,
    p_insti     IN Stud_Info.institute%TYPE
  );

  PROCEDURE cancel_admission (
    p_roll_number IN Stud_Info.rollno%TYPE
  );

  PROCEDURE lodge_complain (
    p_rollno         IN Stud_Info.rollno%TYPE,
    p_complaint_type IN Complain.com_type%TYPE
  );

  PROCEDURE submit_feedback (
    p_rollno   IN Stud_Info.rollno%TYPE,
    p_feedback IN Mess_Fb_Junc.feedback%TYPE,
    p_rating   IN Mess_Fb_Junc.rating%TYPE
  );

  PROCEDURE apply_for_leave (
    p_rollno      IN Stud_Info.rollno%TYPE,
    p_leave_dt    IN Leave.leave_dt%TYPE,
    p_address     IN Leave.address%TYPE,
    p_reason      IN Leave.reason%TYPE,
    p_no_of_day   IN Leave.no_of_day%TYPE
  );
END student_pkg;
/

-- Body
CREATE OR REPLACE PACKAGE BODY student_pkg AS
  -- Functions
  FUNCTION student_login  (
    username IN Stud_Password.semail%TYPE,
    password IN Stud_Password.spass%TYPE
  ) RETURN BOOLEAN IS
  DECLARE
    count NUMBER;
  BEGIN
    -- Check if the provided username and password match any student record
    SELECT COUNT(*) INTO count
    FROM Student_Info
    WHERE semail = username
    AND spass = password;

    -- Return TRUE if a matching record is found, FALSE otherwise
    RETURN count > 0;

  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An error occurred : ' || SQLERRM);
      RETURN FALSE;

  END student_login;

  FUNCTION get_student_details (
    v_rollno IN Stud_Info.rollno%TYPE
  ) RETURN CURSOR IS
  DECLARE
    v_cur CURSOR;
  BEGIN
    -- Open the cursor for the specified roll number
    OPEN v_cur FOR
      SELECT si.*, se.semail, sr.rm_no
      FROM Stud_Info si
      LEFT JOIN Stud_Email se ON si.rollno = se.rollno
      LEFT JOIN Stud_Rooms sr ON si.rollno = sr.rollno
      WHERE si.rollno = v_rollno;

    RETURN v_cur;
  EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred : ' || SQLERRM);
        RETURN NULL;
  END get_student_details;

  FUNCTION get_student_leave_details (
    v_rollno IN Stud_Info.rollno%TYPE
  ) RETURN CURSOR IS
  DECLARE
    cur CURSOR;
  BEGIN

    OPEN cur FOR
    SELECT * FROM Leave
    WHERE rollno = v_rollno;

    RETURN cur;

  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An error occurred : ' || SQLERRM);
      RETURN NULL;
  END get_student_leave_details;

  FUNCTION get_room_details (
    v_rollno IN Stud_Info.rollno%TYPE
  ) RETURN CURSOR IS
  DECLARE
    cur CURSOR;
  BEGIN
    SELECT rm_no INTO v_rm_no
    FROM Stud_Rooms
    WHERE rollno = v_rollno;

    OPEN cur FOR
    SELECT * FROM Rooms
    WHERE rm_no = v_rm_no;
    RETURN cur;
  
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An error occurred : ' || SQLERRM);
      RETURN NULL;
  END get_room_details;

  FUNCTION get_feedback_details (
    v_rollno IN Stud_Info.rollno%TYPE
  ) RETURN CURSOR IS
  DECLARE
    cur CURSOR;
  BEGIN
    OPEN cur FOR
    SELECT * FROM Feedback
    WHERE rollno = v_rollno;

    RETURN cur;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An error occurred : ' || SQLERRM);
      RETURN NULL;
  END get_feedback_details;

  FUNCTION get_complain_details (
    v_rollno IN Stud_Info.rollno%TYPE
  ) RETURN CURSOR IS
  DECLARE
    cur CURSOR;
  BEGIN
    OPEN cur FOR
    SELECT * FROM Complain
    WHERE rollno = v_rollno;

    RETURN cur;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An error occurred : ' || SQLERRM);
      RETURN NULL;
  END get_complain_details;

  -- Procedures

  PROCEDURE new_student_registration (
    p_name      IN Stud_Info.sname%TYPE,
    p_email     IN Stud_Password.semail%TYPE,
    p_password  IN Stud_Password.spass%TYPE,
    p_dob       IN Stud_Info.sdob%TYPE,
    p_address   IN Stud_Info.saddress%TYPE,
    p_phone     IN Stud_Info.sphoneno%TYPE,
    p_course    IN Stud_Info.course%TYPE,
    p_insti     IN Stud_Info.institute%TYPE
  ) IS
  DECLARE
    p_roll Stud_Info.rollno%TYPE;
  BEGIN
    INSERT INTO Student_Info (sname, sphoneno, saddress, sdob, course, institute)
    VALUES (p_name, p_phone, p_address, p_dob, p_course, p_insti);

    SELECT rollno into p_roll FROM Stud_Info
    WHERE sphoneno = p_phone;

    INSERT INTO Stud_Email(rollno, semail)
    VALUES (p_roll, p_email);

    INSERT INTO Stud_Password(semail, spass)
    VALUES (p_email, p_password);

    COMMIT; -- Commit the transaction
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
      ROLLBACK; -- Rollback the transaction to maintain data consistency
  END new_student_registration;

  PROCEDURE cancel_admission (
    p_roll_number IN Stud_Info.rollno%TYPE
  ) IS
  BEGIN
    -- Attempt to delete the student from the student table
    DELETE FROM Stud_Info WHERE rollno = p_roll_number;

    -- Commit the transaction
    COMMIT;
    
    EXCEPTION
    -- Handle exceptions
    WHEN NO_DATA_FOUND THEN
      -- Handle the case where no student with the provided roll number is found
      DBMS_OUTPUT.PUT_LINE('No student found with roll number ' || p_roll_number);
    WHEN OTHERS THEN
        -- Handle any other exceptions
      DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
      ROLLBACK; -- Rollback the transaction to maintain data consistency
  END cancel_admission;

  PROCEDURE lodge_complain (
    p_rollno         IN Stud_Info.rollno%TYPE,
    p_complaint_type IN Complain.com_type%TYPE
  ) IS
    BEGIN
    -- Step 1: Input Validation (if necessary)
    -- This could include checking if the provided roll number exists in the Stud_Info table

    -- Step 2: Insert into Database
      INSERT INTO Complain (rollno, com_type, is_done)
      VALUES (p_rollno, p_complaint_type, NULL);

    -- Step 3: Logging (Optional)
    -- Add logging logic here if needed

    COMMIT; -- Commit the transaction

    EXCEPTION
    WHEN OTHERS THEN
        -- Handle any exceptions that might occur
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        ROLLBACK; -- Rollback the transaction to maintain data consistency
  END lodge_complain;

  PROCEDURE submit_feedback (
    p_rollno   IN Stud_Info.rollno%TYPE,
    p_feedback IN Mess_Fb_Junc.feedback%TYPE,
    p_rating   IN Mess_Fb_Junc.rating%TYPE
  ) IS
    BEGIN
      -- Step 1: Input Validation (if necessary)
      -- This could include checking if the provided roll number exists in the Stud_Info table

      -- Step 2: Insert into Database
      INSERT INTO HR.Feedback (rollno, feedback, rating)
      VALUES (p_rollno, p_feedback, p_rating);


    -- Step 3: Logging (Optional)
    -- Add logging logic here if needed

      COMMIT; -- Commit the transaction

    EXCEPTION
      WHEN OTHERS THEN
        -- Handle any exceptions that might occur
          DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
          ROLLBACK; -- Rollback the transaction to maintain data consistency
  END submit_feedback;

  PROCEDURE apply_for_leave (
    p_rollno      IN Stud_Info.rollno%TYPE,
    p_leave_dt    IN Leave.leave_dt%TYPE,
    p_address     IN Leave.address%TYPE,
    p_reason      IN Leave.reason%TYPE,
    p_no_of_day   IN Leave.no_of_day%TYPE
  ) IS
    BEGIN
    -- Step 1: Input Validation (if necessary)
    -- This could include checking if the provided roll number exists in the Stud_Info table
    -- Also, validate other parameters as needed
    
    -- Step 2: Insert into Database
      INSERT INTO Leave (rollno, leave_dt, address, reason, no_of_day)
      VALUES (p_rollno, p_leave_dt, p_address, p_reason, p_no_of_day);
    
    -- Step 3: Notification (if necessary)
    -- Add notification logic here if needed
    
    -- Step 4: Logging
    -- Add logging logic here if needed

      COMMIT; -- Commit the transaction
    EXCEPTION
      WHEN OTHERS THEN
        -- Handle any exceptions that might occur
          DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
          ROLLBACK; -- Rollback the transaction to maintain data consistency
  END apply_for_leave;

END student_pkg;
/
