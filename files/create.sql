-- ENUMS (Preserved from original file)
DO $$ BEGIN
    CREATE TYPE business_type_enum AS ENUM (
        'Startup', 'Early-stage company', 'Small Business', 'Established small business',
        'Enterprise', 'Large organization', 'Agency', 'Service provider',
        'Freelancer', 'Individual consultant', 'Other', 'Something else'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE industry_enum AS ENUM (
        'Technology', 'E-commerce', 'Healthcare', 'Education', 'Finance',
        'Real Estate', 'Marketing', 'Consulting', 'SaaS', 'Other'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- USER PROVIDED DUMP
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', 'public', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: avnadmin
--

CREATE TABLE public.api_keys (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    api_key_hash text NOT NULL,
    name character varying(255),
    scopes text[],
    rate_limit integer,
    expires_at timestamp with time zone,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.api_keys OWNER TO avnadmin;

--
-- Name: background_jobs; Type: TABLE; Schema: public; Owner: avnadmin
--

CREATE TABLE public.background_jobs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    job_type character varying(100) NOT NULL,
    user_id character varying(100),
    bot_id character varying(100),
    status character varying(20) DEFAULT 'queued'::character varying NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    result jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    started_at timestamp with time zone,
    finished_at timestamp with time zone
);


ALTER TABLE public.background_jobs OWNER TO avnadmin;

--
-- Name: bot_messages; Type: TABLE; Schema: public; Owner: avnadmin
--

CREATE TABLE public.bot_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bot_id uuid NOT NULL,
    user_id uuid,
    subscription_id uuid,
    message text NOT NULL,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    client_id text,
    query text DEFAULT ''::text NOT NULL,
    model text,
    max_tokens integer,
    temperature numeric(3,2),
    top_k integer,
    time_taken_ms integer,
    session_id character varying
);


ALTER TABLE public.bot_messages OWNER TO avnadmin;

--
-- Name: bot_progress; Type: TABLE; Schema: public; Owner: avnadmin
--

CREATE TABLE public.bot_progress (
    bot_id uuid NOT NULL,
    step_1_created boolean DEFAULT true,
    step_2_sources_added boolean DEFAULT false,
    step_3_config_done boolean DEFAULT false,
    step_4_tested boolean DEFAULT false,
    step_5_embedded boolean DEFAULT false
);


ALTER TABLE public.bot_progress OWNER TO avnadmin;

--
-- Name: bots; Type: TABLE; Schema: public; Owner: avnadmin
--

CREATE TABLE public.bots (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.bots OWNER TO avnadmin;

--
-- Name: communications; Type: TABLE; Schema: public; Owner: avnadmin
--

CREATE TABLE public.communications (
    id integer NOT NULL,
    username text NOT NULL,
    email text NOT NULL,
    message text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.communications OWNER TO avnadmin;

--
-- Name: communications_id_seq; Type: SEQUENCE; Schema: public; Owner: avnadmin
--

CREATE SEQUENCE public.communications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.communications_id_seq OWNER TO avnadmin;

--
-- Name: communications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: avnadmin
--

ALTER SEQUENCE public.communications_id_seq OWNED BY public.communications.id;


--
-- Name: conversations; Type: TABLE; Schema: public; Owner: avnadmin
--

CREATE TABLE public.conversations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bot_id uuid NOT NULL,
    user_question text NOT NULL,
    bot_response text,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.conversations OWNER TO avnadmin;

--
-- Name: mcp_executions; Type: TABLE; Schema: public; Owner: avnadmin
--

CREATE TABLE public.mcp_executions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bot_id uuid NOT NULL,
    mcp_server_id uuid NOT NULL,
    tool_name character varying(255) NOT NULL,
    input_parameters json,
    output_result json,
    execution_time_ms integer,
    status character varying(50) NOT NULL,
    error_message text,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.mcp_executions OWNER TO avnadmin;

--
-- Name: mcp_servers; Type: TABLE; Schema: public; Owner: avnadmin
--

CREATE TABLE public.mcp_servers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bot_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    endpoint_url text NOT NULL,
    api_key text,
    is_active boolean DEFAULT true,
    timeout_seconds integer DEFAULT 30,
    retry_attempts integer DEFAULT 3,
    config json DEFAULT '{}'::json,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.mcp_servers OWNER TO avnadmin;

--
-- Name: mcp_tools; Type: TABLE; Schema: public; Owner: avnadmin
--

CREATE TABLE public.mcp_tools (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    mcp_server_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    schema json NOT NULL,
    is_active boolean DEFAULT true,
    usage_count integer DEFAULT 0,
    last_used timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.mcp_tools OWNER TO avnadmin;

--
-- Name: settings; Type: TABLE; Schema: public; Owner: avnadmin
--

CREATE TABLE public.settings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bot_id uuid NOT NULL,
    theme jsonb DEFAULT '{}'::jsonb,
    welcome_message text,
    enable_smart_actions boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.settings OWNER TO avnadmin;

--
-- Name: sources; Type: TABLE; Schema: public; Owner: avnadmin
--

CREATE TABLE public.sources (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bot_id uuid NOT NULL,
    type character varying(50) NOT NULL,
    url text,
    file_path text,
    text_content text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT sources_type_check CHECK (((type)::text = ANY ((ARRAY['website'::character varying, 'pdf'::character varying, 'text'::character varying, 'sitemap'::character varying, 'link'::character varying, 'multiple_links'::character varying])::text[])))
);


ALTER TABLE public.sources OWNER TO avnadmin;

--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: avnadmin
--

CREATE TABLE public.subscriptions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    max_bots integer NOT NULL,
    price_per_month numeric(10,2),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    messages_per_day integer,
    max_file_upload_size_mb integer,
    max_files_allowed integer,
    customizability smallint,
    has_priority_support boolean DEFAULT false,
    has_api_access boolean DEFAULT false,
    has_white_labeling boolean DEFAULT false,
    can_use_webhooks boolean DEFAULT false,
    max_team_members integer DEFAULT 1,
    CONSTRAINT subscriptions_customizability_check CHECK ((customizability = ANY (ARRAY[1, 2]))),
    CONSTRAINT subscriptions_max_bots_check CHECK ((max_bots >= 0)),
    CONSTRAINT subscriptions_max_file_upload_size_mb_check CHECK ((max_file_upload_size_mb = ANY (ARRAY[10, 40]))),
    CONSTRAINT subscriptions_max_files_allowed_check CHECK ((max_files_allowed >= 0)),
    CONSTRAINT subscriptions_max_team_members_check CHECK ((max_team_members >= 1)),
    CONSTRAINT subscriptions_messages_per_day_check CHECK ((messages_per_day >= 0)),
    CONSTRAINT subscriptions_price_per_month_check CHECK ((price_per_month >= (0)::numeric))
);


ALTER TABLE public.subscriptions OWNER TO avnadmin;

--
-- Name: user; Type: TABLE; Schema: public; Owner: avnadmin
--

CREATE TABLE public."user" (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255) NOT NULL,
    password_hash text NOT NULL,
    name character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    role character varying(255),
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_active boolean DEFAULT true,
    is_verified boolean DEFAULT false,
    is_deleted boolean DEFAULT false,
    company_or_project_name character varying,
    ai_experience text,
    botforge_goal text,
    website_domain character varying,
    chatbot_embed_location text,
    primary_use_case text,
    expected_monthly_users integer,
    business_type public.business_type_enum,
    industry public.industry_enum
);


ALTER TABLE public."user" OWNER TO avnadmin;

--
-- Name: user_subscriptions; Type: TABLE; Schema: public; Owner: avnadmin
--

CREATE TABLE public.user_subscriptions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    subscription_id uuid NOT NULL,
    start_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    end_date timestamp with time zone,
    is_active boolean DEFAULT true
);


ALTER TABLE public.user_subscriptions OWNER TO avnadmin;

--
-- Name: users; Type: TABLE; Schema: public; Owner: avnadmin
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_active boolean DEFAULT true,
    is_verified boolean DEFAULT false,
    is_deleted boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    email character varying NOT NULL,
    password_hash text NOT NULL,
    name character varying
);


