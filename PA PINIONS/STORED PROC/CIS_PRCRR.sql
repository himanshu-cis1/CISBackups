USE [PAP_LIVE_Branch]
GO
/****** Object:  StoredProcedure [dbo].[CIS_PRCRR]    Script Date: 12/11/2024 3:24:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Proc [dbo].[CIS_PRCRR]

@FromDate as Datetime ,
@Todate As Datetime 

---Execute CIS_PRCRR '2022-07-01','2022-07-31'
As
Begin 

----/* CIS_PRCRR ( Select @FromDate=T1.U_SHSD From "@TURND" T1 Where T1.U_SHSD ='[%1]',
----,Select @FromDate=T1.U_SHSD From "@TURND" T1 Where T1.U_SHSD ='[%2]') */

--Declare @FromDate as Date 
--Declare @Todate As Date 

--Select @FromDate=T1.U_SHSD From "@TURND" T1 Where T1.U_SHSD ='[%1]'
--Select @ToDate=T1.U_SHSD From "@TURND" T1 Where T1.U_SHSD ='[%2]'

--Select @FromDate=T1.U_SHSD From "@TURND" T1 Where T1.U_SHSD ='[%1]'
--Select @ToDate=T1.U_SHSD From "@TURND" T1 Where T1.U_SHSD ='[%2]'

SELECT DisTinct A.[Prod. Ord. No.], ---A.StartDate, -- A.[Receipt From Prod. No.],
--A.[Shift Start Date],
 A.Branch, A.[M/C NO.],-- A.[Inventory Transfer Date], 
 A.[Customer Code], A.[Part Name], A.[Part No.], A.[Foregin Name], 
		A.[Raw Material Code], A.[Raw Material Name],
		A.[Type of Material], A.[length of Bar],A.[Dia of bar],A.[Pcs/Bar], 
 /* CASE WHEN (A.[length of Bar] = 0.000000 or A.[Dia of bar] = 0.000000 or A.[sp gravity] = 0.0000000) then A.[Rod/Kg] 
else 1/(3.14*(A.[Dia of bar]/2)*(A.[Dia of bar]/2)* A.[length of Bar]*A.[sp gravity]/1000000) END as 'Rods per kg',*/
A.[Rod/Kg],
A.[Raw Material Price],
--A.[Rod/Kg], 
A.[Part Wt.], A.[Bar Issued (Nos.)], A.[Bar Returned (No.)], 
--		(A.[Bar Issued (Nos.)] - A.[Bar Returned (No.)]) AS [Bar Comsumed (Nos.)], 
		A.[Bar To Issue] AS [Bar Comsumed (Nos.)], 
--	FLOOR((A.[Bar Issued (Nos.)] - A.[Bar Returned (No.)]) * A.[Pcs/Bar]) AS [Prod. Acc. Bar], 
	FLOOR(A.[Bar To Issue] * A.[Pcs/Bar]) AS [Prod. Acc. Bar], 
	A.[Turning Ok Production], A.[Turning Rej. Production], A.[Quality Ok Production], A.[Quality Rejection], A.[Rate per Part], 
	(A.[Quality Ok Production] * A.[Rate per Part]) AS [Value of OK Prod.], 
	A.[Total Rejection], 
	(A.[Total Rejection] * A.[Rate per Part]) AS [Total Rejection Value], 
--(A.[Total Rejection] + A.[Quality Ok Production]) AS [Total Prod.], 
	(A.[Turning Ok Production] + A.[Turning Rej. Production]) AS [Total Prod.], 

--ISNULL(A.[Total Rejection], 0) , ISNULL(A.[Quality Ok Production], 0),

CASE WHEN (A.[Turning Ok Production] + A.[Turning Rej. Production]) = 0 THEN 0 ELSE (A.[Total Rejection] / (A.[Turning Ok Production] + A.[Turning Rej. Production]) * 100) END AS [Rej%age], 
/*
CASE WHEN A.[length of Bar] = 0  OR A.[length of Bar] = 300 or A.[Dia of bar] = 0 or A.[sp gravity] = 0 or A.[Pcs/Bar] = 0 then A.[Weight of Scrap Per Part] 
 else (1/(A.[Pcs/Bar]*(1*(1/(3.14*(A.[Dia of bar]/2)*(A.[Dia of bar]/2)*(A.[length of Bar]-300)*A.[sp gravity]/1000000)))))-A.[Part Wt.] END as 'Wt of scrap/part', */
 A.[Weight of Scrap Per Part],
