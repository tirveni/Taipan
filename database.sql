--
-- Database for taipan 
-- --
-- 
-- Version 0.2
-- Tirveni Yadav <tirveni@udyansh.org>
-- use database taipan;
--
-- 0.2: Address,City,State,Country,TimeZone
-- 2017-11-11
--

\c taipan 
\echo *** DROP Tables

\echo *** Drop Address country,state,city,timezone....
DROP TABLE IF EXISTS CURRENCY;
DROP TABLE IF EXISTS ADDRESS;
DROP TABLE IF EXISTS Zone;
DROP TABLE IF EXISTS TimeZone;
DROP TABLE IF EXISTS CITY;
DROP TABLE IF EXISTS CityLang;
DROP TABLE IF EXISTS StateLang;
DROP TABLE IF EXISTS State;
DROP TABLE IF EXISTS Country_More;
DROP TABLE IF EXISTS CountryLang;
DROP TABLE IF EXISTS Country;

\echo *** Drop Notices....
DROP TABLE IF EXISTS UserNotified	CASCADE;
DROP TABLE IF EXISTS Notification	CASCADE;
DROP TABLE IF EXISTS NotifyType		CASCADE;

\echo *** Drop Static Pages....
DROP TABLE IF EXISTS TagsOfPage		CASCADE;
DROP TABLE IF EXISTS TagType		CASCADE;
DROP TABLE IF EXISTS PageStaticLang	CASCADE;
DROP TABLE IF EXISTS PageStatic		CASCADE;

\echo *** Drop Languages and Messages....
DROP TABLE IF EXISTS LanguageType	CASCADE;	
DROP TABLE IF EXISTS Message		CASCADE;	
DROP TABLE IF EXISTS MessageLang	CASCADE;	

\echo *** Drop PODs....
DROP TABLE IF EXISTS Ipx_pod_host	CASCADE;	
DROP TABLE IF EXISTS Ipx_pod		CASCADE;	

\echo *** Drop TypeValues and AppUser....
DROP TABLE IF EXISTS TypeValues		CASCADE;

DROP TABLE IF EXISTS AppUserKey		CASCADE;
DROP TABLE IF EXISTS AppUser		CASCADE;

\echo *** Drop Roles,Privileges,Access....
DROP TABLE IF EXISTS Roles		CASCADE;
DROP TABLE IF EXISTS PrivilegeCategory	CASCADE;
DROP TABLE IF EXISTS Privilege		CASCADE;
DROP TABLE IF EXISTS Access		CASCADE;

\echo *** Drop Logs....
DROP TABLE IF EXISTS LogException	CASCADE;
DROP TABLE IF EXISTS LoginAttempts    	CASCADE;

------------------------------------------------
\echo	*** CREATE Tables

--
-- Roles and Permissions
-- UNKN, GUEST,Business
CREATE TABLE Roles
(
        role            CHAR(8),
	level		smallint,
        description     text,
	PRIMARY KEY(role)
);

-- UNKN, Guest, Business
CREATE TABLE PrivilegeCategory
(
	category	CHAR(10)PRIMARY KEY,
	description	text
);

CREATE TABLE Privilege
(
        privilege       text    PRIMARY KEY,
	-- URL(Privilege) is unique, hence privilege is PRIMARY KEY
	category	CHAR(10) REFERENCES
		PrivilegeCategory  ON UPDATE CASCADE,
	description     text,

	--MENU/API/BIZAPP
	type		char(16),
	--appid 
	appid		char(16)
);

-- This tells you whether a user has access to a URL(Privilege) of an App(BizApp).
CREATE TABLE Access
(
        privilege       text REFERENCES 
		Privilege   ON UPDATE CASCADE,
        role            CHAR(8),
        PRIMARY KEY (role,privilege)
);

--
-- User role can be UNKN, guest,business
--
CREATE TABLE AppUser
(
        userid          text    PRIMARY KEY,
        name            text,
        details         text,
        password        text,
	date_joined	timestamp with time zone default (now() at time zone 'utc'),
        active          boolean,
        role            CHAR(8) REFERENCES
		Roles ON UPDATE CASCADE,
	dob		date,
	sex		char(1),
	email		text,
	verification_code	text	,
	podid		char(12),
	-- Loose Reference to POD currently

	phone		char(24),

        created_at      timestamp 
                with time zone default (now() at time zone 'utc')   
);

