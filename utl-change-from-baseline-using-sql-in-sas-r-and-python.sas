%let pgm=utl-change-from-baseline-using-sql-in-sas-r-and-python;

Change from baseline using sql in sas r and python

    Three Solutions

        1 sas proc sql
        2 r sql
        3 python sql

github
https://tinyurl.com/5n8jd92r
https://github.com/rogerjdeangelis/utl-change-from-baseline-using-sql-in-sas-r-and-python

stackoverflow
https://tinyurl.com/yvxa5d3k
https://stackoverflow.com/questions/78711104/percentage-change-over-multiple-columns-in-r


Related REPOS
--------------------------------------------------------------------------------------------------------------------
https://github.com/rogerjdeangelis/utl-add-rows-with-followup-mean-and-baseline-change-from-followup-week-average
https://github.com/rogerjdeangelis/utl-change-from-baseline-to-week1-to-week8-using-wps-r-python-base-and-sql
https://github.com/rogerjdeangelis/utl-set-type-for-subject-based-on-baseline-dose-wps-r-python-sql


SOAPBOX ON

There have been many extensions, data types, data structures, functions and packages added the S/R language,
origianally  developed by Bell Laboratories John Chambers,
however, I sometimes feel solving problems using as many of the original base R and S functions, data types
and data structures leads to more clear and maintainable code.
The addition of sqllite and interfaces to external databases like PostgreSQL, and mySQL should be used where appropriate.

The sqllite interface in Python needs work, it is un-neccessarly slow and vey difficult instal and setup.
Simple functions like the standard deviation and may others need to be added by default.

SOAPBOX OFF

