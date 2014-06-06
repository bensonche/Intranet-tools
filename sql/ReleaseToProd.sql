with lastQA as
(
    select RDIItemId, max(changedate) date
    from RDIItemHistory
    where StatusId = 8
    group by RDIItemId
),
lastReview as
(
    select row_number() over (partition by a.rdiitemid order by changedate) seq, a.RDIItemId, a.UpdatedBy
    from RDIItemHistory a
        left join lastQA b
            on a.RDIItemId = b.RDIItemId
    where a.StatusId = 7
    and a.AssignedTo = 10000
    and (b.date is null or a.ChangeDate > b.date)
)
select a.RDIItemId a, FeatureBranch,
	case when b.sql_ct is null then '' else convert(varchar(2), b.sql_ct) end [sql count],
	case when d.sql_ct is null then '' else convert(varchar(2), d.sql_ct) end [all sql count],
	case when rtrim(ltrim(isnull(ChangedDescription, ''))) = '' then 'missing change description' else '' end as ChangedDescriptionCheck,
	c.FULLNAME2,
	c.empid
from RDIItem a
left join (
	select a.rdiitemid, count(*) sql_ct
	from ItemFile a
	    inner join DOCS b
	        on a.DocID = b.DOC_ID
	    left join DOC_METADATA c
	        on b.DOC_ID = c.DOC_ID
        left join lastQA d
            on a.RDIItemId = d.RDIItemId
	where DOC_EXTENSION = '.sql'
        and (d.date is null or a.ins_date > d.date)
	group by a.rdiitemid ) b
on a.RDIItemId = b.RDIItemId
left join (
	select a.RDIItemId, b.FULLNAME2, b.userid as empid
	from lastReview a
	    inner join allusers b
            on a.UpdatedBy = b.USERID
) c
on a.RDIItemId = c.RDIItemId
left join (
	select a.rdiitemid, count(*) sql_ct
	from ItemFile a
	    inner join DOCS b
	        on a.DocID = b.DOC_ID
	    left join DOC_METADATA c
	        on b.DOC_ID = c.DOC_ID
	where DOC_EXTENSION = '.sql'
	group by a.rdiitemid ) d
on a.RDIItemId = d.RDIItemId
where
    a.CLIENT_ID = 363
    and a.PROJECT_NO = 9
    and StatusId = 48
    and AssignedTo = 10000
order by a.RDIItemId

---------------------------------------------
declare @PTLink varchar(500)
set @PTLink = '<a href=''https://www.resdat.com/privatedn/ProjectTrack/IssueGrid.aspx?IssueID=';

with lastQA as (
    select rdiitemid, max(ChangeDate) changeDate
    from RDIItemHistory
    where StatusId = 8
    group by RDIItemId
)
select url
from
(
    select @PTlink + convert(varchar(10), a.RDIItemId) + '''>' + convert(varchar(10), a.RDIItemId) + isnull(b.url, '') + '</a>' url, a.RDIItemId, 1 as sequence
    from RDIItem a
		left join (
			select a.rdiitemid, ' - ' + convert(varchar, count(*)) as url
			    from ItemFile a
			        inner join DOCS b
			            on a.DocID = b.DOC_ID
			        left join DOC_METADATA c
			            on b.DOC_ID = c.DOC_ID
                    left join lastQA d
                        on a.RDIItemId = d.RDIItemId
			where DOC_EXTENSION = '.sql'
                and (d.changeDate is null or a.ins_date > d.changeDate)
			group by a.rdiitemid 
			having count(*) > 0
        ) b
		    on a.RDIItemId = b.RDIItemId
    where
        CLIENT_ID = 363
        and PROJECT_NO = 9
        and StatusId = 48
        and AssignedTo = 10000
    union all
    select '<br />' as url, RDIItemId, 2 as sequence
    from RDIItem
    where
        CLIENT_ID = 363
        and PROJECT_NO = 9
        and StatusId = 48
        and AssignedTo = 10000
) a
order by a.RDIItemId, sequence

----------------------------------------------------------
--select b.RDIItemId, b.upd_date, b.comments
--from RDIItemHistory b
--inner join rdiitem a
--	on a.RDIItemId = b.RDIItemId
--where a.CLIENT_ID = 363
--and a.PROJECT_NO = 9
--and a.StatusId = 48
--and a.AssignedTo = 10000
--and isnull(b.comments, '') <> ''
--order by b.RDIItemId, b.upd_date desc