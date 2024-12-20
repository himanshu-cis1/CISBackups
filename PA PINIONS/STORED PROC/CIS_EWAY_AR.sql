USE [PAP_LIVE_Branch]
GO
/****** Object:  StoredProcedure [dbo].[CIS_EWAY_AR]    Script Date: 12/11/2024 3:21:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
		
ALTER Procedure [dbo].[CIS_EWAY_AR]
(
	@DocEntry INTEGER
)

-- Last Updated 26092021 0151

AS
BEGIN

SELECT  DISTINCT T0."U_Irn" AS "Irn",
( CASE 
				WHEN T0."TrnspCode" in ('1','2') THEN  '1'
				 																
				ELSE ''
			END) "TransMode",
			T0.U_EWGSTIN AS  "Transid"  ,
			Case When T0.U_Distance = '173209' then 2 Else 0 End AS "Distance",
			 T0."U_Transdocno" "Transdocno",'' "TransdocDt",T0."U_VehicleNo"
			
			 "Vehno",T0."U_VehType" as "Vehtype" ,

											---(Select A.CompnyName From OADM A)
											'' as "ShipFrom_Nm",

--,T12."Street" AS "ShipFrom_Addr1",
--ISNULL(T12."Block",'') +',' + Cast (ISNULL(T12."Building",'')as NVarChar) AS "ShipFrom_Addr2",
--ISNULL(T12."City",'') + ', '+ISNULL((SELECT "Name" FROM OCST WHERE T12."State" = "Code" AND T12."Country" = "Country"),'') AS "ShipFrom_Loc",
--T12."ZipCode" AS "ShipFrom_Pin",
-- LEFT(T12."GSTRegnNo",2) AS "ShipFrom_Stcd",
'' AS "ShipFrom_Addr1",
'' AS "ShipFrom_Addr2",
'' AS "ShipFrom_Loc",
'' AS "ShipFrom_Pin",
'' AS "ShipFrom_Stcd",
--T6."Street" AS "ShipTo_Addr1",ISNULL(T6."Block",'')+','+Cast(ISNULL(T6."Building",'')As NvarChar) AS "ShipTo_Addr2",
--T6."City" AS "ShipTo_Loc",
--T6."ZipCode" as "ShipTo_Pin", LEFT(T6."GSTRegnNo",2) as "ShipTo_Stcd",
--------------
CASE WHEN T1."AcctCode" = '40111001' THEN T6."Street" Else '' End AS "ShipTo_Addr1",
CASE WHEN T1."AcctCode" = '40111001' THEN ISNULL(T6."Block",'')+','+Cast(ISNULL(T6."Building",'')As NvarChar) Else '' End AS "ShipTo_Addr2",
CASE WHEN T1."AcctCode" = '40111001' THEN T6."City" Else '' End AS "ShipTo_Loc",
CASE WHEN T1."AcctCode" = '40111001' THEN T0."U_Distance" Else '' End AS "ShipTo_Pin", 
CASE WHEN T1."AcctCode" = '40111001' THEN LEFT(T0."U_EWGSTIN",2) Else '' End AS "ShipTo_Stcd",
T12.GSTRegnNo AS "GSTIN"
,T27.[U_EwCD] "CDKey",T27.[U_EInvUsNa] "EWbUserName" ,
T27.[U_EInvPwd] "EWbPassword",T27.[U_EWEF] "EFUserName",T27.[U_EWEFPASS] "EFPassword" 


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