USE [MSPLNew_Live_@25062024]
GO
/****** Object:  StoredProcedure [dbo].[CIS_EINV_ARCN]    Script Date: 12/12/2024 5:35:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER Procedure [dbo].[CIS_EINV_ARCN]
(
	 @DocEntry INTEGER
)
AS
BEGIN
	SELECT  T12."GSTRegnNo" "GSTIN", '' "Version", '' "Irn", 'GST' "Tran_TaxSch",		
			 CASE 
				WHEN T2."ImpORExp" = 'Y' THEN 'EXPWOP' ELSE 'B2B'
			END "Tran_SupTyp",'N' "Tran_RegRev", 
			
			CASE
				WHEN T0."PayToCode" = T0."ShipToCode" THEN 'REG' 
				WHEN T0."PayToCode"<>T0."ShipToCode" THEN 'SHP' 
				ELSE ''
			END "Tran_Typ", '' "Tran_EcmGstin", 'N' "Tran_IgstOnIntra", 
			
			CASE 
				WHEN T0."ObjType"= 13 AND T0."GSTTranTyp" = 'GA' THEN 'RIN'
				WHEN T0."ObjType"= 13 AND T0."GSTTranTyp" = 'GD' THEN 'DBN'
				WHEN T0."ObjType"= 14 THEN 'CRN'
				ELSE ''
			END "Doc_Typ", T0."DocNum" "Doc_No", Convert(varchar,T0."DocDate",103) As "Doc_Dt", T12."GSTRegnNo" "BillFrom_Gstin", 'Milestones Switchgears Pvt. Ltd.' "BillFrom_LglNm", 
			'Milestones Switchgears Pvt. Ltd.' "BillFrom_TrdNm", T12."Street" "BillFrom_Addr1", ISNULL(CAST(T12."Block" AS CHAR),'')+','+ISNULL(CAST(T12."Building" AS CHAR),'') "BillFrom_Addr2",
			ISNULL(T12."City",'') +', '+ISNULL((SELECT "Name" FROM OCST WHERE T12."State" = "Code" AND T12."Country" = "Country"),'') "BillFrom_Loc",
			T12."ZipCode" "BillFrom_Pin", LEFT(T12."GSTRegnNo",2) "BillFrom_Stcd", T15."E_Mail" "BillFrom_Em", T15."PortNum" "BillFrom_Ph", 
			CASE WHEN T2."ImpORExp" = 'Y'  THEN 'URP' ELSE T5.GSTRegnNo END "BillTo_Gstin", T3."CardName" "BillTo_LglNm",
			T3."CardName" "BillTo_TrdNm", 
			CASE WHEN  T2."ImpORExp" = 'Y' THEN '96' ELSE (SELECT "GSTCode" FROM OCST WHERE OCST."Code" = T2."BpStateCod" AND "Country" = T2."BpCountry") END "BillTo_Pos",
			T5."Block" "BillTo_Addr1",  T5."Street" "BillTo_Addr2", ISNULL(T5."City",'')+''+ISNULL(T7."Name",'') "BillTo_Loc", T5."ZipCode" "BillTo_Pin", 
			CASE WHEN  T2."ImpORExp" = 'Y' THEN '96' ELSE  (SELECT "GSTCode" FROM OCST WHERE OCST."Code" = T5.State AND "Country" = T5."Country") END "BillTo_Stcd", 
			(SELECT OCPR.Cellolar FROM OCPR WHERE OCPR."CardCode" = T0."CardCode" AND OCPR.CntctCode = T0.CntctCode) "BillTo_Ph", 
			(SELECT OCPR.E_MailL FROM OCPR WHERE OCPR."CardCode" = T0."CardCode" AND OCPR.CntctCode = T0.CntctCode) "BillTo_Em",
			'' "ShipFrom_Nm", '' "ShipFrom_Addr1",	'' "ShipFrom_Addr2",	'' "ShipFrom_Loc", '' "ShipFrom_Pin", '' "ShipFrom_Stcd",
			
			'' "ShipTo_Gstin",
			'' "ShipTo_LglNm",
			''  "ShipTo_TrdNm",
			'' "ShipTo_Addr1", 
			'' "ShipTo_Addr2", 
			'' "ShipTo_Loc", 
			'' "ShipTo_Pin",
			'' "ShipTo_Stcd",
			
			
			T1."VisOrder"+1 "Item_SlNo",ISNULL(T1."ItemCode",'')+''+ISNULL(T11."ItemCode",'')+''+ISNULL(T1."LegalText",'') "Item_PrdDesc",
			CASE WHEN T11."ItemClass" = 1 THEN 'Y' ELSE 'N' END "Item_IsServc", 
			CASE 
				WHEN T11."ItemClass" = 1 THEN (SELECT "ServCode" FROM OSAC WHERE T1."SacEntry" = "AbsEntry")
				WHEN T11."ItemClass" = 2 THEN REPLACE((SELECT TOP 1 OCHP.ChapterID FROM OCHP WHERE T11.ChapterID = OCHP.AbsEntry),'.','')
				ELSE ''
			END "Item_HsnCd", '' "Item_Barcde", T1."Quantity" "Item_Qty", 0 "Item_FreeQty",
			CASE 
				WHEN UPPER(T11."SalUnitMsr")  = 'BOTTLE' THEN 'BTL'
				WHEN UPPER(T11."SalUnitMsr")  = 'KGS' THEN 'KGS'
				WHEN UPPER(T11."SalUnitMsr")  = 'KGS.' THEN 'KGS'
				WHEN UPPER(T11."SalUnitMsr")  = 'LENGTH' THEN 'NOS'
				WHEN UPPER(T11."SalUnitMsr")  = 'Nos' THEN 'NOS'
				
				
				
			ELSE T11."SalUnitMsr"
			END	"Item_Unit"
			, Cast( T1."Price" as Dec(16,2)) "Item_UnitPrice", Cast((T1."Quantity"*T1."Price") as dec(15,2)) "Item_TotAmt",
			0.00   as "Item_Discount", '0' "Item_PreTaxVal",
			Cast(T1."LineTotal" as dec (15,2)) "Item_AssAmt",Cast(T1."VatPrcnt" as dec(15,2))  "Item_GstRt", 
			
			ISNULL((SELECT Cast(SUM(x."TaxSum") as dec (15,2))FROM RIN4 x WHERE x."DocEntry" = T0."DocEntry" AND x."staType" = -120 AND x."LineNum" = T1."LineNum" AND x."RelateType" = 1), 0.00)"Item_IgstAmt",
	   		ISNULL((SELECT Cast(SUM(x."TaxSum") as dec (15,2))FROM RIN4 x WHERE x."DocEntry" = T0."DocEntry" AND x."staType" = -110 AND x."LineNum" = T1."LineNum" AND x."RelateType" = 1), 0) "Item_CgstAmt",
	   		ISNULL((SELECT Cast(SUM(x."TaxSum") as dec (15,2))FROM RIN4 x WHERE x."DocEntry" = T0."DocEntry" AND x."staType" = -100 AND x."LineNum" = T1."LineNum" AND x."RelateType" = 1), 0) "Item_SgstAmt",
	   		'0' "Item_CesRt", '0' "Item_CesAmt",	'0' "Item_CesNonAdvlAmt",	'0' "Item_StateCesRt",	'0' "Item_StateCesAmt",	'0' "Item_StateCesNonAdvlAmt",	
			0 "Item_OthChrg",
	   	
	   	(cast(T1."LineTotal" as dec (15,2))+
	  	ISNULL((SELECT  Cast(SUM(x."TaxSum") as dec (15,2))FROM RIN4 x WHERE x."DocEntry" = T0."DocEntry" AND x."staType" = -100 AND x."LineNum" = T1."LineNum" AND x."RelateType" = 1), 0) + 
	    ISNULL((SELECT Cast( SUM(x."TaxSum") as dec (15,2))FROM RIN4 x WHERE x."DocEntry" = T0."DocEntry" AND x."staType" = -110 AND x."LineNum" = T1."LineNum" AND x."RelateType" = 1), 0) +
	    ISNULL((SELECT Cast(SUM(x."TaxSum") as dec (15,2))FROM RIN4 x WHERE x."DocEntry" = T0."DocEntry" AND x."staType" = -120 AND x."LineNum" = T1."LineNum" AND x."RelateType" = 1), 0) )"Item_TotItemVal",
	    
	    '' "Item_OrdLineRef",	'' "Item_OrgCntry",	'' "Item_PrdSlNo",	'' "Item_Attrib_Nm",	'' "Item_Attrib_Val",	'' "Item_Bch_Nm",	'' "Item_Bch_ExpDt",	
	    '' "Item_Bch_WrDt",
	    
	    (SELECT Cast( SUM(B."LineTotal") as dec (15,2)) FROM RIN1 B WHERE T1."DocEntry" = B."DocEntry")+
		ISNULL((SELECT cast(SUM(RIN3.LineTotal)as dec (15,2)) FROM RIN3 WHERE RIN3.ExpnsCode <> 9 AND T0.DocEntry = RIN3.DocEntry ),0) "Val_AssVal",  
	  	ISNULL((SELECT Cast( SUM(x."TaxSum")  as dec(15,2))
	  	FROM RIN4 x WHERE x."DocEntry" = T0."DocEntry" AND x."staType" = -100 ), 0) AS "Val_CgstVal", 
	
	    ISNULL((SELECT Cast( SUM(x."TaxSum")  as dec (15,2))
	    FROM RIN4 x WHERE x."DocEntry" = T0."DocEntry" AND x."staType" = -110 ), 0) AS "Val_SgstVal",
	 
	    ISNULL((SELECT Cast (SUM(x."TaxSum") as dec (15,2)) 
	    FROM RIN4 x WHERE x."DocEntry" = T0."DocEntry" AND x."staType" = -120 ), 0) AS "Val_IgstVal",
	    
	    '0' "Val_CesVal",	'0' "Val_StCesVal",	0 "Val_RndOffAmt",  T0."DocTotal" "Val_TotInvVal",   '0' "Val_TotInvValFc",	'0' "Val_Discount",	
		(SELECT SUM(RIN3.LineTotal) FROM RIN3 WHERE RIN3.ExpnsCode = 9 AND T0.DocEntry = RIN3.DocEntry ) "Val_OthChrg",	
		'' "Pay_Nm",	'' "Pay_AccDet",	'' "Pay_Mode",'' "Pay_FinInsBr",	'' "Pay_PayTerm",	'' "Pay_PayInstr",	'' "Pay_CrTrn",	'' "Pay_DirDr",	'0' "Pay_CrDay",	
	    '0' "Pay_PaidAmt",	'0' "Pay_PaymtDue",	'' "Ref_InvRm",	'' "Ref_InvStDt",	'' "Ref_InvEndDt",	'' "Ref_PrecDoc_InvNo",	
	    '' "Ref_PrecDoc_InvDt",	'' "Ref_PrecDoc_OthRefNo",	'' "Ref_Contr_RecAdvRefr",	'' "Ref_Contr_RecAdvDt",	'' "Ref_Contr_TendRefr",	
	    '' "Ref_Contr_ContrRefr",	'' "Ref_Contr_ExtRefr",	'' "Ref_Contr_ProjRefr", 
		SUBSTRING(T0."NumAtCard", 0, 16) "Ref_Contr_PORefr", 
		T0.RevRefDate "Ref_Contr_PORefDt",
	    '' "AddlDoc_Url",	'' "AddlDoc_Docs",	'' "AddlDoc_Info",	'' "Exp_ShipBNo",	'' "Exp_ShipBDt",	'' "Exp_Port",	'' "Exp_RefClm",	
	    '' "Exp_ForCur",	'' "Exp_CntCode",	'0' "Exp_ExpDuty",''	"Ewb_TransId",	'' "Ewb_TransName", 
	    --(SELECT "TrnspName" FROM OSHP WHERE T16."TransMode" = "TrnspCode")  "Ewb_TransMode",	
	   ''  "Ewb_TransMode",	
	   ''	"Ewb_Distance",	''	"Ewb_TransDocNo",	
	   ''	"Ewb_TransDocDt",	''	"Ewb_VehNo",	
	    ''	"Ewb_VehType",
	    T27."U_CDKey" "CDKey",	T27."U_EInvUsNa" "EInvUserName", T27."U_EInvPwd" "EInvPassword", 
	    T27."U_EFUserNa" "EFUserName", T27."U_EFUserPw" "EFPassword",
	    0 "GetQRImg", 1 "GetSignedInvoice",	1 "ImgSize",	'' "RefNo"
		
	FROM ORIN T0  
	INNER JOIN RIN1 T1 ON T0."DocEntry" = T1."DocEntry" 
	INNER JOIN RIN12 T2 ON T0."DocEntry" = T2."DocEntry" 
	INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
	LEFT OUTER JOIN CRD1 T5 ON T0."CardCode"  = T5."CardCode" AND T0."PayToCode" = T5."Address" AND T5."AdresType" = 'B'
	LEFT OUTER JOIN CRD1 T6 ON T0."CardCode"  = T6."CardCode" AND T0."ShipToCode" = T6."Address" AND T6."AdresType" = 'S'
	LEFT OUTER JOIN OCST T7 ON T5."State" = T7."Code" AND T5."Country" = T7."Country"
	LEFT OUTER JOIN OCST T8 ON T6."State" = T8."Code" AND T6."Country" = T8."Country"
	LEFT OUTER JOIN CRD1 T9 ON T0."ShipToCode" = T9."CardCode" AND T0."ShipToCode" = T9."Address" AND T9."AdresType" = 'S'
	LEFT OUTER JOIN OCRD T10 ON T9."CardCode" = T10."CardCode"
	LEFT OUTER JOIN OITM T11 ON T1."ItemCode" = T11."ItemCode"
	INNER JOIN OLCT T12 ON T1."LocCode" = T12."Code"
	LEFT OUTER JOIN RDR1 T13 ON T1."BaseEntry" = T13."DocEntry" AND T1."BaseLine" = T13."LineNum"
	LEFT OUTER JOIN ORDR T14 ON T13."DocEntry" = T14."DocEntry"
	LEFT OUTER JOIN OUSR T15 ON T14."UserSign" = T15."INTERNAL_K"
	--INNER JOIN RIN26 T16 ON T0."DocEntry" = T16."DocEntry"
	INNER JOIN "@CIS_OEIC" T27 ON T1."LocCode" = T27."Code"
	LEFT JOIN NNM1 S ON S.Series=T0.Series
	WHERE --T0."Series" NOT IN (SELECT "Series" FROM NNM1 WHERE "Remark" = 'TCS') AND 
	T0."DocEntry" =@DocEntry
	--AND T0."GSTTranTyp" <> '--'

--WHERE T0."DocDate" = [%0] AND T0."Series" <> '420' AND T0."GSTTranTyp" <> '--'
	
	UNION ALL
	
	SELECT DISTINCT T12."GSTRegnNo" "GSTIN", '' "Version", '' "Irn", 'GST' "Tran_TaxSch",		
			 CASE 
				WHEN T2."ImpORExp" = 'Y' THEN 'EXPWOP' ELSE 'B2B'
			END "Tran_SupTyp"
			,'N' "Tran_RegRev", 
			
			CASE
				WHEN T0."PayToCode" = T0."ShipToCode" THEN 'REG' 
				WHEN T0."PayToCode"<>T0."ShipToCode" THEN 'SHP' 
				ELSE ''
			END "Tran_Typ", '' "Tran_EcmGstin", 'N' "Tran_IgstOnIntra", 
			
			CASE 
				WHEN T0."ObjType"= 13 AND T0."GSTTranTyp" = 'GA' THEN 'RIN'
				WHEN T0."ObjType"= 13 AND T0."GSTTranTyp" = 'GD' THEN 'DBN'
				WHEN T0."ObjType"= 14 THEN 'CRN'
				ELSE ''
			END "Document Type", T0."DocNum" "Doc_No", Convert(varchar,T0."DocDate",103) As "Doc_Dt", T12."GSTRegnNo" "BillFrom_Gstin", 'Milestones Switchgears Pvt. Ltd.'"BillFrom_LglNm", 
			'Milestones Switchgears Pvt. Ltd.' "BillFrom_TrdNm", T12."Street" "BillFrom_Addr1", ISNULL(CAST(T12."Block"AS CHAR),'')+','+ISNULL(CAST(T12."Building" AS CHAR),'') "BillFrom_Addr2",
			ISNULL(T12."City",'') +', '+ISNULL((SELECT "Name" FROM OCST WHERE T12."State" = "Code" AND T12."Country" = "Country"),'') "BillFrom_Loc",
			T12."ZipCode" "BillFrom_Pin", LEFT(T12."GSTRegnNo",2) "BillFrom_Stcd", T15."E_Mail" "BillFrom_Em", T15."PortNum" "BillFrom_Ph", 
			CASE WHEN T2."ImpORExp" = 'Y' THEN 'URP' ELSE T5.GSTRegnNo END "BillTo_Gstin", T3."CardName" "BillTo_LglNm",
			T3."CardName" "BillTo_TrdNm", 
			CASE WHEN  T2."ImpORExp" = 'Y' THEN '96' ELSE (SELECT "GSTCode" FROM OCST WHERE OCST."Code" = T2."BpStateCod" AND "Country" = T2."BpCountry") END "BillTo_Pos",
			T5."Block" "BillTo_Addr1",  T5."Street" "BillTo_Addr2", ISNULL(T5."City",'')+''+ISNULL(T7."Name",'') "BillTo_Loc", T5."ZipCode" "BillTo_Pin", 
			CASE WHEN  T2."ImpORExp" = 'Y' THEN '96' ELSE  (SELECT "GSTCode" FROM OCST WHERE OCST."Code" = T5.State AND "Country" = T5."Country") END "BillTo_Stcd", 
			(SELECT OCPR.Cellolar FROM OCPR WHERE OCPR."CardCode" = T0."CardCode" AND OCPR.CntctCode = T0.CntctCode) "BillTo_Ph", 
			(SELECT OCPR.E_MailL FROM OCPR WHERE OCPR."CardCode" = T0."CardCode" AND OCPR.CntctCode = T0.CntctCode) "BillTo_Em",
			'' "ShipFrom_Nm", '' "ShipFrom_Addr1",	'' "ShipFrom_Addr2",	'' "ShipFrom_Loc", '' "ShipFrom_Pin", '' "ShipFrom_Stcd",
			
			
			'' "ShipTo_Gstin",
			'' "ShipTo_LglNm",
			''  "ShipTo_TrdNm",
			'' "ShipTo_Addr1", 
			'' "ShipTo_Addr2", 
			'' "ShipTo_Loc", 
			'' "ShipTo_Pin",
			'' "ShipTo_Stcd",

		   (SELECT MAX(RIN1."VisOrder") FROM RIN1 WHERE RIN1."DocEntry" = T0."DocEntry" )+1+ROW_NUMBER () OVER (ORDER BY T0.DocEntry) "Item_SlNo",
			(SELECT OEXD."ExpnsName" FROM OEXD WHERE T1.ExpnsCode = OEXD."ExpnsCode" )  "Item_PrdDesc",
			
			'N' "Item_IsServc", REPLACE((SELECT TOP 1 OCHP.ChapterID FROM OCHP WHERE T11.ChapterID = OCHP.AbsEntry),'.','') "Item_HsnCd", 
			'' "Item_Barcde", 1 "Item_Qty", 0 "Item_FreeQty",
			'NOS'	"Item_Unit", T1."LineTotal" "Item_UnitPrice", T1."LineTotal" "Item_TotAmt",
			0 "Item_Discount", 0 "Item_PreTaxVal",
			Cast(T1."LineTotal" as dec (15,2))"Item_AssAmt",Cast(T1."VatPrcnt" as dec(15,2))  "Item_GstRt", 
			
			ISNULL((SELECT Cast(SUM(x."TaxSum")as dec (15,2))FROM RIN4 x WHERE x."DocEntry" = T0."DocEntry" AND x."staType" = -120 AND x."LineNum" = T1."LineNum" AND x."RelateType" = 3), 0.00)"Item_IgstAmt",
	   		ISNULL((SELECT Cast(SUM(x."TaxSum") as dec (15,2))FROM RIN4 x WHERE x."DocEntry" = T0."DocEntry" AND x."staType" = -110 AND x."LineNum" = T1."LineNum" AND x."RelateType" = 3), 0) "Item_CgstAmt",
	   		ISNULL((SELECT Cast(SUM(x."TaxSum") as dec (15,2))FROM RIN4 x WHERE x."DocEntry" = T0."DocEntry" AND x."staType" = -100 AND x."LineNum" = T1."LineNum" AND x."RelateType" = 3), 0) "Item_SgstAmt",
	   		0 "Item_CesRt", 0 "Item_CesAmt",	0 "Item_CesNonAdvlAmt",	0 "Item_StateCesRt",	0 "Item_StateCesAmt",	0 "Item_StateCesNonAdvlAmt",	0 "Item_OthChrg",
	   	
	   Cast	(T1."LineTotal" as dec (15,2))+
	  	ISNULL((SELECT Cast( SUM(x."TaxSum") as dec (15,2))FROM RIN4 x WHERE x."DocEntry" = T0."DocEntry" AND x."staType" = -100 AND x."LineNum" = T1."LineNum" AND x."RelateType" = 3), 0) + 
	    ISNULL((SELECT Cast( SUM(x."TaxSum") as dec (15,2))FROM RIN4 x WHERE x."DocEntry" = T0."DocEntry" AND x."staType" = -110 AND x."LineNum" = T1."LineNum" AND x."RelateType" = 3), 0) +
	    ISNULL((SELECT Cast( SUM(x."TaxSum") as dec (15,2))FROM RIN4 x WHERE x."DocEntry" = T0."DocEntry" AND x."staType" = -120 AND x."LineNum" = T1."LineNum" AND x."RelateType" = 3), 0) "Item_TotItemVal",
	    
	    '' "Item_OrdLineRef",	'' "Item_OrgCntry",	'' "Item_PrdSlNo",	'' "Item_Attrib_Nm",	'' "Item_Attrib_Val",	'' "Item_Bch_Nm",	'' "Item_Bch_ExpDt",	
	    '' "Item_Bch_WrDt",
	    
	    (SELECT Cast(SUM(B."LineTotal") as dec(15,2)) FROM RIN1 B WHERE T1."DocEntry" = B."DocEntry")+T0."TotalExpns" "Val_AssVal",  
	  	ISNULL((SELECT Cast( SUM(x."TaxSum") as dec (15,2))  
	  	FROM RIN4 x WHERE x."DocEntry" = T0."DocEntry" AND x."staType" = -100 ), 0) AS "Val_CgstVal", 
	
	    ISNULL((SELECT  Cast(SUM(x."TaxSum") as dec(15,2)) 
	    FROM RIN4 x WHERE x."DocEntry" = T0."DocEntry" AND x."staType" = -110 ), 0) AS "Val_SgstVal",
	 
	    ISNULL((SELECT Cast (SUM(x."TaxSum") as dec (15,2)) 
	    FROM RIN4 x WHERE x."DocEntry" = T0."DocEntry" AND x."staType" = -120 ), 0) AS "Val_IgstVal",

	    '' "Val_CesVal",	'' "Val_StCesVal",	0 "Val_RndOffAmt",  T0."DocTotal" "Val_TotInvVal",
	    '' "Val_TotInvValFc",	'' "Val_Discount",	0 "Val_OthChrg",	'' "Pay_Nm",	'' "Pay_AccDet",	'' "Pay_Mode",	
	    '' "Pay_FinInsBr",	'' "Pay_PayTerm",	'' "Pay_PayInstr",	'' "Pay_CrTrn",	'' "Pay_DirDr",	'' "Pay_CrDay",	
	    '' "Pay_PaidAmt",	'' "Pay_PaymtDue",	'' "Ref_InvRm",	'' "Ref_InvStDt",	'' "Ref_InvEndDt",	'' "Ref_PrecDoc_InvNo",	
	    '' "Ref_PrecDoc_InvDt",	'' "Ref_PrecDoc_OthRefNo",	'' "Ref_Contr_RecAdvRefr",	'' "Ref_Contr_RecAdvDt",	'' "Ref_Contr_TendRefr",	
	    '' "Ref_Contr_ContrRefr",	'' "Ref_Contr_ExtRefr",	'' "Ref_Contr_ProjRefr", 
		SUBSTRING(T0."NumAtCard", 0, 16) "Ref_Contr_PORefr", 
		'' "Ref_Contr_PORefDt",
	    '' "AddlDoc_Url",	'' "AddlDoc_Docs",	'' "AddlDoc_Info",	'' "Exp_ShipBNo",	'' "Exp_ShipBDt",	'' "Exp_Port",	'' "Exp_RefClm",	
	    '' "Exp_ForCur",	'' "Exp_CntCode",	'' "Exp_ExpDuty",''	"Ewb_TransId",	'' "Ewb_TransName", 
	    --(SELECT "TrnspName" FROM OSHP WHERE T16."TransMode" = "TrnspCode")  "Ewb_TransMode",	
	   ''  "Ewb_TransMode",	
	   ''	"Ewb_Distance",	''	"Ewb_TransDocNo",	
	   ''	"Ewb_TransDocDt",	''	"Ewb_VehNo",	
	    ''	"Ewb_VehType",
	    T27."U_CDKey" "CDKey",	T27."U_EInvUsNa" "EInvUserName", T27."U_EInvPwd" "EInvPassword", 
	    T27."U_EFUserNa" "EFUserName", T27."U_EFUserPw" "EFPassword",
	    0 "GetQRImg", 1 "GetSignedInvoice",	1 "ImgSize",	'' "RefNo"    
	  	
		
	FROM ORIN T0  
	INNER JOIN RIN3 T1 ON T0."DocEntry" = T1."DocEntry"
	INNER JOIN RIN1 T17 ON T0."DocEntry" = T17."DocEntry" AND T17.VisOrder = 0 
	INNER JOIN RIN12 T2 ON T0."DocEntry" = T2."DocEntry" 
	INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
	LEFT OUTER JOIN CRD1 T5 ON T0."CardCode"  = T5."CardCode" AND T0."PayToCode" = T5."Address" AND T5."AdresType" = 'B'
	LEFT OUTER JOIN CRD1 T6 ON T0."CardCode"  = T6."CardCode" AND T0."ShipToCode" = T6."Address" AND T6."AdresType" = 'S'
	LEFT OUTER JOIN OCST T7 ON T5."State" = T7."Code" AND T5."Country" = T7."Country"
	LEFT OUTER JOIN OCST T8 ON T6."State" = T8."Code" AND T6."Country" = T8."Country"
	LEFT OUTER JOIN CRD1 T9 ON T0."ShipToCode" = T9."CardCode" AND T0."ShipToCode" = T9."Address" AND T9."AdresType" = 'S'
	LEFT OUTER JOIN OCRD T10 ON T9."CardCode" = T10."CardCode"
	LEFT OUTER JOIN OITM T11 ON T17."ItemCode" = T11."ItemCode"
	INNER JOIN OLCT T12 ON T17."LocCode" = T12."Code"
	LEFT OUTER JOIN RDR1 T13 ON T17."BaseEntry" = T13."DocEntry" AND T17."BaseLine" = T13."LineNum"
	LEFT OUTER JOIN ORDR T14 ON T13."DocEntry" = T14."DocEntry"
	LEFT OUTER JOIN OUSR T15 ON T14."UserSign" = T15."INTERNAL_K"
	--INNER JOIN RIN26 T16 ON T0."DocEntry" = T16."DocEntry"
	INNER JOIN "@CIS_OEIC" T27 ON T17."LocCode" = T27."Code"
    LEFT JOIN NNM1 S ON S.Series=T0.Series  
	WHERE ---T0."Series" NOT IN (SELECT "Series" FROM NNM1 WHERE "Remark" = 'TCS') AND T1.ExpnsCode <> 7 AND 
	T0."DocEntry" =  @DocEntry;
	--AND T0."GSTTranTyp" <> '--'

	
END
