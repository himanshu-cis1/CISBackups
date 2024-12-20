USE [Novateur]
GO
/****** Object:  StoredProcedure [dbo].[CIS_Perfoma_Invoice]    Script Date: 17/12/2024 3:29:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER Procedure [dbo].[CIS_Perfoma_Invoice] --'34'     
(        
@Docentry Integer        
)        
as        
begin      

SELECT  T0.[DocEntry]
,U_ITMNO,isnull(t0.U_TBDT,0) as "Total Order AMount"
,t0.U_DISPRC AS "GST%",Isnull(t0.U_TCS,0) AS "TCS",isnull(t0.U_DST,0) AS "Advance in", Cast(T0.[DocNum] As nvarchar) 'DocNum', T0.[Period], T0.[Canceled], T0.[UserSign], T0.[Status],b.unitMSR,
 T0.[Remark], T0.[RequestStatus], T0.[Remark], T0.[U_CUST], T0.[U_NAME], T0.[U_CNTP], T0.[U_SNO1],
  T0.[U_POS], T0.[U_BRNH], T0.[U_No], T0.[U_STS], T0.[U_PSTD], T0.[U_DLYD], T0.[U_SOD], T0.[U_BRGN],
   T0.[U_ISTY], T0.[U_SMTY], T0.[U_OWNR],  T0.[U_TBDT], T0.[U_DST], T0.[U_FRGT], 
   T0.[U_ROUN], Isnull(T0.[U_TAX],0) AS "IGST" ,T0.[U_TTL], T0.[U_SODEE], T0.[U_SLEMP], T0.[U_SLEMP], T0.[U_DocNum] 
 ,T1.[U_ITMNO], T1.[U_ITDES],T1.[U_QNTY], T1.[U_UTPR], T1.[U_DSCT], T1.[U_TXCD], T1.[U_TTLC], 
 T1.[U_WHSE], T1.[U_TXAMT], T1.[U_HSN], T1.[U_SAC], T1.[U_POSR], T1.[U_CONDT], T1.[U_EXDESC],
Isnull( T0.U_SAYBAMT,0) AS "SayAMnt",

 T1.[U_ITDEC], T1.[U_SODED],
---- Location Address Details ----
	(Select x.CompnyName From OADM x) [CompName],
	(Select x.Street from OLCT x where x.Code = b.LocCode)        [Loc Street],
	(Select x.Block from OLCT x where x.Code = b.LocCode)         [Loc Block],
	(Select x.Building from OLCT x where x.Code = b.LocCode)      [Loc Building],
	(Select x.City from OLCT x where x.Code = b.LocCode)          [Loc City],
	(Select x.ZipCode from OLCT x where x.Code = b.LocCode)       [Loc Zipcode],
	(Select x.PanNo from OLCT x where x.Code = b.LocCode)         [Loc PAN No],
	--(Select x.ExemptNo from OLCT x where x.Code = b.LocCode)      [Loc CIN No],
		
	(Select Name from OCRY where Code=T5.Country)'Loc Country Name',
    (Select Name from OCST where Code=t5.State)'Loc State Name'
    -- X2.LocGSTN,X2.LocStatCod,X2.LocStaGSTN,
    /*(case when X2.LocGSTType='2' then 'Casual Taxable Person' 
          when X2.LocGSTType='3' then 'Composition Levy'
          when X2.LocGSTType='4' then 'Government Department or PSU'
          when X2.LocGSTType='5' then 'Non Resident Taxable Person' 
          when X2.LocGSTType='1' then 'Regular/TDS/ISD'
          when X2.LocGSTType='6' then 'UN Agency or Embassy' End) 'LocGSTType'*/
		  ,T3.Street,T3.Block,T3.City,t3.ZipCode,
		  (Select Name from OCRY where Code=T3.Country)'Ship Country Name',
      (Select Name from OCST where Code=t3.State and country = t3.country)'Ship State Name',
	 (Select Ecode from OCST where Code=t3.State and country = t3.country) 'Ship To State Code',
	T4.Street AS "StreetB",T4.Block AS "BlockB",T4.City AS "CityB",t4.ZipCode AS "ZipCodeB",
		  (Select Name from OCRY where Code=T4.Country)'Ship Country Name',
    (Select Name from OCST where Code=t4.State and Country = t4.Country)'Ship State Name',T7.Name,T7.Cellolar,T7.E_Maill,
	(Select Ecode from OCST where Code=t4.State and Country = t4.Country) 'Bill To State Code',
	   ISNULL((Select (case when  sum(x.RvsChrgTax)<=0  then sum(x.TaxSum)/a.DocRate else 0 end) From RDR4 x Where x.DocEntry = a.DocEntry and x.staType = -100 and x.LineNum = b.LineNum and x.RelateType = 1),0) [CGSTAmt], 
       ISNULL((Select (case when  sum(x.RvsChrgTax)<=0  then sum(x.TaxSum)/a.DocRate else 0 end) From RDR4 x Where x.DocEntry = a.DocEntry and x.staType = -110 and x.LineNum = b.LineNum and x.RelateType = 1),0) [SGSTAmt],
       ISNULL((Select (case when  sum(x.RvsChrgTax)<=0  then sum(x.TaxSum)/a.DocRate else 0 end) From RDR4 x Where x.DocEntry = a.DocEntry and x.staType = -120 and x.LineNum = b.LineNum and x.RelateType = 1),0) [IGSTAmt],
	    ISNULL((Select (case when  sum(x.RvsChrgTax)<=0  then sum(x.TaxSum)/a.DocRate else 0 end) From RDR4 x Where x.DocEntry = a.DocEntry and x.staType = -150 and x.LineNum = b.LineNum and x.RelateType = 1),0) [UTGSTAmt],
		ISNULL((Select (case when  sum(x.RvsChrgTax)<=0  then sum(x.TaxSum)/a.DocRate else 0 end) From RDR4 x Where x.DocEntry = a.DocEntry and x.staType = 9 and x.LineNum = b.LineNum and x.RelateType = 1),0) [TCSAmt],


       ISNULL((Select distinct (case when  sum(x.RvsChrgTax)<=0  then  x.TaxRate else 0 end ) From RDR4 x Where x.DocEntry = a.DocEntry and x.staType = -100 and x.LineNum = b.LineNum and x.RelateType = 1 group by X.TaxRate),0) [CGSTRate], 
       ISNULL((Select distinct (case when  sum(x.RvsChrgTax)<=0  then x.TaxRate else 0 end ) From RDR4 x Where x.DocEntry = a.DocEntry and x.staType = -110 and x.LineNum = b.LineNum and x.RelateType = 1 group by X.TaxRate),0) [SGSTRate],
       ISNULL((Select distinct (case when  sum(x.RvsChrgTax)<=0  then x.TaxRate else 0 end ) From RDR4 x Where x.DocEntry = a.DocEntry and x.staType = -120 and x.LineNum = b.LineNum and x.RelateType = 1 group by X.TaxRate),0) [IGSTRate],
	   ISNULL((Select distinct (case when  sum(x.RvsChrgTax)<=0  then x.TaxRate else 0 end ) From RDR4 x Where x.DocEntry = a.DocEntry and x.staType = -150 and x.LineNum = b.LineNum and x.RelateType = 1 group by X.TaxRate),0) [UTGSTRate],
	   ISNULL((Select distinct (case when  sum(x.RvsChrgTax)<=0  then x.TaxRate else 0 end ) From RDR4 x Where x.DocEntry = a.DocEntry and x.staType = 9 and x.LineNum = b.LineNum and x.RelateType = 1 group by X.TaxRate),0) [TCS Rate],


       ISNULL((Select Sum(x.RvsChrgTax)/a.DocRate From RDR4 x Where x.DocEntry = a.DocEntry and x.staType = -100 and x.LineNum = b.LineNum and x.RelateType = 1),0) [RevsCGST], 
       ISNULL((Select Sum(x.RvsChrgTax)/a.DocRate From RDR4 x Where x.DocEntry = a.DocEntry and x.staType = -110 and x.LineNum = b.LineNum and x.RelateType = 1),0) [RevsSGST],
       ISNULL((Select Sum(x.RvsChrgTax)/a.DocRate From RDR4 x Where x.DocEntry = a.DocEntry and x.staType = -120 and x.LineNum = b.LineNum and x.RelateType = 1),0) [RevsIGST],
	   ISNULL((Select Sum(x.RvsChrgTax)/a.DocRate From RDR4 x Where x.DocEntry = a.DocEntry and x.staType = -150 and x.LineNum = b.LineNum and x.RelateType = 1),0) [RevsUTGST],


	  ISNULL((select top 1 (case when  sum(n.RvsChrgTax)<=0  then  n.TaxRate else 0 end )  
	  from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-100 and n.ExpnsCode=2 group by n.TaxRate),0)'CGSTFreightRate',
      ISNULL((select top 1 (case when  sum(n.RvsChrgTax)<=0  then  n.TaxRate else 0 end )  from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-110 and n.ExpnsCode=2 group by n.TaxRate),0)'SGSTFreightRate',
	  ISNULL((select top 1 (case when  sum(n.RvsChrgTax)<=0  then  n.TaxRate else 0 end )   from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-120 and n.ExpnsCode=2
	   group by n.TaxRate),0)'IGSTFreightRate',
	  ISNULL((select top 1 (case when  sum(n.RvsChrgTax)<=0  then  n.TaxRate else 0 end )   from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-150 and n.ExpnsCode=2 group by n.TaxRate),0)'UTGSTFreightRate',


	  ISNULL((select  (case when  sum(n.RvsChrgTax)<=0  then sum(n.TaxSum)/a.DocRate else 0 end)  from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-100 and n.ExpnsCode=2),0)'CGSTFreight',
      ISNULL((select  (case when  sum(n.RvsChrgTax)<=0  then sum(n.TaxSum)/a.DocRate else 0 end)   from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-110 and n.ExpnsCode=2),0)'SGSTFreight',
	  ISNULL((select  (case when  sum(n.RvsChrgTax)<=0  then sum(n.TaxSum)/a.DocRate else 0 end)   from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-120 and n.ExpnsCode=2),0)'IGSTFreight',
	  ISNULL((select  (case when  sum(n.RvsChrgTax)<=0  then sum(n.TaxSum)/a.DocRate else 0 end)   from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-150 and n.ExpnsCode=2),0)'UTGSTFreight',

	  ISNULL((select top 1 (case when  sum(n.RvsChrgTax)<=0  then  n.TaxRate else 0 end )  from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-100 and n.ExpnsCode=4 group by n.TaxRate),0)'CGSTPackingRate',
      ISNULL((select top 1 (case when  sum(n.RvsChrgTax)<=0  then  n.TaxRate else 0 end )  from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-110 and n.ExpnsCode=4 group by n.TaxRate),0)'SGSTPackingRate',
	  ISNULL((select top 1 (case when  sum(n.RvsChrgTax)<=0  then  n.TaxRate else 0 end )  from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-120 and n.ExpnsCode=4 group by n.TaxRate),0)'IGSTPackingRate',
	   ISNULL((select top 1 (case when  sum(n.RvsChrgTax)<=0  then  n.TaxRate else 0 end )  from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-150 and n.ExpnsCode=4 group by n.TaxRate),0)'UTGSTPackingRate',

	  ISNULL((select  (case when  sum(n.RvsChrgTax)<=0  then sum(n.TaxSum)/a.DocRate else 0 end)   from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-100 and n.ExpnsCode=4),0)'CGSTPacking',
      ISNULL((select  (case when  sum(n.RvsChrgTax)<=0  then sum(n.TaxSum)/a.DocRate else 0 end)   from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-110 and n.ExpnsCode=4),0)'SGSTPacking',
	  ISNULL((select  (case when  sum(n.RvsChrgTax)<=0  then sum(n.TaxSum)/a.DocRate else 0 end)  from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-120 and n.ExpnsCode=4),0)'IGSTPacking',
	  ISNULL((select  (case when  sum(n.RvsChrgTax)<=0  then sum(n.TaxSum)/a.DocRate else 0 end)  from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-150 and n.ExpnsCode=4),0)'UTGSTPacking',

	  ISNULL((select top 1 (case when  sum(n.RvsChrgTax)<=0  then  n.TaxRate else 0 end )  from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-100 and n.ExpnsCode=3 group by n.TaxRate),0)'CGSTInsuranceRate',
      ISNULL((select top 1 (case when  sum(n.RvsChrgTax)<=0  then  n.TaxRate else 0 end )  from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-110 and n.ExpnsCode=3 group by n.TaxRate),0)'SGSTInsuranceRate',
	  ISNULL((select top 1 (case when  sum(n.RvsChrgTax)<=0  then  n.TaxRate else 0 end )  from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-120 and n.ExpnsCode=3 group by n.TaxRate),0)'IGSTInsuranceRate',
	  ISNULL((select top 1 (case when  sum(n.RvsChrgTax)<=0  then  n.TaxRate else 0 end )  from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-150 and n.ExpnsCode=3 group by n.TaxRate),0)'UTGSTInsuranceRate',

	  ISNULL((select  (case when  sum(n.RvsChrgTax)<=0  then sum(n.TaxSum)/a.DocRate else 0 end)   from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-100 and n.ExpnsCode=3),0)'CGSTInsurance',
      ISNULL((select  (case when  sum(n.RvsChrgTax)<=0  then sum(n.TaxSum)/a.DocRate else 0 end)   from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-110 and n.ExpnsCode=3),0)'SGSTInsurance',
	  ISNULL((select  (case when  sum(n.RvsChrgTax)<=0  then sum(n.TaxSum)/a.DocRate else 0 end)   from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-120 and n.ExpnsCode=3),0)'IGSTInsurance',
	  ISNULL((select  (case when  sum(n.RvsChrgTax)<=0  then sum(n.TaxSum)/a.DocRate else 0 end)   from RDR4 n left join RDR3 b on n.DocEntry=b.DocEntry and n.ExpnsCode=b.ExpnsCode where n.DocEntry=a.docentry and n.staType=-150 and n.ExpnsCode=3),0)'UTGSTInsurance',