/* CASE WHEN A.[length of Bar] = 0  OR A.[length of Bar] = 300 or A.[Dia of bar] = 0 or A.[sp gravity] = 0 or A.[Pcs/Bar] = 0 then A.[Weight of Scrap Per Part] 
else (1/(A.[Pcs/Bar]*(1*(1/(3.14*(A.[Dia of bar]/2)*(A.[Dia of bar]/2)*(A.[length of Bar]-300)*A.[sp gravity]/1000000)))))-A.[Part Wt.] END *(A.[Turning Ok Production] + A.[Turning Rej. Production]) as 'Scrap Wt Burada',*/
A.[Weight of Scrap Per Part] *(A.[Turning Ok Production] + A.[Turning Rej. Production]) as 'Scrap Wt Burada',
--A.[Weight of Scrap Per Part],
--(A.[Weight of Scrap Per Part] * (A.[Turning Ok Production] + A.[Turning Rej. Production])) AS [Scrap Wt. (Buradda)], 
(A.[Total Rejection] * A.[Part Wt.]) AS [Scrap Of Rej.], 
A.[Wt. Of End Piece Scrap Per Part], 
(A.[Wt. Of End Piece Scrap Per Part] * (A.[Turning Ok Production] + A.[Turning Rej. Production])) AS [Scrap Of End Piece], 
/*
((A.[Wt. Of End Piece Scrap Per Part] * (A.[Turning Ok Production] + A.[Turning Rej. Production]))
	+ (A.[Total Rejection] * A.[Part Wt.])
	+ (CASE WHEN A.[length of Bar] = 0  OR A.[length of Bar] = 300 or A.[Dia of bar] = 0 or A.[sp gravity] = 0 or A.[Pcs/Bar] = 0 then A.[Weight of Scrap Per Part] 
 else (1/(A.[Pcs/Bar]*(1*(1/(3.14*(A.[Dia of bar]/2)*(A.[Dia of bar]/2)*(A.[length of Bar]-300)*A.[sp gravity]/1000000)))))-A.[Part Wt.] END * (A.[Turning Ok Production] + A.[Turning Rej. Production]))) AS [Total Scrap],   */
((A.[Wt. Of End Piece Scrap Per Part] * (A.[Turning Ok Production] + A.[Turning Rej. Production]))
	+ (A.[Total Rejection] * A.[Part Wt.]) + A.[Weight of Scrap Per Part] * (A.[Turning Ok Production] + A.[Turning Rej. Production])) AS [Total Scrap],

