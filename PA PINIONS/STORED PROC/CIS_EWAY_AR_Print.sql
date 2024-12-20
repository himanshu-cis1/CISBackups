USE [PAP_LIVE_Branch]
GO
/****** Object:  StoredProcedure [dbo].[CIS_EWAY_AR_Print]    Script Date: 12/11/2024 3:22:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER Procedure [dbo].[CIS_EWAY_AR_Print]
(
@DocEntry INTEGER
)



AS
BEGIN


SELECT Distinct 

T12.GSTRegnNo AS "GSTIN",
T0.U_EBILLNO AS  "ewbNo",
YEAr(T0.DocDate) as "Year"
,MONTH(T0.DocDate) as "Month"
,T27.[U_EwCD] "CDKey", T27.[U_EWEF]  "EWbUserName" ,
 T27.[U_EWEFPASS] "EWbPassword",T27.[U_EInvUsNa]"EFUserName", T27.[U_EInvPwd] "EFPassword" 




FROM OINV T0 

	INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry"

	INNER JOIN INV12 T2 ON T0."DocEntry" = T2."DocEntry"

	INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"

	LEFT OUTER JOIN CRD1 T5 ON T0."CardCode"  = T5."CardCode" AND T0."PayToCode" = T5."Address" AND T5."AdresType" = 'B'

	LEFT OUTER JOIN CRD1 T6 ON T0."CardCode"  = T6."CardCode" AND T0."ShipToCode" = T6."Address" AND T6."AdresType" = 'S'

	--LEFT OUTER JOIN CRD1 W ON T0."U_VENDOR"  = W."CardCode" AND T0."U_EwayAddress"=W."Address"  AND W."AdresType" = 'S'

	LEFT OUTER JOIN OCST T7 ON T5."State" = T7."Code" AND T5."Country" = T7."Country"

	LEFT OUTER JOIN OCST T8 ON T6."State" = T8."Code" AND T6."Country" = T8."Country"

	LEFT OUTER JOIN CRD1 T9 ON T0."ShipToCode" = T9."CardCode" AND T0."ShipToCode" = T9."Address" AND T9."AdresType" = 'S'

	LEFT OUTER JOIN OCRD T10 ON T9."CardCode" = T10."CardCode"

	LEFT OUTER JOIN OITM T11 ON T1."ItemCode" = T11."ItemCode"

	INNER JOIN OLCT T12 ON T1."LocCode" = T12."Code"

	LEFT OUTER JOIN RDR1 T13 ON T1."BaseEntry" = T13."DocEntry" AND T1."BaseLine" = T13."LineNum"

	LEFT OUTER JOIN ORDR T14 ON T13."DocEntry" = T14."DocEntry"

	LEFT OUTER JOIN OUSR T15 ON T14."UserSign" = T15."INTERNAL_K"

	INNER JOIN INV26 T16 ON T0."DocEntry" = T16."DocEntry"

	LEFT JOIN "@CIS_OEIC" T27 ON T1."LocCode" = T27."Code"

	WHERE--- T0."Series" NOT IN (SELECT "Series" FROM NNM1 WHERE "Remark" = 'TCS'

T0."DocEntry" =@DocEntry;
END