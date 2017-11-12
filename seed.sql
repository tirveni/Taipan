


-- Inserts

----------------------
\echo *** Error and Messages ***
\copy message (msgid,type,name,message)  from 'SQL/errors.csv' delimiter '|'  ;

\echo *** Add Countries *** 
\i SQL/country.sql

\echo *** TimeZone ***
\i SQL/timezone.sql

\echo *** States ***
\copy state(state_country,statecode,statename)  from 'SQL/states.csv' delimiter '|'  ;

\echo *** Cities ****
\copy city(city_country,city_state,citycode,cityname)  from 'SQL/cities.csv' delimiter '|'  ;

\echo *** Currencies  ****
\copy currency(currencycode,currencyname,symbol)  from 'SQL/currency.csv' delimiter '|'  ;
----------------------

\echo roles
INSERT into Roles VALUES ('SU',        	1,   'Administrator');
INSERT into Roles VALUES ('MANAGER',   	10,  'Manager');
INSERT into Roles VALUES ('STAFF',     	20,  'Staff');
INSERT INTO Roles VALUES ('GUEST' ,     51,  'Client');
INSERT INTO Roles VALUES ('UNKN' ,      101, 'Not Logged In');
INSERT INTO Roles VALUES ('DISABLED' ,  1001,'DISABLED');


-- User
INSERT INTO APPUSER VALUES( 'UNKN','Unknown','DETAILS UNKNOWN','PWD','2014-11-01','1','UNKN');
INSERT INTO APPUSER VALUES( 'admin@abc.com','Viper','Handles Administration', 'g3BkGZVnIIlVJnhUVyB0MOZRKhs','2013-01-01','1','SU');


INSERT into PrivilegeCategory VALUES('GUEST','Privileges for GUEST');
INSERT into PrivilegeCategory VALUES('UNKN','Privileges for UNKN');
INSERT into PrivilegeCategory VALUES('SU','Privileges for SU');
INSERT into PrivilegeCategory VALUES('Staff','Privileges for Staff');


\echo *** Privileges *** 
INSERT INTO Privilege VALUES ('index',          'UNKN', 'Base Page');
INSERT INTO Privilege VALUES ('home',           'GUEST', 'Home Page');
INSERT INTO Privilege VALUES ('leaf/index',           'GUEST', 'Static Page');
INSERT INTO Privilege VALUES ('user/index',     'GUEST', 'User Edit');
INSERT INTO Privilege VALUES ('user/edit',      'GUEST', 'User Edit');
INSERT INTO Privilege VALUES ('user/apikey',    'GUEST', 'User API Key');
INSERT INTO Privilege VALUES ('user/address',   'GUEST', 'User Edit Key');
INSERT INTO Privilege VALUES ('staff/index',    'SU', 'User Edit');
INSERT INTO Privilege VALUES ('staff/list',    	'SU', 'User add');
INSERT INTO Privilege VALUES ('staff/add',    	'SU', 'User add');
INSERT INTO Privilege VALUES ('config/index',   'SU', 'Config Edit');
INSERT INTO Privilege VALUES ('config/list',   	'SU', 'Config List');
INSERT INTO Privilege VALUES ('privileges/list',	  	'SU', 'List permissions');
INSERT INTO Privilege VALUES ('privileges/rolelist',	  	'SU', 'List Roles');
INSERT INTO Privilege VALUES ('privileges/accesslist',  	'SU', 'Available Permissions for a role');
INSERT INTO Privilege VALUES ('privileges/allowed',	  	'SU', 'Allowed Permissions for a role');
INSERT INTO Privilege VALUES ('privileges/info',	  	'SU', 'Edit Permission');

-- Login/Logout/Default
INSERT INTO Privilege VALUES ('login/index',    'UNKN', 'Login Page');
INSERT INTO Privilege VALUES ('g/user/login',   'UNKN', 'Login Page REST');
INSERT INTO Privilege VALUES ('logout/index',   'GUEST', 'Logout for All users other than UNKN');
INSERT into privilege VALUES ('default','UNKN','Default');

\echo *** Add Default Page *** 
INSERT into access VALUES ('default',		'UNKN');
INSERT into access VALUES ('default',		'GUEST');
INSERT into access VALUES ('default',		'STAFF');
INSERT into access VALUES ('default',		'MANAGER');
INSERT into access VALUES ('default',		'SU');