CREATE TABLE AppUserKey
(
        userid          text REFERENCES 
		AppUser  ON UPDATE CASCADE,
	key_guava	text NOT NULL, -- key1
	key_jamun	text NOT NULL, -- key2
		UNIQUE(key_guava,key_jamun),

	valid_from	timestamp with time zone default (now() at time zone 'utc'),
	valid_till	timestamp with time zone NOT NULL,
		CONSTRAINT valid_till_gt_valid_till CHECK (valid_till >= valid_from),

	valid		boolean,
	ip		text,
	type		CHAR(10) DEFAULT 'API',
	-- API,TOKEN,RESOURCE

	method		text,
	method_type	char(24),

	expiry		timestamp with time zone,

        created_at      timestamp 
                with time zone default (now() at time zone 'utc')   ,
        update_userid          text REFERENCES 
		AppUser  ON UPDATE CASCADE,

	primary key(userid,valid_from,valid_till)
);

COMMENT ON COLUMN appuserkey.key_guava is 'Used as key_guava or id/consumer_key/client_id';
COMMENT ON COLUMN appuserkey.key_jamun is 'Used as key_jamun or key/consumer_secret/client_secret';
COMMENT ON COLUMN appuserkey.type is 'API: API access. TOKEN: Token access. Resource: temporary method access(exact method column is matched).';

-- https://www.digitalocean.com/community/tutorials/an-introduction-to-oauth-2
-- http://search.cpan.org/~jjnapiork/CatalystX-OAuth2-0.001004/lib/CatalystX/OAuth2.pm



-- Type Values for Various entities's statues in future.
-- 
CREATE TABLE TypeValues
(
	dtable		char(24),
	tableuniq	char(24),
	cfield		char(24),
	cvalue		char(72),

	ctype		text,
	description	text,

	valid		boolean,
	internal	boolean,


	field2		text,
	value2		text,
	field3		text,
	value3		text,
	field4		text,
	value4		text,
	field5		text,
	value5		text,
	field6		text,
	value6		text,

	priority	smallint,
        created_at      timestamp 
                with time zone default (now() at time zone 'utc')   ,
        update_userid          text REFERENCES 
		AppUser  ON UPDATE CASCADE,

	PRIMARY KEY(dtable,tableuniq,cfield)

);

-- Messages
CREATE TABLE Message
(
	msgid		int PRIMARY KEY,
	type		char(20),
	--ERROR, COMMENT

	name		text,
	message		text,
        created_at      timestamp 
                with time zone default (now() at time zone 'utc')   

);

CREATE TABLE MessageLang
(
	msgid		int PRIMARY KEY,
	languagetype	char(4),
	message		text,
        created_at      timestamp 
                with time zone default (now() at time zone 'utc')  
);


--Stores Login Attempts, Succes/Failure
CREATE TABLE LoginAttempts
(
	ip_address	text,
	userid		text REFERENCES 
		AppUser  ON UPDATE CASCADE,
	date		timestamp(0) with time zone,
	tried_userid	text,
	login_success	boolean, 
	comments	text,
--  of Boolean, More than 1 in a time period. Boolean
        created_at      timestamp 
                with time zone default (now() at time zone 'utc')   ,
	user_agent	text,
	url		text,
	field1		text,
	value1		text,
	field2		text,
	value2		text,

	PRIMARY KEY(ip_address,created_at)

);

-- Stores Exceptional events
CREATE TABLE LogException
(
	exceptionid	SERIAL PRIMARY KEY,
	userid		text REFERENCES 
		AppUser  ON UPDATE CASCADE,
	type		text,
	reason		text,

	
        created_at      timestamp 
                with time zone default (now() at time zone 'utc')   ,
	field1		text,
	value1		text,
	field2		text,
	value2		text,
	field3		text,
	value3		text,
	field4		text,
	value4		text,
	field5		text,
	value5		text,
	field6		text,
	value6		text,
	field7		text,
	value7		text,
	field8		text,
	value8		text,
	field9		text,
	value9		text,

	entity		text
	--table_name

);






