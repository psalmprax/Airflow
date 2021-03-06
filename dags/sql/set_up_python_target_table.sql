-- Set up Target table company, company_audits, log_last_company_audits_changes function and last_company_audits_changes trigger

drop view if exists last_address_record_inserted;
drop view if exists last_company_record_inserted;
drop trigger if exists last_address_audits_changes on public.address;
drop trigger if exists log_last_address on public.address;
drop trigger if exists last_company_audits_changes on public.company;
drop trigger if exists log_last_company on public.company;
drop function if exists log_last_address_audits_changes();
drop function if exists log_last_table();
drop function if exists log_last_company_audits_changes();
drop table if exists address;
drop table if exists address_audits;
drop table if exists company;
drop table if exists company_audits;
drop table if exists occupations;
drop table if exists last_insert_audits;

CREATE TABLE company
(
    company_id text COLLATE pg_catalog."default",
    status character varying(255) COLLATE pg_catalog."default",
    rating_threshold character varying(255) COLLATE pg_catalog."default",
    company_name text COLLATE pg_catalog."default",
    foundation_date date,
    legal_form character varying(255) COLLATE pg_catalog."default",
    created_at date
);

CREATE TABLE IF NOT EXISTS company_audits (
   id SERIAL PRIMARY KEY,
   company_id text COLLATE pg_catalog."default",
   changed_on TIMESTAMP(6) NOT NULL
);

CREATE OR REPLACE FUNCTION public.log_last_company_audits_changes()
  RETURNS trigger AS
  $BODY$
  BEGIN
     IF EXISTS(SELECT 1 FROM company c WHERE c.company_id = NEW.company_id) THEN
           PERFORM * FROM company_audits LIMIT 1;
     ELSE
           INSERT INTO company_audits(company_id,changed_on) VALUES(NEW.company_id,now());
     END IF;
     RETURN NEW;
  END;
  $BODY$
    LANGUAGE plpgsql;

CREATE TRIGGER last_company_audits_changes
  BEFORE INSERT
  ON company
  FOR EACH ROW
  EXECUTE PROCEDURE log_last_company_audits_changes();

-- Set up Target table address, address_audits, log_last_address_audits_changes function and last_address_audits_changes trigger

CREATE TABLE address
(
    id integer,
    company_id text COLLATE pg_catalog."default",
    country character varying(255) COLLATE pg_catalog."default",
    postal_code character varying(255) COLLATE pg_catalog."default",
    city character varying(255) COLLATE pg_catalog."default",
    district character varying(255) COLLATE pg_catalog."default",
    street character varying(255) COLLATE pg_catalog."default",
    street_number character varying(255) COLLATE pg_catalog."default",
    addition character varying(255) COLLATE pg_catalog."default",
    created_at date
);

CREATE TABLE IF NOT EXISTS address_audits (
   idx SERIAL PRIMARY KEY,
   id integer,
   company_id text COLLATE pg_catalog."default",
   changed_on TIMESTAMP(6) NOT NULL
);

CREATE OR REPLACE FUNCTION public.log_last_address_audits_changes()
  RETURNS trigger AS
  $BODY$
  BEGIN
     IF EXISTS(SELECT 1 FROM address a WHERE a.id = NEW.id) THEN
           PERFORM * FROM address_audits LIMIT 1;
     ELSE
           INSERT INTO address_audits(id,company_id,changed_on) VALUES(NEW.id, NEW.company_id,now());
     END IF;
     RETURN NEW;
  END;
  $BODY$
     LANGUAGE plpgsql;

CREATE TRIGGER last_address_audits_changes
  BEFORE INSERT
  ON address
  FOR EACH ROW
  EXECUTE PROCEDURE log_last_address_audits_changes();

-- Set up Target table last record insert tracker as view last_address_record_inserted, last_company_record_inserted

CREATE OR REPLACE VIEW last_address_record_inserted AS
SELECT a.id, a.company_id, a.country, a.postal_code,
a.city, a.district, a.street, a.street_number, a.addition, a.created_at FROM address a
inner join (SELECT id from address_audits where changed_on = (
SELECT changed_on FROM public.address_audits order by changed_on desc limit 1)) as b
on a.id = b.id;

CREATE OR REPLACE VIEW last_company_record_inserted AS
SELECT a.company_id, a.status, a.rating_threshold, a.company_name,
a.foundation_date, a.legal_form, a.created_at FROM company a
inner join (SELECT company_id from company_audits where changed_on = (
SELECT changed_on FROM public.company_audits order by changed_on desc limit 1))as b
on a.company_id = b.company_id;


CREATE TABLE IF NOT EXISTS last_insert_audits (
   idx SERIAL PRIMARY KEY,
   table_name text COLLATE pg_catalog."default",
   insert_on TIMESTAMP(6) NOT NULL
);


CREATE OR REPLACE FUNCTION log_last_table()
   RETURNS trigger AS $$
   DECLARE arg text COLLATE pg_catalog."default";
   BEGIN
      FOREACH arg IN ARRAY TG_ARGV LOOP
        INSERT INTO last_insert_audits(table_name,insert_on) VALUES(arg,now());
      END LOOP;
      RETURN NEW;
   END;
   $$ LANGUAGE plpgsql;


CREATE TRIGGER log_last_address
  BEFORE INSERT
  ON address
  EXECUTE PROCEDURE log_last_table('address');

CREATE TRIGGER log_last_company
  BEFORE INSERT
  ON company
  EXECUTE PROCEDURE log_last_table('company');
