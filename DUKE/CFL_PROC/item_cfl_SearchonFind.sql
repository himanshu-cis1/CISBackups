USE [DukeLiveNew]
GO
/****** Object:  StoredProcedure [dbo].[ITEM_CFL_SearchOnFind]    Script Date: 02-12-2024 10:17:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER procedure [dbo].[ITEM_CFL_SearchOnFind] 
(
@mode		nvarchar(40)=null,
@parameter1	nvarchar(40)=null,
@parameter2	nvarchar(40)=null,
@parameter3	nvarchar(40)=null,
@parameter4	nvarchar(40)=null,
@parameter5	nvarchar(40)=null,
@parameter6	nvarchar(40)=null,
@parameter7	nvarchar(40)=null,
@parameter8	nvarchar(40)=null,
@parameter9	nvarchar(40)=null,
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

if(@parameter6)=''
begin
set @parameter6=NULL 
end

if(@parameter7)=''
begin
set @parameter7=NULL 
end

if(@parameter8)=''
begin
set @parameter8=NULL 
end


if(@parameter9)=''
begin
set @parameter9=NULL 
end







IF upper (@mode)='getItemmaster'						   /*--<CFL FOR DOCNUM From PURCHASE ORDER Screen--*/

BEGIN


Select Distinct ItemCode,ItemName,ItmsGrpCod into #z from OITM(nolock);

IF(@order='ASC')  
BEGIN 
if (@ColumnName='' or @ColumnName='ItemCode')
begin
SELECT * FROM #z WHERE [ItemCode] LIKE  @parameter1 order by ItemCode ASC
end

if (@ColumnName='ItemName')
begin
SELECT * FROM #z WHERE [ItemName] LIKE  @parameter1 order by ItemName ASC
end

if (@ColumnName='ItmsGrpCod')
begin
SELECT * FROM #z WHERE [ItmsGrpCod] LIKE  @parameter1 order by ItmsGrpCod ASC
end
END

IF(@order='DESC')  
BEGIN 
if (@ColumnName='' or @ColumnName='ItemCode')
begin
SELECT * FROM #z WHERE [ItemCode] LIKE  @parameter1 order by ItemCode DESC
end

if (@ColumnName='ItemName')
begin
SELECT * FROM #z WHERE [ItemName] LIKE  @parameter1 order by ItemName DESC
end

if (@ColumnName='ItmsGrpCod')
begin
SELECT * FROM #z WHERE [ItmsGrpCod] LIKE  @parameter1 order by ItmsGrpCod DESC
end
END

DROP TABLE #z

END
				 


IF upper (@mode)='getUser'						   /*--<CFL FOR DOCNUM From PURCHASE ORDER Screen--*/

BEGIN


select  Distinct USER_CODE,U_NAME,GROUPS  into #z1 from OUSR(nolock);

IF(@order='ASC')  
BEGIN 
if (@ColumnName='' or @ColumnName='USER_CODE')
begin
SELECT * FROM #z1 WHERE USER_CODE LIKE  @parameter1 order by USER_CODE ASC
end

if (@ColumnName='U_NAME')
begin
SELECT * FROM #z1 WHERE U_NAME LIKE  @parameter1 order by U_NAME ASC
end

if (@ColumnName='GROUPS')
begin
SELECT * FROM #z1 WHERE GROUPS LIKE  @parameter1 order by GROUPS ASC
end
END

IF(@order='DESC')  
BEGIN 
if (@ColumnName='' or @ColumnName='USER_CODE')
begin
SELECT * FROM #z1 WHERE USER_CODE LIKE  @parameter1 order by USER_CODE DESC
end

if (@ColumnName='U_NAME')
begin
SELECT * FROM #z1 WHERE U_NAME LIKE  @parameter1 order by U_NAME DESC
end

if (@ColumnName='GROUPS')
begin
SELECT * FROM #z1 WHERE GROUPS LIKE  @parameter1 order by GROUPS DESC
end
END

DROP TABLE #z1

END



IF upper (@mode)='get_ItemGroup'						   /*--<CFL FOR DOCNUM From PURCHASE ORDER Screen--*/

BEGIN



Select  Distinct ItmsGrpCod,ItmsGrpNam into #bin from OITB;