-- Inter Pod Exchange
CREATE TABLE Ipx_Pod
(
	podid			char(12) PRIMARY KEY,
	active			boolean,
	name			text
	--Alias

);

CREATE TABLE Ipx_pod_host
(
	podid			char(12),
	ip			inet,
	internal_ip		inet,
	priority		smallint,
	hostname		text,
	active			boolean,	

	PRIMARY KEY(podid,ip)

);

-- 

CREATE TABLE LanguageType
(
        code            CHAR(4) PRIMARY KEY,
        description     text,
        path_of_icon    text,
        path_of_picture text,
        created_at      timestamp 
                with time zone default (now() at time zone 'utc')   ,
        update_userid          text REFERENCES 
		AppUser  ON UPDATE CASCADE
);

CREATE TABLE PageStatic
(
        pageid          char(20) PRIMARY KEY,
        pagename        char(24),
        content         text,
        created_at      timestamp 
                with time zone default (now() at time zone 'utc')   ,
        update_userid          text REFERENCES 
		AppUser  ON UPDATE CASCADE
);

CREATE TABLE PageStaticLang
(
        pageid          char(20) references 
                PageStatic  ON DELETE CASCADE ON UPDATE CASCADE,
        languagetype    CHAR(4) references
                LanguageType ON DELETE CASCADE ON UPDATE CASCADE,
        content         text,
        created_at      timestamp 
                with time zone default (now() at time zone 'utc')   ,
        update_userid          text REFERENCES 
		AppUser  ON UPDATE CASCADE,
        PRIMARY KEY(pageid,languagetype)                                
);

-- Tag

CREATE TABLE TagType
(
        TagType         CHAR(24) PRIMARY KEY,
        description     text,
        created_at      timestamp 
                with time zone default (now() at time zone 'utc')   ,
        update_userid          text REFERENCES 
		AppUser  ON UPDATE CASCADE
);

CREATE TABLE TagsOfPage
(
        TagType         CHAR(24) NOT NULL references
                TagType ON DELETE CASCADE ON UPDATE CASCADE,
        pageid          char(20) NOT NULL references 
                PageStatic  ON DELETE CASCADE ON UPDATE CASCADE,
        priority        smallint,

        details         text,
        created_at      timestamp 
                with time zone default (now() at time zone 'utc')   ,
        update_userid          text REFERENCES 
		AppUser  ON UPDATE CASCADE,
        
        PRIMARY KEY(TagType,PageID,Priority)
);


CREATE TABLE NotifyType
(
	notifyType	char(24) PRIMARY KEY,
	description	text
);


CREATE TABLE Notification
(
	notifyid	BIGSERIAL PRIMARY KEY,

	type		CHAR(24) REFERENCES
		notifyType	ON UPDATE CASCADE,
		

	message		text,
	active		boolean,

	role		CHAR(8)  default 'ALL',

	user_confirmation	boolean,

	email_required		boolean,
	mobile_required		boolean,

        active_from     timestamp with time zone, -- UTC
        active_till     timestamp with time zone, -- UTC
	priority		smallint,

        created_at      timestamp 
                with time zone default (now() at time zone 'utc')   ,
        update_userid          text REFERENCES 
		AppUser  ON UPDATE CASCADE
	

);

CREATE TABLE UserNotified
(
	notifyid		BigInt	References
		Notification	ON Update CASCADe,
	
	
        userid          text REFERENCES 
		AppUser  ON UPDATE CASCADE,

	tried			smallint,
	user_confirmation	boolean,

        created_at      timestamp 
                with time zone default (now() at time zone 'utc')   ,
        update_userid          text REFERENCES 
		AppUser  ON UPDATE CASCADE,

	PRIMARY KEY(notifyid,userid)

);



CREATE TABLE Country
(
        CountryCode             char(3) PRIMARY KEY ,
        CountryName             text,
        verified                boolean default 't'
) ;


