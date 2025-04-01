# Optimization- Performace Tuning

# profile PLSQL code using DBMS_PROFILER

# Create the profiler tables from the table creation script available in oracle home directory

drop table plsql_profiler_data cascade constraints;
drop table plsql_profiler_units cascade constraints;
drop table plsql_profiler_runs cascade constraints;

drop sequence plsql_profiler_runnumber;

create table plsql_profiler_runs
(
  runid           number primary key,  -- unique run identifier,
                                       -- from plsql_profiler_runnumber
  related_run     number,              -- runid of related run (for client/
                                       --     server correlation)
  run_owner       varchar2(32),        -- user who started run
  run_date        date,                -- start time of run
  run_comment     varchar2(2047),      -- user provided comment for this run
  run_total_time  number,              -- elapsed time for this run
  run_system_info varchar2(2047),      -- currently unused
  run_comment1    varchar2(2047),      -- additional comment
  spare1          varchar2(256)        -- unused
);

comment on table plsql_profiler_runs is
        'Run-specific information for the PL/SQL profiler';

create table plsql_profiler_units
(
  runid              number references plsql_profiler_runs,
  unit_number        number,           -- internally generated library unit #
  unit_type          varchar2(32),     -- library unit type
  unit_owner         varchar2(32),     -- library unit owner name
  unit_name          varchar2(32),     -- library unit name
  -- timestamp on library unit, can be used to detect changes to
  -- unit between runs
  unit_timestamp     date,
  total_time         number DEFAULT 0 NOT NULL,
  spare1             number,           -- unused
  spare2             number,           -- unused
  --  
  primary key (runid, unit_number)
);

comment on table plsql_profiler_units is 
        'Information about each library unit in a run';

create table plsql_profiler_data
(
  runid           number,           -- unique (generated) run identifier
  unit_number     number,           -- internally generated library unit #
  line#           number not null,  -- line number in unit
  total_occur     number,           -- number of times line was executed
  total_time      number,           -- total time spent executing line
  min_time        number,           -- minimum execution time for this line
  max_time        number,           -- maximum execution time for this line
  spare1          number,           -- unused
  spare2          number,           -- unused
  spare3          number,           -- unused
  spare4          number,           -- unused
  --
  primary key (runid, unit_number, line#),
  foreign key (runid, unit_number) references plsql_profiler_units
);

comment on table plsql_profiler_data is 
        'Accumulated data from all profiler runs';

create sequence plsql_profiler_runnumber start with 1 nocache;

@C:\orclee18c\WINDOWS.X64_180000_db_home_ORACLE18C\rdbms\admin\proftab.sql

** Search for "proftab.sql" in your oracle home directory


Scripts to clear the profiler tables

truncate table plsql_profiler_data;
delete from plsql_profiler_units;
delete from plsql_profiler_runs;

Invoke "dbms_profiler.start_profiler" to start the profiler and "dbms_profiler.stop_profiler" to stop the profiler.Sample code give below,

exec dbms_profiler.start_profiler ('MY_TEST_PERFORMANCE_RUN1');
exec proc_a;
exec dbms_profiler.stop_profiler();

select * from plsql_profiler_data;
select * from plsql_profiler_units;
select * from plsql_profiler_runs;


Query to find the line wise time taken

SELECT
plsql_profiler_runs.RUN_DATE, 
plsql_profiler_runs.RUN_COMMENT,
plsql_profiler_units.UNIT_TYPE, 
plsql_profiler_units.UNIT_NAME,
plsql_profiler_data.LINE#, 
plsql_profiler_data.TOTAL_OCCUR, 
plsql_profiler_data.TOTAL_TIME, 
plsql_profiler_data.MIN_TIME, 
plsql_profiler_data.MAX_TIME,
round(plsql_profiler_data.total_time/1000000000) total_time_in_sec,
trunc(((plsql_profiler_data.total_time)/(sum(plsql_profiler_data.total_time) over()))*100,2) pct_of_time_taken
FROM
    plsql_profiler_data,plsql_profiler_runs,plsql_profiler_units
where plsql_profiler_data.total_time > 0 
and plsql_profiler_data.runid = plsql_profiler_runs.runid
and plsql_profiler_units.UNIT_NUMBER = plsql_profiler_data.UNIT_NUMBER
and plsql_profiler_units.runid = plsql_profiler_runs.runid
ORDER BY
    plsql_profiler_data.total_time DESC;