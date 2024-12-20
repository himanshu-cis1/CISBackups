USE [DukeLiveNew]
GO
/****** Object:  StoredProcedure [dbo].[Dispatch_DUKE_CFL]    Script Date: 02-12-2024 10:13:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure  [dbo].[Dispatch_DUKE_CFL] 
(
@mode	varchar(40),
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
@parameter12	nvarchar(40)=null,
@parameter13    nvarchar(40)=null,
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
IF (@parameter6)=''
begin
set @parameter6=NULL
end
IF (@parameter7)=''
begin
set @parameter7=NULL
end

IF (@parameter8)=''
begin
set @parameter8=NULL
end

IF (@parameter9)=''
begin
set @parameter9=NULL
end


IF (@parameter10)=''
begin
set @parameter10=NULL
end


IF (@parameter11)=''
begin
set @parameter11=NULL
end

IF (@parameter12)=''
begin
set @parameter12=NULL
end


IF (@parameter13)=''
begin
set @parameter13=NULL
end





--------------------------get bp--------------------------------
IF upper (@mode)='get_SalesOrder'						  
begin 

 Select   Distinct a.DocEntry,a.DocNum,a.CardName,a.CardCode,b.City from ORDR(Nolock) a
 Left join CRD1(NoLock) b on a.CardCode = b.CardCode Where a.DocStatus='O';

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



if UPPER (@mode)='GETDelivery'
Begin
 select Distinct A.DocNum,A.CardCode,A.CardName,B.BaseDocNum AS SalesOrderno  from ODLN A Inner join DLN1 B On A.DocEntry=B.DocEntry Where A. CANCELED !='Y'  And B.BaseEntry is not null
end



---saleQuotation

IF upper (@mode)='get_ItemGroup'						  
begin 
Select Distinct ItmsGrpCod,ItmsGrpNam from OITB;

end



IF upper (@mode)='getbin'						  
begin 
select Distinct U_BNAME AS BIN,U_SBNAME AS SBName from OITM(nolock) Where ItmsGrpCod =  @parameter5 and U_BNAME is not null;

end

IF upper (@mode)='getsubbin'						  
begin 
select Distinct U_SBNAME AS SBName ,U_BNAME AS BIN from OITM(nolock) Where U_BNAME =  @parameter2   and U_SBNAME is not null;

end

IF upper (@mode)='getItems'						  
begin 
select Distinct ItemCode,ItemName from OITM(nolock) Where U_SBNAME =  @parameter3;

end

IF upper (@mode)='getArticlee'						  
begin 
Select Distinct FrgnName Article,U_Color 'Color' from OITM Where ItmsGrpCod = @parameter6 and FrgnName is not null;

end

IF upper (@mode)='getSize'						  
begin 
Select Distinct U_SizeG 'SizeGarment' ,U_Color  from OITM Where U_Color = @parameter7 and U_SizeG is not null ;

end

IF upper (@mode)='getColor'						  
begin 
Select Distinct U_Color AS COLOR,U_SizeG 'SizeGarment'  from OITM Where FrgnName = @parameter8  and U_Color is not null;

end

IF upper (@mode)='getItems2'						  
begin 
select Distinct ItemCode,ItemName from OITM(nolock) Where U_SizeG =  @parameter9;

end






IF upper (@mode)='QuotNo'						  
begin 

select DocEntry,DocNum,DocStatus,NumAtCard from OQUT Where DOCStatus = 'O'

end


IF upper (@mode)='QuotNoCategory'						  
begin 

select Distinct U_ItemCategory AS ItemCategory,U_Store AS Store,DocEntry  from QUT1 Where DocEntry = @parameter11 group by U_ItemCategory,U_Store,DocEntry ;

end




IF upper (@mode)='SIZE'						  
begin 

select  T0.FrgnName AS Article,T0.U_SizeG AS SIZE, (T1.OnHand-T1.IsCommited) AS Availablestock from OITM T0 inner join OITW T1 on T0.Itemcode = T1.Itemcode Where     (T1.OnHand-T1.IsCommited) > '0.00' And T1.WhsCode = 'FG-HO'and  T0.FrgnName = @parameter12 AND  T0.U_SizeG != @parameter13 AND  T0.ItemCode Like '%-%'   ;

end




END
