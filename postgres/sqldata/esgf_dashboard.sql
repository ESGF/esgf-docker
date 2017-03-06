--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: esgf_dashboard; Type: SCHEMA; Schema: -; Owner: dbsuper
--

CREATE SCHEMA esgf_dashboard;


ALTER SCHEMA esgf_dashboard OWNER TO dbsuper;

SET search_path = esgf_dashboard, pg_catalog;

--
-- Name: delete_dashboard_queue(); Type: FUNCTION; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE FUNCTION delete_dashboard_queue() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
BEGIN
-- Update dashboard_queue table
delete from esgf_dashboard.dashboard_queue where id=OLD.id;
RETURN NEW;
END
$$;


ALTER FUNCTION esgf_dashboard.delete_dashboard_queue() OWNER TO dbsuper;

--
-- Name: store_dashboard_queue(); Type: FUNCTION; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE FUNCTION store_dashboard_queue() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
BEGIN
-- Update dashboard_queue table
insert into esgf_dashboard.dashboard_queue(id, url_path, remote_addr,
user_id_hash, user_idp, service_type, success, duration, size,
timestamp)values(NEW.id, NEW.url, NEW.remote_addr, NEW.user_id_hash,
NEW.user_idp, NEW.service_type, NEW.success, NEW.duration,
NEW.data_size, NEW.date_fetched);
RETURN NEW;
END
$$;


ALTER FUNCTION esgf_dashboard.store_dashboard_queue() OWNER TO dbsuper;

--
-- Name: update_dashboard_queue(); Type: FUNCTION; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE FUNCTION update_dashboard_queue() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
url_http varchar;
BEGIN
-- Update dashboard_queue table
update esgf_dashboard.dashboard_queue set success=NEW.success, size=NEW.data_size, duration=NEW.duration WHERE id = OLD.id; 
url_http:=url_path from esgf_dashboard.dashboard_queue WHERE id = OLD.id;
if strpos(url_http,'http')<>0 then
update esgf_dashboard.dashboard_queue set url_path=subquery.url_res
FROM (select file.url as url_res from public.file_version as file,
esgf_dashboard.dashboard_queue as log where log.url_path like '%'||file.url
and log.url_path=url_http) as subquery where url_path=url_http and id=OLD.id;
end if;
RETURN NEW;
END
$$;


ALTER FUNCTION esgf_dashboard.update_dashboard_queue() OWNER TO dbsuper;

