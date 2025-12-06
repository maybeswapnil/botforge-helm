-- First, define the enums for business_type and industry if not already created
CREATE TYPE business_type_enum AS ENUM (
    'Startup',
    'Early-stage company',
    'Small Business',
    'Established small business',
    'Enterprise',
    'Large organization',
    'Agency',
    'Service provider',
    'Freelancer',
    'Individual consultant',
    'Other',
    'Something else'
);

CREATE TYPE industry_enum AS ENUM (
    'Technology',
    'E-commerce',
    'Healthcare',
    'Education',
    'Finance',
    'Real Estate',
    'Marketing',
    'Consulting',
    'SaaS',
    'Other'
);

-- Updated table schema
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    email VARCHAR NOT NULL,
    password_hash TEXT NOT NULL,
    name VARCHAR,
    role VARCHAR,

    -- New Columns
    company_or_project_name VARCHAR,
    ai_experience TEXT,
    botforge_goal TEXT, -- "What do you want BotForge to help you with?"
    website_domain VARCHAR,
    chatbot_embed_location TEXT,
    primary_use_case TEXT,
    expected_monthly_users INTEGER,
    business_type business_type_enum,
    industry industry_enum
);



CREATE INDEX idx_users_email ON users(email);

-- Subscription plans
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    
    max_bots INTEGER NOT NULL CHECK (max_bots >= 0),
    price_per_month NUMERIC(10, 2) CHECK (price_per_month >= 0),

    messages_per_day INTEGER CHECK (messages_per_day >= 0),

    -- Max upload size per file in megabytes
    max_file_upload_size_mb INTEGER CHECK (max_file_upload_size_mb IN (10, 40)),

    -- Max number of files allowed per bot or interaction
    max_files_allowed INTEGER CHECK (max_files_allowed >= 0),

    -- Level of customization (1 = basic, 2 = advanced)
    customizability SMALLINT CHECK (customizability IN (1, 2)),

    -- Optional feature toggles
    has_priority_support BOOLEAN DEFAULT FALSE,
    has_api_access BOOLEAN DEFAULT FALSE,
    has_white_labeling BOOLEAN DEFAULT FALSE,
    can_use_webhooks BOOLEAN DEFAULT FALSE,
    max_team_members INTEGER DEFAULT 1 CHECK (max_team_members >= 1),

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- User-subscription mapping
CREATE TABLE user_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subscription_id UUID NOT NULL REFERENCES subscriptions(id),
    start_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_user_subs_user_id ON user_subscriptions(user_id);
CREATE INDEX idx_user_subs_active ON user_subscriptions(user_id, is_active);

-- Bots created by users
CREATE TABLE bots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_bots_user_id ON bots(user_id);
CREATE INDEX idx_bots_active ON bots(is_active);

-- Bot data sources
CREATE TABLE sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bot_id UUID NOT NULL REFERENCES bots(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL CHECK (type IN ('website', 'pdf', 'text', 'sitemap', 'link', 'multiple_links')),
    url TEXT,
    file_path TEXT,
    text_content TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sources_bot_id ON sources(bot_id);

-- Bot conversation logs
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bot_id UUID NOT NULL REFERENCES bots(id) ON DELETE CASCADE,
    user_question TEXT NOT NULL,
    bot_response TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_conversations_bot_id ON conversations(bot_id);
CREATE INDEX idx_conversations_timestamp ON conversations(timestamp);

-- Bot appearance/config settings
CREATE TABLE settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bot_id UUID UNIQUE NOT NULL REFERENCES bots(id) ON DELETE CASCADE,
    theme JSONB DEFAULT '{}'::jsonb,
    welcome_message TEXT,
    enable_smart_actions BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Track progress of onboarding steps
CREATE TABLE bot_progress (
    bot_id UUID PRIMARY KEY REFERENCES bots(id) ON DELETE CASCADE,
    step_1_created BOOLEAN DEFAULT TRUE,
    step_2_sources_added BOOLEAN DEFAULT FALSE,
    step_3_config_done BOOLEAN DEFAULT FALSE,
    step_4_tested BOOLEAN DEFAULT FALSE,
    step_5_embedded BOOLEAN DEFAULT FALSE
);

-- API keys for business users (session-based bot access)
CREATE TABLE api_keys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    api_key_hash TEXT NOT NULL,
    name VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMPTZ
);

CREATE INDEX idx_api_keys_user_id ON api_keys(user_id);
CREATE INDEX idx_api_keys_hash ON api_keys(api_key_hash);
CREATE INDEX idx_api_keys_active ON api_keys(is_active);