\echo ** Access Logout For Everyone.
insert into access values ('logout/index','SU');
insert into access values ('logout/index','GUEST');
insert into access values ('logout/index','MANAGER');
insert into access values ('logout/index','DISABLED');

-- Access
INSERT INTO Access VALUES ('',                  'UNKN');
INSERT INTO Access VALUES ('index',             'UNKN');
INSERT INTO Access VALUES ('login/index',       'UNKN');
INSERT INTO Access VALUES ('g/user/login',       'UNKN');
--index and home
INSERT INTO Access VALUES ('index',             'SU');
INSERT INTO Access VALUES ('index',             'MANAGER');
INSERT INTO Access VALUES ('index',             'STAFF');
INSERT INTO Access VALUES ('index',             'GUEST');
INSERT INTO Access VALUES ('home',              'SU');
INSERT INTO Access VALUES ('home',              'MANAGER');
INSERT INTO Access VALUES ('home',              'STAFF');
INSERT INTO Access VALUES ('home',              'GUEST');
INSERT INTO Access VALUES ('leaf/index',              'SU');
INSERT INTO Access VALUES ('leaf/index',              'MANAGER');
INSERT INTO Access VALUES ('leaf/index',              'STAFF');
INSERT INTO Access VALUES ('leaf/index',              'GUEST');
INSERT INTO Access VALUES ('leaf/index',              'UNKN');
-- Self Editing
INSERT INTO Access VALUES ('user/index',        'SU');
INSERT INTO Access VALUES ('user/index',        'GUEST');
INSERT INTO Access VALUES ('user/index',        'MANAGER');
INSERT INTO Access VALUES ('user/index',        'STAFF');
INSERT INTO Access VALUES ('user/edit',         'SU');
INSERT INTO Access VALUES ('user/edit',         'MANAGER');
INSERT INTO Access VALUES ('user/edit',         'STAFF');
INSERT INTO Access VALUES ('user/edit',         'GUEST');
INSERT INTO Access VALUES ('user/apikey',       'SU');
INSERT INTO Access VALUES ('user/apikey',       'MANAGER');
INSERT INTO Access VALUES ('user/apikey',       'STAFF');
INSERT INTO Access VALUES ('user/apikey',       'GUEST');
INSERT INTO Access VALUES ('user/address',      'SU');
INSERT INTO Access VALUES ('user/address',      'MANAGER');
INSERT INTO Access VALUES ('user/address',      'STAFF');
INSERT INTO Access VALUES ('user/address',      'GUEST');

-- Staff Add/Edit
INSERT INTO Access VALUES ('staff/index',      	'MANAGER');
INSERT INTO Access VALUES ('staff/add',         'MANAGER');
INSERT INTO Access VALUES ('staff/list',        'MANAGER');

-- Staff Add/Edit
INSERT INTO Access VALUES ('staff/index',      	'SU');
INSERT INTO Access VALUES ('staff/add',         'SU');
INSERT INTO Access VALUES ('staff/list',        'SU');

INSERT INTO Access VALUES ('privileges/list',      	'SU');
INSERT INTO Access VALUES ('privileges/rolelist',      	'SU');
INSERT INTO Access VALUES ('privileges/accesslist',    	'SU');
INSERT INTO Access VALUES ('privileges/allowed',      	'SU');
INSERT INTO Access VALUES ('privileges/info',      	'SU');


INSERT INTO Access VALUES ('config/index',     	'SU');
INSERT INTO Access VALUES ('config/list',       'SU');


-- TypeValues(config):Redis Cache Keys
INSERT INTO typevalues (dtable,tableuniq,cfield,cvalue,description,valid,internal,ctype)
        values ('redkey','apikey','expiry','60','API Key Cache Expires in seconds','t','t','int');
INSERT INTO typevalues (dtable,tableuniq,cfield,cvalue,description,valid,internal,ctype)
        values ('redkey','apikey','max_expiry','600','API Key Cache Expires in Max seconds','t','t','int');
INSERT INTO typevalues (dtable,tableuniq,cfield,cvalue,description,valid,internal,ctype)
        values ('redkey','user','expiry','600','User Object Expires in seconds','t','t','int');
INSERT INTO typevalues (dtable,tableuniq,cfield,cvalue,description,valid,internal,ctype)
        values ('redkey','user','max_expiry','3600','User Object Cache Expires in Max seconds','t','t','int');


INSERT INTO NotifyType values ('MAINTENANCE','Maintenance Notification');
INSERT INTO NotifyType values ('MISC','Miscellaneous Notication');




