USE [DukeLiveNew]
GO
/****** Object:  StoredProcedure [dbo].[Dispatch_DUKE_CFL_SearchOnFind]    Script Date: 02-12-2024 10:13:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER procedure [dbo].[Dispatch_DUKE_CFL_SearchOnFind] 
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
@parameter10	nvarchar(40)=null,
@parameter11	nvarchar(40)=null,




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




if(@parameter10)=''
begin
set @parameter10=NULL 
end


if(@parameter11)=''
begin
set @parameter11=NULL 
end



---------------------------------------------DOCS-------------------------------------------------

if UPPER (@mode)='get_SalesOrder'
Begin


 Select   Distinct a.DocEntry,a.DocNum,a.CardName,a.CardCode,b.City into #DOCS from ORDR(NoLock) a
 Left join CRD1(NoLock) b on a.CardCode = b.CardCode Where a.DocStatus='O';

IF(@order='ASC')
BEGIN
if (@ColumnName='' or @ColumnName='DocEntry')
begin
SELECT * FROM #DOCS WHERE DocEntry LIKE  @parameter1 order by DocEntry ASC
end

if (@ColumnName='' or @ColumnName='DocNum')
begin
SELECT * FROM #DOCS WHERE DocNum LIKE  @parameter1 order by DocNum ASC
end

if (@ColumnName='' or @ColumnName='CardName')
begin
SELECT * FROM #DOCS WHERE CardName LIKE  @parameter1 order by CardName ASC
end

if (@ColumnName='' or @ColumnName='CardCode')
begin
SELECT * FROM #DOCS WHERE CardCode LIKE  @parameter1 order by CardCode ASC
end
END


IF(@order='DESC')
BEGIN
if (@ColumnName='' or @ColumnName='DocEntry')
begin
SELECT * FROM #DOCS WHERE DocEntry LIKE  @parameter1 order by DocEntry DESC
end


if (@ColumnName='' or @ColumnName='DocNum')
begin
SELECT * FROM #DOCS WHERE DocNum LIKE  @parameter1 order by DocNum DESC
end


if (@ColumnName='' or @ColumnName='CardName')
begin
SELECT * FROM #DOCS WHERE CardName LIKE  @parameter1 order by CardName DESC
end

if (@ColumnName='' or @ColumnName='CardCode')
begin
SELECT * FROM #DOCS WHERE CardCode LIKE  @parameter1 order by CardCode DESC
end


END

DROP TABLE #DOCS
END



if UPPER (@mode)='get_Article'
Begin
select FrgnName,U_Category ,U_Color,U_Size,U_MRP, ItemCode  from OITM;

IF(@order='ASC')
BEGIN
if (@ColumnName='' or @ColumnName='FrgnName')
begin
SELECT * FROM #DOCS WHERE FrgnName LIKE  @parameter1 order by FrgnName ASC
end

if (@ColumnName='' or @ColumnName='U_Category')
begin
SELECT * FROM #DOCS WHERE U_Category LIKE  @parameter1 order by U_Category ASC
end

if (@ColumnName='' or @ColumnName='U_Color')
begin
SELECT * FROM #DOCS WHERE U_Color LIKE  @parameter1 order by U_Color ASC
end

if (@ColumnName='' or @ColumnName='U_Size')
begin
SELECT * FROM #DOCS WHERE U_Size LIKE  @parameter1 order by U_Size ASC
end

if (@ColumnName='' or @ColumnName='U_MRP')
begin
SELECT * FROM #DOCS WHERE U_MRP LIKE  @parameter1 order by U_MRP ASC
end

if (@ColumnName='' or @ColumnName='ItemCode')
begin
SELECT * FROM #DOCS WHERE ItemCode LIKE  @parameter1 order by ItemCode ASC
end
END


IF(@order='DESC')
BEGIN
if (@ColumnName='' or @ColumnName='FrgnName')
begin
SELECT * FROM #DOCS WHERE FrgnName LIKE  @parameter1 order by FrgnName DESC
end

if (@ColumnName='' or @ColumnName='U_Category')
begin
SELECT * FROM #DOCS WHERE U_Category LIKE  @parameter1 order by U_Category DESC
end

if (@ColumnName='' or @ColumnName='U_Color')
begin
SELECT * FROM #DOCS WHERE U_Color LIKE  @parameter1 order by U_Color DESC
end

if (@ColumnName='' or @ColumnName='U_Size')
begin
SELECT * FROM #DOCS WHERE U_Size LIKE  @parameter1 order by U_Size DESC
end

if (@ColumnName='' or @ColumnName='U_MRP')
begin
SELECT * FROM #DOCS WHERE U_MRP LIKE  @parameter1 order by U_MRP DESC
end

if (@ColumnName='' or @ColumnName='ItemCode')
begin
SELECT * FROM #DOCS WHERE ItemCode LIKE  @parameter1 order by ItemCode DESC
end

END

DROP TABLE #DOCS
END
----------------------------------------------------------------------------------------------------------------------------------

-----------------------Search for DOCNUM from PURCHASE ORDER SCREEN---------------------

IF upper (@mode)='OPEN_PO'						   /*--<CFL FOR DOCNUM From PURCHASE ORDER Screen--*/

