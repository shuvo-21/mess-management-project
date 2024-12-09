-- Student tables
-- 1
CREATE TABLE Stud_Info (
    rollno VARCHAR2(20) PRIMARY KEY,
    sname VARCHAR2(100),
    sphoneno VARCHAR2(20),
    saddress VARCHAR2(200),
    sdob DATE,
    course VARCHAR2(100),
    institute VARCHAR2(100),
    CONSTRAINT chk_sphone CHECK(LENGTH(sphoneno) = 10)
);

-- 2
CREATE TABLE Stud_Email (
    rollno VARCHAR2(20),
    semail VARCHAR2(100),
    CONSTRAINT fk_stud_email FOREIGN KEY (rollno) REFERENCES Stud_Info(rollno) ON DELETE CASCADE,
    CONSTRAINT fk_stud_password FOREIGN KEY (semail) REFERENCES Stud_Password(semail) ON DELETE CASCADE,
    CONSTRAINT pk_stud_email PRIMARY KEY (rollno, semail)
);

-- 3
CREATE TABLE Stud_Password (
    semail VARCHAR2(100),
    spass VARCHAR2(100),
    CONSTRAINT pk_stud_password PRIMARY KEY (semail)
);

-- 4
CREATE TABLE Stud_Rooms (
    rollno VARCHAR2(20),
    rm_no VARCHAR2(20),
    CONSTRAINT fk_stud_rooms_rollno FOREIGN KEY (rollno) REFERENCES Stud_Info(rollno) ON DELETE CASCADE,
    CONSTRAINT fk_stud_rooms FOREIGN KEY (rm_no) REFERENCES Rooms(rm_no) ON DELETE CASCADE,
    CONSTRAINT pk_stud_rooms PRIMARY KEY (rollno, rm_no)
);

-- Employee tables

-- 5
CREATE TABLE Emp_Info (
    empno VARCHAR2(20) PRIMARY KEY,
    ename VARCHAR2(100),
    ephoneno VARCHAR2(20),
    eaddress VARCHAR2(200),
    gender VARCHAR2(10),
    marital_st CHAR(1),
    edob DATE,
    CONSTRAINT chk_ephoneno CHECK(LENGTH(ephoneno) = 10),
    CONSTRAINT chk_gender CHECK(gender IN ('MALE', 'FEMALE', 'OTHERS')),
    CONSTRAINT chk_marital_st CHECK(marital_st IN ('Y', 'N')) 
);

-- 6
CREATE TABLE Emp_Email (
    empno VARCHAR2(20),
    e_email VARCHAR2(100),
    CONSTRAINT fk_emp_password FOREIGN KEY (e_email) REFERENCES Emp_Email(e_email) ON DELETE CASCADE,
    CONSTRAINT fk_emp_email FOREIGN KEY (empno) REFERENCES Emp_Info(empno) ON DELETE CASCADE,
    CONSTRAINT pk_emp_email PRIMARY KEY (empno, e_email)
);

-- 7
CREATE TABLE Emp_Password (
    e_email VARCHAR2(100),
    epass VARCHAR2(100),
    CONSTRAINT pk_emp_password PRIMARY KEY (e_email)
);

-- 8
CREATE TABLE Emp_Job_Info (
    empno VARCHAR2(20),
    ejob VARCHAR2(100),
    CONSTRAINT fk_emp_job_info FOREIGN KEY (empno) REFERENCES Emp_Info(empno) ON DELETE CASCADE,
    CONSTRAINT fk_emp_job FOREIGN KEY (ejob) REFERENCES Job(ejob) ON DELETE CASCADE,
    CONSTRAINT pk_emp_job_info PRIMARY KEY (empno)
);

-- 9
CREATE TABLE Job (
    ejob VARCHAR2(20) PRIMARY KEY,
    sal NUMBER,
    CONSTRAINT chk_job CHECK(ejob IN ('MESS STAFF', 'SWEEPER', 'GARDENER', 'OFFICE STAFF'))
);

