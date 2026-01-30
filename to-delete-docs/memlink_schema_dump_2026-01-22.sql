--
-- PostgreSQL database dump
--

\restrict bKvVn5KvIF0XTZ9Z5yCXvVgQI3qOFnrdDvRd5kRFQ1xsmn3gDWv3WNU6MeeRj7y

-- Dumped from database version 16.10
-- Dumped by pg_dump version 16.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: job_outbox; Type: TABLE; Schema: public; Owner: memlink_user
--

CREATE TABLE public.job_outbox (
    id bigint NOT NULL,
    event_type text NOT NULL,
    payload jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    processed_at timestamp with time zone,
    claimed_at timestamp with time zone,
    attempts integer DEFAULT 0
);


ALTER TABLE public.job_outbox OWNER TO memlink_user;

--
-- Name: job_outbox_id_seq; Type: SEQUENCE; Schema: public; Owner: memlink_user
--

CREATE SEQUENCE public.job_outbox_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.job_outbox_id_seq OWNER TO memlink_user;

--
-- Name: job_outbox_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: memlink_user
--

ALTER SEQUENCE public.job_outbox_id_seq OWNED BY public.job_outbox.id;


--
-- Name: job_runs; Type: TABLE; Schema: public; Owner: memlink_user
--

CREATE TABLE public.job_runs (
    id bigint NOT NULL,
    chat_id text NOT NULL,
    provider text NOT NULL,
    status text NOT NULL,
    error text,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    finished_at timestamp with time zone,
    payload jsonb,
    metadata jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.job_runs OWNER TO memlink_user;

--
-- Name: job_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: memlink_user
--

CREATE SEQUENCE public.job_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.job_runs_id_seq OWNER TO memlink_user;

--
-- Name: job_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: memlink_user
--

ALTER SEQUENCE public.job_runs_id_seq OWNED BY public.job_runs.id;


--
-- Name: job_watermarks; Type: TABLE; Schema: public; Owner: memlink_user
--

CREATE TABLE public.job_watermarks (
    chat_id text NOT NULL,
    last_message_id text,
    message_count integer DEFAULT 0,
    checksum text,
    updated_at timestamp with time zone DEFAULT now(),
    last_chat_updated_at bigint DEFAULT 0,
    last_synced_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.job_watermarks OWNER TO memlink_user;

--
-- Name: kg_entities; Type: TABLE; Schema: public; Owner: memlink_user
--

CREATE TABLE public.kg_entities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    type character varying(50) NOT NULL,
    aliases text[] DEFAULT '{}'::text[],
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.kg_entities OWNER TO memlink_user;

--
-- Name: kg_triples; Type: TABLE; Schema: public; Owner: memlink_user
--

CREATE TABLE public.kg_triples (
    subject_id uuid NOT NULL,
    predicate character varying(50) NOT NULL,
    object_id uuid NOT NULL,
    confidence numeric,
    source_message_id uuid,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT kg_triples_confidence_check CHECK (((confidence >= (0)::numeric) AND (confidence <= (1)::numeric)))
);


ALTER TABLE public.kg_triples OWNER TO memlink_user;

--
-- Name: memlink_admin_audit; Type: TABLE; Schema: public; Owner: memlink_user
--

CREATE TABLE public.memlink_admin_audit (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    actor_hash text,
    action text NOT NULL,
    tenant_id uuid,
    target_type text,
    target_id text,
    request_ip text,
    user_agent text,
    payload jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.memlink_admin_audit OWNER TO memlink_user;

--
-- Name: memlink_chat_summaries; Type: TABLE; Schema: public; Owner: memlink_user
--

CREATE TABLE public.memlink_chat_summaries (
    chat_id uuid NOT NULL,
    user_id uuid,
    title text,
    summary text NOT NULL,
    message_count integer,
    summary_hash text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.memlink_chat_summaries OWNER TO memlink_user;

--
-- Name: memlink_control; Type: TABLE; Schema: public; Owner: memlink_user
--

CREATE TABLE public.memlink_control (
    id text NOT NULL,
    paused boolean DEFAULT false NOT NULL,
    reason text,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.memlink_control OWNER TO memlink_user;

--
-- Name: memlink_embeddings; Type: TABLE; Schema: public; Owner: memlink_user
--

CREATE TABLE public.memlink_embeddings (
    id bigint NOT NULL,
    tenant_id uuid,
    chat_id text NOT NULL,
    artifact_type text NOT NULL,
    artifact_hash text NOT NULL,
    content text NOT NULL,
    embedding double precision[] NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.memlink_embeddings OWNER TO memlink_user;

--
-- Name: memlink_embeddings_id_seq; Type: SEQUENCE; Schema: public; Owner: memlink_user
--

CREATE SEQUENCE public.memlink_embeddings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.memlink_embeddings_id_seq OWNER TO memlink_user;

--
-- Name: memlink_embeddings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: memlink_user
--

ALTER SEQUENCE public.memlink_embeddings_id_seq OWNED BY public.memlink_embeddings.id;


--
-- Name: memlink_graph_edges; Type: TABLE; Schema: public; Owner: memlink_user
--

CREATE TABLE public.memlink_graph_edges (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    from_node_id uuid NOT NULL,
    to_node_id uuid NOT NULL,
    relation_type text NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb,
    evidence jsonb DEFAULT '{}'::jsonb,
    verified_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.memlink_graph_edges OWNER TO memlink_user;

--
-- Name: memlink_graph_nodes; Type: TABLE; Schema: public; Owner: memlink_user
--

CREATE TABLE public.memlink_graph_nodes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    node_type text NOT NULL,
    node_key text NOT NULL,
    label text,
    metadata jsonb DEFAULT '{}'::jsonb,
    evidence jsonb DEFAULT '{}'::jsonb,
    verified_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    trust_tier text,
    signer_id text
);


ALTER TABLE public.memlink_graph_nodes OWNER TO memlink_user;

--
-- Name: memlink_jobs; Type: TABLE; Schema: public; Owner: memlink_user
--

CREATE TABLE public.memlink_jobs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    chat_id text NOT NULL,
    provider text NOT NULL,
    status text NOT NULL,
    payload jsonb NOT NULL,
    error text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.memlink_jobs OWNER TO memlink_user;

--
-- Name: memlink_memory_facts; Type: TABLE; Schema: public; Owner: memlink_user
--

CREATE TABLE public.memlink_memory_facts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    chat_id uuid NOT NULL,
    fact text NOT NULL,
    source_message_id text,
    confidence numeric,
    scope text,
    evidence jsonb DEFAULT '{}'::jsonb,
    verified_at timestamp with time zone,
    summary_hash text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    trust_tier text,
    signer_id text
);


ALTER TABLE public.memlink_memory_facts OWNER TO memlink_user;

--
-- Name: memlink_query_audit; Type: TABLE; Schema: public; Owner: memlink_user
--

CREATE TABLE public.memlink_query_audit (
    id bigint NOT NULL,
    tenant_id uuid,
    chat_id text,
    query text NOT NULL,
    refused boolean DEFAULT false NOT NULL,
    refusal_reason text,
    evidence jsonb DEFAULT '{}'::jsonb,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.memlink_query_audit OWNER TO memlink_user;

--
-- Name: memlink_query_audit_id_seq; Type: SEQUENCE; Schema: public; Owner: memlink_user
--

CREATE SEQUENCE public.memlink_query_audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.memlink_query_audit_id_seq OWNER TO memlink_user;

--
-- Name: memlink_query_audit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: memlink_user
--

ALTER SEQUENCE public.memlink_query_audit_id_seq OWNED BY public.memlink_query_audit.id;


--
-- Name: memlink_schema_migrations; Type: TABLE; Schema: public; Owner: memlink_user
--

CREATE TABLE public.memlink_schema_migrations (
    id integer NOT NULL,
    name text NOT NULL,
    run_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.memlink_schema_migrations OWNER TO memlink_user;

--
-- Name: memlink_schema_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: memlink_user
--

CREATE SEQUENCE public.memlink_schema_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.memlink_schema_migrations_id_seq OWNER TO memlink_user;

--
-- Name: memlink_schema_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: memlink_user
--

ALTER SEQUENCE public.memlink_schema_migrations_id_seq OWNED BY public.memlink_schema_migrations.id;


--
-- Name: memlink_segment_summaries; Type: TABLE; Schema: public; Owner: memlink_user
--

CREATE TABLE public.memlink_segment_summaries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    chat_id uuid NOT NULL,
    segment_index integer NOT NULL,
    title text,
    summary text NOT NULL,
    summary_hash text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.memlink_segment_summaries OWNER TO memlink_user;

--
-- Name: memlink_tenant_configs; Type: TABLE; Schema: public; Owner: memlink_user
--

CREATE TABLE public.memlink_tenant_configs (
    tenant_id uuid NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.memlink_tenant_configs OWNER TO memlink_user;

--
-- Name: memlink_tenant_mappings; Type: TABLE; Schema: public; Owner: memlink_user
--

CREATE TABLE public.memlink_tenant_mappings (
    id bigint NOT NULL,
    tenant_id uuid NOT NULL,
    scope_type text NOT NULL,
    scope_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.memlink_tenant_mappings OWNER TO memlink_user;

--
-- Name: memlink_tenant_mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: memlink_user
--

CREATE SEQUENCE public.memlink_tenant_mappings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.memlink_tenant_mappings_id_seq OWNER TO memlink_user;

--
-- Name: memlink_tenant_mappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: memlink_user
--

ALTER SEQUENCE public.memlink_tenant_mappings_id_seq OWNED BY public.memlink_tenant_mappings.id;


--
-- Name: memlink_tenants; Type: TABLE; Schema: public; Owner: memlink_user
--

CREATE TABLE public.memlink_tenants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    slug text NOT NULL,
    name text,
    status text DEFAULT 'active'::text NOT NULL,
    rate_limit_per_min integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.memlink_tenants OWNER TO memlink_user;

--
-- Name: tenant_schema_migrations; Type: TABLE; Schema: public; Owner: memlink_user
--

CREATE TABLE public.tenant_schema_migrations (
    id integer NOT NULL,
    name text NOT NULL,
    run_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tenant_schema_migrations OWNER TO memlink_user;

--
-- Name: tenant_schema_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: memlink_user
--

CREATE SEQUENCE public.tenant_schema_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tenant_schema_migrations_id_seq OWNER TO memlink_user;

--
-- Name: tenant_schema_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: memlink_user
--

ALTER SEQUENCE public.tenant_schema_migrations_id_seq OWNED BY public.tenant_schema_migrations.id;


--
-- Name: job_outbox id; Type: DEFAULT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.job_outbox ALTER COLUMN id SET DEFAULT nextval('public.job_outbox_id_seq'::regclass);


--
-- Name: job_runs id; Type: DEFAULT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.job_runs ALTER COLUMN id SET DEFAULT nextval('public.job_runs_id_seq'::regclass);


--
-- Name: memlink_embeddings id; Type: DEFAULT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_embeddings ALTER COLUMN id SET DEFAULT nextval('public.memlink_embeddings_id_seq'::regclass);


--
-- Name: memlink_query_audit id; Type: DEFAULT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_query_audit ALTER COLUMN id SET DEFAULT nextval('public.memlink_query_audit_id_seq'::regclass);


--
-- Name: memlink_schema_migrations id; Type: DEFAULT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_schema_migrations ALTER COLUMN id SET DEFAULT nextval('public.memlink_schema_migrations_id_seq'::regclass);


--
-- Name: memlink_tenant_mappings id; Type: DEFAULT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_tenant_mappings ALTER COLUMN id SET DEFAULT nextval('public.memlink_tenant_mappings_id_seq'::regclass);


--
-- Name: tenant_schema_migrations id; Type: DEFAULT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.tenant_schema_migrations ALTER COLUMN id SET DEFAULT nextval('public.tenant_schema_migrations_id_seq'::regclass);


--
-- Name: job_outbox job_outbox_pkey; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.job_outbox
    ADD CONSTRAINT job_outbox_pkey PRIMARY KEY (id);


--
-- Name: job_runs job_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.job_runs
    ADD CONSTRAINT job_runs_pkey PRIMARY KEY (id);


--
-- Name: job_watermarks job_watermarks_pkey; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.job_watermarks
    ADD CONSTRAINT job_watermarks_pkey PRIMARY KEY (chat_id);


--
-- Name: kg_entities kg_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.kg_entities
    ADD CONSTRAINT kg_entities_pkey PRIMARY KEY (id);


--
-- Name: kg_triples kg_triples_pkey; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.kg_triples
    ADD CONSTRAINT kg_triples_pkey PRIMARY KEY (subject_id, predicate, object_id);


--
-- Name: memlink_admin_audit memlink_admin_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_admin_audit
    ADD CONSTRAINT memlink_admin_audit_pkey PRIMARY KEY (id);


--
-- Name: memlink_chat_summaries memlink_chat_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_chat_summaries
    ADD CONSTRAINT memlink_chat_summaries_pkey PRIMARY KEY (chat_id);


--
-- Name: memlink_control memlink_control_pkey; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_control
    ADD CONSTRAINT memlink_control_pkey PRIMARY KEY (id);


--
-- Name: memlink_embeddings memlink_embeddings_pkey; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_embeddings
    ADD CONSTRAINT memlink_embeddings_pkey PRIMARY KEY (id);


--
-- Name: memlink_graph_edges memlink_graph_edges_pkey; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_graph_edges
    ADD CONSTRAINT memlink_graph_edges_pkey PRIMARY KEY (id);


--
-- Name: memlink_graph_edges memlink_graph_edges_tenant_id_from_node_id_to_node_id_relat_key; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_graph_edges
    ADD CONSTRAINT memlink_graph_edges_tenant_id_from_node_id_to_node_id_relat_key UNIQUE (tenant_id, from_node_id, to_node_id, relation_type);


--
-- Name: memlink_graph_nodes memlink_graph_nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_graph_nodes
    ADD CONSTRAINT memlink_graph_nodes_pkey PRIMARY KEY (id);


--
-- Name: memlink_graph_nodes memlink_graph_nodes_tenant_id_node_type_node_key_key; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_graph_nodes
    ADD CONSTRAINT memlink_graph_nodes_tenant_id_node_type_node_key_key UNIQUE (tenant_id, node_type, node_key);


--
-- Name: memlink_jobs memlink_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_jobs
    ADD CONSTRAINT memlink_jobs_pkey PRIMARY KEY (id);


--
-- Name: memlink_memory_facts memlink_memory_facts_pkey; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_memory_facts
    ADD CONSTRAINT memlink_memory_facts_pkey PRIMARY KEY (id);


--
-- Name: memlink_query_audit memlink_query_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_query_audit
    ADD CONSTRAINT memlink_query_audit_pkey PRIMARY KEY (id);


--
-- Name: memlink_schema_migrations memlink_schema_migrations_name_key; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_schema_migrations
    ADD CONSTRAINT memlink_schema_migrations_name_key UNIQUE (name);


--
-- Name: memlink_schema_migrations memlink_schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_schema_migrations
    ADD CONSTRAINT memlink_schema_migrations_pkey PRIMARY KEY (id);


--
-- Name: memlink_segment_summaries memlink_segment_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_segment_summaries
    ADD CONSTRAINT memlink_segment_summaries_pkey PRIMARY KEY (id);


--
-- Name: memlink_tenant_configs memlink_tenant_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_tenant_configs
    ADD CONSTRAINT memlink_tenant_configs_pkey PRIMARY KEY (tenant_id);


--
-- Name: memlink_tenant_mappings memlink_tenant_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_tenant_mappings
    ADD CONSTRAINT memlink_tenant_mappings_pkey PRIMARY KEY (id);


--
-- Name: memlink_tenant_mappings memlink_tenant_mappings_scope_type_scope_id_key; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_tenant_mappings
    ADD CONSTRAINT memlink_tenant_mappings_scope_type_scope_id_key UNIQUE (scope_type, scope_id);


--
-- Name: memlink_tenants memlink_tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_tenants
    ADD CONSTRAINT memlink_tenants_pkey PRIMARY KEY (id);


--
-- Name: memlink_tenants memlink_tenants_slug_key; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_tenants
    ADD CONSTRAINT memlink_tenants_slug_key UNIQUE (slug);


--
-- Name: tenant_schema_migrations tenant_schema_migrations_name_key; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.tenant_schema_migrations
    ADD CONSTRAINT tenant_schema_migrations_name_key UNIQUE (name);


--
-- Name: tenant_schema_migrations tenant_schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.tenant_schema_migrations
    ADD CONSTRAINT tenant_schema_migrations_pkey PRIMARY KEY (id);


--
-- Name: idx_job_runs_chat_started_at; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_job_runs_chat_started_at ON public.job_runs USING btree (chat_id, started_at DESC);


--
-- Name: idx_job_runs_status; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_job_runs_status ON public.job_runs USING btree (status);


--
-- Name: idx_kg_entities_name; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_kg_entities_name ON public.kg_entities USING btree (name);


--
-- Name: idx_kg_entities_type; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_kg_entities_type ON public.kg_entities USING btree (type);


--
-- Name: idx_kg_triples_object; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_kg_triples_object ON public.kg_triples USING btree (object_id);


--
-- Name: idx_kg_triples_predicate; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_kg_triples_predicate ON public.kg_triples USING btree (predicate);


--
-- Name: idx_kg_triples_subject; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_kg_triples_subject ON public.kg_triples USING btree (subject_id);


--
-- Name: idx_memlink_admin_audit_action; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_memlink_admin_audit_action ON public.memlink_admin_audit USING btree (action);


--
-- Name: idx_memlink_admin_audit_created; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_memlink_admin_audit_created ON public.memlink_admin_audit USING btree (created_at DESC);


--
-- Name: idx_memlink_admin_audit_tenant; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_memlink_admin_audit_tenant ON public.memlink_admin_audit USING btree (tenant_id);


--
-- Name: idx_memlink_chat_summaries_hash; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_memlink_chat_summaries_hash ON public.memlink_chat_summaries USING btree (summary_hash);


--
-- Name: idx_memlink_embeddings_artifact; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE UNIQUE INDEX idx_memlink_embeddings_artifact ON public.memlink_embeddings USING btree (chat_id, artifact_type, artifact_hash);


--
-- Name: idx_memlink_embeddings_created; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_memlink_embeddings_created ON public.memlink_embeddings USING btree (created_at DESC);


--
-- Name: idx_memlink_embeddings_tenant; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_memlink_embeddings_tenant ON public.memlink_embeddings USING btree (tenant_id);


--
-- Name: idx_memlink_graph_edges_from; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_memlink_graph_edges_from ON public.memlink_graph_edges USING btree (from_node_id);


--
-- Name: idx_memlink_graph_edges_relation; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_memlink_graph_edges_relation ON public.memlink_graph_edges USING btree (relation_type);


--
-- Name: idx_memlink_graph_edges_tenant; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_memlink_graph_edges_tenant ON public.memlink_graph_edges USING btree (tenant_id);


--
-- Name: idx_memlink_graph_edges_to; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_memlink_graph_edges_to ON public.memlink_graph_edges USING btree (to_node_id);


--
-- Name: idx_memlink_graph_nodes_key; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_memlink_graph_nodes_key ON public.memlink_graph_nodes USING btree (node_key);


--
-- Name: idx_memlink_graph_nodes_tenant; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_memlink_graph_nodes_tenant ON public.memlink_graph_nodes USING btree (tenant_id);


--
-- Name: idx_memlink_graph_nodes_type; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_memlink_graph_nodes_type ON public.memlink_graph_nodes USING btree (node_type);


--
-- Name: idx_memlink_jobs_chat; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_memlink_jobs_chat ON public.memlink_jobs USING btree (chat_id, created_at DESC);


--
-- Name: idx_memlink_jobs_status; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_memlink_jobs_status ON public.memlink_jobs USING btree (status);


--
-- Name: idx_memlink_memory_facts_chat; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_memlink_memory_facts_chat ON public.memlink_memory_facts USING btree (chat_id);


--
-- Name: idx_memlink_memory_facts_summary_hash; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_memlink_memory_facts_summary_hash ON public.memlink_memory_facts USING btree (summary_hash);


--
-- Name: idx_memlink_query_audit_created; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_memlink_query_audit_created ON public.memlink_query_audit USING btree (created_at DESC);


--
-- Name: idx_memlink_query_audit_tenant; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_memlink_query_audit_tenant ON public.memlink_query_audit USING btree (tenant_id);


--
-- Name: idx_memlink_segment_summaries_chat; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_memlink_segment_summaries_chat ON public.memlink_segment_summaries USING btree (chat_id);


--
-- Name: idx_memlink_segment_summaries_unique; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE UNIQUE INDEX idx_memlink_segment_summaries_unique ON public.memlink_segment_summaries USING btree (chat_id, summary_hash, segment_index);


--
-- Name: idx_memlink_tenant_mappings_tenant; Type: INDEX; Schema: public; Owner: memlink_user
--

CREATE INDEX idx_memlink_tenant_mappings_tenant ON public.memlink_tenant_mappings USING btree (tenant_id);


--
-- Name: kg_triples kg_triples_object_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.kg_triples
    ADD CONSTRAINT kg_triples_object_id_fkey FOREIGN KEY (object_id) REFERENCES public.kg_entities(id) ON DELETE CASCADE;


--
-- Name: kg_triples kg_triples_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.kg_triples
    ADD CONSTRAINT kg_triples_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.kg_entities(id) ON DELETE CASCADE;


--
-- Name: memlink_admin_audit memlink_admin_audit_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_admin_audit
    ADD CONSTRAINT memlink_admin_audit_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.memlink_tenants(id);


--
-- Name: memlink_graph_edges memlink_graph_edges_from_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_graph_edges
    ADD CONSTRAINT memlink_graph_edges_from_node_id_fkey FOREIGN KEY (from_node_id) REFERENCES public.memlink_graph_nodes(id) ON DELETE CASCADE;


--
-- Name: memlink_graph_edges memlink_graph_edges_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_graph_edges
    ADD CONSTRAINT memlink_graph_edges_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.memlink_tenants(id) ON DELETE CASCADE;


--
-- Name: memlink_graph_edges memlink_graph_edges_to_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_graph_edges
    ADD CONSTRAINT memlink_graph_edges_to_node_id_fkey FOREIGN KEY (to_node_id) REFERENCES public.memlink_graph_nodes(id) ON DELETE CASCADE;


--
-- Name: memlink_graph_nodes memlink_graph_nodes_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_graph_nodes
    ADD CONSTRAINT memlink_graph_nodes_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.memlink_tenants(id) ON DELETE CASCADE;


--
-- Name: memlink_tenant_configs memlink_tenant_configs_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_tenant_configs
    ADD CONSTRAINT memlink_tenant_configs_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.memlink_tenants(id) ON DELETE CASCADE;


--
-- Name: memlink_tenant_mappings memlink_tenant_mappings_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memlink_user
--

ALTER TABLE ONLY public.memlink_tenant_mappings
    ADD CONSTRAINT memlink_tenant_mappings_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.memlink_tenants(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict bKvVn5KvIF0XTZ9Z5yCXvVgQI3qOFnrdDvRd5kRFQ1xsmn3gDWv3WNU6MeeRj7y