BEGIN 

select  a.DocEntry,B.LineNum,a.DocNum,b.ItemCode,B.Dscription,b.OpenCreQty,b.Price,b.Quantity 
into #ITEM	from OPOR(NOLOCK) a,POR1(NOLOCK) b,NNM1(nolock) c 
where a.DocEntry=b.DocEntry AND a.DocStatus='O' AND A.CardCode=ISNULL(@parameter2,A.CardCode)
and a.Series=c.series and c.Locked='N' and b.OpenCreQty<>0.0
--AND C.SeriesName=ISNULL(@parameter3,C.SeriesName) AND B.LocCode=isnull(@parameter4,B.LocCode)


IF(@order='ASC')
BEGIN

if (@ColumnName='' or @ColumnName='DocEntry')
begin
SELECT * FROM #ITEM WHERE DocEntry LIKE  @parameter1 order by DocEntry ASC
end
if (@ColumnName='LineNum')
begin
SELECT * FROM #ITEM WHERE LineNum LIKE  @parameter1 order by LineNum ASC
end

if (@ColumnName='DocNum')
begin
SELECT * FROM #ITEM WHERE DocNum LIKE  @parameter1 order by DocNum ASC
end
if (@ColumnName='ItemCode')
begin
SELECT * FROM #ITEM WHERE ItemCode LIKE  @parameter1 order by ItemCode ASC
end

if (@ColumnName='Dscription')
begin
SELECT * FROM #ITEM WHERE Dscription LIKE  @parameter1 order by Dscription ASC
end

if (@ColumnName='OpenCreQty')
begin
SELECT * FROM #ITEM WHERE OpenCreQty LIKE  @parameter1 order by OpenCreQty ASC
end

if (@ColumnName='Price')
begin
SELECT * FROM #ITEM WHERE Price LIKE  @parameter1 order by Price ASC
end

if (@ColumnName='Quantity')
begin
SELECT * FROM #ITEM WHERE Quantity LIKE  @parameter1 order by Quantity ASC
end
END

ELSE IF(@order='DESC')
BEGIN
if (@ColumnName='' or @ColumnName='DocEntry')
begin
SELECT * FROM #ITEM WHERE DocEntry LIKE  @parameter1 order by DocEntry DESC
end
if (@ColumnName='LineNum')
begin
SELECT * FROM #ITEM WHERE LineNum LIKE  @parameter1 order by LineNum DESC
end

if (@ColumnName='DocNum')
begin
SELECT * FROM #ITEM WHERE DocNum LIKE  @parameter1 order by DocNum DESC
end

if (@ColumnName='ItemCode')
begin
SELECT * FROM #ITEM WHERE ItemCode LIKE  @parameter1 order by ItemCode DESC
end

if (@ColumnName='Dscription')
begin
SELECT * FROM #ITEM WHERE Dscription LIKE  @parameter1 order by Dscription DESC
end

if (@ColumnName='OpenCreQty')
begin
SELECT * FROM #ITEM WHERE OpenCreQty LIKE  @parameter1 order by OpenCreQty DESC
end

if (@ColumnName='Price')
begin
SELECT * FROM #ITEM WHERE Price LIKE  @parameter1 order by Price DESC
end

if (@ColumnName='Quantity')
begin
SELECT * FROM #ITEM WHERE Quantity LIKE  @parameter1 order by Quantity DESC
end

drop table #ITEM
END

END
--------------------------------item code search-----------------------------

IF upper (@mode)='get_item'						   /*--<CFL FOR DOCNUM From PURCHASE ORDER Screen--*/

