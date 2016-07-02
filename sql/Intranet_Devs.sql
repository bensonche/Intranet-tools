use rdi_production
go

select distinct a.empid, b.FULLNAME2, EMAIL
from time_sht a
inner join AllUsers b
on a.EMPID = b.USERID
where a.CLIENT_ID = 363
and PROJECT_NO = 9
and WK_DATE > DATEADD(ww, -2, GETDATE())
and RDIItemId is not null
and JOB_CODE in (340,345,430,435,305,310,311,1340,1345,1430,1435,1305,1310,1311)
order by FULLNAME2