

Create PROCEDURE [dbo].[ControlProceso_sp]
AS
/*
Versión: 1.0
Autor: Marcelo Aguero
Fecha: 1/11/2007
Descripción: El procedimiento devuelve los bloqueos en el servidor, también devuelve los procesos que están esperando a que se libere el bloequeo.

Versión 1.1
Autor: Iván Kurlat
Fecha: 11/06/2008
Descripción: Se agregaron los campos de lastwaittype y waitresource en el reporte.


*/

declare @musu           varchar(50)
declare @musu_nt        varchar(50)
declare @mter           varchar(50)
declare @mspid          int
declare @mspid2         varchar(50)
declare @cant2          varchar(50)
declare @cant           int

select  @mspid = 0

select  @musu = suser_name(uid), @mspid = spid, @musu_nt = nt_username, @mter = hostname
from    master..sysprocesses
where   spid in (select blocked from master..sysprocesses where blocked <> 0) and blocked = 0

select  @cant = count(*)
from    master..sysprocesses
where   blocked <> 0

if @cant = 0
      begin
            select 'NO HAY BLOQUEOS'
      end
else
      begin
            select @cant2     = 'Cantidad de Blockeos :' + convert(varchar(10), @cant)
            select @mter      = 'Equipo               :' + @mter
            select @mspid2    = 'Id de proceso        :' + convert(varchar(50), @mspid)
            select @musu_nt   = 'Usuario NT           :' + @musu_nt
            select @musu      = 'Usuario SQL          :' + @musu

            print'********** PROCESO QUE BLOQUEA **********'
            print''
            print @cant2
            print @mter
            print @mspid2
            print @musu_nt
            print @musu
            print'*****************************************'

            dbcc inputbuffer(@mspid) WITH NO_INFOMSGS

            select spid, status, lastwaittype,convert(varchar(50),waitresource) as waitresource,convert (varchar, loginame) as Login, convert (varchar, hostname) as HostName, 
                   convert (smallint, blocked) as blkby, DBName = convert (varchar, db_name(dbid)), 
                   convert (char(20), cmd) as command, convert (int, cpu) as cputime, 
                       convert (bigint, physical_io) as DiskIO, last_batch
            from master..sysprocesses
            where spid = @mspid


            select spid, status,lastwaittype,convert(varchar(50),waitresource) as waitresource, convert (varchar, loginame) as Login, convert (varchar, hostname) as HostName, 
                   convert (smallint, blocked) as BlkBy, DBName = convert (varchar, db_name(dbid)), 
                   convert (char(20), cmd) as Command, convert (int, cpu) as CPUTime, 
                       convert (bigint, physical_io) as DiskIO, Last_Batch
            from master..sysprocesses
            where blocked <> 0 and 
                      cmd not in ('LAZY WRITER', 
                          'LOG WRITER', 
                          'SIGNAL HANDLER', 
                          'LOCK MONITOR', 
                          'TASK MANAGER', 
                          'CHECKPOINT SLEEP')                     
                  
      End
