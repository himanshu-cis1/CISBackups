USE [DukeLiveNew]
GO
/****** Object:  StoredProcedure [dbo].[BarCode_CFL_SearchOnFind]    Script Date: 02-12-2024 10:12:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[BarCode_CFL_SearchOnFind] 
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

if UPPER (@mode)='DocEntrys'
Begin
select DocEntry,DocNum,U_PartyCode'CardCode',Status into #DOCS from [@GE_IN]

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

if (@ColumnName='' or @ColumnName='CardCode')
begin
SELECT * FROM #DOCS WHERE CardCode LIKE  @parameter1 order by CardCode ASC
end

if (@ColumnName='' or @ColumnName='Status')
begin
SELECT * FROM #DOCS WHERE Status LIKE  @parameter1 order by Status ASC
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

if (@ColumnName='' or @ColumnName='CardCode')
begin
SELECT * FROM #DOCS WHERE CardCode LIKE  @parameter1 order by CardCode DESC
end

if (@ColumnName='' or @ColumnName='Status')
begin
SELECT * FROM #DOCS WHERE Status LIKE  @parameter1 order by Status DESC
end
END

DROP TABLE #DOCS
END
----------------------------------------------------------------------------------------------------------------------------------

-----------------------Search for DOCNUM from PURCHASE ORDER SCREEN---------------------

IF upper (@mode)='get_Article'						   /*--<CFL FOR DOCNUM From PURCHASE ORDER Screen--*/

BEGIN 

select FrgnName,U_Category ,U_Color,U_Size,U_MRP, ItemCode  into #ITEM   from OITM;


IF(@order='ASC')
BEGIN

if (@ColumnName='' or @ColumnName='FrgnName')
begin
SELECT * FROM #ITEM WHERE FrgnName LIKE  @parameter1 order by FrgnName ASC
end
if (@ColumnName='U_Category')
begin
SELECT * FROM #ITEM WHERE U_Category LIKE  @parameter1 order by U_Category ASC
end

if (@ColumnName='U_Color')
begin
SELECT * FROM #ITEM WHERE U_Color LIKE  @parameter1 order by U_Color ASC
end
if (@ColumnName='U_Size')
begin
SELECT * FROM #ITEM WHERE U_Size LIKE  @parameter1 order by U_Size ASC
end

if (@ColumnName='U_MRP')
begin
SELECT * FROM #ITEM WHERE U_MRP LIKE  @parameter1 order by U_MRP ASC
end

if (@ColumnName='ItemCode')
begin
SELECT * FROM #ITEM WHERE ItemCode LIKE  @parameter1 order by ItemCode ASC
end

END

ELSE IF(@order='DESC')
BEGIN
if (@ColumnName='' or @ColumnName='FrgnName')
begin
SELECT * FROM #ITEM WHERE FrgnName LIKE  @parameter1 order by FrgnName DESC
end
if (@ColumnName='U_Category')
begin
SELECT * FROM #ITEM WHERE U_Category LIKE  @parameter1 order by U_Category DESC
end

if (@ColumnName='U_Color')
begin
SELECT * FROM #ITEM WHERE U_Color LIKE  @parameter1 order by U_Color DESC
end
if (@ColumnName='U_Size')
begin
SELECT * FROM #ITEM WHERE U_Size LIKE  @parameter1 order by U_Size DESC
end

if (@ColumnName='U_MRP')
begin
SELECT * FROM #ITEM WHERE U_MRP LIKE  @parameter1 order by U_MRP DESC
end

if (@ColumnName='ItemCode')
begin
SELECT * FROM #ITEM WHERE ItemCode LIKE  @parameter1 order by ItemCode DESC
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
END






