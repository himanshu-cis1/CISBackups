USE [SHIVALIC_18_05_2024]
GO
/****** Object:  StoredProcedure [dbo].[CIS_EWAY_AR_Print]    Script Date: 13/12/2024 12:27:36 PM ******/
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


SELECT   DISTINCT
T12.GSTRegnNo AS "GSTIN",
T0.U_EBILLNO AS  "ewbNo",
YEAr(T0.DocDate) as "Year"
,MONTH(T0.DocDate) as "Month"
,T27.[U_EwCD] "CDKey",T27.[U_EInvUsNa] "EFUserName" ,
T27.[U_EInvPwd] "EFPassword", T27.U_EFUSERNAME  "EWbUserName" , T27.U_EFPASS  "EWbPassword"

FROM OINV T0 
	INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry"
	INNER JOIN OLCT T12 ON T1."LocCode" = T12."Code"
	LEFT JOIN "@CIS_OEIC" T27 ON T1."LocCode" = T27."Code"
WHERE T0."DocEntry" =@DocEntry;
END