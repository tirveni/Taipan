-- use Taipan
--
-- 0.1 Taipan
-- <tirveni@udyansh.org>

\c taipan;

CREATE TABLE TASK
(
	taskid			SERIAL PRIMARY KEY,

	maximum_tries		smallint,

	is_cron			boolean,
	cron_minute		smallint,
	cron_hour		smallint,
	cron_day_of_month	smallint,
	cron_month		smallint,
	cron_day_of_week	smallint,

	-- Outgoing Request	
	method			text,
	method_type		char(24),
	method_data		text,	-- JSON is stored in text.
	
	-- Callback, to Initiator of this Task
	callback_method		text,
	callback_method_type	text,
	callback_method_data	text,

        userid                  text REFERENCES 
                AppUser  ON UPDATE CASCADE,
        date_created      timestamp 
                with time zone default (now() at time zone 'utc')
);
