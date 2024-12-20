USE [DukeLiveNew]
GO
/****** Object:  StoredProcedure [dbo].[GE_CFL]    Script Date: 02-12-2024 10:15:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure  [dbo].[GE_CFL] 
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
IF upper (@mode)='get_bp'						  
begin 
--select CardCode,CardName,CardType
--from OCRD(nolock)where  frozenFor='N'

select "CardCode","CardName","CardType"
from "OCRD" where  "frozenFor"='N';
 

end


--------------------------get item --------------------------------
IF upper (@mode)='get_item'						  
begin 
select DocEntry,LineNum from POR1 where DocEntry=@DOC

--select "DocEntry","LineNum" from "POR1" where "DocEntry"=@DOC;
 

end
--------------------------get GL account --------------------------------
IF upper (@mode)='get_gla'						  
begin 
select AcctCode,AcctName
from OACT(nolock) where frozenFor='N'


--select "AcctCode","AcctName" from "OACT" where "FrozenFor"='N' ;

end

----------------------------------------------------------


IF upper (@mode)='OPEN_PO'						   /*--<CFL FOR DOCNUM From PURCHASE ORDER Screen--*/

BEGIN 

select a.DocEntry,B.LineNum,a.DocNum,a.DocType,a.ObjType,b.ItemCode,B.Dscription,b.OpenCreQty,b.U_Article AS Article,b.U_Size As Size,U_Color AS Color 
 from OPOR(NOLOCK) a,POR1(NOLOCK) b,NNM1(nolock) c 
where a.DocEntry=b.DocEntry AND a.DocStatus='O' AND A.CardCode=ISNULL(@parameter2,A.CardCode)
and a.Series=c.series and c.Locked='N' and (Select SUM(bb."Quantity") From "POR1" bb WHERE bb."DocEntry"=a."DocEntry" and bb."LineNum"=b."LineNum" )
	>(select ISNULL( SUM(P."U_ACTQTY"),0.00) from "@GE_INL" P
	LEFT Join "@GE_IN"  Q ON Q."DocEntry"=P."DocEntry"
	WHERE B."DocEntry"= P."U_bsentry" and p."U_baseline"=b."LineNum" );--b.OpenCreQty<>0.0
--AND C.SeriesName=ISNULL(@parameter3,C.SeriesName) AND B.LocCode=isnull(@parameter4,B.LocCode)

------HANA----------

--select a."DocEntry",B."LineNum",a."DocNum",a."DocType",a."ObjType",b."ItemCode",B."Dscription",b."OpenCreQty",b."Price",b."Quantity"
-- from "OPOR" a,"POR1" b,"NNM1" c 
--where a."DocEntry"=b."DocEntry" 
--AND a."DocStatus"='O' AND A."CardCode"=ISNULL(@parameter2,A."CardCode")
--and a."Series"=c."Series" 
-- and c."Locked"='N' 

-- and 
--	(Select SUM(bb."Quantity") From "POR1" bb WHERE bb."DocEntry"=a."DocEntry" and bb."LineNum"=b."LineNum" )
--	>(select ISNULL( SUM(P."U_ACTQTY"),0.00) from "@GE_INL" P
--	LEFT Join "@GE_IN"  Q ON Q."DocEntry"=P."DocEntry"
--	WHERE B."DocEntry"= P."U_bsentry" and p."U_baseline"=b."LineNum" );
--AND C.SeriesName=ISNULL(@parameter3,C.SeriesName) AND B.LocCode=isnull(@parameter4,B.LocCode)

--- END HANA--------------------

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






UPDATE H SET Quantity=(Quantity-QTY)
FROM #P H,#Q D 
WHERE H.DocEntry=D.U_BSENTRY AND H.ItemCode=D.U_ITEMCODE AND H.ObjType=D.U_basetype





SELECT DISTINCT DocNum,ItemCode,Dscription,Quantity,price,DocEntry,LineNum,ObjType FROM #P 
WHERE Quantity>0.0 and CardCode=ISNULL(@parameter2,CardCode) AND
SeriesName=ISNULL(@parameter3,SeriesName)



DROP TABLE #P
DROP TABLE #Q


----HANA---------------


--CREATE LOCAL TEMPORARY TABLE #P
--		(
--		DocEntry       NVARCHAR(100),
--		LineNum     NVARCHAR(100),
--		DocNum		NVARCHAR(100),
--		DocDate     NVARCHAR(100),
--		DocType NVARCHAR(100),
--		ObjType   NVARCHAR(100),
--		CardCode  NVARCHAR(100),
--		CardName  NVARCHAR(100),
--		SeriesName NVARCHAR(100),
--		ItemCode  NVARCHAR(100),
--		Dscription  NVARCHAR(100),
--		Quantity  NVARCHAR(100),
--		Price  NVARCHAR(100)
--		);
		
		
--		INSERT INTO #P
--		(
--		DocEntry,  
--		LineNum,
--		DocNum,
--		DocDate,
--		DocType,
--		ObjType,
--		CardCode,
--		CardName,
--		SeriesName,
--		ItemCode,
--		Dscription,
--		Quantity,
--		Price	
--       )
       
--       select a."DocEntry",B."LineNum",a."DocNum",a."DocDate",a."DocType",a."ObjType",a."CardCode",a."CardName",c."SeriesName",
--b."ItemCode",B."Dscription",b."Quantity",b."Price" 
--from "ORIN" a,"RIN1" b,"NNM1" c
--where a."DocEntry"=b."DocEntry" AND a."DocStatus"='O' AND "DocType"='I'
--and a."Series"=c."Series" and c."Locked"='N';


--CREATE LOCAL TEMPORARY TABLE #Q
--		(
--		U_BSENTRY       NVARCHAR(100),
--		U_basetype     NVARCHAR(100),
--		U_ITEMCODE		NVARCHAR(100),
--		QTY     NVARCHAR(100)
		
--		);
		
		
--		INSERT INTO #Q
--		(
--		U_BSENTRY,  
--		U_basetype,
--		U_ITEMCODE,
--		QTY
		
--       )
       
--    --select * from "@GE_IN"
		
--SELECT D."U_bsentry",D."U_basetype",D."U_ItemCode",SUM(D."U_Quantity")"QTY" 
--FROM "@GE_INL" D WHERE D."U_basetype"='14'
--GROUP BY D."U_bsentry",D."U_basetype",D."U_ItemCode";


--UPDATE H SET Quantity=(Quantity-"QTY")
--FROM #P H,#Q D 
--WHERE H.DocEntry=D.U_bsentry AND H.ItemCode=D.U_ITEMCODE AND H.ObjType=D.U_basetype;

--SELECT DISTINCT DocNum,ItemCode,Dscription,Quantity,price,DocEntry,LineNum,ObjType FROM #P 
--WHERE Quantity>0.0 and CardCode=IFNULL(PARA2,CardCode) AND
--SeriesName=IFNULL(PARA3,SeriesName);


--DROP TABLE #P;
--DROP TABLE #Q;


-- END HANA-----------------------------------



END
-----------------------------------------------DOC--------------------------------------------------------------------


if UPPER (@mode)='DocEntrys'
Begin
 select DocEntry,DocNum,U_PartyCode'CardCode',Status from [@GE_IN]

 


end

END

/*Minimum no of column is 3 in CFL*/

