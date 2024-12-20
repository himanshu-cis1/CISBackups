USE [DukeLiveNew]
GO
/****** Object:  StoredProcedure [dbo].[POD_CFL_SearchOnFind]    Script Date: 02-12-2024 10:18:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[POD_CFL_SearchOnFind] 
(
@mode		nvarchar(40)=null,
@parameter1	nvarchar(40)=null,
@parameter2	nvarchar(40)=null,
@parameter3	nvarchar(40)=null,
@parameter4	nvarchar(40)=null,
@parameter5	nvarchar(40)=null,
@ColumnName nvarchar(60)=null,
@order		nvarchar(60)=null, 
@DOC  nvarchar(60)=null 

)
as 
begin

if(@order='')
begin
set @order='ASC'
end

if(@parameter2)=''
begin
set @parameter2=NULL
end
if(@parameter3)=''
begin
set @parameter3=NULL 
end
if(@parameter4)=''
begin
set @parameter4=NULL 
end
if(@parameter5)=''
begin
set @parameter5=NULL 
end



---------------------------------------------DOCS-------------------------------------------------
 
if UPPER (@mode)='get_BIllingTransporter'
Begin

SELECT DISTINCT U_TN  AS TransporterName,U_TN  AS TransporterName2,U_TN  AS TransporterName3 into  #DOCS FROM OINV WHERE U_TN IS NOT NULL;

IF(@order='ASC')
BEGIN
if (@ColumnName='' or @ColumnName='TransporterName')
begin
SELECT * FROM #DOCS WHERE TransporterName LIKE  @parameter1 order by TransporterName ASC
end


if (@ColumnName='' or @ColumnName='TransporterName2')
begin
SELECT * FROM #DOCS WHERE TransporterName2 LIKE  @parameter1 order by TransporterName2 ASC
end


if (@ColumnName='' or @ColumnName='TransporterName3')
begin
SELECT * FROM #DOCS WHERE TransporterName3 LIKE  @parameter1 order by TransporterName3 ASC
end




END


IF(@order='DESC')
BEGIN
if (@ColumnName='' or @ColumnName='TransporterName')
begin
SELECT * FROM #DOCS WHERE TransporterName LIKE  @parameter1 order by TransporterName DESC
end



if (@ColumnName='' or @ColumnName='TransporterName2')
begin
SELECT * FROM #DOCS WHERE TransporterName2 LIKE  @parameter1 order by TransporterName2 DESC
end


if (@ColumnName='' or @ColumnName='TransporterName3')
begin
SELECT * FROM #DOCS WHERE TransporterName3 LIKE  @parameter1 order by TransporterName3 DESC
end






END

DROP TABLE #DOCS
END





if UPPER (@mode)='get_ReturnTransporter'
Begin

Select  Distinct T0.U_Transporter AS TransporterName,T0.U_Transporter AS TransporterName2,T0.U_Transporter AS TransporterName3  Into #DOCS2 From [@GATEENTRYH] t0 where t0.U_Transporter is not null;

IF(@order='ASC')
BEGIN
if (@ColumnName='' or @ColumnName='TransporterName')
begin
SELECT * FROM #DOCS2 WHERE TransporterName LIKE  @parameter1 order by TransporterName ASC
end

if (@ColumnName='' or @ColumnName='TransporterName2')
begin
SELECT * FROM #DOCS2 WHERE TransporterName2 LIKE  @parameter1 order by TransporterName2 ASC
end

if (@ColumnName='' or @ColumnName='TransporterName3')
begin
SELECT * FROM #DOCS2 WHERE TransporterName3 LIKE  @parameter1 order by TransporterName3 ASC
end


END


IF(@order='DESC')
BEGIN
if (@ColumnName='' or @ColumnName='TransporterName')
begin
SELECT * FROM #DOCS2 WHERE TransporterName LIKE  @parameter1 order by TransporterName DESC
end


if (@ColumnName='' or @ColumnName='TransporterName2')
begin
SELECT * FROM #DOCS2 WHERE TransporterName2 LIKE  @parameter1 order by TransporterName2 DESC
end



if (@ColumnName='' or @ColumnName='TransporterName3')
begin
SELECT * FROM #DOCS2 WHERE TransporterName3 LIKE  @parameter1 order by TransporterName3 DESC
end





END

DROP TABLE #DOCS
DROP TABLE #DOCS2
END










END






