-- 1. Room Allocator Trigger
CREATE OR REPLACE TRIGGER room_allocator_trigger
BEFORE INSERT ON Stud_Info
FOR EACH ROW
DECLARE
    v_room_no Rooms.rm_no%TYPE;
BEGIN
    -- Find the room with the smallest difference between capacity and occupancy
    SELECT rm_no INTO v_room_no
    FROM (
        SELECT rm_no, capacity - NVL(occupancy, 0) AS diff
        FROM Rooms
        ORDER BY diff
    )
    WHERE ROWNUM = 1;

    -- Allocate the room to the student in Stud_Rooms table
    INSERT INTO Stud_Rooms (rollno, rm_no)
    VALUES (:NEW.rollno, v_room_no);
    
    -- Increase occupancy of the allocated room
    UPDATE Rooms
    SET occupancy = NVL(occupancy, 0) + 1
    WHERE rm_no = v_room_no;
END;
/

-- 2. Entry-Exit Time and Date Noter
CREATE OR REPLACE TRIGGER entry_exit_time_noter_trigger
BEFORE INSERT ON Entry_Exit
FOR EACH ROW
BEGIN
    -- Set the entry/exit date to the current system date
    IF :NEW.ee_date IS NULL THEN
        :NEW.ee_date := TRUNC(SYSDATE);
    END IF;
    
    -- Set the entry/exit time to the current system timestamp
    IF :NEW.ee_time IS NULL THEN
        :NEW.ee_time := SYSTIMESTAMP;
    END IF;
END;
/

-- 3. Feedback Date Noter
CREATE OR REPLACE TRIGGER feedback_date_noter_trigger
BEFORE INSERT ON Feedback
FOR EACH ROW
BEGIN
    -- Set the feedback date to the current system date
    IF :NEW.fb_dt IS NULL THEN
        :NEW.fb_dt := SYSDATE;
    END IF;
    
    -- Set the day of the week
    :NEW.day := TO_CHAR(SYSDATE, 'DAY');
END;
/

-- 4. Complain Date Noter
CREATE OR REPLACE TRIGGER complain_date_noter_trigger
BEFORE INSERT ON Complain
FOR EACH ROW
BEGIN
    -- Set the complain date to the current system date
    IF :NEW.com_dt IS NULL THEN
        :NEW.com_dt := SYSDATE;
    END IF;
END;
/

-- 5. Roll No Allocator
CREATE OR REPLACE TRIGGER student_before_insert
BEFORE INSERT ON Stud_Info
FOR EACH ROW
DECLARE
    max_rollno Stud_Info.rollno%TYPE;
BEGIN
    SELECT COUNT(*) INTO max_rollno FROM Stud_Info;
    max_rollno := max_rollno + 1;
    :NEW.rollno := 'STUD' || LPAD(TO_CHAR(max_rollno, 5, 0));
END;
/

-- 6. Emp No Allocator
CREATE OR REPLACE TRIGGER employee_before_insert
BEFORE INSERT ON Emp_Info
FOR EACH ROW
DECLARE
    max_empno Emp_Info.empno%TYPE;
BEGIN
    SELECT COUNT(*) INTO max_empno FROM Emp_Info;
    max_empno := max_empno + 1;
    :NEW.empno := 'EMP' || LPAD(TO_CHAR(empno, 5, 0));
END;

-- 7. Complain Assigner
CREATE OR REPLACE TRIGGER assign_complaint_to_employee
AFTER INSERT ON Complain
FOR EACH ROW
DECLARE
    v_empno Emp_Info.empno%TYPE;
BEGIN
    -- Retrieve the employee number based on the complaint type
    SELECT empno INTO v_empno
    FROM (
        SELECT empno
        FROM Emp_Job_Info
        WHERE ejob = (
            CASE :NEW.com_type
                WHEN 'MESS' THEN 'MESS STAFF'
                WHEN 'CLEANING' THEN 'SWEEPER'
                WHEN 'GARDENING' THEN 'GARDENER'
                ELSE 'OFFICE STAFF'
            END
        )
        ORDER BY DBMS_RANDOM.VALUE
    )
    WHERE ROWNUM = 1;

    -- Insert the complaint into the Emp_Comp_Junc table
    INSERT INTO Emp_Comp_Junc (rollno, com_dt, empno)
    VALUES (:NEW.rollno, SYSDATE, v_empno);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle the case where no employees are found for the given job role
        INSERT INTO Complain (rollno, com_dt, com_type, is_done)
        VALUES (:NEW.rollno, SYSDATE, :NEW.com_type, 'N');

        -- You can log the error or take other appropriate actions
        DBMS_OUTPUT.PUT_LINE('No employees found for the specified job role.');
    WHEN OTHERS THEN
        -- Handle other exceptions if needed
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/