--A.[Remarks Stage 1 To 2], A.[Remarks Stage 2 To 3], A.[Raw Material Price], 
(A.[Turning Ok Production] * A.[Rate per Part]) AS [Turning Production Value]
FROM
(

SELECT T5.DocNum AS 'Prod. Ord. No.', --T5.StartDate, --T0.DocNum AS 'Receipt From Prod. No.', 
T12.U_SHSD 'Shift Start Date' ,
T4.Location AS 'Branch', T5.U_Machinenam AS 'M/C NO.', 
	
	(SELECT TOP 1 T00.TaxDate FROM OWTR T00 (NOLOCK) 
		INNER JOIN WTR1 T01 (NOLOCK) ON T01.DocEntry = T00.DocEntry 
		WHERE T01.BaseEntry = T1.DocEntry AND T01.BaseType = T1.ObjType) AS 'Inventory Transfer Date', 
	
	T8.U_customercode AS 'Customer Code', T8.ItemName AS 'Part Name', T11.U_ITCD AS 'Part No.', T8.FrgnName AS 'Foregin Name', 

	(SELECT TOP 1 T00.ItemCode FROM WOR1 T00 (NOLOCK) INNER JOIN OITM T01 (NOLOCK) ON T01.ItemCode = T00.ItemCode 
		WHERE T00.DocEntry = T5.DocEntry AND T01.ItmsGrpCod = 103) AS 'Raw Material Code', 

	(SELECT TOP 1 T01.ItemName FROM WOR1 T00 (NOLOCK) INNER JOIN OITM T01 (NOLOCK) ON T01.ItemCode = T00.ItemCode 
		WHERE T00.DocEntry = T5.DocEntry AND T01.ItmsGrpCod = 103) AS 'Raw Material Name', 

	(SELECT TOP 1 T01.U_Material_Type FROM ITT1 T00 (NOLOCK) INNER JOIN OITM T01 (NOLOCK) ON T01.ItemCode = T00.Code
		WHERE T00.Father = T1.ItemCode AND T01.ItmsGrpCod = 103) AS 'Type of Material',

	(SELECT TOP 1 T00.U_Specficgravty FROM ITT1 T00 (NOLOCK) INNER JOIN OITM T01 (NOLOCK) ON T01.ItemCode = T00.Code
		WHERE T00.Father = T1.ItemCode AND T01.ItmsGrpCod = 103) AS 'sp gravity',

	(SELECT TOP 1 T00.U_totallengthofbar FROM WOR1 T00 (NOLOCK) INNER JOIN OITM T01 (NOLOCK) ON T01.ItemCode = T00.ItemCode 
		WHERE T00.DocEntry = T5.DocEntry AND T01.ItmsGrpCod = 103) AS 'length of Bar', 

	(SELECT TOP 1 T00.U_dia FROM WOR1 T00 (NOLOCK) INNER JOIN OITM T01 (NOLOCK) ON T01.ItemCode = T00.ItemCode 
		WHERE T00.DocEntry = T5.DocEntry AND T01.ItmsGrpCod = 103) AS 'Dia of Bar', 

	ISNULL((SELECT TOP 1 FLOOR(T00.U_Noofpcsbar) FROM WOR1 T00 (NOLOCK) INNER JOIN OITM T01 (NOLOCK) ON T01.ItemCode = T00.ItemCode 
				WHERE T00.DocEntry = T5.DocEntry AND T01.ItmsGrpCod = 103), 0) AS 'Pcs/Bar', 

	case when ISNULL((SELECT SUM(ISNULL(T00.U_RodPerKg, 0.000)) FROM IGE1 T00 (NOLOCK) 
				WHERE T00.BaseEntry = T5.DocEntry AND T00.BaseRef = T5.DocNum AND T00.BaseType = T5.ObjType), 0.0000) <> 0.00000 then 
             ISNULL((SELECT 1/SUM(ISNULL(T00.U_RodPerKg, 0)) FROM IGE1 T00 (NOLOCK) 
				WHERE T00.BaseEntry = T5.DocEntry AND T00.BaseRef = T5.DocNum AND T00.BaseType = T5.ObjType), 0.000)  else 0.000 end AS 'Rod/Kg',

	ISNULL((SELECT TOP 1 T00.U_Actualweightofpart FROM ITT1 T00 (NOLOCK) INNER JOIN OITM T01 (NOLOCK) ON T01.ItemCode = T00.Code
				WHERE T00.Father = T5.ItemCode AND T01.ItmsGrpCod = 103), 0) AS 'Part Wt.',

	ISNULL((SELECT SUM(ISNULL(T00.U_NoOfBar, 0)) FROM IGE1 T00 (NOLOCK) 
				WHERE T00.BaseEntry = T5.DocEntry AND T00.BaseRef = T5.DocNum AND T00.BaseType = T5.ObjType), 0) AS 'Bar Issued (Nos.)',

	ISNULL((SELECT SUM(ISNULL(T00.U_NoOfBar, 0)) FROM IGN1 T00 INNER JOIN OITM T01 (NOLOCK) ON T01.ItemCode = T00.ItemCode 
				WHERE T00.BaseEntry = T5.DocEntry AND T01.ItmsGrpCod = 103), 0) AS 'Bar Returned (No.)',

	0 AS 'Bar Comsumed (Nos.)', 
	0 AS 'Prod. Acc. Bar',

          ISNULL((Select SUM(D.U_OKPR) from [dbo].[@TURNH] A 
                                    Inner Join [dbo].[@TURND] D On A.DocEntry=D.DocEntry 
									Inner Join [dbo].[@ROTIH] B On A.U_ITCD = B.U_ITEM 
									Inner Join [dbo].[@ROTID] C On C.DocEntry=B.DocEntry And a.U_SEQU=c.LineId
                                    Where A.U_PORN=T5.DocNum And A.U_ITCD=T5.ItemCode And c.U_PRCO = 'TURNING'),0) AS 'Turning Ok Production',

           ISNULL((Select SUM(D.U_REJE)+SUM(D.U_SERE) from [dbo].[@TURNH] A 
                                    Inner Join [dbo].[@TURND] D On A.DocEntry=D.DocEntry 
									Inner Join [dbo].[@ROTIH] B On A.U_ITCD = B.U_ITEM 
									Inner Join [dbo].[@ROTID] C On C.DocEntry=B.DocEntry 
                                    Where A.U_PORN=T5.DocNum And A.U_ITCD=T5.ItemCode And a.U_SEQU=c.LineId And c.U_PRCO = 'TURNING' ),0) AS 'Turning Rej. Production',

          ISNULL((Select SUM(D.U_TOAQ) from [dbo].[@TURNH] A 
                                    Inner Join [dbo].[@TURND] D On A.DocEntry=D.DocEntry 
									Inner Join [dbo].[@ROTIH] B On A.U_ITCD = B.U_ITEM 
									Inner Join [dbo].[@ROTID] C On C.DocEntry=B.DocEntry And a.U_SEQU=c.LineId
                                    Where A.U_PORN=T5.DocNum And A.U_ITCD=T5.ItemCode And c.U_PRCO = 'QUALITY' And C.U_MPRS ='TURNING' ),0) AS 'Quality Ok Production',
/*

	ISNULL((SELECT SUM(ISNULL(T00.Quantity, 0)) FROM WTR1 T00 (NOLOCK) 
				WHERE T00.BaseEntry = T1.DocEntry AND T00.BaseType = T1.ObjType AND T00.ItemCode = T1.ItemCode AND T00.WhsCode NOT LIKE 'REJ%'), 0) AS 'Turning Ok Production', 

	ISNULL((SELECT SUM(ISNULL(T00.Quantity, 0)) FROM WTR1 T00 (NOLOCK) 
				WHERE T00.BaseEntry = T1.DocEntry AND T00.BaseType = T1.ObjType AND T00.ItemCode = T1.ItemCode AND T00.U_RoutSeq IN (2) AND T00.WhsCode LIKE 'REJ%'), 0) AS 'Turning Rej. Production', 

	ISNULL((SELECT SUM(ISNULL(T01.Quantity, 0)) FROM WTR1 T00 (NOLOCK) 
				INNER JOIN WTR1 T01 (NOLOCK) ON T01.BaseEntry = T00.DocEntry AND T01.BaseType = T00.ObjType AND T01.ItemCode = T00.ItemCode AND T01.WhsCode NOT LIKE 'REJ%'
				WHERE T00.BaseEntry = T1.DocEntry AND T00.BaseType = T1.ObjType AND T00.ItemCode = T1.ItemCode AND T00.WhsCode NOT LIKE 'REJ%'), 0) AS 'Quality Ok Production', 
				*/
	ISNULL(T2.U_CTPT, 0) AS 'Rate per Part',
	0 AS 'Value of OK Prod.',

	--ISNULL(ISNULL((SELECT SUM(ISNULL(T00.Quantity, 0)) FROM IGN1 T00 (NOLOCK) WHERE T00.BaseEntry = T1.BaseEntry AND T00.WhsCode LIKE 'REJ%'), 0) 
	--	+  ISNULL((SELECT SUM(ISNULL(T00.Quantity, 0)) FROM WTR1 T00 (NOLOCK) 
	--					WHERE T00.BlockNum = T1.BlockNum AND T00.ItemCode = T1.ItemCode AND T00.U_RoutSeq IN (2,3) AND T00.WhsCode LIKE 'REJ%'), 0)
	--	, 0) AS 'Total Rejection',
	      ISNULL((Select SUM(D.U_REQA) from [dbo].[@TURNH] A 
                                    Inner Join [dbo].[@TURND] D On A.DocEntry=D.DocEntry 
									Inner Join [dbo].[@ROTIH] B On A.U_ITCD = B.U_ITEM 
									Inner Join [dbo].[@ROTID] C On C.DocEntry=B.DocEntry And a.U_SEQU=c.LineId
                                    Where A.U_PORN=T5.DocNum And A.U_ITCD=T5.ItemCode And c.U_PRCO = 'QUALITY' And C.U_MPRS ='TURNING' ),0) AS 'Quality Rejection',
          ISNULL((Select SUM(D.U_TRAQ) from [dbo].[@TURNH] A 
                                    Inner Join [dbo].[@TURND] D On A.DocEntry=D.DocEntry 
									Inner Join [dbo].[@ROTIH] B On A.U_ITCD = B.U_ITEM 
									Inner Join [dbo].[@ROTID] C On C.DocEntry=B.DocEntry And a.U_SEQU=c.LineId
                                    Where A.U_PORN=T5.DocNum And A.U_ITCD=T5.ItemCode And c.U_PRCO = 'QUALITY' And C.U_MPRS ='TURNING' ),0) AS 'Total Rejection',

/*
	ISNULL((SELECT SUM(ISNULL(T00.Quantity, 0)) FROM WTR1 T00 (NOLOCK) 
						WHERE T00.BlockNum = T1.BlockNum AND T00.ItemCode = T1.ItemCode AND T00.U_RoutSeq IN (3) AND T00.WhsCode LIKE 'REJ%'), 0)
	 AS 'Quality Rejection',

	ISNULL((SELECT SUM(ISNULL(T00.Quantity, 0)) FROM WTR1 T00 (NOLOCK) 
						WHERE T00.BlockNum = T1.BlockNum AND T00.ItemCode = T1.ItemCode AND T00.U_RoutSeq IN (2, 3) AND T00.WhsCode LIKE 'REJ%'), 0)
	 AS 'Total Rejection',
	 */
	0 AS 'Total Rejection Value',
	0 AS 'Total Prod.',
	0 AS 'Rej%age',
	ISNULL((SELECT SUM(ISNULL(T00.U_Weightofscrappart, 0)) FROM ITT1 T00 WHERE T00.Father = T1.ItemCode), 0) AS 'Weight of Scrap Per Part',
	0 AS 'Scrap Wt. (Buradda)',
	0 AS 'Scrap Of Rej.',
	ISNULL((SELECT SUM(ISNULL(T00.U_WeightEndpieceScrap, 0)) FROM ITT1 T00 WHERE T00.Father = T1.ItemCode), 0) AS 'Wt. Of End Piece Scrap Per Part',
	0 AS 'Scrap Of End Piece',
	0 AS 'Total Scrap',

	(SELECT TOP 1 T00.Comments FROM OWTR T00 (NOLOCK) 
	        INNER JOIN WTR1 T01 (NOLOCK) ON T01.DocEntry = T00.DocEntry
		     WHERE T01.BaseEntry = T1.DocEntry AND T01.BaseType = T1.ObjType AND T01.ItemCode = T1.ItemCode AND T01.BlockNum = T1.BlockNum AND T01.WhsCode NOT LIKE 'REJ%') AS 'Remarks Stage 1 To 2',

	(SELECT TOP 1 T00.Comments FROM OWTR T00 (NOLOCK) 
	    INNER JOIN WTR1 T01 (NOLOCK) ON T01.DocEntry = T00.DocEntry
		INNER JOIN WTR1 T02 (NOLOCK) ON T02.DocEntry = T01.BaseEntry AND T02.ObjType = T01.BaseType AND T02.ItemCode = T01.ItemCode and T02.BlockNum = T01.BlockNum
		WHERE T02.BaseEntry = T1.DocEntry AND T02.BaseType = T1.ObjType AND T02.ItemCode = T1.ItemCode AND T02.BlockNum = T1.BlockNum AND T02.WhsCode NOT LIKE 'REJ%')AS 'Remarks Stage 2 To 3',

	T2.U_CTPT AS 'Stage 1 Price',

	CASE WHEN ISNULL((SELECT SUM(T00.U_NoOfPcsKg) FROM ITT1 T00 WHERE T00.Father = T5.ItemCode), 0) <> 0 THEN 
		ISNULL((ISNULL((SELECT SUM(T00.Price) FROM IGE1 T00 WHERE T00.BaseEntry = T5.DocEntry AND T00.BaseType = T5.ObjType), 0)
				/ ISNULL((SELECT SUM(T00.U_NoOfPcsKg) FROM ITT1 T00 WHERE T00.Father = T5.ItemCode), 0)
			) ,0)
	ELSE
		0
	END AS 'Raw Material Price',

	(SELECT TOP 1 ISNULL(T50.U_BarsIssue, 0) FROM WOR1 T50 WHERE T50.DocEntry = T5.DocEntry) AS [Bar To Issue]

	FROM OWOR T5 (NOLOCK)
	LEFT JOIN IGN1 T1 (NOLOCK) ON T5.DocNum = T1.BaseRef AND T5.DocEntry = T1.BaseEntry AND T5.ObjType = T1.BaseType AND T5.ItemCode = T1.ItemCode
--	LEFT JOIN OIGN T0 (NOLOCK) ON T1.DocEntry = T0.DocEntry
	LEFT JOIN "@TURNH" T11 On T11.U_PORN=T5.DocNum
	Left JOIN "@TURND" T12 On T12.DocEntry=T11.DocEntry
	Left Join [dbo].[@ROTIH] T9 On T5.ItemCode=T9.U_ITEM
	LEFT JOIN [dbo].[@ROTID] T2 On T9.DocEntry=T2.DocEntry And T11.U_SEQU=T2.LineId
	LEFT JOIN OLCT T4 (NOLOCK) ON T4.Code = T11.U_LOCA
	LEFT JOIN OITM T8 (NOLOCK) ON T8.ItemCode = T11.U_ITCD
	WHERE T2.U_PRCO = 'TURNING' ---And T5.DocNum= '222382153' 
	AND convert(varchar, T12.U_SHSD, 112) Between @FromDate And @Todate

	)A
    ORDER BY A.[Prod. Ord. No.]

End


