-- Put this file wherever you extract sqlcl: sqlcl/login.sql
set sqlprompt "@|red _USER@_CONNECT_IDENTIFIER> |@"
ALTER SESSION SET NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'; 
ALTER SESSION SET NLS_TIMESTAMP_FORMAT='DD-MON-YYYY HH24:MI:SS.FF'; 
