-- trigger to create new student login
CREATE OR REPLACE FUNCTION create_new_student_login()
RETURNS TRIGGER 
LANGUAGE PLPGSQL 
AS $$
BEGIN 
    EXECUTE format('CREATE USER %I WITH ENCRYPTED PASSWORD %L;', NEW.student_id, 'abc');
    EXECUTE format('GRANT SELECT ON current_sem_and_year TO %I;' , NEW.student_id);
    EXECUTE format('GRANT SELECT ON timetable_slot_list TO %I;',  NEW.student_id);
    EXECUTE format('GRANT SELECT ON student TO %I;',  NEW.student_id);
    EXECUTE format('GRANT SELECT ON instructor TO %I;',  NEW.student_id);
    EXECUTE format('GRANT SELECT ON batch_adviser TO %I;',  NEW.student_id);
    EXECUTE format('GRANT SELECT ON Course_Catalog TO %I;', NEW.student_id);
    EXECUTE format('GRANT SELECT,INSERT ON %I TO %I;', 'ticket_student_'||NEW.student_id, NEW.student_id);
    EXECUTE format('GRANT SELECT ON %I TO %I;', 'trans_'||NEW.student_id, NEW.student_id);
    --EXECUTE format('REVOKE ALL ON %I FROM %I;', 'ticket_instructor_'||NEW.ins_id, NEW.student_id);
    --EXECUTE format('REVOKE ALL ON %I FROM %I;', 'ticket_batch_adviser_'||NEW.ins_id, NEW.student_id);
    --EXECUTE format('REVOKE ALL ON tickets_dean FROM %I;', NEW.student_id);
    return NULL;
END;
$$;

CREATE TRIGGER new_student_login
AFTER INSERT 
ON student 
FOR each row 
EXECUTE PROCEDURE create_new_student_login();

-- trigger to create new instructor login 
CREATE OR REPLACE FUNCTION create_new_ins_login()
RETURNS TRIGGER 
LANGUAGE PLPGSQL 
AS $$
DECLARE
temp_student_id char(11);
BEGIN 
    EXECUTE format('CREATE USER %I WITH ENCRYPTED PASSWORD %L;', 'instructor_'||NEW.ins_id, 'abc');
    EXECUTE format('GRANT pg_read_server_files TO %I;', 'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON current_sem_and_year TO %I;',  'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON timetable_slot_list TO %I;',  'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON student TO %I;',  'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON instructor TO %I;', 'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON batch_adviser TO %I;', 'instructor_'||NEW.ins_id);
    EXECUTE format('GRANT SELECT ON Course_Catalog TO %I;',  'instructor_'||NEW.ins_id);
    --EXECUTE format('GRANT SELECT ON %I TO %I;', 'ticket_student_'||NEW.student_id, 'instructor_'||NEW.ins_id);
    FOR temp_student_id in select student_id from student LOOP 
        EXECUTE format('GRANT SELECT ON %I TO %I;', 'ticket_student_'||temp_student_id, 'instructor_'||NEW.ins_id);
    END LOOP;

    EXECUTE format('GRANT ALL ON %I TO %I;', 'ticket_instructor_'||NEW.ins_id, 'instructor_'||NEW.ins_id);
    --EXECUTE format('REVOKE ALL ON %I FROM %I;', 'ticket_batch_adviser_'||NEW.ins_id, 'instructor_'||NEW.ins_id);
    --EXECUTE format('REVOKE ALL ON tickets_dean FROM %I;', 'instructor_'||NEW.ins_id);
    return NULL;
END;
$$;

CREATE TRIGGER new_ins_login
AFTER INSERT 
ON instructor
FOR each row 
EXECUTE PROCEDURE create_new_ins_login();

-- trigger to create new batch adviser login
CREATE OR REPLACE FUNCTION create_new_ba_login()
RETURNS TRIGGER 
LANGUAGE PLPGSQL 
AS $$
DECLARE 
temp_student_id char(11);
temp_ins_id integer;
BEGIN 
    EXECUTE format('CREATE USER %I WITH ENCRYPTED PASSWORD %L;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch, 'abc');
    EXECUTE format('GRANT SELECT ON current_sem_and_year TO %I;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT SELECT ON timetable_slot_list TO %I;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT SELECT ON student TO %I;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT SELECT ON instructor TO %I;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT SELECT ON batch_adviser TO %I;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT SELECT ON Course_Catalog TO %I;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    -- EXECUTE format('GRANT SELECT ON %I TO %I;', 'ticket_student_'||NEW.student_id, 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    FOR temp_student_id in select student_id from student LOOP
        EXECUTE format('GRANT SELECT ON %I TO %I;', 'ticket_student_'||temp_student_id, 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    END LOOP;

    FOR temp_ins_id in select ins_id from instructor LOOP 
        EXECUTE format('GRANT SELECT ON %I TO %I;', 'ticket_instructor_'||temp_ins_id, 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    END LOOP;

    -- EXECUTE format('GRANT SELECT ON %I TO %I;', 'ticket_instructor_'||NEW.ins_id, 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    EXECUTE format('GRANT ALL ON %I TO %I;', 'ticket_batch_adviser_'||NEW.ins_id, 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    --EXECUTE format('REVOKE ALL ON tickets_dean FROM %I;', 'batch_adviser_'||NEW.ins_id||'_'||NEW.batch);
    return NULL;
END;
$$;

CREATE TRIGGER new_ba_login
AFTER INSERT 
ON batch_adviser
FOR each row 
EXECUTE PROCEDURE create_new_ba_login();