-- Note: bot_sessions are stored in Redis for performance
-- Key format: session:<hashed_token>
-- Value: JSON with session data including context, expiration, etc.

-- Optional: Materialized view for analytics (example)
-- CREATE MATERIALIZED VIEW bot_usage_stats AS
-- SELECT bot_id, COUNT(*) AS total_conversations
-- FROM conversations
-- GROUP BY bot_id;
-- You can refresh this view periodically for fast dashboard analytics.

-- MCP SERVERS

CREATE TABLE mcp_servers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bot_id UUID NOT NULL REFERENCES bots(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    endpoint_url TEXT NOT NULL,
    api_key TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    timeout_seconds INTEGER DEFAULT 30,
    retry_attempts INTEGER DEFAULT 3,
    config JSON DEFAULT '{}'::json,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_mcp_servers_bot_id ON mcp_servers(bot_id);
CREATE INDEX idx_mcp_servers_active ON mcp_servers(is_active);

-- MCP TOOLS

CREATE TABLE mcp_tools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mcp_server_id UUID NOT NULL REFERENCES mcp_servers(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    schema JSON NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    usage_count INTEGER DEFAULT 0,
    last_used TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_mcp_tools_server_id ON mcp_tools(mcp_server_id);
CREATE INDEX idx_mcp_tools_active ON mcp_tools(is_active);

-- MCP EXECUTIONS

CREATE TABLE mcp_executions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bot_id UUID NOT NULL REFERENCES bots(id) ON DELETE CASCADE,
    mcp_server_id UUID NOT NULL REFERENCES mcp_servers(id) ON DELETE CASCADE,
    tool_name VARCHAR(255) NOT NULL,
    input_parameters JSON,
    output_result JSON,
    execution_time_ms INTEGER,
    status VARCHAR(50) NOT NULL,  -- success, error, timeout
    error_message TEXT,
    timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_mcp_exec_bot_id ON mcp_executions(bot_id);
CREATE INDEX idx_mcp_exec_server_id ON mcp_executions(mcp_server_id);
CREATE INDEX idx_mcp_exec_status ON mcp_executions(status);

-- Starter Plan
INSERT INTO subscriptions (
    id, name, max_bots, price_per_month, created_at,
    messages_per_day, max_file_upload_size_mb, max_files_allowed,
    customizability, has_priority_support, has_api_access,
    has_white_labeling, can_use_webhooks, max_team_members
) VALUES (
    '11111111-1111-1111-1111-111111111111', 'Starter', 2, 0.00, '2025-06-26 16:33:00.252+05:30',
    100, 10, 2,
    1, FALSE, FALSE,
    FALSE, FALSE, 1
);

-- Pro Plan
INSERT INTO subscriptions (
    id, name, max_bots, price_per_month, created_at,
    messages_per_day, max_file_upload_size_mb, max_files_allowed,
    customizability, has_priority_support, has_api_access,
    has_white_labeling, can_use_webhooks, max_team_members
) VALUES (
    '22222222-2222-2222-2222-222222222222', 'Pro', 5, 19.99, '2025-06-26 16:33:00.252+05:30',
    1000, 40, 5,
    2, TRUE, TRUE,
    FALSE, TRUE, 5
);

-- Enterprise Plan
INSERT INTO subscriptions (
    id, name, max_bots, price_per_month, created_at,
    messages_per_day, max_file_upload_size_mb, max_files_allowed,
    customizability, has_priority_support, has_api_access,
    has_white_labeling, can_use_webhooks, max_team_members
) VALUES (
    '33333333-3333-3333-3333-333333333333', 'Enterprise', 20, 99.99, '2025-06-26 16:33:00.252+05:30',
    10000, 40, 10,
    2, TRUE, TRUE,
    TRUE, TRUE, 20
);

CREATE TABLE bot_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bot_id UUID NOT NULL,
    client_id TEXT,  -- e.g., "web-client"
    user_id UUID,    -- optional: if tracking user-wise
    subscription_id UUID, -- optional: link to plan
    session_id VARCHAR, -- session identifier
    query TEXT NOT NULL,  -- the input sent by user
    message TEXT NOT NULL, -- the response from bot
    model TEXT,  -- e.g., "gpt-3.5-turbo"
    max_tokens INT,
    temperature NUMERIC(3,2),  -- e.g., 0.7
    top_k INT,
    time_taken_ms INT, -- total time taken in milliseconds
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