/*               _     _
 _ __  _ __ ___ | |__ | | ___ _ __ ___
| `_ \| `__/ _ \| `_ \| |/ _ \ `_ ` _ \
| |_) | | | (_) | |_) | |  __/ | | | | |
| .__/|_|  \___/|_.__/|_|\___|_| |_| |_|
|_|
*/

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  THIS IS HOW WE COMPUTE PERCENT CHANGE                                                                                 */
/*                                                                                                                        */
/*                                                            MPG                           CYL                           */
/*                 CAR        MPG          Delta Percent  Percent Change  CYL           Percent Change                    */
/*                                                                                                                        */
/*  BASELINE       BASECAR     27                                          5                                              */
/*                                                                                                                        */
/*                 DATSUN      22  100*(27-22)/27 = 18.5%   18.518519      4                   20                         */
/*                 TAURUS      24                           11.111111      4                   20                         */
/*                 FORD        23                           14.814815      8                  -60                         */
/*                                                                                                                        */
/*                 CHEVY       27  100*(27-22)/27 = 0        0.000000      4                   20                         */
/*                 HONDA       26                            3.703704      4 100*(5-4)/5 =20   20                         */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*                   _           _ _             _       _   _
(_)_ __  _ __  _   _| |_    __ _| | |  ___  ___ | |_   _| |_(_) ___  _ __  ___
| | `_ \| `_ \| | | | __|  / _` | | | / __|/ _ \| | | | | __| |/ _ \| `_ \/ __|
| | | | | |_) | |_| | |_  | (_| | | | \__ \ (_) | | |_| | |_| | (_) | | | \__ \
|_|_| |_| .__/ \__,_|\__|  \__,_|_|_| |___/\___/|_|\__,_|\__|_|\___/|_| |_|___/
        |_|
*/

libname sd1 "d:/sd1";
options validvarname=upcase;
 data sd1.have;
  call streaminit(4321);
  do car = 'BASECAR','DATSUN','TAURUS','FORD','CHEVY','HONDA';
       mpg=int(20 + 10* rand('uniform'));
       cyl=int(3  + 6*  rand('uniform'));
       hp=int(60  + 200*rand('uniform'));
       output;
  end;
  stop;
run;quit;

/*                             _
/ |  ___  __ _ ___   ___  __ _| |
| | / __|/ _` / __| / __|/ _` | |
| | \__ \ (_| \__ \ \__ \ (_| | |
|_| |___/\__,_|___/ |___/\__, |_|
                            |_|
*/
proc sql;
 create
    table want as
 select
    r.car as from
   ,l.car as carpct
   ,100*((r.mpg-l.mpg)/r.mpg)  as pctChgMpg
   ,100*((r.cyl-l.cyl)/r.cyl)  as pctChgCyl
   ,100*((r.hp-l.hp)/r.hp)     as pctHp
 from
   have as l left join have as r
 on
  r.car eq "BASECAR"
where
  l.car ne "BASECAR"

;quit;

/**************************************************************************************************************************/
/*  SAS                                                                                                                   */
/*                                                                                                                        */
/*  WORK.WANT total obs=5                                                                                                 */
/*                                                                                                                        */
/*    FROM      CARPCT    PCTCHGMPG    PCTCHGCYL      PCTHP                                                               */
/*                                                                                                                        */
/*   BASECAR    DATSUN     18.5185         20        19.1837                                                              */
/*   BASECAR    TAURUS     11.1111         20        37.9592                                                              */
/*   BASECAR    FORD       14.8148        -60        58.3673                                                              */
/*   BASECAR    CHEVY       0.0000         20        55.5102                                                              */
/*   BASECAR    HONDA       3.7037         20        -2.4490                                                              */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*___                     _
|___ \   _ __   ___  __ _| |
  __) | | `__| / __|/ _` | |
 / __/  | |    \__ \ (_| | |
|_____| |_|    |___/\__, |_|
                       |_|
*/

%utl_rbeginx;
parmcards4;
library(haven)
library(sqldf)
source("c:/oto/fn_tosas9x.R")
have<-read_sas("d:/sd1/have.sas7bdat")
have
want<-sqldf('
 select
    r.car as base
   ,l.car as carpct
   ,100*((r.mpg-l.mpg)/r.mpg)  as pctChgMpg
   ,100*((r.cyl-l.cyl)/r.cyl)  as pctChgCyl
   ,100*((r.hp-l.hp)/r.hp)     as pctHp
 from
   have as l left join have as r
 on
  r.car = "BASECAR"
where
  l.car <> "BASECAR"
')
want
fn_tosas9x(
      inp    = want
     ,outlib ="d:/sd1/"
     ,outdsn ="want"
     );
;;;;
%utl_rendx;

/**************************************************************************************************************************/
/*                                                                                                                        */
/* R                                                                                                                      */
/* ==                                                                                                                     */
/*                                                                                                                        */
/* > want                                                                                                                 */
/*      base carpct pctChgMpg pctChgCyl    pctHp                                                                          */
/*                                                                                                                        */
/* 1 BASECAR DATSUN 18.518519        20 19.18367                                                                          */
/* 2 BASECAR TAURUS 11.111111        20 37.95918                                                                          */
/* 3 BASECAR   FORD 14.814815       -60 58.36735                                                                          */
/* 4 BASECAR  CHEVY  0.000000        20 55.51020                                                                          */
/* 5 BASECAR  HONDA  3.703704        20 -2.44898                                                                          */
/*                                                                                                                        */
/* SAS                                                                                                                    */
/* ===                                                                                                                    */
/*                                                                                                                        */
/* SD1.WANT total obs=5                                                                                                   */
/*                                                                                                                        */
/*   ROWNAMES     BASE      CARPCT    PCTCHGMPG    PCTCHGCYL      PCTHP                                                   */
/*                                                                                                                        */
/*       1       BASECAR    DATSUN     18.5185         20        19.1837                                                  */
/*       2       BASECAR    TAURUS     11.1111         20        37.9592                                                  */
/*       3       BASECAR    FORD       14.8148        -60        58.3673                                                  */
/*       4       BASECAR    CHEVY       0.0000         20        55.5102                                                  */
/*       5       BASECAR    HONDA       3.7037         20        -2.4490                                                  */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*____               _   _                             _
|___ /   _ __  _   _| |_| |__   ___  _ __    ___  __ _| |
  |_ \  | `_ \| | | | __| `_ \ / _ \| `_ \  / __|/ _` | |
 ___) | | |_) | |_| | |_| | | | (_) | | | | \__ \ (_| | |
|____/  | .__/ \__, |\__|_| |_|\___/|_| |_| |___/\__, |_|
        |_|    |___/                                |_|
*/

%utl_pybeginx;
parmcards4;
import pyperclip
import os
from os import path
import sys
import subprocess
import time
import pandas as pd
import pyreadstat as ps
import numpy as np
import pandas as pd
from pandasql import sqldf
mysql = lambda q: sqldf(q, globals())
from pandasql import PandaSQL
pdsql = PandaSQL(persist=True)
sqlite3conn = next(pdsql.conn.gen).connection.connection
sqlite3conn.enable_load_extension(True)
sqlite3conn.load_extension('c:/temp/libsqlitefunctions.dll')
mysql = lambda q: sqldf(q, globals())
have, meta = ps.read_sas7bdat("d:/sd1/have.sas7bdat")
exec(open('c:/temp/fn_tosas9.py').read())
print(have);
want = pdsql("""
 select
    r.car as base
   ,l.car as carpct
   ,100*((r.mpg-l.mpg)/r.mpg)  as pctChgMpg
   ,100*((r.cyl-l.cyl)/r.cyl)  as pctChgCyl
   ,100*((r.hp-l.hp)/r.hp)     as pctHp
 from
   have as l left join have as r
 on
  r.car = "BASECAR"
where
  l.car <> "BASECAR"
""")
print(want)
fn_tosas9(
   want
   ,dfstr="want"
   ,timeest=3
   )
;;;;
%utl_pyendx;

libname tmp "c:/temp";
proc print data=tmp.want;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/* Python                                                                                                                 */
/* ======                                                                                                                 */
/*                                                                                                                        */
/*       base  carpct  pctChgMpg  pctChgCyl      pctHp                                                                    */
/* 0  BASECAR  DATSUN  18.518519       20.0  19.183673                                                                    */
/* 1  BASECAR  TAURUS  11.111111       20.0  37.959184                                                                    */
/* 2  BASECAR    FORD  14.814815      -60.0  58.367347                                                                    */
/* 3  BASECAR   CHEVY   0.000000       20.0  55.510204                                                                    */
/* 4  BASECAR   HONDA   3.703704       20.0  -2.448980                                                                    */
/*                                                                                                                        */
/*                                                                                                                        */
/* SAS                                                                                                                    */
/* ===                                                                                                                    */
/*                                                                                                                        */
/*     BASE      CARPCT    PCTCHGMPG    PCTCHGCYL      PCTHP                                                              */
/*                                                                                                                        */
/*    BASECAR    DATSUN     18.5185         20        19.1837                                                             */
/*    BASECAR    TAURUS     11.1111         20        37.9592                                                             */
/*    BASECAR    FORD       14.8148        -60        58.3673                                                             */
/*    BASECAR    CHEVY       0.0000         20        55.5102                                                             */
/*    BASECAR    HONDA       3.7037         20        -2.4490                                                             */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
