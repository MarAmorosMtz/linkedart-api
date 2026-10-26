--
-- PostgreSQL database dump
--

\restrict TIANzMd5hSJe2fkAdTZzbaTrJPMA6oq28miYm3hKChLJdcvo1jbciykrkyxazLg

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

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
-- Name: comment_media; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comment_media (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    comment_id uuid NOT NULL,
    type character varying(10) NOT NULL,
    storage_key character varying(500) NOT NULL,
    mime_type character varying(100) NOT NULL,
    file_size bigint NOT NULL,
    width integer,
    height integer,
    duration integer,
    "position" integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_comment_media_file_size CHECK ((file_size > 0)),
    CONSTRAINT chk_comment_media_position CHECK (("position" >= 0)),
    CONSTRAINT chk_comment_media_type CHECK (((type)::text = ANY ((ARRAY['IMAGE'::character varying, 'VIDEO'::character varying, 'GIF'::character varying])::text[])))
);


ALTER TABLE public.comment_media OWNER TO postgres;

--
-- Name: comment_reactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comment_reactions (
    comment_id uuid NOT NULL,
    user_id uuid NOT NULL,
    type character varying(20) DEFAULT 'LIKE'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_comment_reactions_type CHECK (((type)::text = ANY ((ARRAY['LIKE'::character varying, 'LOVE'::character varying, 'CELEBRATE'::character varying, 'SUPPORT'::character varying, 'FUNNY'::character varying, 'SAD'::character varying, 'ANGRY'::character varying])::text[])))
);


ALTER TABLE public.comment_reactions OWNER TO postgres;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    post_id uuid NOT NULL,
    user_id uuid NOT NULL,
    parent_id uuid,
    content text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.comments OWNER TO postgres;

--
-- Name: course_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.course_details (
    opportunity_id uuid NOT NULL,
    instructor_name character varying(150),
    duration_hours numeric(6,2),
    modality character varying(20) DEFAULT 'ONSITE'::character varying NOT NULL,
    capacity integer,
    level character varying(20),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_course_details_capacity CHECK (((capacity IS NULL) OR (capacity > 0))),
    CONSTRAINT chk_course_details_duration CHECK (((duration_hours IS NULL) OR (duration_hours > (0)::numeric))),
    CONSTRAINT chk_course_details_level CHECK (((level IS NULL) OR ((level)::text = ANY ((ARRAY['BEGINNER'::character varying, 'INTERMEDIATE'::character varying, 'ADVANCED'::character varying, 'ALL'::character varying])::text[])))),
    CONSTRAINT chk_course_details_modality CHECK (((modality)::text = ANY ((ARRAY['ONSITE'::character varying, 'ONLINE'::character varying, 'HYBRID'::character varying])::text[])))
);


ALTER TABLE public.course_details OWNER TO postgres;

--
-- Name: event_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event_details (
    opportunity_id uuid NOT NULL,
    capacity integer,
    event_type character varying(30) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_event_details_capacity CHECK (((capacity IS NULL) OR (capacity > 0))),
    CONSTRAINT chk_event_details_type CHECK (((event_type)::text = ANY ((ARRAY['CONFERENCE'::character varying, 'WORKSHOP'::character varying, 'CULTURAL'::character varying, 'SPORTS'::character varying, 'MEETING'::character varying, 'FESTIVAL'::character varying, 'OTHER'::character varying])::text[])))
);


ALTER TABLE public.event_details OWNER TO postgres;

--
-- Name: experiences; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.experiences (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    organization_id uuid,
    "position" character varying(150) NOT NULL,
    description text,
    start_date date NOT NULL,
    end_date date,
    is_current boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_experiences_dates CHECK (((end_date IS NULL) OR (end_date >= start_date)))
);


ALTER TABLE public.experiences OWNER TO postgres;

--
-- Name: follows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.follows (
    follower_id uuid NOT NULL,
    following_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_follows_no_self_follow CHECK ((follower_id <> following_id))
);