IsNull((select   sum(n.LineTotal) from RDR3 n  where n.DocEntry=a.DocEntry  and n.ExpnsCode=2),0) 'Freightbase',
IsNull((select   sum(n.LineTotal) from RDR3 n  where n.DocEntry=a.DocEntry  and n.ExpnsCode=3),0) 'Insurbase',
IsNull((select   sum(n.LineTotal) from RDR3 n  where n.DocEntry=a.DocEntry  and n.ExpnsCode=4),0) 'Packbase',

(SELECT distinct T0.[SacCode] FROM OEXD T0  INNER JOIN RDR4 T1 ON T0.[ExpnsCode] = T1.[ExpnsCode]  WHERE T0.[ExpnsCode] ='2' and T1.DocEntry=a.DocEntry)'FreightSacCode',
(SELECT distinct T0.[SacCode] FROM OEXD T0  INNER JOIN RDR4 T1 ON T0.[ExpnsCode] = T1.[ExpnsCode] WHERE T0.[ExpnsCode] ='4' and T1.DocEntry=a.DocEntry)'PackSacCode',
(SELECT distinct T0.[SacCode] FROM OEXD T0  INNER JOIN RDR4 T1 ON T0.[ExpnsCode] = T1.[ExpnsCode] WHERE T0.[ExpnsCode] ='3' and T1.DocEntry=a.DocEntry)'InsuSacCode',