BEGIN
select DocEntry,LineNum into #c from POR1 where DocEntry=@DOC

BEGIN
if (@ColumnName='DocEntry')
begin
SELECT * FROM #c WHERE DocEntry LIKE  @parameter1 order by DocEntry ASC 
end

if (@ColumnName='LineNum')
begin
SELECT * FROM #c WHERE LineNum LIKE  @parameter1 order by LineNum ASC 
end
END

IF(@order='DESC')  
BEGIN 
if (@ColumnName='DocEntry')
begin
SELECT * FROM #c WHERE DocEntry LIKE  @parameter1 order by DocEntry DESC 
end

if (@ColumnName='LineNum')
begin
SELECT * FROM #c WHERE LineNum LIKE  @parameter1 order by LineNum DESC 
end
END

DROP TABLE #c

END

--------------------------------BP CODE SEARCH-----------------------------

IF upper (@mode)='get_bp'						   /*--<CFL FOR DOCNUM From PURCHASE ORDER Screen--*/

BEGIN
select CardCode,CardName,CardType into #l
from OCRD(nolock)where  frozenFor='N'

IF(@order='ASC')  
BEGIN 
if (@ColumnName='' or @ColumnName='CardCode')
begin
SELECT * FROM #l WHERE [CardCode] LIKE  @parameter1 order by CardCode ASC
end

if (@ColumnName='CardName')
begin
SELECT * FROM #l WHERE [CardName] LIKE  @parameter1 order by CardName ASC
end

if (@ColumnName='CardType')
begin
SELECT * FROM #l WHERE [CardType] LIKE  @parameter1 order by CardType ASC
end

END

IF(@order='DESC')  
BEGIN 
if (@ColumnName='' or @ColumnName='CardCode')
begin
SELECT * FROM #l WHERE [CardCode] LIKE  @parameter1 order by CardCode DESC
end

if (@ColumnName='CardName')
begin
SELECT * FROM #l WHERE [CardName] LIKE  @parameter1 order by CardName DESC
end

if (@ColumnName='CardType')
begin
SELECT * FROM #l WHERE [CardType] LIKE  @parameter1 order by CardType DESC
end

END

DROP TABLE #l

END


--------------------------------GL account SEARCH-----------------------------

IF upper (@mode)='get_gla'						   /*--<CFL FOR DOCNUM From PURCHASE ORDER Screen--*/

BEGIN
select AcctCode,AcctName into #z
from OACT(nolock) where frozenFor='N'

IF(@order='ASC')  
BEGIN 
if (@ColumnName='' or @ColumnName='AcctCode')
begin
SELECT * FROM #z WHERE [AcctCode] LIKE  @parameter1 order by AcctCode ASC
end

if (@ColumnName='AcctName')
begin
SELECT * FROM #z WHERE [AcctName] LIKE  @parameter1 order by AcctName ASC
end
END

IF(@order='DESC')  
BEGIN 
if (@ColumnName='' or @ColumnName='AcctCode')
begin
SELECT * FROM #z WHERE [AcctCode] LIKE  @parameter1 order by AcctCode DESC
end

if (@ColumnName='AcctName')
begin
SELECT * FROM #z WHERE [AcctName] LIKE  @parameter1 order by AcctName DESC
end
END

DROP TABLE #z

END



----------------------------Search for DOCNUM from A/R credit note SCREEN------------------------------
IF upper (@mode)='OPEN_CN'						 
BEGIN 
select a.DocEntry,B.LineNum,a.DocNum,a.DocDate,a.DocType,a.ObjType,a.CardCode,a.CardName,c.SeriesName,
b.ItemCode,B.Dscription,b.Quantity,b.Price into #P	
from ORIN(NOLOCK) a,RIN1(NOLOCK) b,NNM1(nolock) c
where a.DocEntry=b.DocEntry AND a.DocStatus='O' AND DocType='I'
and a.Series=c.series and c.Locked='N'
		
SELECT D.U_BSENTRY,D.U_basetype,D.U_ITEMCODE,SUM(D.U_QUANTITY)'QTY' INTO #Q
FROM [@GE_INL](NOLOCK) D WHERE D.U_basetype='14'
GROUP BY D.U_BSENTRY,D.U_basetype,D.U_ITEMCODE

UPDATE #P SET Quantity=(Quantity-QTY)
FROM #P H,#Q D 
WHERE H.DocEntry=D.U_BSENTRY AND H.ItemCode=D.U_ITEMCODE AND H.ObjType=D.U_basetype