ALTER TABLE public.users OWNER TO avnadmin;

--
-- Name: communications id; Type: DEFAULT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.communications ALTER COLUMN id SET DEFAULT nextval('public.communications_id_seq'::regclass);


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: background_jobs background_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.background_jobs
    ADD CONSTRAINT background_jobs_pkey PRIMARY KEY (id);


--
-- Name: bot_messages bot_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.bot_messages
    ADD CONSTRAINT bot_messages_pkey PRIMARY KEY (id);


--
-- Name: bot_progress bot_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.bot_progress
    ADD CONSTRAINT bot_progress_pkey PRIMARY KEY (bot_id);


--
-- Name: bots bots_pkey; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.bots
    ADD CONSTRAINT bots_pkey PRIMARY KEY (id);


--
-- Name: communications communications_pkey; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.communications
    ADD CONSTRAINT communications_pkey PRIMARY KEY (id);


--
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (id);


--
-- Name: mcp_executions mcp_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.mcp_executions
    ADD CONSTRAINT mcp_executions_pkey PRIMARY KEY (id);


--
-- Name: mcp_servers mcp_servers_pkey; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.mcp_servers
    ADD CONSTRAINT mcp_servers_pkey PRIMARY KEY (id);


--
-- Name: mcp_tools mcp_tools_pkey; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.mcp_tools
    ADD CONSTRAINT mcp_tools_pkey PRIMARY KEY (id);


