USE [Novateur]
GO
/****** Object:  StoredProcedure [dbo].[CIS_PROC_RM_Forecast_Report]    Script Date: 17/12/2024 3:31:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[CIS_PROC_RM_Forecast_Report] 
(
	@FromDate VARCHAR(20)
  , @ToDate VARCHAR(20)
)
AS
BEGIN

	DECLARE @SQL VARCHAR(MAX) = ''
	DECLARE @SONos VARCHAR(MAX) = ''

	CREATE TABLE #Temp_SODetails (SONo VARCHAR(100), SODE INT, SODate DATETIME, CardCode VARCHAR(100), CardName VARCHAR(300), ItemCode VARCHAR(100) COLLATE DATABASE_DEFAULT
								, ItemName VARCHAR(400), CatRefNo VARCHAR(100)
								, SOQty DECIMAL(19, 3), SOOpenQty DECIMAL(19, 3))

	CREATE TABLE #Temp_ProdDetails (PrdNo INT, PrdDE INT, PlanQty DECIMAL(19, 6) , RMCode VARCHAR(100)  COLLATE DATABASE_DEFAULT, RMName VARCHAR(400)
								   , RM_Plan_Qty DECIMAL(19, 3), RM_Issued_Qty DECIMAL(19, 3), RM_Req DECIMAL(19, 3))

	CREATE TABLE #Temp_ForecastReport (SONo VARCHAR(100), SODE INT, SODate DATETIME, CardCode VARCHAR(100), CardName VARCHAR(300), ItemCode VARCHAR(100)
								      , ItemName VARCHAR(400), CatRefNo VARCHAR(100), RMPartyRefNo VARCHAR(100)
								      , Manufacturer VARCHAR(100)
								      , SOQty DECIMAL(19, 3), SOOpenQty DECIMAL(19, 3)
									  , PrdNo INT, PrdDE INT, PlanQty DECIMAL(19, 6), RMCode VARCHAR(100), RMName VARCHAR(400), RM_Plan_Qty DECIMAL(19, 3)
									  , RM_Issued_Qty DECIMAL(19, 3), RM_Req DECIMAL(19, 3), RM_Excess_Issue DECIMAL(19, 3))


	INSERT INTO #Temp_SODetails (SONo, SODE, SODate, CardCode, CardName, ItemCode, ItemName, SOQty, SOOpenQty)
	SELECT CAST(T0.DocNum AS VARCHAR) + '/ ' 
	 + CASE WHEN ISNULL(T0.U_JOBno, '') <> '' THEN ISNULL(T0.U_JOBno, '')  ELSE '' END SNo
	-- + '/ '  + CASE WHEN ISNULL(T3.U_RMPartyNO, '') <> '' THEN ISNULL(T3.U_RMPartyNO, '')  ELSE '' END SNo
	, T0.DocEntry, T0.DocDate, T0.CardCode, T0.CardName, T1.ItemCode, T3.ItemName
	, SUM(ISNULL(T1.Quantity, 0.00)) Quantity, SUM(ISNULL(T1.OpenQty, 0.0)) OpenQty
	FROM ORDR (NOLOCK) T0
	INNER JOIN RDR1 (NOLOCK) T1 ON T0.DocEntry = T1.DocEntry
--	INNER JOIN OWOR (NOLOCK) T2 ON T1.DocEntry = T2.OriginAbs AND T1.ItemCode = T2.ItemCode
	INNER JOIN OITM (NOLOCK) T3 ON T1.ItemCode = T3.ItemCode
	WHERE ISNULL(T1.OpenQty, 0.00) > 0
	AND CONVERT(VARCHAR, T0.DocDate, 112) BETWEEN @FromDate AND @ToDate
	AND T1.LineStatus = 'O' AND T0.DocStatus = 'O'
	GROUP BY T0.DocNum, T0.DocEntry, T0.DocDate, T0.CardCode, T0.CardName, T1.ItemCode, T3.ItemName, T0.U_JOBno
	, T3.U_RMPartyNO

	INSERT INTO #Temp_ForecastReport (SONo, SODE, SODate, CardCode, CardName, ItemCode, ItemName, SOQty, SOOpenQty
										--, PrdNo, PrdDE
								     , PlanQty, RMCode, RMName, CatRefNo, RMPartyRefNo, Manufacturer
								     , RM_Plan_Qty, RM_Issued_Qty, RM_Req, RM_Excess_Issue)
	SELECT T0.SONo, T0.SODE, T0.SODate, T0.CardCode, T0.CardName, T0.ItemCode, T0.ItemName, T0.SOQty, T0.SOOpenQty
	--, T1.DocNum, T1.DocEntry
	, T0.SOQty, T2.Code, T3.ItemName, T3.U_RMfamilycode CatRefNo, T3.U_RMPartyNO, T4.FirmName
	, T0.SOOpenQty * T2.Quantity
	--, ISNULL(T2.IssuedQty, 0.00) IssuedQty
	, 0.00 IssuedQty
	, ISNULL(T0.SOOpenQty, 0.00) * ISNULL(T2.Quantity, 0.00) RM_Req
	--, ISNULL(T2.IssuedQty, 0.00) - (ISNULL(T2.Quantity, 0.00) * ISNULL(T1.CmpltQty, 0.00)) RM_Excess_Issue
	, 0.00 RM_Excess_Issue
	FROM #Temp_SODetails T0
	INNER JOIN OITT (NOLOCK) T1 ON T0.ItemCode = T1.Code
	INNER JOIN ITT1 (NOLOCK) T2 ON T1.Code = T2.Father
	INNER JOIN OITM (NOLOCK) T3 ON T2.Code = T3.ItemCode
	INNER JOIN OMRC (NOLOCK) T4 ON T3.FirmCode = T4.FirmCode
	AND T4.FirmName = 'LEGRAND'

	SELECT @SONos = STUFF(( SELECT DISTINCT '],[' + CAST(SONo AS VARCHAR)
							FROM #Temp_ForecastReport T0
							WHERE ISNULL(RM_Req, 0.00) - ISNULL(RM_Excess_Issue, 0.00) > 0
							ORDER BY '],[' + CAST(SONo AS VARCHAR) 
							FOR XML PATH('')), 1, 2, '')
							
	IF ISNULL(@SONos, '') <> ''							
	BEGIN

		SET @SONos = @SONos + ']'
	
		SET @SQL = 'SELECT RMCode [Item Code], RMName [Item Name], CatRefNo [Category Name], RMPartyRefNo, Manufacturer, ' + @SONos + '
				FROM
				(	SELECT RMCode, RMName, CatRefNo, RMPartyRefNo, SONo, Manufacturer
					, SUM(ISNULL(RM_Req, 0.00) - ISNULL(RM_Excess_Issue, 0.00)) RM_Req
					FROM #Temp_ForecastReport T0
					GROUP BY RMCode, RMName, CatRefNo, SONo, RMPartyRefNo, Manufacturer
					HAVING SUM(ISNULL(RM_Req, 0.00) - ISNULL(RM_Excess_Issue, 0.00)) > 0
				) AS SourceTable
				PIVOT
				(
					SUM(RM_Req)
					FOR SONo IN ('+ @SONos +')
				) AS PivotTable
				ORDER BY RMCode '
		PRINT(@SQL)				
		EXEC(@SQL)
	END

	--SELECT *
	----SUM(ISNULL(RM_Req, 0.00) - ISNULL(RM_Excess_Issue, 0.00)) RM_Req, RMCode 
	--FROM #Temp_ForecastReport 
	--WHERE SODE IN (9277, 9341) 
	--GROUP BY RMCode

	DROP TABLE #Temp_SODetails
	DROP TABLE #Temp_ProdDetails
	DROP TABLE #Temp_ForecastReport
	
END