CREATE TABLE CountryLang
(
        CountryCode             char(3) REFERENCES
                Country  ON UPDATE CASCADE,
        CountryName             text,
        LanguageType    char(4) REFERENCES 
                LanguageType  ON UPDATE CASCADE,

        PRIMARY KEY(CountryCode,LanguageType)
);

-- CountrMore
CREATE TABLE country_more 
(
    countrycode         character(2) PRIMARY KEY,
    currencycode        character(3),
    continent           character(2),
    iso3                character(3),
    isd                 text,
    capital             text
);



CREATE TABLE State
(
        State_Country           char(3) REFERENCES 
                Country  ON UPDATE CASCADE,
        StateCode               char(3),
        StateName               text,

        verified                boolean default 't',
        userid                  text,
        created_at              timestamp with time zone 
                default (now() at time zone 'utc'),

        PRIMARY KEY( State_Country, StateCode )
) ;

CREATE TABLE StateLang
(
        State_Country           char(3) REFERENCES 
                Country  ON UPDATE CASCADE,
        StateCode               char(3),
        StateName               text,
        LanguageType    char(4) REFERENCES 
                LanguageType  ON UPDATE CASCADE,
        FOREIGN KEY( state_country,statecode) REFERENCES
                State  ON UPDATE CASCADE,
        PRIMARY KEY( State_Country, StateCode, LanguageType )
        
);


CREATE TABLE City
(
        City_Country            char(3),
        City_State              char(3),
        CityCode                char(20),
        CityName                text,
        Latitude                text,
        Longitude               text,

        verified                boolean default 't',
        userid                  text,
        created_at              timestamp with time zone 
                default (now() at time zone 'utc'),

        FOREIGN KEY( City_country,City_state) REFERENCES
                State  ON UPDATE CASCADE,
        PRIMARY KEY( City_Country, City_State, CityCode )
);

--Description of a City/Town in a specified Language
CREATE TABLE CityLang
(
        City_Country            char(3),
        City_State              char(3), 
        CityCode                char(20), 
        LanguageType    char(4) REFERENCES 
                LanguageType  ON UPDATE CASCADE,
        CityName                text,
        FOREIGN KEY( City_country,City_state,CityCode) REFERENCES
                City  ON UPDATE CASCADE,
        PRIMARY KEY( City_Country, City_State, CityCode,LanguageType )
                
);


-- View V_city
CREATE VIEW v_city AS select a.citycode,a.cityname,
        a.city_country,a.city_state,s.statename,
        c.countryname 
        FROM city a,state s,country c 
        WHERE a.city_country=s.state_country 
                AND a.city_state=s.statecode 
                AND s.state_country=c.countrycode ;


CREATE TABLE timezone 
(
        zone_id         int not null,
        abbreviation    text   NOT NULL,
        time_start      int NOT NULL,
        gmt_offset      int NOT NULL,
        dst             CHAR(1) NOT NULL
);
CREATE INDEX i_timezone_zone_id ON timezone(zone_id);
CREATE INDEX i_timezone_time_start ON timezone(time_start);

CREATE TABLE zone
(
        zone_id         int NOT NULL ,
        CountryCode             char(3) REFERENCES
                Country  ON UPDATE CASCADE,
        zone_name VARCHAR(35) PRIMARY KEY 
);
CREATE UNIQUE INDEX i_zone_zone_id ON zone(zone_id);



CREATE TABLE Address
(
        AddressID               serial primary key ,
        StreetAddress1          text,
        StreetAddress2          text,
        StreetAddress3          text,
        address_city            char(20),
        address_state           char(3),
        address_country         char(3),
        Address_Area            char(8),
        Address_Locality        char(8),
        AddressVerified         char(1),
        Directions              text,
        priority                int,
        pincode                 text,
        created_at      timestamp 
                with time zone default (now() at time zone 'utc'),   
        foreign key( address_Country, address_State, address_City ) 
                references City  ON UPDATE CASCADE
) ;

CREATE TABLE Currency
(
        CurrencyCode            char(3) PRIMARY KEY,
        CurrencyName            text,
        Symbol                  char(30),
        RoundingFactor          smallint,
        Country                 char(2) REFERENCES Country

);

