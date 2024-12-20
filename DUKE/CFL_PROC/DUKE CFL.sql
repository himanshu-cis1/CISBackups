USE [DukeLiveNew]
GO
/****** Object:  StoredProcedure [dbo].[DUKE_CFL]    Script Date: 02-12-2024 10:14:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure  [dbo].[DUKE_CFL] 
(
@mode	varchar(40),
@parameter1	nvarchar(40)=null,
@parameter2	nvarchar(40)=null,
@parameter3	nvarchar(40)=null,
@parameter4	nvarchar(40)=null,
@parameter5	nvarchar(40)=null,
@parameter6	nvarchar(40)=null,
@ColumnName nvarchar(60)=null,
@order  nvarchar(60)=null , 
@DOC  nvarchar(60)=null 
)
as
BEGIN

if(@parameter2)=''
begin
set @parameter2=NULL
end
IF (@parameter3)=''
begin
set @parameter3=NULL
end
IF (@parameter4)=''
begin
set @parameter4=NULL
end
IF (@parameter5)=''
begin
set @parameter5=NULL
end
--------------------------get bp--------------------------------
IF upper (@mode)='get_SalesOrder'						  
begin 

 Select DocEntry,DocNum,CardName,CardCode from ORDR Where DocStatus='O';

end


--------------------------get item --------------------------------
IF upper (@mode)='get_item'		
				  
begin 
select DocEntry,LineNum from POR1 where DocEntry=@DOC
 

end

IF upper (@mode)='get_Article'	

begin 
--select FrgnName 'Article',U_Category 'Category',U_Color 'Colour',U_Size 'Size',U_MRP 'MRP', ItemCode 'EAN_Code' from OITM
 select FrgnName,U_Category ,U_Color,U_Size,U_MRP, ItemCode  from OITM;

end
--------------------------get GL account --------------------------------
IF upper (@mode)='get_gla'						  
begin 
select AcctCode,AcctName
from OACT(nolock) where frozenFor='N'

end

----------------------------------------------------------


IF upper (@mode)='OPEN_PO'						   /*--<CFL FOR DOCNUM From PURCHASE ORDER Screen--*/

BEGIN 

select a.DocEntry,B.LineNum,a.DocNum,a.DocType,a.ObjType,b.ItemCode,B.Dscription,b.OpenCreQty,b.Price,Quantity
 from OPOR(NOLOCK) a,POR1(NOLOCK) b,NNM1(nolock) c 
where a.DocEntry=b.DocEntry AND a.DocStatus='O' AND A.CardCode=ISNULL(@parameter2,A.CardCode)
and a.Series=c.series and c.Locked='N' and b.OpenCreQty<>0.0
--AND C.SeriesName=ISNULL(@parameter3,C.SeriesName) AND B.LocCode=isnull(@parameter4,B.LocCode)
END
----------------------------------------------------------
IF upper (@mode)='OPEN_CN'						   /*--<CFL FOR DOCNUM From A/R CREDIT MEMO  Screen--*/

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
WHERE Quantity>0.0 and CardCode=ISNULL(@parameter2,CardCode) AND
SeriesName=ISNULL(@parameter3,SeriesName)

DROP TABLE #P
DROP TABLE #Q

END
-----------------------------------------------DOC--------------------------------------------------------------------


if UPPER (@mode)='DocEntrys'
Begin
 select DocEntry,DocNum,U_PartyCode'CardCode',Status from [@GE_IN]
end

END