--
-- Name: settings settings_bot_id_key; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_bot_id_key UNIQUE (bot_id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: sources sources_pkey; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.sources
    ADD CONSTRAINT sources_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_name_key; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_name_key UNIQUE (name);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: bots unique_bot_name; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.bots
    ADD CONSTRAINT unique_bot_name UNIQUE (name);


--
-- Name: user_subscriptions user_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.user_subscriptions
    ADD CONSTRAINT user_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: user users_email_key; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: user users_pkey; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey1; Type: CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey1 PRIMARY KEY (id);


--
-- Name: idx_background_jobs_bot_id; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_background_jobs_bot_id ON public.background_jobs USING btree (bot_id);


--
-- Name: idx_background_jobs_status; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_background_jobs_status ON public.background_jobs USING btree (status);


--
-- Name: idx_background_jobs_user_id; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_background_jobs_user_id ON public.background_jobs USING btree (user_id);


--
-- Name: idx_bot_messages_bot_id; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_bot_messages_bot_id ON public.bot_messages USING btree (bot_id);


--
-- Name: idx_bot_messages_session_id; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_bot_messages_session_id ON public.bot_messages USING btree (session_id);


--
-- Name: idx_bot_messages_subscription_id; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_bot_messages_subscription_id ON public.bot_messages USING btree (subscription_id);


--
-- Name: idx_bot_messages_timestamp; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_bot_messages_timestamp ON public.bot_messages USING btree ("timestamp");


--
-- Name: idx_bot_messages_user_id; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_bot_messages_user_id ON public.bot_messages USING btree (user_id);


--
-- Name: idx_bots_active; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_bots_active ON public.bots USING btree (is_active);


--
-- Name: idx_bots_user_id; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_bots_user_id ON public.bots USING btree (user_id);


--
-- Name: idx_conversations_bot_id; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_conversations_bot_id ON public.conversations USING btree (bot_id);


--
-- Name: idx_conversations_timestamp; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_conversations_timestamp ON public.conversations USING btree ("timestamp");


--
-- Name: idx_mcp_exec_bot_id; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_mcp_exec_bot_id ON public.mcp_executions USING btree (bot_id);


--
-- Name: idx_mcp_exec_server_id; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_mcp_exec_server_id ON public.mcp_executions USING btree (mcp_server_id);


--
-- Name: idx_mcp_exec_status; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_mcp_exec_status ON public.mcp_executions USING btree (status);


--
-- Name: idx_mcp_servers_active; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_mcp_servers_active ON public.mcp_servers USING btree (is_active);


--
-- Name: idx_mcp_servers_bot_id; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_mcp_servers_bot_id ON public.mcp_servers USING btree (bot_id);


--
-- Name: idx_mcp_servers_created_at; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_mcp_servers_created_at ON public.mcp_servers USING btree (created_at);


--
-- Name: idx_mcp_servers_is_active; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_mcp_servers_is_active ON public.mcp_servers USING btree (is_active);


--
-- Name: idx_mcp_tools_active; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_mcp_tools_active ON public.mcp_tools USING btree (is_active);


--
-- Name: idx_mcp_tools_server_id; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_mcp_tools_server_id ON public.mcp_tools USING btree (mcp_server_id);


--
-- Name: idx_sources_bot_id; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_sources_bot_id ON public.sources USING btree (bot_id);


--
-- Name: idx_user_subs_active; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_user_subs_active ON public.user_subscriptions USING btree (user_id, is_active);


--
-- Name: idx_user_subs_user_id; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_user_subs_user_id ON public.user_subscriptions USING btree (user_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: avnadmin
--

CREATE INDEX idx_users_email ON public."user" USING btree (email);


--
-- Name: api_keys api_keys_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: bot_progress bot_progress_bot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.bot_progress
    ADD CONSTRAINT bot_progress_bot_id_fkey FOREIGN KEY (bot_id) REFERENCES public.bots(id) ON DELETE CASCADE;


--
-- Name: bots bots_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.bots
    ADD CONSTRAINT bots_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: conversations conversations_bot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_bot_id_fkey FOREIGN KEY (bot_id) REFERENCES public.bots(id) ON DELETE CASCADE;


--
-- Name: mcp_executions mcp_executions_bot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.mcp_executions
    ADD CONSTRAINT mcp_executions_bot_id_fkey FOREIGN KEY (bot_id) REFERENCES public.bots(id) ON DELETE CASCADE;


--
-- Name: mcp_executions mcp_executions_mcp_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.mcp_executions
    ADD CONSTRAINT mcp_executions_mcp_server_id_fkey FOREIGN KEY (mcp_server_id) REFERENCES public.mcp_servers(id) ON DELETE CASCADE;


--
-- Name: mcp_servers mcp_servers_bot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.mcp_servers
    ADD CONSTRAINT mcp_servers_bot_id_fkey FOREIGN KEY (bot_id) REFERENCES public.bots(id) ON DELETE CASCADE;


--
-- Name: mcp_tools mcp_tools_mcp_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.mcp_tools
    ADD CONSTRAINT mcp_tools_mcp_server_id_fkey FOREIGN KEY (mcp_server_id) REFERENCES public.mcp_servers(id) ON DELETE CASCADE;


--
-- Name: settings settings_bot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_bot_id_fkey FOREIGN KEY (bot_id) REFERENCES public.bots(id) ON DELETE CASCADE;


--
-- Name: sources sources_bot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.sources
    ADD CONSTRAINT sources_bot_id_fkey FOREIGN KEY (bot_id) REFERENCES public.bots(id) ON DELETE CASCADE;


--
-- Name: user_subscriptions user_subscriptions_subscription_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.user_subscriptions
    ADD CONSTRAINT user_subscriptions_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES public.subscriptions(id);


--
-- Name: user_subscriptions user_subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: avnadmin
--

ALTER TABLE ONLY public.user_subscriptions
    ADD CONSTRAINT user_subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;

-- INITIAL DATA

-- Starter Plan
INSERT INTO public.subscriptions (
    id, name, max_bots, price_per_month, created_at,
    messages_per_day, max_file_upload_size_mb, max_files_allowed,
    customizability, has_priority_support, has_api_access,
    has_white_labeling, can_use_webhooks, max_team_members
) VALUES (
    '11111111-1111-1111-1111-111111111111', 'Starter', 2, 0.00, '2025-06-26 16:33:00.252+05:30',
    100, 10, 2,
    1, FALSE, FALSE,
    FALSE, FALSE, 1
) ON CONFLICT (name) DO NOTHING;

-- Pro Plan
INSERT INTO public.subscriptions (
    id, name, max_bots, price_per_month, created_at,
    messages_per_day, max_file_upload_size_mb, max_files_allowed,
    customizability, has_priority_support, has_api_access,
    has_white_labeling, can_use_webhooks, max_team_members
) VALUES (
    '22222222-2222-2222-2222-222222222222', 'Pro', 5, 19.99, '2025-06-26 16:33:00.252+05:30',
    1000, 40, 5,
    2, TRUE, TRUE,
    FALSE, TRUE, 5
) ON CONFLICT (name) DO NOTHING;

-- Enterprise Plan
INSERT INTO public.subscriptions (
    id, name, max_bots, price_per_month, created_at,
    messages_per_day, max_file_upload_size_mb, max_files_allowed,
    customizability, has_priority_support, has_api_access,
    has_white_labeling, can_use_webhooks, max_team_members
) VALUES (
    '33333333-3333-3333-3333-333333333333', 'Enterprise', 20, 99.99, '2025-06-26 16:33:00.252+05:30',
    10000, 40, 10,
    2, TRUE, TRUE,
    TRUE, TRUE, 20
) ON CONFLICT (name) DO NOTHING;