--
-- Name: update_url(integer); Type: FUNCTION; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE FUNCTION update_url(integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
declare
i alias for $1;
j integer:=28+i;
begin
UPDATE esgf_dashboard.dashboard_queue SET url_path = substr(url_path,
j) where url_path like 'http%';
return 0;
end;
$_$;


ALTER FUNCTION esgf_dashboard.update_url(integer) OWNER TO dbsuper;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: aggregation_process; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE aggregation_process (
    hostname character varying(255) NOT NULL,
    lastprocessed_id bigint DEFAULT (-1),
    time_stamp timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE esgf_dashboard.aggregation_process OWNER TO dbsuper;

--
-- Name: aggregation_process_planb; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE aggregation_process_planb (
    host character varying(1024) NOT NULL,
    time_stamp timestamp without time zone DEFAULT now() NOT NULL,
    action bigint DEFAULT 0 NOT NULL,
    counter_aggr bigint DEFAULT 0 NOT NULL
);


ALTER TABLE esgf_dashboard.aggregation_process_planb OWNER TO dbsuper;

--
-- Name: all_data_usage; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE all_data_usage (
    year double precision,
    month double precision,
    downloads bigint,
    files bigint,
    users bigint,
    gb numeric,
    host character varying(1024)
);


ALTER TABLE esgf_dashboard.all_data_usage OWNER TO dbsuper;

--
-- Name: all_data_usage_continent; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE all_data_usage_continent (
    year double precision,
    month double precision,
    downloads bigint,
    files bigint,
    users bigint,
    gb numeric,
    continent character varying(64),
    host character varying(1024)
);


ALTER TABLE esgf_dashboard.all_data_usage_continent OWNER TO dbsuper;

--
-- Name: client_stats_dm; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE client_stats_dm (
    host character varying(255),
    ip character varying(64),
    lat numeric(9,6),
    lon numeric(9,6),
    country character varying(64),
    numclient integer,
    continent character varying(64)
);


ALTER TABLE esgf_dashboard.client_stats_dm OWNER TO dbsuper;

--
-- Name: cmip5_bridge_experiment; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_bridge_experiment (
    experiment_key integer NOT NULL,
    experiment_group_key smallint NOT NULL
);


ALTER TABLE esgf_dashboard.cmip5_bridge_experiment OWNER TO dbsuper;

--
-- Name: cmip5_bridge_institute; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_bridge_institute (
    institute_key integer NOT NULL,
    institute_group_key smallint NOT NULL
);


ALTER TABLE esgf_dashboard.cmip5_bridge_institute OWNER TO dbsuper;

--
-- Name: cmip5_bridge_model; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_bridge_model (
    model_key integer NOT NULL,
    model_group_key smallint NOT NULL
);


ALTER TABLE esgf_dashboard.cmip5_bridge_model OWNER TO dbsuper;

--
-- Name: cmip5_bridge_realm; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_bridge_realm (
    realm_key integer NOT NULL,
    realm_group_key smallint NOT NULL
);


ALTER TABLE esgf_dashboard.cmip5_bridge_realm OWNER TO dbsuper;

--
-- Name: cmip5_bridge_time_frequency; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_bridge_time_frequency (
    time_frequency_key integer NOT NULL,
    time_frequency_group_key integer NOT NULL
);


ALTER TABLE esgf_dashboard.cmip5_bridge_time_frequency OWNER TO dbsuper;

--
-- Name: cmip5_bridge_variable; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_bridge_variable (
    variable_key integer NOT NULL,
    variable_group_key integer NOT NULL
);


ALTER TABLE esgf_dashboard.cmip5_bridge_variable OWNER TO dbsuper;

--
-- Name: cmip5_data_usage; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_data_usage (
    year double precision,
    month double precision,
    downloads bigint,
    files bigint,
    users bigint,
    gb numeric,
    host character varying(1024)
);


ALTER TABLE esgf_dashboard.cmip5_data_usage OWNER TO dbsuper;

--
-- Name: cmip5_data_usage_continent; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_data_usage_continent (
    year double precision,
    month double precision,
    downloads bigint,
    files bigint,
    users bigint,
    gb numeric,
    continent character varying(64),
    host character varying(1024)
);


ALTER TABLE esgf_dashboard.cmip5_data_usage_continent OWNER TO dbsuper;

--
-- Name: cmip5_dim_dataset; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_dim_dataset (
    dataset_key bigint NOT NULL,
    dataset_name character varying(64),
    dataset_version smallint,
    datetime_start character varying(64),
    datetime_stop character varying(64)
);


ALTER TABLE esgf_dashboard.cmip5_dim_dataset OWNER TO dbsuper;

--
-- Name: cmip5_dim_dataset_dataset_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE cmip5_dim_dataset_dataset_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.cmip5_dim_dataset_dataset_key_seq OWNER TO dbsuper;

--
-- Name: cmip5_dim_dataset_dataset_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE cmip5_dim_dataset_dataset_key_seq OWNED BY cmip5_dim_dataset.dataset_key;


--
-- Name: cmip5_dim_date; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_dim_date (
    date_key integer NOT NULL,
    download_date date,
    month smallint,
    year smallint
);


ALTER TABLE esgf_dashboard.cmip5_dim_date OWNER TO dbsuper;

--
-- Name: cmip5_dim_date_date_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE cmip5_dim_date_date_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.cmip5_dim_date_date_key_seq OWNER TO dbsuper;

--
-- Name: cmip5_dim_date_date_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE cmip5_dim_date_date_key_seq OWNED BY cmip5_dim_date.date_key;


--
-- Name: cmip5_dim_experiment; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_dim_experiment (
    experiment_key integer NOT NULL,
    experiment_name character varying(64)
);


ALTER TABLE esgf_dashboard.cmip5_dim_experiment OWNER TO dbsuper;

--
-- Name: cmip5_dim_experiment_experiment_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE cmip5_dim_experiment_experiment_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.cmip5_dim_experiment_experiment_key_seq OWNER TO dbsuper;

--
-- Name: cmip5_dim_experiment_experiment_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE cmip5_dim_experiment_experiment_key_seq OWNED BY cmip5_dim_experiment.experiment_key;


--
-- Name: cmip5_dim_geolocation; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_dim_geolocation (
    geolocation_key bigint NOT NULL,
    latitude numeric(14,11),
    longitude numeric(14,11),
    country_id integer NOT NULL
);


ALTER TABLE esgf_dashboard.cmip5_dim_geolocation OWNER TO dbsuper;

--
-- Name: cmip5_dim_geolocation_geolocation_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE cmip5_dim_geolocation_geolocation_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.cmip5_dim_geolocation_geolocation_key_seq OWNER TO dbsuper;

--
-- Name: cmip5_dim_geolocation_geolocation_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE cmip5_dim_geolocation_geolocation_key_seq OWNED BY cmip5_dim_geolocation.geolocation_key;


--
-- Name: cmip5_dim_institute; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_dim_institute (
    institute_key integer NOT NULL,
    institute_name character varying(64)
);


ALTER TABLE esgf_dashboard.cmip5_dim_institute OWNER TO dbsuper;

--
-- Name: cmip5_dim_institute_institute_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE cmip5_dim_institute_institute_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.cmip5_dim_institute_institute_key_seq OWNER TO dbsuper;

--
-- Name: cmip5_dim_institute_institute_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE cmip5_dim_institute_institute_key_seq OWNED BY cmip5_dim_institute.institute_key;


--
-- Name: cmip5_dim_model; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_dim_model (
    model_key integer NOT NULL,
    model_name character varying(64)
);


ALTER TABLE esgf_dashboard.cmip5_dim_model OWNER TO dbsuper;

--
-- Name: cmip5_dim_model_model_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE cmip5_dim_model_model_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.cmip5_dim_model_model_key_seq OWNER TO dbsuper;

--
-- Name: cmip5_dim_model_model_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE cmip5_dim_model_model_key_seq OWNED BY cmip5_dim_model.model_key;


--
-- Name: cmip5_dim_realm; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_dim_realm (
    realm_key integer NOT NULL,
    realm_name character varying(64)
);


ALTER TABLE esgf_dashboard.cmip5_dim_realm OWNER TO dbsuper;

--
-- Name: cmip5_dim_realm_realm_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE cmip5_dim_realm_realm_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.cmip5_dim_realm_realm_key_seq OWNER TO dbsuper;

--
-- Name: cmip5_dim_realm_realm_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE cmip5_dim_realm_realm_key_seq OWNED BY cmip5_dim_realm.realm_key;


--
-- Name: cmip5_dim_time_frequency; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_dim_time_frequency (
    time_frequency_key integer NOT NULL,
    time_frequency_value character varying(64)
);


ALTER TABLE esgf_dashboard.cmip5_dim_time_frequency OWNER TO dbsuper;

--
-- Name: cmip5_dim_time_frequency_time_frequency_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE cmip5_dim_time_frequency_time_frequency_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.cmip5_dim_time_frequency_time_frequency_key_seq OWNER TO dbsuper;

--
-- Name: cmip5_dim_time_frequency_time_frequency_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE cmip5_dim_time_frequency_time_frequency_key_seq OWNED BY cmip5_dim_time_frequency.time_frequency_key;


--
-- Name: cmip5_dim_variable; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_dim_variable (
    variable_key integer NOT NULL,
    variable_code character varying(64),
    variable_long_name character varying(64),
    cf_standard_name character varying(64)
);


ALTER TABLE esgf_dashboard.cmip5_dim_variable OWNER TO dbsuper;

--
-- Name: cmip5_dim_variable_variable_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE cmip5_dim_variable_variable_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.cmip5_dim_variable_variable_key_seq OWNER TO dbsuper;

--
-- Name: cmip5_dim_variable_variable_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE cmip5_dim_variable_variable_key_seq OWNED BY cmip5_dim_variable.variable_key;


--
-- Name: cmip5_dmart_clients_host_time_geolocation; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_dmart_clients_host_time_geolocation (
    dmart_key bigint NOT NULL,
    total_size bigint,
    number_of_downloads bigint,
    number_of_successful_downloads bigint,
    average_duration integer,
    number_of_users integer,
    number_of_replica_downloads bigint,
    month smallint,
    year smallint,
    latitude numeric(14,11),
    longitude numeric(14,11),
    host_name character varying(64)
);


ALTER TABLE esgf_dashboard.cmip5_dmart_clients_host_time_geolocation OWNER TO dbsuper;

--
-- Name: cmip5_dmart_clients_host_time_geolocation_dmart_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE cmip5_dmart_clients_host_time_geolocation_dmart_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.cmip5_dmart_clients_host_time_geolocation_dmart_key_seq OWNER TO dbsuper;

--
-- Name: cmip5_dmart_clients_host_time_geolocation_dmart_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE cmip5_dmart_clients_host_time_geolocation_dmart_key_seq OWNED BY cmip5_dmart_clients_host_time_geolocation.dmart_key;


--
-- Name: cmip5_dmart_dataset_host_time; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_dmart_dataset_host_time (
    dmart_key bigint NOT NULL,
    total_size bigint,
    number_of_downloads bigint,
    number_of_successful_downloads bigint,
    average_duration integer,
    number_of_users integer,
    number_of_replica_downloads bigint,
    month smallint,
    year smallint,
    host_name character varying(64),
    dataset_name character varying(64),
    dataset_version smallint,
    datetime_start character varying(64),
    datetime_stop character varying(64)
);


ALTER TABLE esgf_dashboard.cmip5_dmart_dataset_host_time OWNER TO dbsuper;

--
-- Name: cmip5_dmart_dataset_host_time_dmart_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE cmip5_dmart_dataset_host_time_dmart_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.cmip5_dmart_dataset_host_time_dmart_key_seq OWNER TO dbsuper;

--
-- Name: cmip5_dmart_dataset_host_time_dmart_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE cmip5_dmart_dataset_host_time_dmart_key_seq OWNED BY cmip5_dmart_dataset_host_time.dmart_key;


--
-- Name: cmip5_dmart_experiment_host_time; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_dmart_experiment_host_time (
    dmart_key bigint NOT NULL,
    total_size bigint,
    number_of_downloads bigint,
    number_of_successful_downloads bigint,
    average_duration integer,
    number_of_users integer,
    number_of_replica_downloads bigint,
    month smallint,
    year smallint,
    host_name character varying(64),
    experiment_name character varying(64)
);


ALTER TABLE esgf_dashboard.cmip5_dmart_experiment_host_time OWNER TO dbsuper;

--
-- Name: cmip5_dmart_experiment_host_time_dmart_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE cmip5_dmart_experiment_host_time_dmart_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.cmip5_dmart_experiment_host_time_dmart_key_seq OWNER TO dbsuper;

--
-- Name: cmip5_dmart_experiment_host_time_dmart_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE cmip5_dmart_experiment_host_time_dmart_key_seq OWNED BY cmip5_dmart_experiment_host_time.dmart_key;


--
-- Name: cmip5_dmart_model_host_time; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_dmart_model_host_time (
    dmart_key bigint NOT NULL,
    total_size bigint,
    number_of_downloads bigint,
    number_of_successful_downloads bigint,
    average_duration integer,
    number_of_users integer,
    number_of_replica_downloads bigint,
    month smallint,
    year smallint,
    host_name character varying(64),
    model_name character varying(64)
);


ALTER TABLE esgf_dashboard.cmip5_dmart_model_host_time OWNER TO dbsuper;

--
-- Name: cmip5_dmart_model_host_time_dmart_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE cmip5_dmart_model_host_time_dmart_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.cmip5_dmart_model_host_time_dmart_key_seq OWNER TO dbsuper;

--
-- Name: cmip5_dmart_model_host_time_dmart_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE cmip5_dmart_model_host_time_dmart_key_seq OWNED BY cmip5_dmart_model_host_time.dmart_key;


--
-- Name: cmip5_dmart_variable_host_time; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_dmart_variable_host_time (
    dmart_key bigint NOT NULL,
    total_size bigint,
    number_of_downloads bigint,
    number_of_successful_downloads bigint,
    average_duration integer,
    number_of_users integer,
    number_of_replica_downloads bigint,
    month smallint,
    year smallint,
    host_name character varying(64),
    variable_code character varying(64),
    variable_long_name character varying(64),
    cf_standard_name character varying(64)
);


ALTER TABLE esgf_dashboard.cmip5_dmart_variable_host_time OWNER TO dbsuper;

--
-- Name: cmip5_dmart_variable_host_time_dmart_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE cmip5_dmart_variable_host_time_dmart_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.cmip5_dmart_variable_host_time_dmart_key_seq OWNER TO dbsuper;

--
-- Name: cmip5_dmart_variable_host_time_dmart_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE cmip5_dmart_variable_host_time_dmart_key_seq OWNED BY cmip5_dmart_variable_host_time.dmart_key;


--
-- Name: cmip5_fact_download; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cmip5_fact_download (
    download_key bigint NOT NULL,
    size bigint,
    success boolean,
    duration integer,
    replica boolean,
    host_name character varying,
    hour smallint,
    minute smallint,
    user_id_hash character varying,
    user_idp character varying,
    date_key integer,
    geolocation_key bigint,
    dataset_key bigint,
    time_frequency_group_key integer,
    variable_group_key integer,
    experiment_group_key integer,
    model_group_key integer,
    realm_group_key integer,
    institute_group_key integer
);


ALTER TABLE esgf_dashboard.cmip5_fact_download OWNER TO dbsuper;

--
-- Name: cmip5_fact_download_download_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE cmip5_fact_download_download_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.cmip5_fact_download_download_key_seq OWNER TO dbsuper;

--
-- Name: cmip5_fact_download_download_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE cmip5_fact_download_download_key_seq OWNED BY cmip5_fact_download.download_key;


--
-- Name: continent; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE continent (
    continent_code character(2) NOT NULL,
    continent_name character varying(255) DEFAULT NULL::character varying
);


ALTER TABLE esgf_dashboard.continent OWNER TO dbsuper;

--
-- Name: cordex_data_usage; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cordex_data_usage (
    year double precision,
    month double precision,
    downloads bigint,
    files bigint,
    users bigint,
    gb numeric,
    host character varying(1024)
);


ALTER TABLE esgf_dashboard.cordex_data_usage OWNER TO dbsuper;

--
-- Name: cordex_data_usage_continent; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cordex_data_usage_continent (
    year double precision,
    month double precision,
    downloads bigint,
    files bigint,
    users bigint,
    gb numeric,
    continent character varying(64),
    host character varying(1024)
);


ALTER TABLE esgf_dashboard.cordex_data_usage_continent OWNER TO dbsuper;

--
-- Name: country; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE country (
    country_id integer NOT NULL,
    country_code character(2) NOT NULL,
    country_name character varying(64) NOT NULL,
    continent_code character(2) NOT NULL
);


ALTER TABLE esgf_dashboard.country OWNER TO dbsuper;

--
-- Name: country_country_id_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE country_country_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.country_country_id_seq OWNER TO dbsuper;

--
-- Name: country_country_id_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE country_country_id_seq OWNED BY country.country_id;


--
-- Name: cpu_metrics; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cpu_metrics (
    loadavg1 real,
    loadavg5 real,
    loadavg15 real,
    time_stamp timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE esgf_dashboard.cpu_metrics OWNER TO dbsuper;

--
-- Name: cross_bridge_project; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cross_bridge_project (
    project_key integer NOT NULL,
    project_group_key integer NOT NULL
);


ALTER TABLE esgf_dashboard.cross_bridge_project OWNER TO dbsuper;

--
-- Name: cross_dim_date; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cross_dim_date (
    date_key integer NOT NULL,
    download_date date,
    month smallint,
    year smallint
);


ALTER TABLE esgf_dashboard.cross_dim_date OWNER TO dbsuper;

--
-- Name: cross_dim_date_date_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE cross_dim_date_date_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.cross_dim_date_date_key_seq OWNER TO dbsuper;

--
-- Name: cross_dim_date_date_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE cross_dim_date_date_key_seq OWNED BY cross_dim_date.date_key;


--
-- Name: cross_dim_geolocation; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cross_dim_geolocation (
    geolocation_key bigint NOT NULL,
    latitude numeric(14,11),
    longitude numeric(14,11),
    country_id integer NOT NULL
);


ALTER TABLE esgf_dashboard.cross_dim_geolocation OWNER TO dbsuper;

--
-- Name: cross_dim_geolocation_geolocation_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE cross_dim_geolocation_geolocation_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.cross_dim_geolocation_geolocation_key_seq OWNER TO dbsuper;

--
-- Name: cross_dim_geolocation_geolocation_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE cross_dim_geolocation_geolocation_key_seq OWNED BY cross_dim_geolocation.geolocation_key;


--
-- Name: cross_dim_project; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cross_dim_project (
    project_key integer NOT NULL,
    project_name character varying(64)
);


ALTER TABLE esgf_dashboard.cross_dim_project OWNER TO dbsuper;

--
-- Name: cross_dim_project_project_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE cross_dim_project_project_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.cross_dim_project_project_key_seq OWNER TO dbsuper;

--
-- Name: cross_dim_project_project_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE cross_dim_project_project_key_seq OWNED BY cross_dim_project.project_key;


--
-- Name: cross_dmart_project_host_geolocation; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cross_dmart_project_host_geolocation (
    dmart_key bigint NOT NULL,
    total_size bigint,
    number_of_downloads bigint,
    number_of_successful_downloads bigint,
    number_of_replica_downloads bigint,
    average_duration integer,
    number_of_users integer,
    host_name character varying(64),
    project_name character varying(64),
    latitude numeric(14,11),
    longitude numeric(14,11)
);


ALTER TABLE esgf_dashboard.cross_dmart_project_host_geolocation OWNER TO dbsuper;

--
-- Name: cross_dmart_project_host_geolocation_dmart_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE cross_dmart_project_host_geolocation_dmart_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.cross_dmart_project_host_geolocation_dmart_key_seq OWNER TO dbsuper;

--
-- Name: cross_dmart_project_host_geolocation_dmart_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE cross_dmart_project_host_geolocation_dmart_key_seq OWNED BY cross_dmart_project_host_geolocation.dmart_key;


--
-- Name: cross_dmart_project_host_time; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cross_dmart_project_host_time (
    dmart_key bigint NOT NULL,
    total_size bigint,
    number_of_downloads bigint,
    number_of_successful_downloads bigint,
    number_of_replica_downloads bigint,
    average_duration integer,
    number_of_users integer,
    host_name character varying(64),
    project_name character varying(64),
    month smallint,
    year smallint
);


ALTER TABLE esgf_dashboard.cross_dmart_project_host_time OWNER TO dbsuper;

--
-- Name: cross_dmart_project_host_time_dmart_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE cross_dmart_project_host_time_dmart_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.cross_dmart_project_host_time_dmart_key_seq OWNER TO dbsuper;

--
-- Name: cross_dmart_project_host_time_dmart_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE cross_dmart_project_host_time_dmart_key_seq OWNED BY cross_dmart_project_host_time.dmart_key;


--
-- Name: cross_fact_download; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE cross_fact_download (
    download_key bigint NOT NULL,
    size bigint,
    success boolean,
    duration integer,
    replica boolean,
    user_id_hash character varying(64),
    host_name character varying(64),
    user_idp character varying(64),
    hour smallint,
    minute smallint,
    project_group_key integer,
    geolocation_key bigint,
    date_key integer
);


ALTER TABLE esgf_dashboard.cross_fact_download OWNER TO dbsuper;

--
-- Name: cross_fact_download_download_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE cross_fact_download_download_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.cross_fact_download_download_key_seq OWNER TO dbsuper;

--
-- Name: cross_fact_download_download_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE cross_fact_download_download_key_seq OWNED BY cross_fact_download.download_key;


--
-- Name: dashboard_queue; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE dashboard_queue (
    id integer NOT NULL,
    url_path character varying NOT NULL,
    remote_addr character varying NOT NULL,
    user_id_hash character varying,
    user_idp character varying,
    service_type character varying,
    success boolean,
    duration double precision,
    size bigint DEFAULT (-1),
    "timestamp" double precision NOT NULL,
    processed smallint DEFAULT 0 NOT NULL
);


ALTER TABLE esgf_dashboard.dashboard_queue OWNER TO dbsuper;

--
-- Name: dashboard_queue_id_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE dashboard_queue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.dashboard_queue_id_seq OWNER TO dbsuper;

--
-- Name: dashboard_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE dashboard_queue_id_seq OWNED BY dashboard_queue.id;


--
-- Name: downloads_by_idp; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE downloads_by_idp (
    numdownloads bigint,
    user_idp character varying
);


ALTER TABLE esgf_dashboard.downloads_by_idp OWNER TO dbsuper;

--
-- Name: downloads_by_user; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE downloads_by_user (
    numdownloads bigint,
    downloadeddata numeric,
    user_id_hash character varying
);


ALTER TABLE esgf_dashboard.downloads_by_user OWNER TO dbsuper;

--
-- Name: federationdw; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE federationdw (
    al_id bigint,
    datasetid integer,
    file_id integer,
    project character varying(1024),
    model character varying(1024),
    experiment character varying(512),
    url character varying(1024),
    mv integer,
    var character varying(512),
    realm character varying(512),
    user_id_hash character varying(512),
    user_idp character varying(256),
    year integer,
    month integer,
    day integer,
    hour integer,
    service_type character varying(512),
    remote_addr character varying(128),
    datasetname character varying(255),
    time_frequency character varying(512),
    institute character varying(512),
    product character varying(512),
    ensemble character varying(512),
    cmor_table character varying(512),
    size bigint,
    success integer,
    duration bigint,
    peername character varying(1024)
);


ALTER TABLE esgf_dashboard.federationdw OWNER TO dbsuper;

--
-- Name: federationdw_planb; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE federationdw_planb (
    id integer NOT NULL,
    year integer,
    month integer,
    downloads bigint,
    files bigint,
    users bigint,
    gb numeric,
    host character varying(1024) NOT NULL,
    time_stamp timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE esgf_dashboard.federationdw_planb OWNER TO dbsuper;

--
-- Name: federationdw_planb_id_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE federationdw_planb_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.federationdw_planb_id_seq OWNER TO dbsuper;

--
-- Name: federationdw_planb_id_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE federationdw_planb_id_seq OWNED BY federationdw_planb.id;


--
-- Name: hasfeed; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE hasfeed (
    idrssfeed bigint NOT NULL,
    idhost bigint NOT NULL
);


ALTER TABLE esgf_dashboard.hasfeed OWNER TO dbsuper;

--
-- Name: host; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE host (
    id integer NOT NULL,
    ip character varying(64) NOT NULL,
    name character varying(255),
    city character varying(255),
    latitude numeric(9,6),
    longitude numeric(9,6),
    nodetype integer DEFAULT 4,
    regusers integer DEFAULT 0,
    suppemail character varying(255),
    defaultpeer integer,
    downloaddata bigint DEFAULT 0,
    downloaddatacount bigint DEFAULT 0,
    swversion character varying(255),
    swrelease character varying(255),
    status integer,
    elapsedtime bigint
);


ALTER TABLE esgf_dashboard.host OWNER TO dbsuper;

--
-- Name: host_id_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE host_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.host_id_seq OWNER TO dbsuper;

--
-- Name: host_id_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE host_id_seq OWNED BY host.id;


--
-- Name: join1; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE join1 (
    iduser bigint NOT NULL,
    idproject bigint NOT NULL
);


ALTER TABLE esgf_dashboard.join1 OWNER TO dbsuper;

--
-- Name: memory_metrics; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE memory_metrics (
    freeram bigint,
    freeswap bigint,
    usedram bigint,
    usedswap bigint,
    time_stamp timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE esgf_dashboard.memory_metrics OWNER TO dbsuper;

--
-- Name: news; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE news (
    idnews integer NOT NULL,
    news character varying(255) NOT NULL,
    datenews timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE esgf_dashboard.news OWNER TO dbsuper;

--
-- Name: news_idnews_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE news_idnews_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.news_idnews_seq OWNER TO dbsuper;

--
-- Name: news_idnews_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE news_idnews_seq OWNED BY news.idnews;


--
-- Name: obs4mips_bridge_institute; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_bridge_institute (
    institute_key integer NOT NULL,
    institute_group_key smallint NOT NULL
);


ALTER TABLE esgf_dashboard.obs4mips_bridge_institute OWNER TO dbsuper;

--
-- Name: obs4mips_bridge_processing_level; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_bridge_processing_level (
    processing_level_key integer NOT NULL,
    processing_level_group_key smallint NOT NULL
);


ALTER TABLE esgf_dashboard.obs4mips_bridge_processing_level OWNER TO dbsuper;

--
-- Name: obs4mips_bridge_realm; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_bridge_realm (
    realm_key integer NOT NULL,
    realm_group_key smallint NOT NULL
);


ALTER TABLE esgf_dashboard.obs4mips_bridge_realm OWNER TO dbsuper;

--
-- Name: obs4mips_bridge_source_id; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_bridge_source_id (
    source_id_key integer NOT NULL,
    source_id_group_key smallint NOT NULL
);


ALTER TABLE esgf_dashboard.obs4mips_bridge_source_id OWNER TO dbsuper;

--
-- Name: obs4mips_bridge_time_frequency; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_bridge_time_frequency (
    time_frequency_key integer NOT NULL,
    time_frequency_group_key integer NOT NULL
);


ALTER TABLE esgf_dashboard.obs4mips_bridge_time_frequency OWNER TO dbsuper;

--
-- Name: obs4mips_bridge_variable; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_bridge_variable (
    variable_key integer NOT NULL,
    variable_group_key integer NOT NULL
);


ALTER TABLE esgf_dashboard.obs4mips_bridge_variable OWNER TO dbsuper;

--
-- Name: obs4mips_data_usage; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_data_usage (
    year double precision,
    month double precision,
    downloads bigint,
    files bigint,
    users bigint,
    gb numeric,
    host character varying(1024)
);


ALTER TABLE esgf_dashboard.obs4mips_data_usage OWNER TO dbsuper;

--
-- Name: obs4mips_data_usage_continent; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_data_usage_continent (
    year double precision,
    month double precision,
    downloads bigint,
    files bigint,
    users bigint,
    gb numeric,
    continent character varying(64),
    host character varying(1024)
);


ALTER TABLE esgf_dashboard.obs4mips_data_usage_continent OWNER TO dbsuper;

--
-- Name: obs4mips_dim_dataset; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_dim_dataset (
    dataset_key bigint NOT NULL,
    dataset_name character varying(64),
    dataset_version smallint,
    datetime_start character varying(64),
    datetime_stop character varying(64)
);


ALTER TABLE esgf_dashboard.obs4mips_dim_dataset OWNER TO dbsuper;

--
-- Name: obs4mips_dim_dataset_dataset_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE obs4mips_dim_dataset_dataset_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.obs4mips_dim_dataset_dataset_key_seq OWNER TO dbsuper;

--
-- Name: obs4mips_dim_dataset_dataset_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE obs4mips_dim_dataset_dataset_key_seq OWNED BY obs4mips_dim_dataset.dataset_key;


--
-- Name: obs4mips_dim_date; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_dim_date (
    date_key integer NOT NULL,
    download_date date,
    month smallint,
    year smallint
);


ALTER TABLE esgf_dashboard.obs4mips_dim_date OWNER TO dbsuper;

--
-- Name: obs4mips_dim_date_date_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE obs4mips_dim_date_date_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.obs4mips_dim_date_date_key_seq OWNER TO dbsuper;

--
-- Name: obs4mips_dim_date_date_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE obs4mips_dim_date_date_key_seq OWNED BY obs4mips_dim_date.date_key;


--
-- Name: obs4mips_dim_file; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_dim_file (
    file_key bigint NOT NULL,
    file_name character varying(64),
    file_size bigint
);


ALTER TABLE esgf_dashboard.obs4mips_dim_file OWNER TO dbsuper;

--
-- Name: obs4mips_dim_file_file_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE obs4mips_dim_file_file_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.obs4mips_dim_file_file_key_seq OWNER TO dbsuper;

--
-- Name: obs4mips_dim_file_file_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE obs4mips_dim_file_file_key_seq OWNED BY obs4mips_dim_file.file_key;


--
-- Name: obs4mips_dim_geolocation; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_dim_geolocation (
    geolocation_key bigint NOT NULL,
    latitude numeric(14,11),
    longitude numeric(14,11),
    country_id integer NOT NULL
);


ALTER TABLE esgf_dashboard.obs4mips_dim_geolocation OWNER TO dbsuper;

--
-- Name: obs4mips_dim_geolocation_geolocation_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE obs4mips_dim_geolocation_geolocation_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.obs4mips_dim_geolocation_geolocation_key_seq OWNER TO dbsuper;

--
-- Name: obs4mips_dim_geolocation_geolocation_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE obs4mips_dim_geolocation_geolocation_key_seq OWNED BY obs4mips_dim_geolocation.geolocation_key;


--
-- Name: obs4mips_dim_institute; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_dim_institute (
    institute_key integer NOT NULL,
    institute_name character varying(64)
);


ALTER TABLE esgf_dashboard.obs4mips_dim_institute OWNER TO dbsuper;

--
-- Name: obs4mips_dim_institute_institute_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE obs4mips_dim_institute_institute_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.obs4mips_dim_institute_institute_key_seq OWNER TO dbsuper;

--
-- Name: obs4mips_dim_institute_institute_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE obs4mips_dim_institute_institute_key_seq OWNED BY obs4mips_dim_institute.institute_key;


--
-- Name: obs4mips_dim_processing_level; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_dim_processing_level (
    processing_level_key integer NOT NULL,
    processing_level_name character varying(64)
);


ALTER TABLE esgf_dashboard.obs4mips_dim_processing_level OWNER TO dbsuper;

--
-- Name: obs4mips_dim_processing_level_processing_level_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE obs4mips_dim_processing_level_processing_level_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.obs4mips_dim_processing_level_processing_level_key_seq OWNER TO dbsuper;

--
-- Name: obs4mips_dim_processing_level_processing_level_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE obs4mips_dim_processing_level_processing_level_key_seq OWNED BY obs4mips_dim_processing_level.processing_level_key;


--
-- Name: obs4mips_dim_realm; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_dim_realm (
    realm_key integer NOT NULL,
    realm_name character varying(64)
);


ALTER TABLE esgf_dashboard.obs4mips_dim_realm OWNER TO dbsuper;

--
-- Name: obs4mips_dim_realm_realm_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE obs4mips_dim_realm_realm_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.obs4mips_dim_realm_realm_key_seq OWNER TO dbsuper;

--
-- Name: obs4mips_dim_realm_realm_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE obs4mips_dim_realm_realm_key_seq OWNED BY obs4mips_dim_realm.realm_key;


--
-- Name: obs4mips_dim_source_id; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_dim_source_id (
    source_id_key integer NOT NULL,
    source_id_name character varying(64)
);


ALTER TABLE esgf_dashboard.obs4mips_dim_source_id OWNER TO dbsuper;

--
-- Name: obs4mips_dim_source_id_source_id_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE obs4mips_dim_source_id_source_id_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.obs4mips_dim_source_id_source_id_key_seq OWNER TO dbsuper;

--
-- Name: obs4mips_dim_source_id_source_id_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE obs4mips_dim_source_id_source_id_key_seq OWNED BY obs4mips_dim_source_id.source_id_key;


--
-- Name: obs4mips_dim_time_frequency; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_dim_time_frequency (
    time_frequency_key integer NOT NULL,
    time_frequency_value character varying(64)
);


ALTER TABLE esgf_dashboard.obs4mips_dim_time_frequency OWNER TO dbsuper;

--
-- Name: obs4mips_dim_time_frequency_time_frequency_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE obs4mips_dim_time_frequency_time_frequency_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.obs4mips_dim_time_frequency_time_frequency_key_seq OWNER TO dbsuper;

--
-- Name: obs4mips_dim_time_frequency_time_frequency_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE obs4mips_dim_time_frequency_time_frequency_key_seq OWNED BY obs4mips_dim_time_frequency.time_frequency_key;


--
-- Name: obs4mips_dim_variable; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_dim_variable (
    variable_key integer NOT NULL,
    variable_code character varying(64),
    variable_long_name character varying(64),
    cf_standard_name character varying(64)
);


ALTER TABLE esgf_dashboard.obs4mips_dim_variable OWNER TO dbsuper;

--
-- Name: obs4mips_dim_variable_variable_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE obs4mips_dim_variable_variable_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.obs4mips_dim_variable_variable_key_seq OWNER TO dbsuper;

--
-- Name: obs4mips_dim_variable_variable_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE obs4mips_dim_variable_variable_key_seq OWNED BY obs4mips_dim_variable.variable_key;


--
-- Name: obs4mips_dmart_clients_host_time_geolocation; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_dmart_clients_host_time_geolocation (
    dmart_key bigint NOT NULL,
    total_size bigint,
    number_of_downloads bigint,
    number_of_successful_downloads bigint,
    average_duration integer,
    number_of_users integer,
    month smallint,
    year smallint,
    latitude numeric(14,11),
    longitude numeric(14,11),
    host_name character varying(64)
);


ALTER TABLE esgf_dashboard.obs4mips_dmart_clients_host_time_geolocation OWNER TO dbsuper;

--
-- Name: obs4mips_dmart_clients_host_time_geolocation_dmart_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE obs4mips_dmart_clients_host_time_geolocation_dmart_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.obs4mips_dmart_clients_host_time_geolocation_dmart_key_seq OWNER TO dbsuper;

--
-- Name: obs4mips_dmart_clients_host_time_geolocation_dmart_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE obs4mips_dmart_clients_host_time_geolocation_dmart_key_seq OWNED BY obs4mips_dmart_clients_host_time_geolocation.dmart_key;


--
-- Name: obs4mips_dmart_dataset_host_time; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_dmart_dataset_host_time (
    dmart_key bigint NOT NULL,
    total_size bigint,
    number_of_downloads bigint,
    number_of_successful_downloads bigint,
    average_duration integer,
    number_of_users integer,
    month smallint,
    year smallint,
    host_name character varying(64),
    dataset_name character varying(64),
    dataset_version smallint,
    datetime_start character varying(64),
    datetime_stop character varying(64)
);


ALTER TABLE esgf_dashboard.obs4mips_dmart_dataset_host_time OWNER TO dbsuper;

--
-- Name: obs4mips_dmart_dataset_host_time_dmart_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE obs4mips_dmart_dataset_host_time_dmart_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.obs4mips_dmart_dataset_host_time_dmart_key_seq OWNER TO dbsuper;

--
-- Name: obs4mips_dmart_dataset_host_time_dmart_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE obs4mips_dmart_dataset_host_time_dmart_key_seq OWNED BY obs4mips_dmart_dataset_host_time.dmart_key;


--
-- Name: obs4mips_dmart_realm_host_time; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_dmart_realm_host_time (
    dmart_key bigint NOT NULL,
    total_size bigint,
    number_of_downloads bigint,
    number_of_successful_downloads bigint,
    average_duration integer,
    number_of_users integer,
    month smallint,
    year smallint,
    host_name character varying(64),
    realm_name character varying(64)
);


ALTER TABLE esgf_dashboard.obs4mips_dmart_realm_host_time OWNER TO dbsuper;

--
-- Name: obs4mips_dmart_realm_host_time_dmart_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE obs4mips_dmart_realm_host_time_dmart_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.obs4mips_dmart_realm_host_time_dmart_key_seq OWNER TO dbsuper;

--
-- Name: obs4mips_dmart_realm_host_time_dmart_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE obs4mips_dmart_realm_host_time_dmart_key_seq OWNED BY obs4mips_dmart_realm_host_time.dmart_key;


--
-- Name: obs4mips_dmart_source_host_time; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_dmart_source_host_time (
    dmart_key bigint NOT NULL,
    total_size bigint,
    number_of_downloads bigint,
    number_of_successful_downloads bigint,
    average_duration integer,
    number_of_users integer,
    month smallint,
    year smallint,
    host_name character varying(64),
    source_id_name character varying(64)
);


ALTER TABLE esgf_dashboard.obs4mips_dmart_source_host_time OWNER TO dbsuper;

--
-- Name: obs4mips_dmart_source_host_time_dmart_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE obs4mips_dmart_source_host_time_dmart_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.obs4mips_dmart_source_host_time_dmart_key_seq OWNER TO dbsuper;

--
-- Name: obs4mips_dmart_source_host_time_dmart_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE obs4mips_dmart_source_host_time_dmart_key_seq OWNED BY obs4mips_dmart_source_host_time.dmart_key;


--
-- Name: obs4mips_dmart_variable_host_time; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_dmart_variable_host_time (
    dmart_key bigint NOT NULL,
    total_size bigint,
    number_of_downloads bigint,
    number_of_successful_downloads bigint,
    average_duration integer,
    number_of_users integer,
    month smallint,
    year smallint,
    host_name character varying(64),
    variable_code character varying(64),
    variable_long_name character varying(64),
    cf_standard_name character varying(64)
);


ALTER TABLE esgf_dashboard.obs4mips_dmart_variable_host_time OWNER TO dbsuper;

--
-- Name: obs4mips_dmart_variable_host_time_dmart_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE obs4mips_dmart_variable_host_time_dmart_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.obs4mips_dmart_variable_host_time_dmart_key_seq OWNER TO dbsuper;

--
-- Name: obs4mips_dmart_variable_host_time_dmart_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE obs4mips_dmart_variable_host_time_dmart_key_seq OWNED BY obs4mips_dmart_variable_host_time.dmart_key;


--
-- Name: obs4mips_fact_download; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE obs4mips_fact_download (
    download_key bigint NOT NULL,
    size bigint,
    success boolean,
    duration integer,
    user_id_hash character varying,
    user_idp character varying,
    host_name character varying,
    hour smallint,
    minute smallint,
    index_node_name character varying(64),
    dataset_key bigint,
    file_key bigint,
    geolocation_key bigint,
    date_key integer,
    institute_group_key integer,
    variable_group_key integer,
    time_frequency_group_key integer,
    processing_level_group_key integer,
    source_id_group_key integer,
    realm_group_key integer
);


ALTER TABLE esgf_dashboard.obs4mips_fact_download OWNER TO dbsuper;

--
-- Name: obs4mips_fact_download_download_key_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE obs4mips_fact_download_download_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.obs4mips_fact_download_download_key_seq OWNER TO dbsuper;

--
-- Name: obs4mips_fact_download_download_key_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE obs4mips_fact_download_download_key_seq OWNED BY obs4mips_fact_download.download_key;


--
-- Name: project_dash; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE project_dash (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(2000),
    startdate timestamp without time zone DEFAULT now() NOT NULL,
    enddate timestamp without time zone,
    regpublic integer DEFAULT 0 NOT NULL
);


ALTER TABLE esgf_dashboard.project_dash OWNER TO dbsuper;

--
-- Name: project_dash_id_se; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE project_dash_id_se
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.project_dash_id_se OWNER TO dbsuper;

--
-- Name: project_dash_id_se; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE project_dash_id_se OWNED BY project_dash.id;


--
-- Name: reconciliation_process; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE reconciliation_process (
    lastprocessed_id bigint,
    time_stamp timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE esgf_dashboard.reconciliation_process OWNER TO dbsuper;

--
-- Name: registry; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE registry (
    datmart character varying(128) NOT NULL,
    dmart_key integer DEFAULT 0,
    "timestamp" integer
);


ALTER TABLE esgf_dashboard.registry OWNER TO dbsuper;

--
-- Name: rssfeed; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE rssfeed (
    idrssfeed integer NOT NULL,
    rssfeed character varying(1024) NOT NULL,
    title character varying(1024) NOT NULL,
    local integer DEFAULT 0,
    daterssfeed timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE esgf_dashboard.rssfeed OWNER TO dbsuper;

--
-- Name: rssfeed_idrssfeed_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE rssfeed_idrssfeed_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.rssfeed_idrssfeed_seq OWNER TO dbsuper;

--
-- Name: rssfeed_idrssfeed_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE rssfeed_idrssfeed_seq OWNED BY rssfeed.idrssfeed;


--
-- Name: service_instance; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE service_instance (
    id integer NOT NULL,
    port bigint NOT NULL,
    name character varying(255),
    institution character varying(255),
    mail_admin character varying(255),
    idhost bigint NOT NULL
);


ALTER TABLE esgf_dashboard.service_instance OWNER TO dbsuper;

--
-- Name: service_instance_id_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE service_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.service_instance_id_seq OWNER TO dbsuper;

--
-- Name: service_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE service_instance_id_seq OWNED BY service_instance.id;


--
-- Name: service_status; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE service_status (
    id integer NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
    status integer NOT NULL,
    elapsedtime bigint NOT NULL,
    idserviceinstance bigint NOT NULL
);


ALTER TABLE esgf_dashboard.service_status OWNER TO dbsuper;

--
-- Name: service_status_id_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE service_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.service_status_id_seq OWNER TO dbsuper;

--
-- Name: service_status_id_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE service_status_id_seq OWNED BY service_status.id;


--
-- Name: user1; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE user1 (
    dn character varying(255),
    id integer NOT NULL,
    name character varying(45) NOT NULL,
    surname character varying(45) NOT NULL,
    mail character varying(45) NOT NULL,
    username character varying(25) NOT NULL,
    password character varying(32) NOT NULL,
    registrationdate timestamp without time zone DEFAULT now() NOT NULL,
    accountcertified smallint DEFAULT 0 NOT NULL,
    idcountry integer
);


ALTER TABLE esgf_dashboard.user1 OWNER TO dbsuper;

--
-- Name: user1_id_seq; Type: SEQUENCE; Schema: esgf_dashboard; Owner: dbsuper
--

CREATE SEQUENCE user1_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE esgf_dashboard.user1_id_seq OWNER TO dbsuper;

--
-- Name: user1_id_seq; Type: SEQUENCE OWNED BY; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER SEQUENCE user1_id_seq OWNED BY user1.id;


--
-- Name: uses; Type: TABLE; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE TABLE uses (
    idproject bigint NOT NULL,
    idserviceinstance bigint NOT NULL,
    startdate timestamp without time zone DEFAULT now() NOT NULL,
    enddate timestamp without time zone
);


ALTER TABLE esgf_dashboard.uses OWNER TO dbsuper;

--
-- Name: dataset_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_dim_dataset ALTER COLUMN dataset_key SET DEFAULT nextval('cmip5_dim_dataset_dataset_key_seq'::regclass);


--
-- Name: date_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_dim_date ALTER COLUMN date_key SET DEFAULT nextval('cmip5_dim_date_date_key_seq'::regclass);


--
-- Name: experiment_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_dim_experiment ALTER COLUMN experiment_key SET DEFAULT nextval('cmip5_dim_experiment_experiment_key_seq'::regclass);


--
-- Name: geolocation_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_dim_geolocation ALTER COLUMN geolocation_key SET DEFAULT nextval('cmip5_dim_geolocation_geolocation_key_seq'::regclass);


--
-- Name: institute_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_dim_institute ALTER COLUMN institute_key SET DEFAULT nextval('cmip5_dim_institute_institute_key_seq'::regclass);


--
-- Name: model_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_dim_model ALTER COLUMN model_key SET DEFAULT nextval('cmip5_dim_model_model_key_seq'::regclass);


--
-- Name: realm_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_dim_realm ALTER COLUMN realm_key SET DEFAULT nextval('cmip5_dim_realm_realm_key_seq'::regclass);


--
-- Name: time_frequency_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_dim_time_frequency ALTER COLUMN time_frequency_key SET DEFAULT nextval('cmip5_dim_time_frequency_time_frequency_key_seq'::regclass);


--
-- Name: variable_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_dim_variable ALTER COLUMN variable_key SET DEFAULT nextval('cmip5_dim_variable_variable_key_seq'::regclass);


--
-- Name: dmart_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_dmart_clients_host_time_geolocation ALTER COLUMN dmart_key SET DEFAULT nextval('cmip5_dmart_clients_host_time_geolocation_dmart_key_seq'::regclass);


--
-- Name: dmart_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_dmart_dataset_host_time ALTER COLUMN dmart_key SET DEFAULT nextval('cmip5_dmart_dataset_host_time_dmart_key_seq'::regclass);


--
-- Name: dmart_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_dmart_experiment_host_time ALTER COLUMN dmart_key SET DEFAULT nextval('cmip5_dmart_experiment_host_time_dmart_key_seq'::regclass);


--
-- Name: dmart_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_dmart_model_host_time ALTER COLUMN dmart_key SET DEFAULT nextval('cmip5_dmart_model_host_time_dmart_key_seq'::regclass);


--
-- Name: dmart_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_dmart_variable_host_time ALTER COLUMN dmart_key SET DEFAULT nextval('cmip5_dmart_variable_host_time_dmart_key_seq'::regclass);


--
-- Name: download_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_fact_download ALTER COLUMN download_key SET DEFAULT nextval('cmip5_fact_download_download_key_seq'::regclass);


--
-- Name: country_id; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY country ALTER COLUMN country_id SET DEFAULT nextval('country_country_id_seq'::regclass);


--
-- Name: date_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cross_dim_date ALTER COLUMN date_key SET DEFAULT nextval('cross_dim_date_date_key_seq'::regclass);


--
-- Name: geolocation_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cross_dim_geolocation ALTER COLUMN geolocation_key SET DEFAULT nextval('cross_dim_geolocation_geolocation_key_seq'::regclass);


--
-- Name: project_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cross_dim_project ALTER COLUMN project_key SET DEFAULT nextval('cross_dim_project_project_key_seq'::regclass);


--
-- Name: dmart_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cross_dmart_project_host_geolocation ALTER COLUMN dmart_key SET DEFAULT nextval('cross_dmart_project_host_geolocation_dmart_key_seq'::regclass);


--
-- Name: dmart_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cross_dmart_project_host_time ALTER COLUMN dmart_key SET DEFAULT nextval('cross_dmart_project_host_time_dmart_key_seq'::regclass);


--
-- Name: download_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cross_fact_download ALTER COLUMN download_key SET DEFAULT nextval('cross_fact_download_download_key_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY dashboard_queue ALTER COLUMN id SET DEFAULT nextval('dashboard_queue_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY federationdw_planb ALTER COLUMN id SET DEFAULT nextval('federationdw_planb_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY host ALTER COLUMN id SET DEFAULT nextval('host_id_seq'::regclass);


--
-- Name: idnews; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY news ALTER COLUMN idnews SET DEFAULT nextval('news_idnews_seq'::regclass);


--
-- Name: dataset_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_dim_dataset ALTER COLUMN dataset_key SET DEFAULT nextval('obs4mips_dim_dataset_dataset_key_seq'::regclass);


--
-- Name: date_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_dim_date ALTER COLUMN date_key SET DEFAULT nextval('obs4mips_dim_date_date_key_seq'::regclass);


--
-- Name: file_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_dim_file ALTER COLUMN file_key SET DEFAULT nextval('obs4mips_dim_file_file_key_seq'::regclass);


--
-- Name: geolocation_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_dim_geolocation ALTER COLUMN geolocation_key SET DEFAULT nextval('obs4mips_dim_geolocation_geolocation_key_seq'::regclass);


--
-- Name: institute_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_dim_institute ALTER COLUMN institute_key SET DEFAULT nextval('obs4mips_dim_institute_institute_key_seq'::regclass);


--
-- Name: processing_level_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_dim_processing_level ALTER COLUMN processing_level_key SET DEFAULT nextval('obs4mips_dim_processing_level_processing_level_key_seq'::regclass);


--
-- Name: realm_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_dim_realm ALTER COLUMN realm_key SET DEFAULT nextval('obs4mips_dim_realm_realm_key_seq'::regclass);


--
-- Name: source_id_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_dim_source_id ALTER COLUMN source_id_key SET DEFAULT nextval('obs4mips_dim_source_id_source_id_key_seq'::regclass);


--
-- Name: time_frequency_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_dim_time_frequency ALTER COLUMN time_frequency_key SET DEFAULT nextval('obs4mips_dim_time_frequency_time_frequency_key_seq'::regclass);


--
-- Name: variable_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_dim_variable ALTER COLUMN variable_key SET DEFAULT nextval('obs4mips_dim_variable_variable_key_seq'::regclass);


--
-- Name: dmart_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_dmart_clients_host_time_geolocation ALTER COLUMN dmart_key SET DEFAULT nextval('obs4mips_dmart_clients_host_time_geolocation_dmart_key_seq'::regclass);


--
-- Name: dmart_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_dmart_dataset_host_time ALTER COLUMN dmart_key SET DEFAULT nextval('obs4mips_dmart_dataset_host_time_dmart_key_seq'::regclass);


--
-- Name: dmart_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_dmart_realm_host_time ALTER COLUMN dmart_key SET DEFAULT nextval('obs4mips_dmart_realm_host_time_dmart_key_seq'::regclass);


--
-- Name: dmart_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_dmart_source_host_time ALTER COLUMN dmart_key SET DEFAULT nextval('obs4mips_dmart_source_host_time_dmart_key_seq'::regclass);


--
-- Name: dmart_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_dmart_variable_host_time ALTER COLUMN dmart_key SET DEFAULT nextval('obs4mips_dmart_variable_host_time_dmart_key_seq'::regclass);


--
-- Name: download_key; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_fact_download ALTER COLUMN download_key SET DEFAULT nextval('obs4mips_fact_download_download_key_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY project_dash ALTER COLUMN id SET DEFAULT nextval('project_dash_id_se'::regclass);


--
-- Name: idrssfeed; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY rssfeed ALTER COLUMN idrssfeed SET DEFAULT nextval('rssfeed_idrssfeed_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY service_instance ALTER COLUMN id SET DEFAULT nextval('service_instance_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY service_status ALTER COLUMN id SET DEFAULT nextval('service_status_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY user1 ALTER COLUMN id SET DEFAULT nextval('user1_id_seq'::regclass);


--
-- Name: aggregation_process_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY aggregation_process
    ADD CONSTRAINT aggregation_process_pkey PRIMARY KEY (hostname);


--
-- Name: aggregation_process_planb_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY aggregation_process_planb
    ADD CONSTRAINT aggregation_process_planb_pkey PRIMARY KEY (host);


--
-- Name: cmip5_dim_dataset_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cmip5_dim_dataset
    ADD CONSTRAINT cmip5_dim_dataset_pkey PRIMARY KEY (dataset_key);


--
-- Name: cmip5_dim_date_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cmip5_dim_date
    ADD CONSTRAINT cmip5_dim_date_pkey PRIMARY KEY (date_key);


--
-- Name: cmip5_dim_experiment_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cmip5_dim_experiment
    ADD CONSTRAINT cmip5_dim_experiment_pkey PRIMARY KEY (experiment_key);


--
-- Name: cmip5_dim_geolocation_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cmip5_dim_geolocation
    ADD CONSTRAINT cmip5_dim_geolocation_pkey PRIMARY KEY (geolocation_key);


--
-- Name: cmip5_dim_institute_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cmip5_dim_institute
    ADD CONSTRAINT cmip5_dim_institute_pkey PRIMARY KEY (institute_key);


--
-- Name: cmip5_dim_model_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cmip5_dim_model
    ADD CONSTRAINT cmip5_dim_model_pkey PRIMARY KEY (model_key);


--
-- Name: cmip5_dim_realm_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cmip5_dim_realm
    ADD CONSTRAINT cmip5_dim_realm_pkey PRIMARY KEY (realm_key);


--
-- Name: cmip5_dim_time_frequency_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cmip5_dim_time_frequency
    ADD CONSTRAINT cmip5_dim_time_frequency_pkey PRIMARY KEY (time_frequency_key);


--
-- Name: cmip5_dim_variable_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cmip5_dim_variable
    ADD CONSTRAINT cmip5_dim_variable_pkey PRIMARY KEY (variable_key);


--
-- Name: cmip5_dmart_clients_host_time_geolocation_1; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cmip5_dmart_clients_host_time_geolocation
    ADD CONSTRAINT cmip5_dmart_clients_host_time_geolocation_1 UNIQUE (total_size, number_of_downloads, number_of_successful_downloads, average_duration, number_of_users, number_of_replica_downloads, month, year, latitude, longitude, host_name);


--
-- Name: cmip5_dmart_clients_host_time_geolocation_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cmip5_dmart_clients_host_time_geolocation
    ADD CONSTRAINT cmip5_dmart_clients_host_time_geolocation_pkey PRIMARY KEY (dmart_key);


--
-- Name: cmip5_dmart_dataset_host_time_1; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cmip5_dmart_dataset_host_time
    ADD CONSTRAINT cmip5_dmart_dataset_host_time_1 UNIQUE (total_size, number_of_downloads, number_of_successful_downloads, average_duration, number_of_users, number_of_replica_downloads, month, year, host_name, dataset_name, dataset_version, datetime_start, datetime_stop);


--
-- Name: cmip5_dmart_dataset_host_time_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cmip5_dmart_dataset_host_time
    ADD CONSTRAINT cmip5_dmart_dataset_host_time_pkey PRIMARY KEY (dmart_key);


--
-- Name: cmip5_dmart_experiment_host_time_1; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cmip5_dmart_experiment_host_time
    ADD CONSTRAINT cmip5_dmart_experiment_host_time_1 UNIQUE (total_size, number_of_downloads, number_of_successful_downloads, average_duration, number_of_users, number_of_replica_downloads, month, year, host_name, experiment_name);


--
-- Name: cmip5_dmart_experiment_host_time_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cmip5_dmart_experiment_host_time
    ADD CONSTRAINT cmip5_dmart_experiment_host_time_pkey PRIMARY KEY (dmart_key);


--
-- Name: cmip5_dmart_model_host_time_1; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cmip5_dmart_model_host_time
    ADD CONSTRAINT cmip5_dmart_model_host_time_1 UNIQUE (total_size, number_of_downloads, number_of_successful_downloads, average_duration, number_of_users, number_of_replica_downloads, month, year, host_name, model_name);


--
-- Name: cmip5_dmart_model_host_time_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cmip5_dmart_model_host_time
    ADD CONSTRAINT cmip5_dmart_model_host_time_pkey PRIMARY KEY (dmart_key);


--
-- Name: cmip5_dmart_variable_host_time_1; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cmip5_dmart_variable_host_time
    ADD CONSTRAINT cmip5_dmart_variable_host_time_1 UNIQUE (total_size, number_of_downloads, number_of_successful_downloads, average_duration, number_of_users, number_of_replica_downloads, month, year, host_name, variable_code, variable_long_name, cf_standard_name);


--
-- Name: cmip5_dmart_variable_host_time_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cmip5_dmart_variable_host_time
    ADD CONSTRAINT cmip5_dmart_variable_host_time_pkey PRIMARY KEY (dmart_key);


--
-- Name: cmip5_fact_download_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cmip5_fact_download
    ADD CONSTRAINT cmip5_fact_download_pkey PRIMARY KEY (download_key);


--
-- Name: continent_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY continent
    ADD CONSTRAINT continent_pkey PRIMARY KEY (continent_code);


--
-- Name: country_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY country
    ADD CONSTRAINT country_pkey PRIMARY KEY (country_id);


--
-- Name: cross_dim_date_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cross_dim_date
    ADD CONSTRAINT cross_dim_date_pkey PRIMARY KEY (date_key);


--
-- Name: cross_dim_geolocation_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cross_dim_geolocation
    ADD CONSTRAINT cross_dim_geolocation_pkey PRIMARY KEY (geolocation_key);


--
-- Name: cross_dim_project_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cross_dim_project
    ADD CONSTRAINT cross_dim_project_pkey PRIMARY KEY (project_key);


--
-- Name: cross_dmart_project_host_geolocation_1; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cross_dmart_project_host_geolocation
    ADD CONSTRAINT cross_dmart_project_host_geolocation_1 UNIQUE (total_size, number_of_downloads, number_of_successful_downloads, number_of_replica_downloads, average_duration, number_of_users, host_name, project_name, longitude, latitude);


--
-- Name: cross_dmart_project_host_geolocation_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cross_dmart_project_host_geolocation
    ADD CONSTRAINT cross_dmart_project_host_geolocation_pkey PRIMARY KEY (dmart_key);


--
-- Name: cross_dmart_project_host_time_1; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cross_dmart_project_host_time
    ADD CONSTRAINT cross_dmart_project_host_time_1 UNIQUE (total_size, number_of_downloads, number_of_successful_downloads, number_of_replica_downloads, average_duration, number_of_users, host_name, project_name, month, year);


--
-- Name: cross_dmart_project_host_time_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cross_dmart_project_host_time
    ADD CONSTRAINT cross_dmart_project_host_time_pkey PRIMARY KEY (dmart_key);


--
-- Name: cross_fact_download_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY cross_fact_download
    ADD CONSTRAINT cross_fact_download_pkey PRIMARY KEY (download_key);


--
-- Name: dashboard_queue_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY dashboard_queue
    ADD CONSTRAINT dashboard_queue_pkey PRIMARY KEY (id);


--
-- Name: federationdw_al_id_key; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY federationdw
    ADD CONSTRAINT federationdw_al_id_key UNIQUE (al_id, peername);


--
-- Name: federationdw_planb_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY federationdw_planb
    ADD CONSTRAINT federationdw_planb_pkey PRIMARY KEY (id);


--
-- Name: host_ip_key; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY host
    ADD CONSTRAINT host_ip_key UNIQUE (ip);


--
-- Name: host_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY host
    ADD CONSTRAINT host_pkey PRIMARY KEY (id);


--
-- Name: join1_iduser_key; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY join1
    ADD CONSTRAINT join1_iduser_key UNIQUE (iduser, idproject);


--
-- Name: join1_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY join1
    ADD CONSTRAINT join1_pkey PRIMARY KEY (iduser, idproject);


--
-- Name: news_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY news
    ADD CONSTRAINT news_pkey PRIMARY KEY (idnews);


--
-- Name: obs4mips_dim_dataset_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY obs4mips_dim_dataset
    ADD CONSTRAINT obs4mips_dim_dataset_pkey PRIMARY KEY (dataset_key);


--
-- Name: obs4mips_dim_date_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY obs4mips_dim_date
    ADD CONSTRAINT obs4mips_dim_date_pkey PRIMARY KEY (date_key);


--
-- Name: obs4mips_dim_file_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY obs4mips_dim_file
    ADD CONSTRAINT obs4mips_dim_file_pkey PRIMARY KEY (file_key);


--
-- Name: obs4mips_dim_geolocation_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY obs4mips_dim_geolocation
    ADD CONSTRAINT obs4mips_dim_geolocation_pkey PRIMARY KEY (geolocation_key);


--
-- Name: obs4mips_dim_institute_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY obs4mips_dim_institute
    ADD CONSTRAINT obs4mips_dim_institute_pkey PRIMARY KEY (institute_key);


--
-- Name: obs4mips_dim_processing_level_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY obs4mips_dim_processing_level
    ADD CONSTRAINT obs4mips_dim_processing_level_pkey PRIMARY KEY (processing_level_key);


--
-- Name: obs4mips_dim_realm_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY obs4mips_dim_realm
    ADD CONSTRAINT obs4mips_dim_realm_pkey PRIMARY KEY (realm_key);


--
-- Name: obs4mips_dim_source_id_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY obs4mips_dim_source_id
    ADD CONSTRAINT obs4mips_dim_source_id_pkey PRIMARY KEY (source_id_key);


--
-- Name: obs4mips_dim_time_frequency_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY obs4mips_dim_time_frequency
    ADD CONSTRAINT obs4mips_dim_time_frequency_pkey PRIMARY KEY (time_frequency_key);


--
-- Name: obs4mips_dim_variable_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY obs4mips_dim_variable
    ADD CONSTRAINT obs4mips_dim_variable_pkey PRIMARY KEY (variable_key);


--
-- Name: obs4mips_dmart_clients_host_time_geolocation_1; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY obs4mips_dmart_clients_host_time_geolocation
    ADD CONSTRAINT obs4mips_dmart_clients_host_time_geolocation_1 UNIQUE (total_size, number_of_downloads, number_of_successful_downloads, average_duration, number_of_users, month, year, latitude, longitude, host_name);


--
-- Name: obs4mips_dmart_clients_host_time_geolocation_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY obs4mips_dmart_clients_host_time_geolocation
    ADD CONSTRAINT obs4mips_dmart_clients_host_time_geolocation_pkey PRIMARY KEY (dmart_key);


--
-- Name: obs4mips_dmart_dataset_host_time_1; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY obs4mips_dmart_dataset_host_time
    ADD CONSTRAINT obs4mips_dmart_dataset_host_time_1 UNIQUE (total_size, number_of_downloads, number_of_successful_downloads, average_duration, number_of_users, month, year, host_name, dataset_name, dataset_version, datetime_start, datetime_stop);


--
-- Name: obs4mips_dmart_dataset_host_time_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY obs4mips_dmart_dataset_host_time
    ADD CONSTRAINT obs4mips_dmart_dataset_host_time_pkey PRIMARY KEY (dmart_key);


--
-- Name: obs4mips_dmart_realm_host_time_1; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY obs4mips_dmart_realm_host_time
    ADD CONSTRAINT obs4mips_dmart_realm_host_time_1 UNIQUE (total_size, number_of_downloads, number_of_successful_downloads, average_duration, number_of_users, month, year, host_name, realm_name);


--
-- Name: obs4mips_dmart_realm_host_time_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY obs4mips_dmart_realm_host_time
    ADD CONSTRAINT obs4mips_dmart_realm_host_time_pkey PRIMARY KEY (dmart_key);


--
-- Name: obs4mips_dmart_source_host_time_1; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY obs4mips_dmart_source_host_time
    ADD CONSTRAINT obs4mips_dmart_source_host_time_1 UNIQUE (total_size, number_of_downloads, number_of_successful_downloads, average_duration, number_of_users, month, year, host_name, source_id_name);


--
-- Name: obs4mips_dmart_source_host_time_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY obs4mips_dmart_source_host_time
    ADD CONSTRAINT obs4mips_dmart_source_host_time_pkey PRIMARY KEY (dmart_key);


--
-- Name: obs4mips_dmart_variable_host_time_1; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY obs4mips_dmart_variable_host_time
    ADD CONSTRAINT obs4mips_dmart_variable_host_time_1 UNIQUE (total_size, number_of_downloads, number_of_successful_downloads, average_duration, number_of_users, month, year, host_name, variable_code, variable_long_name, cf_standard_name);


--
-- Name: obs4mips_dmart_variable_host_time_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY obs4mips_dmart_variable_host_time
    ADD CONSTRAINT obs4mips_dmart_variable_host_time_pkey PRIMARY KEY (dmart_key);


--
-- Name: obs4mips_fact_download_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY obs4mips_fact_download
    ADD CONSTRAINT obs4mips_fact_download_pkey PRIMARY KEY (download_key);


--
-- Name: project_dash_name_key; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY project_dash
    ADD CONSTRAINT project_dash_name_key UNIQUE (name);


--
-- Name: registry_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY registry
    ADD CONSTRAINT registry_pkey PRIMARY KEY (datmart);


--
-- Name: rssfeed_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY rssfeed
    ADD CONSTRAINT rssfeed_pkey PRIMARY KEY (idrssfeed);


--
-- Name: service_instance_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY service_instance
    ADD CONSTRAINT service_instance_pkey PRIMARY KEY (id);


--
-- Name: service_instance_port_key; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY service_instance
    ADD CONSTRAINT service_instance_port_key UNIQUE (port, idhost);


--
-- Name: service_status_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY service_status
    ADD CONSTRAINT service_status_pkey PRIMARY KEY (id);


--
-- Name: user1_dn_key; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY user1
    ADD CONSTRAINT user1_dn_key UNIQUE (dn);


--
-- Name: user1_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY user1
    ADD CONSTRAINT user1_pkey PRIMARY KEY (id);


--
-- Name: user1_username_key; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY user1
    ADD CONSTRAINT user1_username_key UNIQUE (username);


--
-- Name: uses_idproject_key; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY uses
    ADD CONSTRAINT uses_idproject_key UNIQUE (idproject, idserviceinstance);


--
-- Name: uses_pkey; Type: CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

ALTER TABLE ONLY uses
    ADD CONSTRAINT uses_pkey PRIMARY KEY (idproject, idserviceinstance, startdate);


--
-- Name: service_status_index; Type: INDEX; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE INDEX service_status_index ON service_status USING btree (idserviceinstance);


--
-- Name: service_status_status; Type: INDEX; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE INDEX service_status_status ON service_status USING btree (status);


--
-- Name: service_status_timestamp; Type: INDEX; Schema: esgf_dashboard; Owner: dbsuper; Tablespace: 
--

CREATE INDEX service_status_timestamp ON service_status USING btree ("timestamp");


--
-- Name: cmip5_bridge_experiment_experiment_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_bridge_experiment
    ADD CONSTRAINT cmip5_bridge_experiment_experiment_key_fkey FOREIGN KEY (experiment_key) REFERENCES cmip5_dim_experiment(experiment_key);


--
-- Name: cmip5_bridge_institute_institute_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_bridge_institute
    ADD CONSTRAINT cmip5_bridge_institute_institute_key_fkey FOREIGN KEY (institute_key) REFERENCES cmip5_dim_institute(institute_key);


--
-- Name: cmip5_bridge_model_model_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_bridge_model
    ADD CONSTRAINT cmip5_bridge_model_model_key_fkey FOREIGN KEY (model_key) REFERENCES cmip5_dim_model(model_key);


--
-- Name: cmip5_bridge_realm_realm_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_bridge_realm
    ADD CONSTRAINT cmip5_bridge_realm_realm_key_fkey FOREIGN KEY (realm_key) REFERENCES cmip5_dim_realm(realm_key);


--
-- Name: cmip5_bridge_time_frequency_time_frequency_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_bridge_time_frequency
    ADD CONSTRAINT cmip5_bridge_time_frequency_time_frequency_key_fkey FOREIGN KEY (time_frequency_key) REFERENCES cmip5_dim_time_frequency(time_frequency_key);


--
-- Name: cmip5_bridge_variable_variable_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_bridge_variable
    ADD CONSTRAINT cmip5_bridge_variable_variable_key_fkey FOREIGN KEY (variable_key) REFERENCES cmip5_dim_variable(variable_key);


--
-- Name: cmip5_dim_geolocation_country_id_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_dim_geolocation
    ADD CONSTRAINT cmip5_dim_geolocation_country_id_fkey FOREIGN KEY (country_id) REFERENCES country(country_id);


--
-- Name: cmip5_fact_download_dataset_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_fact_download
    ADD CONSTRAINT cmip5_fact_download_dataset_key_fkey FOREIGN KEY (dataset_key) REFERENCES cmip5_dim_dataset(dataset_key);


--
-- Name: cmip5_fact_download_date_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_fact_download
    ADD CONSTRAINT cmip5_fact_download_date_key_fkey FOREIGN KEY (date_key) REFERENCES cmip5_dim_date(date_key);


--
-- Name: cmip5_fact_download_geolocation_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cmip5_fact_download
    ADD CONSTRAINT cmip5_fact_download_geolocation_key_fkey FOREIGN KEY (geolocation_key) REFERENCES cmip5_dim_geolocation(geolocation_key);


--
-- Name: country_continent_code_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY country
    ADD CONSTRAINT country_continent_code_fkey FOREIGN KEY (continent_code) REFERENCES continent(continent_code);


--
-- Name: cross_bridge_project_project_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cross_bridge_project
    ADD CONSTRAINT cross_bridge_project_project_key_fkey FOREIGN KEY (project_key) REFERENCES cross_dim_project(project_key);


--
-- Name: cross_dim_geolocation_country_id_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cross_dim_geolocation
    ADD CONSTRAINT cross_dim_geolocation_country_id_fkey FOREIGN KEY (country_id) REFERENCES country(country_id);


--
-- Name: cross_fact_download_date_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cross_fact_download
    ADD CONSTRAINT cross_fact_download_date_key_fkey FOREIGN KEY (date_key) REFERENCES cross_dim_date(date_key);


--
-- Name: cross_fact_download_geolocation_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY cross_fact_download
    ADD CONSTRAINT cross_fact_download_geolocation_key_fkey FOREIGN KEY (geolocation_key) REFERENCES cross_dim_geolocation(geolocation_key);


--
-- Name: hasfeed_idhost_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY hasfeed
    ADD CONSTRAINT hasfeed_idhost_fkey FOREIGN KEY (idhost) REFERENCES host(id);


--
-- Name: hasfeed_idrssfeed_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY hasfeed
    ADD CONSTRAINT hasfeed_idrssfeed_fkey FOREIGN KEY (idrssfeed) REFERENCES rssfeed(idrssfeed);


--
-- Name: join1_iduser_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY join1
    ADD CONSTRAINT join1_iduser_fkey FOREIGN KEY (iduser) REFERENCES user1(id) ON DELETE CASCADE;


--
-- Name: obs4mips_bridge_institute_institute_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_bridge_institute
    ADD CONSTRAINT obs4mips_bridge_institute_institute_key_fkey FOREIGN KEY (institute_key) REFERENCES obs4mips_dim_institute(institute_key);


--
-- Name: obs4mips_bridge_processing_level_processing_level_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_bridge_processing_level
    ADD CONSTRAINT obs4mips_bridge_processing_level_processing_level_key_fkey FOREIGN KEY (processing_level_key) REFERENCES obs4mips_dim_processing_level(processing_level_key);


--
-- Name: obs4mips_bridge_realm_realm_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_bridge_realm
    ADD CONSTRAINT obs4mips_bridge_realm_realm_key_fkey FOREIGN KEY (realm_key) REFERENCES obs4mips_dim_realm(realm_key);


--
-- Name: obs4mips_bridge_source_id_source_id_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_bridge_source_id
    ADD CONSTRAINT obs4mips_bridge_source_id_source_id_key_fkey FOREIGN KEY (source_id_key) REFERENCES obs4mips_dim_source_id(source_id_key);


--
-- Name: obs4mips_bridge_time_frequency_time_frequency_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_bridge_time_frequency
    ADD CONSTRAINT obs4mips_bridge_time_frequency_time_frequency_key_fkey FOREIGN KEY (time_frequency_key) REFERENCES obs4mips_dim_time_frequency(time_frequency_key);


--
-- Name: obs4mips_bridge_variable_variable_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_bridge_variable
    ADD CONSTRAINT obs4mips_bridge_variable_variable_key_fkey FOREIGN KEY (variable_key) REFERENCES obs4mips_dim_variable(variable_key);


--
-- Name: obs4mips_dim_geolocation_country_id_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_dim_geolocation
    ADD CONSTRAINT obs4mips_dim_geolocation_country_id_fkey FOREIGN KEY (country_id) REFERENCES country(country_id);


--
-- Name: obs4mips_fact_download_dataset_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_fact_download
    ADD CONSTRAINT obs4mips_fact_download_dataset_key_fkey FOREIGN KEY (dataset_key) REFERENCES obs4mips_dim_dataset(dataset_key);


--
-- Name: obs4mips_fact_download_date_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_fact_download
    ADD CONSTRAINT obs4mips_fact_download_date_key_fkey FOREIGN KEY (date_key) REFERENCES obs4mips_dim_date(date_key);


--
-- Name: obs4mips_fact_download_file_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_fact_download
    ADD CONSTRAINT obs4mips_fact_download_file_key_fkey FOREIGN KEY (file_key) REFERENCES obs4mips_dim_file(file_key);


--
-- Name: obs4mips_fact_download_geolocation_key_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY obs4mips_fact_download
    ADD CONSTRAINT obs4mips_fact_download_geolocation_key_fkey FOREIGN KEY (geolocation_key) REFERENCES obs4mips_dim_geolocation(geolocation_key);


--
-- Name: service_instance_idhost_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY service_instance
    ADD CONSTRAINT service_instance_idhost_fkey FOREIGN KEY (idhost) REFERENCES host(id) ON DELETE CASCADE;


--
-- Name: service_status_idserviceinstance_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY service_status
    ADD CONSTRAINT service_status_idserviceinstance_fkey FOREIGN KEY (idserviceinstance) REFERENCES service_instance(id) ON DELETE CASCADE;


--
-- Name: uses_idserviceinstance_fkey; Type: FK CONSTRAINT; Schema: esgf_dashboard; Owner: dbsuper
--

ALTER TABLE ONLY uses
    ADD CONSTRAINT uses_idserviceinstance_fkey FOREIGN KEY (idserviceinstance) REFERENCES service_instance(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