ALTER TABLE public.follows OWNER TO postgres;

--
-- Name: handles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.handles (
    username character varying(30) NOT NULL,
    user_id uuid,
    organization_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_handles_owner CHECK (((((user_id IS NOT NULL))::integer + ((organization_id IS NOT NULL))::integer) = 1)),
    CONSTRAINT handles_username_check CHECK (((username)::text ~ '^[a-z0-9_]{3,30}$'::text))
);


ALTER TABLE public.handles OWNER TO postgres;

--
-- Name: job_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_details (
    opportunity_id uuid NOT NULL,
    employment_type character varying(30) NOT NULL,
    workplace_type character varying(20) DEFAULT 'ONSITE'::character varying NOT NULL,
    salary_min numeric(12,2),
    salary_max numeric(12,2),
    salary_currency character(3) DEFAULT 'MXN'::bpchar,
    experience_level character varying(30),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_job_details_employment_type CHECK (((employment_type)::text = ANY ((ARRAY['FULL_TIME'::character varying, 'PART_TIME'::character varying, 'CONTRACT'::character varying, 'TEMPORARY'::character varying, 'INTERNSHIP'::character varying, 'VOLUNTEER'::character varying])::text[]))),
    CONSTRAINT chk_job_details_salary CHECK ((((salary_min IS NULL) OR (salary_min >= (0)::numeric)) AND ((salary_max IS NULL) OR (salary_max >= (0)::numeric)) AND ((salary_max IS NULL) OR (salary_min IS NULL) OR (salary_max >= salary_min)))),
    CONSTRAINT chk_job_details_workplace_type CHECK (((workplace_type)::text = ANY ((ARRAY['ONSITE'::character varying, 'REMOTE'::character varying, 'HYBRID'::character varying])::text[])))
);


ALTER TABLE public.job_details OWNER TO postgres;

--
-- Name: locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.locations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    label character varying(200),
    address_line character varying(255),
    city character varying(100),
    state character varying(100),
    country character(2) NOT NULL,
    latitude numeric(9,6),
    longitude numeric(9,6),
    google_place_id character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_locations_coords_pair CHECK (((latitude IS NULL) = (longitude IS NULL))),
    CONSTRAINT chk_locations_coords_range CHECK ((((latitude >= ('-90'::integer)::numeric) AND (latitude <= (90)::numeric)) AND ((longitude >= ('-180'::integer)::numeric) AND (longitude <= (180)::numeric))))
);


ALTER TABLE public.locations OWNER TO postgres;

--
-- Name: opportunities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.opportunities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    title character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    description text NOT NULL,
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    application_deadline timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    location_id uuid,
    CONSTRAINT chk_opportunities_dates CHECK (((end_date IS NULL) OR (start_date IS NULL) OR (end_date >= start_date))),
    CONSTRAINT chk_opportunities_type CHECK (((type)::text = ANY ((ARRAY['JOB'::character varying, 'EVENT'::character varying, 'COURSE'::character varying, 'CALL'::character varying])::text[])))
);


ALTER TABLE public.opportunities OWNER TO postgres;

--
-- Name: opportunity_applications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.opportunity_applications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    opportunity_id uuid NOT NULL,
    user_id uuid NOT NULL,
    status character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_opportunity_applications_status CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'ACCEPTED'::character varying, 'REJECTED'::character varying, 'WITHDRAWN'::character varying])::text[])))
);


ALTER TABLE public.opportunity_applications OWNER TO postgres;

--
-- Name: opportunity_skills; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.opportunity_skills (
    opportunity_id uuid NOT NULL,
    skill_id uuid NOT NULL,
    is_required boolean DEFAULT false NOT NULL
);


ALTER TABLE public.opportunity_skills OWNER TO postgres;

