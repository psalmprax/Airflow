INSERT INTO company SELECT * FROM dblink('dbname=sourcedb host=sourcedb user=sourcedb password=solution', 'SELECT company_id, status, rating_threshold, company_name, foundation_date, legal_form, created_at FROM company')
as t1(
    company_id text COLLATE pg_catalog."default",
    status character varying(255) COLLATE pg_catalog."default",
    rating_threshold character varying(255) COLLATE pg_catalog."default",
    company_name text COLLATE pg_catalog."default",
    foundation_date date,
    legal_form character varying(255) COLLATE pg_catalog."default",
    created_at date
)
where not exists(
    SELECT * FROM dblink('dbname=targetdb host=sourcedb user=sourcedb password=solution', 'SELECT company_id FROM company')
    as t2(company_id text COLLATE pg_catalog."default") where t1.company_id = t2.company_id
);






INSERT INTO address SELECT * FROM dblink('dbname=sourcedb host=sourcedb user=sourcedb password=solution', 'SELECT id, company_id, country, postal_code, city, district, street, street_number, addition, created_at FROM address')
as t1(
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
)
where not exists(
    SELECT * FROM dblink('dbname=targetdb host=sourcedb user=sourcedb password=solution', 'SELECT id, company_id FROM address')
    as t2(id integer, company_id text COLLATE pg_catalog."default") where t1.id = t2.id and t1.company_id = t2.company_id
);

