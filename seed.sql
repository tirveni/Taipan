


-- Inserts

\echo *** Error and Messages ***
\copy message (msgid,type,name,message)  from 'SQL/errors.csv' delimiter '|'  ;

\echo roles
INSERT into Roles VALUES ('SU',         1,  'Super User');
INSERT INTO Roles VALUES ('GUEST' ,     51, 'Client of Tenant');
INSERT INTO Roles VALUES ('UNKN' ,      101, 'Not Logged In');


-- User
INSERT INTO APPUSER VALUES( 'UNKN','Unknown','DETAILS UNKNOWN','PWD','2014-11-01','1','UNKN');
INSERT INTO APPUSER VALUES( 'admin@abc.com','Viper','Handles Administration', 'E5Heps6EgklcViMsGX7wEu1K9Kc','2013-01-01','1','SU');


INSERT into PrivilegeCategory VALUES('GUEST','Privileges for GUEST');
INSERT into PrivilegeCategory VALUES('UNKN','Privileges for UNKN');
INSERT into PrivilegeCategory VALUES('SU','Privileges for SU');


\echo *** Privileges *** 
INSERT INTO Privilege VALUES ('index',          'UNKN', 'Base Page');
INSERT INTO Privilege VALUES ('home',           'GUEST', 'Home Page');
INSERT INTO Privilege VALUES ('user/index',     'GUEST', 'User Edit');
INSERT INTO Privilege VALUES ('user/edit',      'GUEST', 'User Edit');
INSERT INTO Privilege VALUES ('user/apikey',    'GUEST', 'User API Key');
INSERT INTO Privilege VALUES ('user/address',   'GUEST', 'User Edit Key');
INSERT INTO Privilege VALUES ('login/index',    'UNKN', 'Login Page');
INSERT INTO Privilege VALUES ('logout/index',   'GUEST', 'Logout for All users other than UNKN');

\echo ** Access Logout For Everyone.
insert into access values ('logout/index','SU');
insert into access values ('logout/index','GUEST');

-- Access
INSERT INTO Access VALUES ('',                  'UNKN');
INSERT INTO Access VALUES ('index',             'UNKN');
INSERT INTO Access VALUES ('login/index',       'UNKN');
INSERT INTO Access VALUES ('index',                     'SU');
INSERT INTO Access VALUES ('index',                     'GUEST');
INSERT INTO Access VALUES ('home',              'SU');
INSERT INTO Access VALUES ('home',              'GUEST');
INSERT INTO Access VALUES ('user/index',              'SU');
INSERT INTO Access VALUES ('user/index',              'GUEST');
INSERT INTO Access VALUES ('user/edit',              'SU');
INSERT INTO Access VALUES ('user/edit',              'GUEST');
INSERT INTO Access VALUES ('user/apikey',            'SU');
INSERT INTO Access VALUES ('user/apikey',            'GUEST');
INSERT INTO Access VALUES ('user/address',            'SU');
INSERT INTO Access VALUES ('user/address',            'GUEST');

\echo *** Add Default Page *** 
INSERT into privilege VALUES ('default','UNKN','Default');
INSERT into access VALUES ('default','GUEST');
INSERT into access VALUES ('default','UNKN');
INSERT into access VALUES ('default','SU');