SELECT DISTINCT DocNum,ItemCode,Dscription,Quantity,price,DocEntry,LineNum,ObjType FROM #P 
WHERE Quantity>0.0 AND  DocNum LIKE @parameter1 and CardCode=ISNULL(@parameter2,CardCode) AND
SeriesName=ISNULL(@parameter3,SeriesName)

IF(@order='ASC')  
BEGIN 

if (@ColumnName='' or @ColumnName='DocNum')
begin
SELECT * FROM #P WHERE DocNum LIKE  @parameter1 order by DocNum ASC
end

if (@ColumnName='CardCode')
begin
SELECT * FROM #P WHERE CardCode LIKE  @parameter1 order by CardCode ASC
end

if (@ColumnName='SeriesName')
begin
SELECT * FROM #P WHERE SeriesName LIKE  @parameter1 order by SeriesName ASC
end

if (@ColumnName='DocDate')
begin
SELECT * FROM #P WHERE DocDate LIKE  @parameter1 order by DocDate ASC
end

if (@ColumnName='DocEntry')
begin
SELECT * FROM #P WHERE DocEntry LIKE  @parameter1 order by DocEntry ASC
end
END

IF(@order='DESC')  
BEGIN 

if (@ColumnName='' or @ColumnName='DocNum')
begin
SELECT * FROM #P WHERE DocNum LIKE  @parameter1 order by DocNum DESC
end

if (@ColumnName='CardCode')
begin
SELECT * FROM #P WHERE CardCode LIKE  @parameter1 order by CardCode DESC
end

if (@ColumnName='SeriesName')
begin
SELECT * FROM #P WHERE SeriesName LIKE  @parameter1 order by SeriesName DESC
end

if (@ColumnName='DocDate')
begin
SELECT * FROM #P WHERE DocDate LIKE  @parameter1 order by DocDate DESC
end

if (@ColumnName='DocEntry')
begin
SELECT * FROM #P WHERE DocEntry LIKE  @parameter1 order by DocEntry DESC
end



END

DROP TABLE #P
DROP TABLE #Q

END



IF upper (@mode)='GETDelivery'						 
BEGIN 


select Distinct A.DocNum,A.CardCode,A.CardName,B.BaseDocNum AS SalesOrderno into #GETD from ODLN A Inner join DLN1 B On A.DocEntry=B.DocEntry Where A.CANCELED !='Y'  And B.BaseEntry is not null

IF(@order='ASC')  
BEGIN 

if (@ColumnName='' or @ColumnName='DocNum')
begin
SELECT * FROM #GETD WHERE DocNum LIKE  @parameter1 order by DocNum ASC
end

if (@ColumnName='CardCode')
begin
SELECT * FROM #GETD WHERE CardCode LIKE  @parameter1 order by CardCode ASC
end

if (@ColumnName='CardName')
begin
SELECT * FROM #GETD WHERE CardName LIKE  @parameter1 order by CardName ASC
end

if (@ColumnName='SalesOrderno')
begin
SELECT * FROM #GETD WHERE SalesOrderno LIKE  @parameter1 order by SalesOrderno ASC
end


END

IF(@order='DESC')  
BEGIN 

if (@ColumnName='' or @ColumnName='DocNum')
begin
SELECT * FROM #GETD WHERE DocNum LIKE  @parameter1 order by DocNum DESC
end

if (@ColumnName='CardCode')
begin
SELECT * FROM #GETD WHERE CardCode LIKE  @parameter1 order by CardCode DESC
end

if (@ColumnName='CardName')
begin
SELECT * FROM #GETD WHERE CardName LIKE  @parameter1 order by CardName DESC
end


if (@ColumnName='SalesOrderno')
begin
SELECT * FROM #GETD WHERE SalesOrderno LIKE  @parameter1 order by SalesOrderno DESC
end



END

DROP TABLE #GETD
DROP TABLE #Q

END


-- sale Quotation




IF upper (@mode)='getItemmaster'						   /*--<CFL FOR DOCNUM From PURCHASE ORDER Screen--*/

BEGIN


Select Distinct ItemCode,ItemName,ItmsGrpCod into #z2 from OITM(nolock);

IF(@order='ASC')  
BEGIN 
if (@ColumnName='' or @ColumnName='ItemCode')
begin
SELECT * FROM #z2 WHERE [ItemCode] LIKE  @parameter1 order by ItemCode ASC
end