--
-- Name: organization_follows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organization_follows (
    follower_id uuid NOT NULL,
    organization_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.organization_follows OWNER TO postgres;

--
-- Name: organization_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organization_members (
    organization_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role character varying(20) DEFAULT 'MEMBER'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_organization_members_role CHECK (((role)::text = ANY ((ARRAY['OWNER'::character varying, 'ADMIN'::character varying, 'MODERATOR'::character varying, 'MEMBER'::character varying])::text[])))
);


ALTER TABLE public.organization_members OWNER TO postgres;

--
-- Name: organizations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organizations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(150) NOT NULL,
    type character varying(30) NOT NULL,
    description text,
    website character varying(500),
    profile_image character varying(500),
    banner_image character varying(500),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    location_id uuid,
    CONSTRAINT chk_organizations_type CHECK (((type)::text = ANY ((ARRAY['COMPANY'::character varying, 'GROUP'::character varying, 'INSTITUTION'::character varying, 'NON_PROFIT'::character varying, 'OTHER'::character varying])::text[])))
);


ALTER TABLE public.organizations OWNER TO postgres;

--
-- Name: post_media; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_media (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    post_id uuid NOT NULL,
    type character varying(10) NOT NULL,
    storage_key character varying(500) NOT NULL,
    mime_type character varying(100) NOT NULL,
    file_size bigint NOT NULL,
    width integer,
    height integer,
    duration integer,
    "position" integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_post_media_file_size CHECK ((file_size > 0)),
    CONSTRAINT chk_post_media_position CHECK (("position" >= 0)),
    CONSTRAINT chk_post_media_type CHECK (((type)::text = ANY ((ARRAY['IMAGE'::character varying, 'VIDEO'::character varying])::text[])))
);


ALTER TABLE public.post_media OWNER TO postgres;

--
-- Name: post_mentions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_mentions (
    post_id uuid NOT NULL,
    user_id uuid NOT NULL,
    "position" integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.post_mentions OWNER TO postgres;

--
-- Name: post_reactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_reactions (
    post_id uuid NOT NULL,
    user_id uuid NOT NULL,
    type character varying(20) DEFAULT 'LIKE'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_post_reactions_type CHECK (((type)::text = ANY ((ARRAY['LIKE'::character varying, 'LOVE'::character varying, 'CELEBRATE'::character varying, 'SUPPORT'::character varying, 'FUNNY'::character varying, 'SAD'::character varying, 'ANGRY'::character varying])::text[])))
);


ALTER TABLE public.post_reactions OWNER TO postgres;

--
-- Name: post_tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_tags (
    post_id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.post_tags OWNER TO postgres;

--
-- Name: posts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.posts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    organization_id uuid,
    content text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    shared_post_id uuid,
    CONSTRAINT chk_posts_author CHECK ((((user_id IS NOT NULL) AND (organization_id IS NULL)) OR ((user_id IS NULL) AND (organization_id IS NOT NULL))))
);


ALTER TABLE public.posts OWNER TO postgres;

--
-- Name: profile_skills; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profile_skills (
    user_id uuid NOT NULL,
    skill_id uuid NOT NULL,
    level character varying(20),
    years_experience smallint,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT profile_skills_years_experience_check CHECK ((years_experience >= 0))
);


ALTER TABLE public.profile_skills OWNER TO postgres;

--
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profiles (
    user_id uuid NOT NULL,
    bio character varying(160),
    description text,
    profile_image character varying(500),
    banner_image character varying(500),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    name character varying(100) NOT NULL,
    location_id uuid
);


ALTER TABLE public.profiles OWNER TO postgres;

--
-- Name: skills; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.skills (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    slug character varying(100) NOT NULL,
    parent_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.skills OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255),
    phone_number character varying(20),
    password_hash character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    email_verified_at timestamp with time zone,
    phone_verified_at timestamp with time zone,
    CONSTRAINT chk_users_email_lower CHECK (((email)::text = lower((email)::text))),
    CONSTRAINT chk_users_has_identifier CHECK (((email IS NOT NULL) OR (phone_number IS NOT NULL))),
    CONSTRAINT chk_users_phone_e164 CHECK (((phone_number IS NULL) OR ((phone_number)::text ~ '^\+[1-9][0-9]{7,14}$'::text))),
    CONSTRAINT chk_users_verified_email CHECK (((email_verified_at IS NULL) OR (email IS NOT NULL))),
    CONSTRAINT chk_users_verified_phone CHECK (((phone_verified_at IS NULL) OR (phone_number IS NOT NULL)))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: verification_codes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.verification_codes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    channel character varying(10) NOT NULL,
    target character varying(255) NOT NULL,
    purpose character varying(30) NOT NULL,
    code_hash character varying(128) NOT NULL,
    attempts smallint DEFAULT 0 NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    consumed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT verification_codes_channel_check CHECK (((channel)::text = ANY ((ARRAY['EMAIL'::character varying, 'PHONE'::character varying])::text[]))),
    CONSTRAINT verification_codes_purpose_check CHECK (((purpose)::text = ANY ((ARRAY['VERIFY_CONTACT'::character varying, 'LOGIN'::character varying, 'PASSWORD_RESET'::character varying])::text[])))
);