IF(@order='ASC')  
BEGIN 
if (@ColumnName='' or @ColumnName='ItmsGrpCod')
begin
SELECT * FROM #bin WHERE ItmsGrpCod LIKE  @parameter1 order by ItmsGrpCod ASC
end

if (@ColumnName='ItmsGrpNam')
begin
SELECT * FROM #bin WHERE ItmsGrpNam LIKE  @parameter1 order by ItmsGrpNam ASC
end

IF(@order='DESC')  
BEGIN 
if (@ColumnName='' or @ColumnName='ItmsGrpCod')
begin
SELECT * FROM #bin WHERE ItmsGrpCod LIKE  @parameter1 order by ItmsGrpCod DESC
end

if (@ColumnName='ItmsGrpNam')
begin
SELECT * FROM #bin WHERE ItmsGrpNam LIKE  @parameter1 order by ItmsGrpNam DESC
end

END

DROP TABLE #bin

END



END



IF upper (@mode)='getbin'						   /*--<CFL FOR DOCNUM From PURCHASE ORDER Screen--*/

BEGIN



select  Distinct U_BNAME AS BIN,U_SBNAME AS SBName into #bin1 from OITM(nolock) Where ItmsGrpCod =  @parameter5  and U_BNAME is not null;

IF(@order='ASC')  
BEGIN 
if (@ColumnName='' or @ColumnName='BIN')
begin
SELECT * FROM #bin1 WHERE BIN LIKE  @parameter1 order by BIN ASC
end

if (@ColumnName='SBName')
begin
SELECT * FROM #bin1 WHERE SBName LIKE  @parameter1 order by SBName ASC
end

IF(@order='DESC')  
BEGIN 
if (@ColumnName='' or @ColumnName='BIN')
begin
SELECT * FROM #bin1 WHERE BIN LIKE  @parameter1 order by BIN DESC
end

if (@ColumnName='SBName')
begin
SELECT * FROM #bin1 WHERE SBName LIKE  @parameter1 order by SBName DESC
end

END

DROP TABLE #bin1

END



END

IF upper (@mode)='getsubbin'						   /*--<CFL FOR DOCNUM From PURCHASE ORDER Screen--*/

BEGIN





select Distinct U_SBNAME AS SBName ,U_BNAME AS BIN into #SUBbin from OITM(nolock) Where U_BNAME =  @parameter2  and U_SBNAME is not null;

IF(@order='ASC')  
BEGIN 
if (@ColumnName='' or @ColumnName='SBName')
begin
SELECT * FROM #SUBbin WHERE SBName LIKE  @parameter1 order by SBName ASC
end

if (@ColumnName='BIN')
begin
SELECT * FROM #SUBbin WHERE SBName LIKE  @parameter1 order by SBName ASC
end

IF(@order='DESC')  
BEGIN 
if (@ColumnName='' or @ColumnName='SBName')
begin
SELECT * FROM #SUBbin WHERE SBName LIKE  @parameter1 order by SBName DESC
end

if (@ColumnName='BIN')
begin
SELECT * FROM #SUBbin WHERE SBName LIKE  @parameter1 order by SBName DESC
end


END

DROP TABLE #SUBbin

END



END




IF upper (@mode)='getItems'						   /*--<CFL FOR DOCNUM From PURCHASE ORDER Screen--*/

BEGIN







select  Distinct ItemCode,ItemName into #Items from OITM(nolock) Where U_SBNAME =  @parameter3;


IF(@order='ASC')  
BEGIN 
if (@ColumnName='' or @ColumnName='ItemCode')
begin
SELECT * FROM #Items WHERE ItemCode LIKE  @parameter1 order by ItemCode ASC
end

if (@ColumnName='ItemName')
begin
SELECT * FROM #Items WHERE ItemName LIKE  @parameter1 order by ItemName ASC
end

IF(@order='DESC')  
BEGIN 
if (@ColumnName='' or @ColumnName='ItemCode')
begin
SELECT * FROM #Items WHERE ItemCode LIKE  @parameter1 order by ItemCode DESC
end

if (@ColumnName='ItemName')
begin
SELECT * FROM #Items WHERE ItemName LIKE  @parameter1 order by ItemName DESC
end


END

DROP TABLE #Items

END

END


IF upper (@mode)='getArticle'						   /*--<CFL FOR DOCNUM From PURCHASE ORDER Screen--*/

BEGIN