if (@ColumnName='ItemName')
begin
SELECT * FROM #z2 WHERE [ItemName] LIKE  @parameter1 order by ItemName ASC
end

if (@ColumnName='ItmsGrpCod')
begin
SELECT * FROM #z2 WHERE [ItmsGrpCod] LIKE  @parameter1 order by ItmsGrpCod ASC
end
END

IF(@order='DESC')  
BEGIN 
if (@ColumnName='' or @ColumnName='ItemCode')
begin
SELECT * FROM #z2 WHERE [ItemCode] LIKE  @parameter1 order by ItemCode DESC
end

if (@ColumnName='ItemName')
begin
SELECT * FROM #z2 WHERE [ItemName] LIKE  @parameter1 order by ItemName DESC
end

if (@ColumnName='ItmsGrpCod')
begin
SELECT * FROM #z2 WHERE [ItmsGrpCod] LIKE  @parameter1 order by ItmsGrpCod DESC
end
END

DROP TABLE #z2

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


IF upper (@mode)='getArticlee'						   /*--<CFL FOR DOCNUM From PURCHASE ORDER Screen--*/

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








-------


IF upper (@mode)='QuotNo'						   /*--<CFL FOR DOCNUM From PURCHASE ORDER Screen--*/

BEGIN





select DocEntry,DocNum,DocStatus,NumAtCard   into #qutat from OQUT Where DOCStatus = 'O'

IF(@order='ASC')  
BEGIN 

if (@ColumnName='' or @ColumnName='DocEntry')
begin
SELECT * FROM #qutat WHERE DocEntry LIKE  @parameter1 order by DocEntry ASC
end

if (@ColumnName='DocNum')
begin
SELECT * FROM #qutat WHERE DocNum LIKE  @parameter1 order by DocNum ASC
end

if (@ColumnName='DocStatus')
begin
SELECT * FROM #qutat WHERE DocStatus LIKE  @parameter1 order by DocStatus ASC
end


if (@ColumnName='NumAtCard')
begin
SELECT * FROM #qutat WHERE NumAtCard LIKE  @parameter1 order by NumAtCard ASC
end




IF(@order='DESC')  
BEGIN 

if (@ColumnName='' or @ColumnName='DocEntry')
begin
SELECT * FROM #qutat WHERE DocEntry LIKE  @parameter1 order by DocEntry DESC
end

if (@ColumnName='DocNum')
begin
SELECT * FROM #qutat WHERE DocNum LIKE  @parameter1 order by DocNum DESC
end

if (@ColumnName='DocStatus')
begin
SELECT * FROM #qutat WHERE DocStatus LIKE  @parameter1 order by DocStatus DESC
end

if (@ColumnName='NumAtCard')
begin
SELECT * FROM #qutat WHERE NumAtCard LIKE  @parameter1 order by NumAtCard DESC
end

END

DROP TABLE #qutat

END

END

-------








IF upper (@mode)='QuotNoCategory'						   /*--<CFL FOR DOCNUM From PURCHASE ORDER Screen--*/

BEGIN





select Distinct U_ItemCategory AS ItemCategory,U_Store AS Store,DocEntry  into #catego from QUT1 Where DocEntry = @parameter11 group by U_ItemCategory,U_Store,DocEntry ;




IF(@order='ASC')  
BEGIN 

if (@ColumnName='' or @ColumnName='ItemCategory')
begin
SELECT * FROM #catego WHERE ItemCategory LIKE  @parameter1 order by ItemCategory ASC
end

if (@ColumnName='Store')
begin
SELECT * FROM #catego WHERE Store LIKE  @parameter1 order by Store ASC
end

if (@ColumnName='DocEntry')
begin
SELECT * FROM #catego WHERE DocEntry LIKE  @parameter1 order by DocEntry ASC
end




IF(@order='DESC')  
BEGIN 

if (@ColumnName='' or @ColumnName='ItemCategory')
begin
SELECT * FROM #catego WHERE ItemCategory LIKE  @parameter1 order by ItemCategory DESC
end

if (@ColumnName='Store')
begin
SELECT * FROM #catego WHERE Store LIKE  @parameter1 order by Store DESC
end

if (@ColumnName='DocEntry')
begin
SELECT * FROM #catego WHERE DocEntry LIKE  @parameter1 order by DocEntry DESC
end

END

DROP TABLE #catego

END

END








END






