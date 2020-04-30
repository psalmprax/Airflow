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

--DROP TABLE company_audits;

CREATE TABLE IF NOT EXISTS company_audits (
   id SERIAL PRIMARY KEY,
   company_id text COLLATE pg_catalog."default",
   changed_on TIMESTAMP(6) NOT NULL
);


--CREATE OR REPLACE FUNCTION log_reset_company_audits_changes()
--   RETURNS trigger AS $$
--   BEGIN
--      DELETE FROM company_audits;
--      RETURN NEW;
--   END;
--   $$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION log_last_company_audits_changes()
   RETURNS trigger AS $$
   BEGIN
      IF EXISTS(SELECT 1 FROM company c WHERE c.company_id = NEW.company_id) THEN
            PERFORM * FROM company_audits LIMIT 1;
      ELSE
            INSERT INTO company_audits(company_id,changed_on) VALUES(NEW.company_id,now());
      END IF;
      RETURN NEW;
   END;
   $$ LANGUAGE plpgsql;


--CREATE TRIGGER last_company_audits_reset_changes_
--  BEFORE INSERT
--  ON company
--  EXECUTE PROCEDURE log_reset_company_audits_changes();


CREATE TRIGGER last_company_audits_changes
  BEFORE INSERT
  ON company
  FOR EACH ROW
  EXECUTE PROCEDURE log_last_company_audits_changes();


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

--DROP TABLE address_audits;

CREATE TABLE IF NOT EXISTS address_audits (
   idx SERIAL PRIMARY KEY,
   id integer,
   company_id text COLLATE pg_catalog."default",
   changed_on TIMESTAMP(6) NOT NULL
);


--CREATE OR REPLACE FUNCTION log_reset_address_audits_changes()
--   RETURNS trigger AS $$
--   BEGIN
--      DELETE FROM address_audits;
--      RETURN NEW;
--   END;
--   $$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION log_last_address_audits_changes()
   RETURNS trigger AS $$
   BEGIN
      IF EXISTS(SELECT 1 FROM address a WHERE a.id = NEW.id) THEN
            PERFORM * FROM address_audits LIMIT 1;
      ELSE
            INSERT INTO address_audits(id,company_id,changed_on) VALUES(NEW.id, NEW.company_id,now());
      END IF;
      RETURN NEW;
   END;
   $$ LANGUAGE plpgsql;

--CREATE TRIGGER last_address_audits_reset_changes_
--  BEFORE INSERT
--  ON address
--  EXECUTE PROCEDURE log_reset_address_audits_changes();


CREATE TRIGGER last_address_audits_changes
  BEFORE INSERT
  ON address
  FOR EACH ROW
  EXECUTE PROCEDURE log_last_address_audits_changes();



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