-- 10
CREATE TABLE Emp_Comp_Junc (
    rollno VARCHAR2(20),
    com_dt DATE,
    empno VARCHAR2(20),
    CONSTRAINT fk_emp_comp_junc_rollno FOREIGN KEY (rollno) REFERENCES Stud_Info(rollno) ON DELETE CASCADE,
    CONSTRAINT fk_emp_comp_junc_empno FOREIGN KEY (empno) REFERENCES Emp_Info(empno) ON DELETE CASCADE,
    CONSTRAINT pk_emp_comp_junc PRIMARY KEY (rollno, com_dt, empno)
);

-- Vehicle table

-- 11
CREATE TABLE Vehicle (
    vl_id VARCHAR2(20) PRIMARY KEY,
    rollno VARCHAR2(20),
    reg_no VARCHAR2(50),
    vl_type VARCHAR2(50),
    CONSTRAINT fk_vehicle_rollno FOREIGN KEY (rollno) REFERENCES Stud_Info(rollno) ON DELETE CASCADE,
    CONSTRAINT chk_vltype CHECK(vl_type in ('BIKE', 'MOPET'))
);

-- Leave table

-- 12
CREATE TABLE Leave (
    rollno VARCHAR2(20),
    leave_dt DATE,
    address VARCHAR2(200),
    reason VARCHAR2(200),
    no_of_day NUMBER,
    CONSTRAINT fk_leave_rollno FOREIGN KEY (rollno) REFERENCES Stud_Info(rollno) ON DELETE CASCADE,
    CONSTRAINT pk_leave PRIMARY KEY (rollno, leave_dt)
);

-- Mess-Menu table

-- 13
CREATE TABLE Mess (
    mess_id NUMBER PRIMARY KEY,
    monday VARCHAR2(100),
    tuesday VARCHAR2(100),
    wednesday VARCHAR2(100),
    thursday VARCHAR2(100),
    friday VARCHAR2(100),
    saturday VARCHAR2(100),
    sunday VARCHAR2(100)
);

-- 14
CREATE TABLE Mess_Fb_Junc (
    rollno VARCHAR2(20),
    fb_dt DATE,
    mess_id NUMBER,
    CONSTRAINT fk_mess_fb_junc_rollno FOREIGN KEY (rollno) REFERENCES Stud_Info(rollno) ON DELETE CASCADE,
    CONSTRAINT fk_mess_fb_junc_mess_id FOREIGN KEY (mess_id) REFERENCES Mess(mess_id) ON DELETE CASCADE,
    CONSTRAINT pk_mess_fb_junc PRIMARY KEY (rollno, fb_dt)
);

-- Feedback table

-- 15
CREATE TABLE Feedback (
    rollno VARCHAR2(20),
    fb_dt DATE,
    day VARCHAR2(20),
    feedback VARCHAR2(20),
    rating NUMBER,
    CONSTRAINT fk_feedback_rollno FOREIGN KEY (rollno) REFERENCES Stud_Info(rollno) ON DELETE CASCADE,
    CONSTRAINT pk_feedback PRIMARY KEY (rollno, fb_dt, day),
    CONSTRAINT chk_rating CHECK(rating < 6)
);

-- Rooms table

-- 16
CREATE TABLE Rooms (
    rm_no VARCHAR2(20) PRIMARY KEY,
    capacity NUMBER,
    occupancy NUMBER
);

-- Complain table

-- 17
CREATE TABLE Complain (
    rollno VARCHAR2(20),
    com_dt DATE,
    com_type VARCHAR2(50),
    is_done CHAR(1),
    CONSTRAINT fk_complain_rollno FOREIGN KEY (rollno) REFERENCES Stud_Info(rollno) ON DELETE CASCADE,
    CONSTRAINT chk_isdone CHECK(is_done IN ('Y', 'N')),
    CONSTRAINT chk_comtype CHECK(com_type IN ('MESS', 'CLEANING', 'GARDENING', 'OTHERS')),
    CONSTRAINT pk_complain PRIMARY KEY (rollno, com_dt)
);

-- Entry-Exit table

-- 18
CREATE TABLE Entry_Exit (
    rollno VARCHAR2(20),
    ee_time TIMESTAMP,
    ee_date DATE,
    place VARCHAR2(100),
    ee_type VARCHAR2(20),
    CONSTRAINT fk_entry_exit_rollno FOREIGN KEY (rollno) REFERENCES Stud_Info(rollno) ON DELETE CASCADE,
    CONSTRAINT pk_entry_exit PRIMARY KEY (rollno, ee_date, ee_time)
);
