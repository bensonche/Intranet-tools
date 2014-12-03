declare @newDBName varchar(50) = 'RDI_Development'

declare @dir varchar(1000) = 'c:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\'
declare @mdf varchar(1000) = @dir + @newDBName + '.mdf'
declare @ldf varchar(1000) = @dir + @newDBName + '.ldf'

declare @yesterday date = dateadd(d, -1, convert(varchar, getdate(), 101))
declare @datestring varchar(20) = convert(varchar, datepart(yy, @yesterday)) + '.'
set @datestring = @datestring + convert(varchar, datepart(m, @yesterday)) + '.'
set @datestring = @datestring + convert(varchar, datepart(d, @yesterday))

declare @bak varchar(max) = '\\anc-files\sqlbackups\RDI_Production.SqlServer3.' + @datestring + '.bak'

--RESTORE FILELISTONLY
--FROM DISK = @bak

--goto quit

----Make Database to single user Mode

declare @sql varchar(max)

set @sql = '
	ALTER DATABASE ' + @newDBName + '
	SET SINGLE_USER WITH
	ROLLBACK IMMEDIATE'
exec( @sql)

print 'Begin DB Restore'

restore database @newDBName
from disk = @bak
with move 'resdat_be2000SQL_dat' to @mdf,
move 'resdat_be2000SQL_log' to @ldf

print 'DB Restore Finished'

if @newDBName = 'RDI_Development'
begin
    print 'Begin scrub'

    set @sql = '
        use ' + @newDBName + '
	    exec rdi_cleandevdatabase'
    exec(@sql)

    print 'End scrub'
end

set @sql = '
	ALTER DATABASE ' + @newDBName + '
	SET MULTI_USER'
exec(@sql)
