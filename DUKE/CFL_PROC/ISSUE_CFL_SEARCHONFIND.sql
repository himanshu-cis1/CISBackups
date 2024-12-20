USE [DukeLiveNew]
GO
/****** Object:  StoredProcedure [dbo].[Issue_CFL_SearchOnFind]    Script Date: 02-12-2024 10:16:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[Issue_CFL_SearchOnFind] 
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

if UPPER (@mode)='get_ItemCode'
Begin
select ItemCode,FrgnName,U_Size,U_MRP,U_Gender,U_CP into #DOCS from [OITM]

IF(@order='ASC')
BEGIN
if (@ColumnName='' or @ColumnName='ItemCode')
begin
SELECT * FROM #DOCS WHERE ItemCode LIKE  @parameter1 order by ItemCode ASC
end

if (@ColumnName='' or @ColumnName='FrgnName')
begin
SELECT * FROM #DOCS WHERE FrgnName LIKE  @parameter1 order by FrgnName ASC
end

if (@ColumnName='' or @ColumnName='U_Size')
begin
SELECT * FROM #DOCS WHERE U_Size LIKE  @parameter1 order by U_Size ASC
end

if (@ColumnName='' or @ColumnName='U_MRP')
begin
SELECT * FROM #DOCS WHERE U_MRP LIKE  @parameter1 order by U_MRP ASC
end





if (@ColumnName='' or @ColumnName='U_Gender')
begin
SELECT * FROM #DOCS WHERE U_Gender LIKE  @parameter1 order by U_Gender ASC
end


if (@ColumnName='' or @ColumnName='U_CP')
begin
SELECT * FROM #DOCS WHERE U_CP LIKE  @parameter1 order by U_CP ASC
end
END

IF(@order='DESC')
BEGIN
if (@ColumnName='' or @ColumnName='ItemCode')
begin
SELECT * FROM #DOCS WHERE ItemCode LIKE  @parameter1 order by ItemCode DESC
end

if (@ColumnName='' or @ColumnName='FrgnName')
begin
SELECT * FROM #DOCS WHERE FrgnName LIKE  @parameter1 order by FrgnName DESC
end

if (@ColumnName='' or @ColumnName='U_Size')
begin
SELECT * FROM #DOCS WHERE U_Size LIKE  @parameter1 order by U_Size DESC
end

if (@ColumnName='' or @ColumnName='U_MRP')
begin
SELECT * FROM #DOCS WHERE U_MRP LIKE  @parameter1 order by U_MRP DESC
end





if (@ColumnName='' or @ColumnName='U_Gender')
begin
SELECT * FROM #DOCS WHERE U_Gender LIKE  @parameter1 order by U_Gender DESC
end


if (@ColumnName='' or @ColumnName='U_CP')
begin
SELECT * FROM #DOCS WHERE U_CP LIKE  @parameter1 order by U_CP DESC
end
END

DROP TABLE #DOCS
END
---------------------------------------





if UPPER (@mode)='get_WHS'
Begin
select WhsCode,WhsName  into #DOCSS from [OWHS]

IF(@order='ASC')
BEGIN
if (@ColumnName='' or @ColumnName='WhsCode')
begin
SELECT * FROM #DOCSS WHERE WhsCode LIKE  @parameter1 order by WhsCode ASC
end

if (@ColumnName='' or @ColumnName='WhsName')
begin
SELECT * FROM #DOCSS WHERE WhsName LIKE  @parameter1 order by WhsName ASC
end

END





IF(@order='DESC')
BEGIN
if (@ColumnName='' or @ColumnName='WhsCode')
begin
SELECT * FROM #DOCSS WHERE WhsCode LIKE  @parameter1 order by WhsCode DESC
end

if (@ColumnName='' or @ColumnName='FrgnName')
begin
SELECT * FROM #DOCSS WHERE WhsName LIKE  @parameter1 order by WhsName DESC
end


END

DROP TABLE #DOCSS
END



-------------------------------------------------------------------------------------------

END






