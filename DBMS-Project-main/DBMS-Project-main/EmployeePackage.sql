CREATE OR REPLACE PACKAGE employee_pkg AS
  -- Functions
  FUNCTION employee_login (
    username IN Emp_Password.e_email%TYPE,
    password IN Emp_Password.epass%TYPE
  ) RETURN BOOLEAN;

  FUNCTION get_employee_details (
    p_empno IN Emp_Info.empno%TYPE
  ) RETURN CURSOR;

  FUNCTION get_job_information (
    p_empno IN Emp_Info.empno%TYPE
  ) RETURN CURSOR;

  FUNCTION get_assigned_complaints (
    p_empno IN Emp_Info.empno%TYPE
  ) RETURN CURSOR;

  -- Procedures
  PROCEDURE new_employee_registration (
    p_ename    IN Emp_Info.ename%TYPE,
    p_ephoneno IN Emp_Info.ephoneno%TYPE,
    p_eaddress IN Emp_Info.eaddress%TYPE,
    p_gender   IN Emp_Info.gender%TYPE,
    p_m_st     IN Emp_Info.marital_st%TYPE,
    p_edob     IN Emp_Info.edob%TYPE,
    p_email    IN Emp_Password.e_email%TYPE,
    p_epass    IN Emp_Password.epass%TYPE
  );

  PROCEDURE terminate_employee (
    p_empno IN Emp_Info.empno%TYPE
  );

  PROCEDURE assign_job (
    p_empno IN Emp_Info.empno%TYPE,
    p_ejob  IN Job.ejob%TYPE
  );

END employee_pkg;


CREATE OR REPLACE PACKAGE BODY employee_pkg AS
  -- Functions
  FUNCTION employee_login (
    username IN Emp_Password.e_email%TYPE,
    password IN Emp_Password.epass%TYPE
  ) RETURN BOOLEAN IS
    count NUMBER;
  BEGIN
    -- Check if the provided username and password match any employee record
    SELECT COUNT(*) INTO count
    FROM Emp_Info
    WHERE eemail = username
    AND epass = password;

    -- Return TRUE if a matching record is found, FALSE otherwise
    RETURN count > 0;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END employee_login;

  FUNCTION get_employee_details (
    p_empno IN Emp_Info.empno%TYPE
  ) RETURN CURSOR IS
    v_cur CURSOR;
  BEGIN
    OPEN v_cur FOR
      SELECT *
      FROM Emp_Info
      WHERE empno = p_empno;

    RETURN v_cur;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_employee_details;

  FUNCTION get_job_information (
    p_empno IN Emp_Info.empno%TYPE
  ) RETURN CURSOR IS
    v_cur CURSOR;
  BEGIN
    OPEN v_cur FOR
      SELECT *
      FROM Emp_Job_Info
      WHERE empno = p_empno;

    RETURN v_cur;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_job_information;

  FUNCTION get_assigned_complaints (
    p_empno IN Emp_Info.empno%TYPE
  ) RETURN CURSOR IS
    v_cur CURSOR;
  BEGIN
    OPEN v_cur FOR
      SELECT *
      FROM Complaints
      WHERE assigned_empno = p_empno;

    RETURN v_cur;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_assigned_complaints;

  -- Procedures
  PROCEDURE new_employee_registration (
    p_ename    IN Emp_Info.ename%TYPE,
    p_ephoneno IN Emp_Info.ephoneno%TYPE,
    p_eaddress IN Emp_Info.eaddress%TYPE,
    p_gender   IN Emp_Info.gender%TYPE,
    p_m_st     IN Emp_Info.marital_st%TYPE,
    p_edob     IN Emp_Info.edob%TYPE,
    p_email    IN Emp_Password.e_email%TYPE,
    p_epass    IN Emp_Password.epass%TYPE
  ) IS
  DECLARE 
    p_empno Emp_Info.empno%TYPE;
  BEGIN
    INSERT INTO Emp_Info (ename, ephoneno, eaddress, gender, marital_st, edob)
    VALUES (p_ename, p_ephoneno, p_eaddress, p_gender, p_m_st, p_edob);

    SELECT empno INTO p_empno FROM
    WHERE ephoneno = p_ephoneno;

    INSERT INTO Emp_Email(empno, e_email) 
    VALUES (p_empno, p_email);

    INSERT INTO Emp_Password(e_email, epass) 
    VALUES (p_email, p_epass);

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
      ROLLBACK;
  END new_employee_registration;

  PROCEDURE terminate_employee (
    p_empno IN Emp_Info.empno%TYPE
  ) IS
  BEGIN
    DELETE FROM Emp_Info WHERE empno = p_empno;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
      ROLLBACK;
  END terminate_employee;

  PROCEDURE assign_job (
    p_empno IN Emp_Info.empno%TYPE,
    p_ejob  IN Job.ejob%TYPE
  ) IS
  BEGIN
    INSERT INTO Emp_Job_Info (empno, ejob)
    VALUES (p_empno, p_ejob);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
      ROLLBACK;
  END assign_job;

END employee_pkg;