ALTER TABLE public.verification_codes OWNER TO postgres;

--
-- Data for Name: comment_media; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comment_media (id, comment_id, type, storage_key, mime_type, file_size, width, height, duration, "position", created_at) FROM stdin;
\.


--
-- Data for Name: comment_reactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comment_reactions (comment_id, user_id, type, created_at) FROM stdin;
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comments (id, post_id, user_id, parent_id, content, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: course_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.course_details (opportunity_id, instructor_name, duration_hours, modality, capacity, level, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: event_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.event_details (opportunity_id, capacity, event_type, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: experiences; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.experiences (id, user_id, organization_id, "position", description, start_date, end_date, is_current, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: follows; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.follows (follower_id, following_id, created_at) FROM stdin;
\.


--
-- Data for Name: handles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.handles (username, user_id, organization_id, created_at) FROM stdin;
\.


--
-- Data for Name: job_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_details (opportunity_id, employment_type, workplace_type, salary_min, salary_max, salary_currency, experience_level, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.locations (id, label, address_line, city, state, country, latitude, longitude, google_place_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: opportunities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.opportunities (id, organization_id, title, type, description, start_date, end_date, application_deadline, created_at, updated_at, location_id) FROM stdin;
\.


--
-- Data for Name: opportunity_applications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.opportunity_applications (id, opportunity_id, user_id, status, message, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: opportunity_skills; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.opportunity_skills (opportunity_id, skill_id, is_required) FROM stdin;
\.


--
-- Data for Name: organization_follows; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organization_follows (follower_id, organization_id, created_at) FROM stdin;
\.


--
-- Data for Name: organization_members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organization_members (organization_id, user_id, role, created_at) FROM stdin;
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, type, description, website, profile_image, banner_image, created_at, updated_at, location_id) FROM stdin;
\.


--
-- Data for Name: post_media; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post_media (id, post_id, type, storage_key, mime_type, file_size, width, height, duration, "position", created_at) FROM stdin;
\.


--
-- Data for Name: post_mentions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post_mentions (post_id, user_id, "position", created_at) FROM stdin;
\.


--
-- Data for Name: post_reactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post_reactions (post_id, user_id, type, created_at) FROM stdin;
\.


--
-- Data for Name: post_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post_tags (post_id, user_id, created_at) FROM stdin;
\.


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.posts (id, user_id, organization_id, content, created_at, updated_at, shared_post_id) FROM stdin;
\.


--
-- Data for Name: profile_skills; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.profile_skills (user_id, skill_id, level, years_experience, created_at) FROM stdin;
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.profiles (user_id, bio, description, profile_image, banner_image, created_at, updated_at, name, location_id) FROM stdin;
\.


--
-- Data for Name: skills; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.skills (id, name, slug, parent_id, created_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, phone_number, password_hash, created_at, updated_at, email_verified_at, phone_verified_at) FROM stdin;
\.


--
-- Data for Name: verification_codes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.verification_codes (id, user_id, channel, target, purpose, code_hash, attempts, expires_at, consumed_at, created_at) FROM stdin;
\.


--
-- Name: comment_media comment_media_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comment_media
    ADD CONSTRAINT comment_media_pkey PRIMARY KEY (id);


--
-- Name: comment_reactions comment_reactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comment_reactions
    ADD CONSTRAINT comment_reactions_pkey PRIMARY KEY (comment_id, user_id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: course_details course_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_details
    ADD CONSTRAINT course_details_pkey PRIMARY KEY (opportunity_id);


--
-- Name: event_details event_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_details
    ADD CONSTRAINT event_details_pkey PRIMARY KEY (opportunity_id);


--
-- Name: experiences experiences_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experiences
    ADD CONSTRAINT experiences_pkey PRIMARY KEY (id);


--
-- Name: follows follows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT follows_pkey PRIMARY KEY (follower_id, following_id);


--
-- Name: handles handles_organization_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.handles
    ADD CONSTRAINT handles_organization_id_key UNIQUE (organization_id);


--
-- Name: handles handles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.handles
    ADD CONSTRAINT handles_pkey PRIMARY KEY (username);


--
-- Name: handles handles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.handles
    ADD CONSTRAINT handles_user_id_key UNIQUE (user_id);


--
-- Name: job_details job_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_details
    ADD CONSTRAINT job_details_pkey PRIMARY KEY (opportunity_id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: opportunities opportunities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opportunities
    ADD CONSTRAINT opportunities_pkey PRIMARY KEY (id);


--
-- Name: opportunity_applications opportunity_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opportunity_applications
    ADD CONSTRAINT opportunity_applications_pkey PRIMARY KEY (id);


--
-- Name: opportunity_skills opportunity_skills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opportunity_skills
    ADD CONSTRAINT opportunity_skills_pkey PRIMARY KEY (opportunity_id, skill_id);


--
-- Name: organization_follows organization_follows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_follows
    ADD CONSTRAINT organization_follows_pkey PRIMARY KEY (follower_id, organization_id);


--
-- Name: organization_members organization_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_members
    ADD CONSTRAINT organization_members_pkey PRIMARY KEY (organization_id, user_id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: post_media post_media_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_media
    ADD CONSTRAINT post_media_pkey PRIMARY KEY (id);


--
-- Name: post_mentions post_mentions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_mentions
    ADD CONSTRAINT post_mentions_pkey PRIMARY KEY (post_id, user_id);


--
-- Name: post_reactions post_reactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_reactions
    ADD CONSTRAINT post_reactions_pkey PRIMARY KEY (post_id, user_id);


--
-- Name: post_tags post_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_tags
    ADD CONSTRAINT post_tags_pkey PRIMARY KEY (post_id, user_id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: profile_skills profile_skills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_skills
    ADD CONSTRAINT profile_skills_pkey PRIMARY KEY (user_id, skill_id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (user_id);


--
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- Name: skills skills_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_slug_key UNIQUE (slug);


--
-- Name: opportunity_applications uq_opportunity_application; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opportunity_applications
    ADD CONSTRAINT uq_opportunity_application UNIQUE (opportunity_id, user_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_number_key UNIQUE (phone_number);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: verification_codes verification_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.verification_codes
    ADD CONSTRAINT verification_codes_pkey PRIMARY KEY (id);


--
-- Name: comment_media_comment_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX comment_media_comment_id_idx ON public.comment_media USING btree (comment_id);


--
-- Name: comment_reactions_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX comment_reactions_user_id ON public.comment_reactions USING btree (user_id);


--
-- Name: comments_parent_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX comments_parent_id_idx ON public.comments USING btree (parent_id);


--
-- Name: comments_post_id_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX comments_post_id_created_at_idx ON public.comments USING btree (post_id, created_at DESC);


--
-- Name: comments_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX comments_user_id ON public.comments USING btree (user_id);


--
-- Name: experiences_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX experiences_user_id_idx ON public.experiences USING btree (user_id);


--
-- Name: follows_following_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX follows_following_id_idx ON public.follows USING btree (following_id);


--
-- Name: locations_country_state_city_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX locations_country_state_city_idx ON public.locations USING btree (country, state, city);


--
-- Name: opportunities_organization_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX opportunities_organization_id_idx ON public.opportunities USING btree (organization_id);


--
-- Name: opportunities_type_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX opportunities_type_created_at_idx ON public.opportunities USING btree (type, created_at DESC);


--
-- Name: opportunity_applications_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX opportunity_applications_user_id_idx ON public.opportunity_applications USING btree (user_id);


--
-- Name: opportunity_skills_skill_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX opportunity_skills_skill_id_idx ON public.opportunity_skills USING btree (skill_id);


--
-- Name: organization_follows_organization_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX organization_follows_organization_id_idx ON public.organization_follows USING btree (organization_id);


--
-- Name: organization_members_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX organization_members_user_id_idx ON public.organization_members USING btree (user_id);


--
-- Name: post_media_post_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX post_media_post_id_idx ON public.post_media USING btree (post_id);


--
-- Name: post_mentions_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX post_mentions_user_id_idx ON public.post_mentions USING btree (user_id);


--
-- Name: post_reactions_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX post_reactions_user_id_idx ON public.post_reactions USING btree (user_id);


--
-- Name: post_tags_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX post_tags_user_id_idx ON public.post_tags USING btree (user_id);


--
-- Name: posts_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX posts_created_at_idx ON public.posts USING btree (created_at DESC);


--
-- Name: posts_organization_id_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX posts_organization_id_created_at_idx ON public.posts USING btree (organization_id, created_at DESC);


--
-- Name: posts_shared_post_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX posts_shared_post_id_idx ON public.posts USING btree (shared_post_id);


--
-- Name: posts_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX posts_user_id_created_at_idx ON public.posts USING btree (user_id, created_at DESC);


--
-- Name: profile_skills_skill_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX profile_skills_skill_id_idx ON public.profile_skills USING btree (skill_id);


--
-- Name: uq_org_single_owner; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_org_single_owner ON public.organization_members USING btree (organization_id) WHERE ((role)::text = 'OWNER'::text);


--
-- Name: verification_codes_user_id_purpose_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX verification_codes_user_id_purpose_created_at_idx ON public.verification_codes USING btree (user_id, purpose, created_at DESC);


--
-- Name: comment_media fk_comment_media_comment; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comment_media
    ADD CONSTRAINT fk_comment_media_comment FOREIGN KEY (comment_id) REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- Name: comment_reactions fk_comment_reactions_comment; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comment_reactions
    ADD CONSTRAINT fk_comment_reactions_comment FOREIGN KEY (comment_id) REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- Name: comment_reactions fk_comment_reactions_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comment_reactions
    ADD CONSTRAINT fk_comment_reactions_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: comments fk_comments_parent; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT fk_comments_parent FOREIGN KEY (parent_id) REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- Name: comments fk_comments_post; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT fk_comments_post FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: comments fk_comments_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT fk_comments_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: course_details fk_course_details_opportunity; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_details
    ADD CONSTRAINT fk_course_details_opportunity FOREIGN KEY (opportunity_id) REFERENCES public.opportunities(id) ON DELETE CASCADE;


--
-- Name: event_details fk_event_details_opportunity; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_details
    ADD CONSTRAINT fk_event_details_opportunity FOREIGN KEY (opportunity_id) REFERENCES public.opportunities(id) ON DELETE CASCADE;


--
-- Name: experiences fk_experiences_organization; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experiences
    ADD CONSTRAINT fk_experiences_organization FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE SET NULL;


--
-- Name: experiences fk_experiences_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experiences
    ADD CONSTRAINT fk_experiences_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: follows fk_follows_follower; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT fk_follows_follower FOREIGN KEY (follower_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: follows fk_follows_following; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT fk_follows_following FOREIGN KEY (following_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: job_details fk_job_details_opportunity; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_details
    ADD CONSTRAINT fk_job_details_opportunity FOREIGN KEY (opportunity_id) REFERENCES public.opportunities(id) ON DELETE CASCADE;


--
-- Name: opportunities fk_opportunities_location; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opportunities
    ADD CONSTRAINT fk_opportunities_location FOREIGN KEY (location_id) REFERENCES public.locations(id) ON DELETE SET NULL;


--
-- Name: opportunities fk_opportunities_organization; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opportunities
    ADD CONSTRAINT fk_opportunities_organization FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: opportunity_applications fk_opportunity_applications_opportunity; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opportunity_applications
    ADD CONSTRAINT fk_opportunity_applications_opportunity FOREIGN KEY (opportunity_id) REFERENCES public.opportunities(id) ON DELETE CASCADE;


--
-- Name: opportunity_applications fk_opportunity_applications_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opportunity_applications
    ADD CONSTRAINT fk_opportunity_applications_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: organization_members fk_organization_members_organization; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_members
    ADD CONSTRAINT fk_organization_members_organization FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: organization_members fk_organization_members_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_members
    ADD CONSTRAINT fk_organization_members_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: organizations fk_organizations_location; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT fk_organizations_location FOREIGN KEY (location_id) REFERENCES public.locations(id) ON DELETE SET NULL;


--
-- Name: post_media fk_post_media_post; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_media
    ADD CONSTRAINT fk_post_media_post FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: post_mentions fk_post_mentions_post; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_mentions
    ADD CONSTRAINT fk_post_mentions_post FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: post_mentions fk_post_mentions_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_mentions
    ADD CONSTRAINT fk_post_mentions_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: post_reactions fk_post_reactions_post; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_reactions
    ADD CONSTRAINT fk_post_reactions_post FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: post_reactions fk_post_reactions_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_reactions
    ADD CONSTRAINT fk_post_reactions_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: post_tags fk_post_tags_post; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_tags
    ADD CONSTRAINT fk_post_tags_post FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: post_tags fk_post_tags_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_tags
    ADD CONSTRAINT fk_post_tags_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: posts fk_posts_organization; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT fk_posts_organization FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: posts fk_posts_shared_post; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT fk_posts_shared_post FOREIGN KEY (shared_post_id) REFERENCES public.posts(id) ON DELETE SET NULL;


--
-- Name: posts fk_posts_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT fk_posts_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: profiles fk_profile_location; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT fk_profile_location FOREIGN KEY (location_id) REFERENCES public.locations(id) ON DELETE SET NULL;


--
-- Name: profiles fk_profiles_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT fk_profiles_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: handles handles_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.handles
    ADD CONSTRAINT handles_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: handles handles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.handles
    ADD CONSTRAINT handles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: opportunity_skills opportunity_skills_opportunity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opportunity_skills
    ADD CONSTRAINT opportunity_skills_opportunity_id_fkey FOREIGN KEY (opportunity_id) REFERENCES public.opportunities(id) ON DELETE CASCADE;


--
-- Name: opportunity_skills opportunity_skills_skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opportunity_skills
    ADD CONSTRAINT opportunity_skills_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES public.skills(id) ON DELETE CASCADE;


--
-- Name: organization_follows organization_follows_follower_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_follows
    ADD CONSTRAINT organization_follows_follower_id_fkey FOREIGN KEY (follower_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: organization_follows organization_follows_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_follows
    ADD CONSTRAINT organization_follows_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: profile_skills profile_skills_skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_skills
    ADD CONSTRAINT profile_skills_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES public.skills(id) ON DELETE CASCADE;


--
-- Name: profile_skills profile_skills_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_skills
    ADD CONSTRAINT profile_skills_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: skills skills_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.skills(id) ON DELETE SET NULL;


--
-- Name: verification_codes verification_codes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.verification_codes
    ADD CONSTRAINT verification_codes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict TIANzMd5hSJe2fkAdTZzbaTrJPMA6oq28miYm3hKChLJdcvo1jbciykrkyxazLg

