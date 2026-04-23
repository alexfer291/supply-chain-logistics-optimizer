--
-- PostgreSQL database dump
--

\restrict QThjRyeaP8aSrdfajEzS5LEefdjSjB32uUNkqqykEEUKPqrhbN6BSCMJQ2k9dlr

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-04-23 19:06:17

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 219 (class 1259 OID 16389)
-- Name: freightrates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.freightrates (
    carrier text,
    orig_port_cd text,
    dest_port_cd text,
    minm_wgh_qty real,
    max_wgh_qty text,
    svc_cd text,
    minimum_cost text,
    rate text,
    mode_dsc text,
    tpt_day_cnt integer,
    carrier_type text
);


ALTER TABLE public.freightrates OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16394)
-- Name: orderlist; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orderlist (
    order_id integer,
    order_date text,
    origin_port text,
    carrier text,
    tpt integer,
    service_level text,
    ship_ahead_day_count integer,
    ship_late_day_count integer,
    customer text,
    product_id integer,
    plant_code text,
    destination_port text,
    unit_quantity integer,
    weight real
);


ALTER TABLE public.orderlist OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16399)
-- Name: plantports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plantports (
    plant_code text,
    port text
);


ALTER TABLE public.plantports OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16404)
-- Name: productsperplant; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.productsperplant (
    plant_code text,
    product_id integer
);


ALTER TABLE public.productsperplant OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16409)
-- Name: vmicustomers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vmicustomers (
    plant_code text,
    customers text
);


ALTER TABLE public.vmicustomers OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16414)
-- Name: whcapacities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.whcapacities (
    plant_id text,
    daily_capacity_ integer
);


ALTER TABLE public.whcapacities OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 24600)
-- Name: vw_analise_capacidade; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_analise_capacidade AS
 SELECT o.plant_code,
    o.order_date,
    count(DISTINCT o.order_id) AS total_pedidos,
    c.daily_capacity_ AS capacidade_maxima,
    round((((count(DISTINCT o.order_id))::numeric / NULLIF((c.daily_capacity_)::numeric, (0)::numeric)) * (100)::numeric), 2) AS perc_ocupacao
   FROM (public.orderlist o
     LEFT JOIN public.whcapacities c ON ((o.plant_code = c.plant_id)))
  GROUP BY o.plant_code, o.order_date, c.daily_capacity_;


ALTER VIEW public.vw_analise_capacidade OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 24619)
-- Name: vw_custos_logisticos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_custos_logisticos AS
 SELECT o.customer,
    o.plant_code,
    o.unit_quantity,
    o.weight,
    f.carrier,
    f.mode_dsc AS modal,
    (replace(regexp_replace(f.minimum_cost, '[^0-9,.]'::text, ''::text, 'g'::text), ','::text, '.'::text))::numeric AS min_cost_limpo,
    (replace(regexp_replace(f.rate, '[^0-9,.]'::text, ''::text, 'g'::text), ','::text, '.'::text))::numeric AS rate_limpo,
    ((replace(regexp_replace(f.minimum_cost, '[^0-9,.]'::text, ''::text, 'g'::text), ','::text, '.'::text))::numeric + ((o.weight)::numeric * (replace(regexp_replace(f.rate, '[^0-9,.]'::text, ''::text, 'g'::text), ','::text, '.'::text))::numeric)) AS custo_total_transporte
   FROM (public.orderlist o
     JOIN public.freightrates f ON (((o.carrier = f.carrier) AND (o.origin_port = f.orig_port_cd) AND (o.destination_port = f.dest_port_cd) AND (o.service_level = f.svc_cd))))
  WHERE (((o.weight)::numeric >= (f.minm_wgh_qty)::numeric) AND ((o.weight)::numeric <= (f.max_wgh_qty)::numeric));


ALTER VIEW public.vw_custos_logisticos OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16419)
-- Name: whcosts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.whcosts (
    wh text,
    "Cost/unit" real
);


ALTER TABLE public.whcosts OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 24624)
-- Name: vw_custos_totais; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_custos_totais AS
 WITH frete_unico AS (
         SELECT DISTINCT ON (freightrates.carrier, freightrates.orig_port_cd, freightrates.dest_port_cd, freightrates.svc_cd, freightrates.minm_wgh_qty, freightrates.max_wgh_qty) freightrates.carrier,
            freightrates.orig_port_cd,
            freightrates.dest_port_cd,
            freightrates.minm_wgh_qty,
            freightrates.max_wgh_qty,
            freightrates.svc_cd,
            freightrates.minimum_cost,
            freightrates.rate,
            freightrates.mode_dsc,
            freightrates.tpt_day_cnt,
            freightrates.carrier_type
           FROM public.freightrates
          ORDER BY freightrates.carrier, freightrates.orig_port_cd, freightrates.dest_port_cd, freightrates.svc_cd, freightrates.minm_wgh_qty, freightrates.max_wgh_qty, freightrates.tpt_day_cnt
        )
 SELECT o.order_id,
    o.plant_code,
    o.carrier,
    f.mode_dsc AS modal,
    o.unit_quantity,
    ((o.unit_quantity)::double precision * w."Cost/unit") AS custo_armazenagem,
    COALESCE(((replace(regexp_replace(f.minimum_cost, '[^0-9,.]'::text, ''::text, 'g'::text), ','::text, '.'::text))::numeric + ((o.weight)::numeric * (replace(regexp_replace(f.rate, '[^0-9,.]'::text, ''::text, 'g'::text), ','::text, '.'::text))::numeric)), (0)::numeric) AS custo_frete_estimado
   FROM ((public.orderlist o
     LEFT JOIN public.whcosts w ON ((o.plant_code = w.wh)))
     LEFT JOIN frete_unico f ON (((o.carrier = f.carrier) AND (o.origin_port = f.orig_port_cd) AND (o.destination_port = f.dest_port_cd) AND (o.service_level = f.svc_cd) AND (((o.weight)::numeric >= (f.minm_wgh_qty)::numeric) AND ((o.weight)::numeric <= (f.max_wgh_qty)::numeric)))));


ALTER VIEW public.vw_custos_totais OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 24610)
-- Name: vw_performance_sla; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_performance_sla AS
 SELECT order_id,
    plant_code,
    carrier,
        CASE
            WHEN (ship_late_day_count > 0) THEN 'Atrasado'::text
            WHEN (ship_ahead_day_count > 0) THEN 'Adiantado'::text
            ELSE 'No Prazo'::text
        END AS status_entrega,
        CASE
            WHEN (ship_late_day_count = 0) THEN 1
            ELSE 0
        END AS otif_on_time,
    (ship_late_day_count - ship_ahead_day_count) AS saldo_dias
   FROM public.orderlist;


ALTER VIEW public.vw_performance_sla OWNER TO postgres;

-- Completed on 2026-04-23 19:06:18

--
-- PostgreSQL database dump complete
--

\unrestrict QThjRyeaP8aSrdfajEzS5LEefdjSjB32uUNkqqykEEUKPqrhbN6BSCMJQ2k9dlr

