create or replace function food_on_day(mess_id_in IN NUMBER, day_in IN VARCHAR2)
  return  VARCHAR2
IS
  food_menu VARCHAR2(100);

begin 
  -- Retrieve food from mess_id and day
  select 
    case upper(day_in)
      WHEN 'MONDAY' THEN monday
      WHEN 'TUESDAY' THEN tuesday
      WHEN 'WEDNESDAY' THEN wednesday
      WHEN 'THURSDAY' THEN thursday
      WHEN 'FRIDAY' THEN friday
      WHEN 'SATURDAY' THEN saturday
      WHEN 'SUNDAY' THEN sunday
     
    END
  INTO food_menu
  FROM Mess
  WHERE mess_id = mess_id_in;

  -- Check if a valid menu was found
  IF food_menu IS NOT NULL THEN
    RETURN food_menu;
  ELSE
    RETURN 'No menu available for this day or mess';
  END IF;
EXCEPTION
    -- if no data found 
  WHEN NO_DATA_FOUND THEN
    RETURN 'Mess or day not found';

END;

CREATE OR REPLACE FUNCTION record_entry_exit(
    p_rollno IN NUMBER,
    p_place IN VARCHAR2,
    p_ee_type IN VARCHAR2
) RETURN VARCHAR2
IS
BEGIN

    -- Insert the entry or exit record into Entry_Exit table
    INSERT INTO Entry_Exit (rollno, place, ee_type)
    VALUES (p_rollno, p_place, p_ee_type);

    -- Commit the transaction
    COMMIT;

    -- Return success message
    RETURN 'Entry/Exit record recorded successfully';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Error: Roll number not found in Stud_Info';
   
END;