USE [DukeLiveNew]
GO
/****** Object:  StoredProcedure [dbo].[SalesOrder1_CFL_SearchOnFind]    Script Date: 02-12-2024 10:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[SalesOrder1_CFL_SearchOnFind] 
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

if UPPER (@mode)='get_ORDR'
Begin
SELECT CardCode,CardName,CreateDate into #DOCS FROM OCRD;


IF(@order='ASC')
BEGIN
if (@ColumnName='' or @ColumnName='CardCode')
begin
SELECT * FROM #DOCS WHERE CardCode LIKE  @parameter1 order by CardCode ASC
end

if (@ColumnName='' or @ColumnName='CardName')
begin
SELECT * FROM #DOCS WHERE CardName LIKE  @parameter1 order by CardName ASC
end

if (@ColumnName='' or @ColumnName='CreateDate')
begin
SELECT * FROM #DOCS WHERE CreateDate LIKE  @parameter1 order by CreateDate ASC
end

END

IF(@order='DESC')
BEGIN
if (@ColumnName='' or @ColumnName='CardCode')
begin
SELECT * FROM #DOCS WHERE CardCode LIKE  @parameter1 order by CardCode DESC
end


if (@ColumnName='' or @ColumnName='CardName')
begin
SELECT * FROM #DOCS WHERE CardName LIKE  @parameter1 order by CardName DESC
end

if (@ColumnName='' or @ColumnName='CreateDate')
begin
SELECT * FROM #DOCS WHERE CreateDate LIKE  @parameter1 order by CreateDate DESC
end


END

DROP TABLE #DOCS
END



----------------------------------------------------------------------------------------------------

if UPPER (@mode)='get_ARTC'
Begin
SELECT ArticleCode,ColorCode,ColorName,Size into #DOCS1 FROM ArticleCode;


IF(@order='ASC')
BEGIN
if (@ColumnName='' or @ColumnName='ArticleCode')
begin
SELECT * FROM #DOCS1 WHERE ArticleCode LIKE  @parameter1 order by ArticleCode ASC
end

if (@ColumnName='' or @ColumnName='ColorCode')
begin
SELECT * FROM #DOCS1 WHERE ColorCode LIKE  @parameter1 order by ColorCode ASC
end

if (@ColumnName='' or @ColumnName='ColorName')
begin
SELECT * FROM #DOCS1 WHERE ColorName LIKE  @parameter1 order by ColorName ASC
end

if (@ColumnName='' or @ColumnName='Size')
begin
SELECT * FROM #DOCS1 WHERE Size LIKE  @parameter1 order by Size ASC
end

END

IF(@order='DESC')
BEGIN
if (@ColumnName='' or @ColumnName='ArticleCode')
begin
SELECT * FROM #DOCS1 WHERE ArticleCode LIKE  @parameter1 order by ArticleCode DESC
end


if (@ColumnName='' or @ColumnName='ColorCode')
begin
SELECT * FROM #DOCS1 WHERE ColorCode LIKE  @parameter1 order by ColorCode DESC
end

if (@ColumnName='' or @ColumnName='ColorName')
begin
SELECT * FROM #DOCS1 WHERE ColorName LIKE  @parameter1 order by ColorName DESC
end


if (@ColumnName='' or @ColumnName='Size')
begin
SELECT * FROM #DOCS1 WHERE Size LIKE  @parameter1 order by Size DESC
end


END

DROP TABLE #DOCS1
END




----------------------------------------------------------------------------------------------------

END