ISNULL((Select x.RvsChrgPrc From RDR4 x Where x.DocEntry = a.DocEntry and x.staType = -100 and x.LineNum = b.LineNum and x.RelateType = 1),0) [RevsCGSTPrc], 
ISNULL((Select x.RvsChrgPrc From RDR4 x Where x.DocEntry = a.DocEntry and x.staType = -110 and x.LineNum = b.LineNum and x.RelateType = 1),0) [RevsSGSTPrc],
ISNULL((Select x.RvsChrgPrc From RDR4 x Where x.DocEntry = a.DocEntry and x.staType = -120 and x.LineNum = b.LineNum and x.RelateType = 1),0) [RevsIGSTPrc],
ISNULL((Select x.RvsChrgPrc From RDR4 x Where x.DocEntry = a.DocEntry and x.staType = -150 and x.LineNum = b.LineNum and x.RelateType = 1),0) [RevsUTGSTPrc]
,T3.GSTRegnNo'ShiptoGst',T4.GSTRegnNo'Bill to Gst',T5.GSTRegnNo'Loc Gst',t3.CardCode,t4.CardCode AS "Bcar",K.Cardname,l.CardName 'CradnameB'
,t8.InvntryUom,t0.U_PAYME,t0.U_FRGT,t0.U_PACHR,t0.U_ADTAXPER,T0.U_PACPER,t0.U_TOTAXAMT,t0.U_TOTTAX,t0.U_TTL,t0.U_ADREC,t0.U_SAYBAMT

FROM [dbo].[@PRINHH]  T0
inner Join [@PRINDD] t1 on t1.DocEntry = T0.DocEntry
Left Join RDR1 b On b.DocEntry= t1.U_SODED And T1.U_ITMNO = b.ItemCode and t1.VisOrder = b.LineNum
Inner Join ORDR a On a.DocEntry = T0.[U_SODEE] 
LEFT  Join CRD1 T3 On T3.CardCode = a.CardCode And a.ShipToCode=T3.Address And T3.AdresType='S'
left joIn ocrd k on k.Cardcode = t3.CardcOde
LEFT Join CRD1 T4 On T4.CardCode = a.CardCode And a.PayToCode=T4.Address And T4.AdresType='B'
leFt join ocrd l on l.cardcoDE = t4.caRdcodE
LEFT Join OLCT T5 On b.LocCode=T5.Code
LEFT Join OCPR T7 ON T7.CardCode=a.CardCode And T7.CntctCode=a.CntctCode
Left join OITM t8 on t8.ItemCode = t1.U_ITMNO

Where T0.Docentry= @Docentry



      

END 