Select  Distinct FrgnName Article,U_Color 'Color' into #z10 from OITM(nolock) Where ItmsGrpCod = @parameter6  and FrgnName is not null;

IF(@order='ASC')  
BEGIN 
if (@ColumnName='' or @ColumnName='Article')
begin
SELECT * FROM #z10 WHERE [Article] LIKE  @parameter1 order by Article ASC
end

if (@ColumnName='Color')
begin
SELECT * FROM #z10 WHERE Color LIKE  @parameter1 order by Color ASC
end


IF(@order='DESC')  
BEGIN 
if (@ColumnName='' or @ColumnName='Article')
begin
SELECT * FROM #z10 WHERE [Article] LIKE  @parameter1 order by Article DESC
end

if (@ColumnName='Color')
begin
SELECT * FROM #z10 WHERE Color LIKE  @parameter1 order by Color DESC
end

END

DROP TABLE #z10

END

END


IF upper (@mode)='getSize'						   /*--<CFL FOR DOCNUM From PURCHASE ORDER Screen--*/

BEGIN


Select Distinct U_SizeG 'SizeGarment' ,U_Color into #z11 from OITM(nolock) Where U_Color = @parameter7 and U_SizeG is not null;

IF(@order='ASC')  
BEGIN 

if (@ColumnName='SizeGarment')
begin
SELECT * FROM #z11 WHERE [SizeGarment] LIKE  @parameter1 order by SizeGarment ASC
end

if (@ColumnName='' or @ColumnName='U_Color')
begin
SELECT * FROM #z11 WHERE [U_Color] LIKE  @parameter1 order by U_Color ASC
end


IF(@order='DESC')  
BEGIN 

if (@ColumnName='SizeGarment')
begin
SELECT * FROM #z11 WHERE [SizeGarment] LIKE  @parameter1 order by SizeGarment DESC
end

if (@ColumnName='' or @ColumnName='U_Color')
begin
SELECT * FROM #z11 WHERE [U_Color] LIKE  @parameter1 order by U_Color DESC
end



END

DROP TABLE #z11

END

END

IF upper (@mode)='getColor'						   /*--<CFL FOR DOCNUM From PURCHASE ORDER Screen--*/

BEGIN


Select Distinct U_Color AS COLOR,U_SizeG 'SizeGarment' into #z12 from OITM(nolock) Where FrgnName = @parameter8  and U_Color is not null;

IF(@order='ASC')  
BEGIN 

if (@ColumnName='' or @ColumnName='COLOR')
begin
SELECT * FROM #z12 WHERE [COLOR] LIKE  @parameter1 order by COLOR ASC
end

if (@ColumnName='SizeGarment')
begin
SELECT * FROM #z12 WHERE [SizeGarment] LIKE  @parameter1 order by SizeGarment ASC
end




IF(@order='DESC')  
BEGIN 

if (@ColumnName='' or @ColumnName='U_Color')
begin
SELECT * FROM #z12 WHERE [U_Color] LIKE  @parameter1 order by U_Color DESC
end

if (@ColumnName='SizeGarment')
begin
SELECT * FROM #z12 WHERE [SizeGarment] LIKE  @parameter1 order by SizeGarment DESC
end

END

DROP TABLE #z12

END

END

IF upper (@mode)='getItems2'						   /*--<CFL FOR DOCNUM From PURCHASE ORDER Screen--*/

BEGIN


Select  Distinct ItemCode,ItemName into #z120 from OITM(nolock) Where U_SizeG =  @parameter9;

IF(@order='ASC')  
BEGIN 

if (@ColumnName='' or @ColumnName='ItemCode')
begin
SELECT * FROM #z120 WHERE [ItemCode] LIKE  @parameter1 order by ItemCode ASC
end

if (@ColumnName='ItemName')
begin
SELECT * FROM #z120 WHERE [ItemName] LIKE  @parameter1 order by ItemName ASC
end




IF(@order='DESC')  
BEGIN 

if (@ColumnName='' or @ColumnName='ItemCode')
begin
SELECT * FROM #z120 WHERE [ItemCode] LIKE  @parameter1 order by ItemCode DESC
end

if (@ColumnName='ItemName')
begin
SELECT * FROM #z120 WHERE [ItemName] LIKE  @parameter1 order by ItemName DESC
end

END

DROP TABLE #z120

END

END

END
