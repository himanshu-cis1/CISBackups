USE [PAP_LIVE_Branch]
GO
/****** Object:  StoredProcedure [dbo].[CIS_LotUtilisation_Report]    Script Date: 12/11/2024 3:22:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Proc [dbo].[CIS_LotUtilisation_Report]
As Begin  

DECLARE @Proc Varchar(200)
DECLARE @ToDate AS DATE
DECLARE @FromDate AS DATE


--Select @proc = T20.U_PRCO FROM "@ROTID" T20 WHERE T20.U_PRCO = '[%0]'
--SELECT TOP 1 @ToDate = T20.U_SHSD FROM "@TURND" T20 WHERE T20.U_SHSD = '[%1]'
--SELECT TOP 1 @FromDate = T20.U_ENDD FROM "@TURND" T20 WHERE T20.U_ENDD = '[%2]'


Select Distinct A.Operator,SUM(A.[Expected Production])'Expected Production',SUM(A.[Ok Production Made])'Production Made',SUM(A.[Total Ok After QA])'Total Ok After QA',
SUM(A.[Total Reject After QA])'Total Reject After QA',AVG(a.[Production Utilization %])'Production Utilization %',SUM(a.[No. Of Machine])'No. of Machine',
SUM(a.[Production Utilization Point])'Production Utilization Point',AVG(a.[Quality Utilisation %])'Quality Utilisation %',SUM(a.[No Of Lots])'No of Lots',
SUM(a.[Direct Ok])'Direct Ok',SUM(a.Rework)'Rework',SUM(A.[Expected Production Value])'Expected Production Value',
SUM(a.[Actual Production Value])'Actual Production Value',SUM(a.[Reject Value])'Reject Value',SUM(a.[Actual Production Value af QA])'Actual Production Value af QA',
SUM(a.[Rework Value])'Rework Value',
SUM(a.[Final Production Value])'Final Production Value',AVG(a.[Lot Acceptance Efficency %])'Lot Acceptance Efficency %',
(SUM(a.[Production Utilization Point])*AVG(a.[Lot Acceptance Efficency %]))/100 'Overall Effiecncy'

From
(Select T5.U_OPNA 'Operator',SUM(T5.U_EPAS)'Expected Production'
,(SUM(T5.U_OKPR)+ISNULL(SUM(T5.U_BREM),0)) 'Ok Production Made',
(Select SUM(ISNULL(P3.U_TOAQ,0))
From "@TURNH" P4
Inner Join "@TURND" P3 On P3.DocEntry=P4.DocEntry 
Inner Join "@ROTIH" P2 On P2.U_ITEM=P4.U_ITCD
Inner Join "@ROTID" P1 on P1.DocEntry=P2.DocEntry And P4.U_SEQU=P1.LineId 
Where P4.U_PORN =T0.U_PORN And P4.U_ITCD=T0.U_ITCD And P1.U_PRCO ='QUALITY' And P1.U_MPRS=T2.U_PRCO And P3.LineId=T5.LineId)'Total Ok After QA',
(Select SUM(ISNULL(P3.U_TRAQ,0))
From "@TURNH" P4
Inner Join "@TURND" P3 On P3.DocEntry=P4.DocEntry 
Inner Join "@ROTIH" P2 On P2.U_ITEM=P4.U_ITCD
Inner Join "@ROTID" P1 on P1.DocEntry=P2.DocEntry And P4.U_SEQU=P1.LineId 
Where P4.U_PORN =T0.U_PORN And P4.U_ITCD=T0.U_ITCD And P1.U_PRCO ='QUALITY' And P1.U_MPRS=T2.U_PRCO And P3.LineId=T5.LineId)'Total Reject After QA',
AVG(T5.U_PRUP)'Production Utilization %',
Count(T5.U_SHFT)'No. Of Machine',
(((SUM(T5.U_OKPR)+ISNULL(SUM(T5.U_BREM),0))/(Case When Sum(T5.U_EPAS)=0 then 1 Else SUM(T5.U_EPAS) End ))*100)*
(Select SUM(ISNULL(P3.U_ACLT,0))
From "@TURNH" P4
Inner Join "@TURND" P3 On P3.DocEntry=P4.DocEntry 
Inner Join "@ROTIH" P2 On P2.U_ITEM=P4.U_ITCD
Inner Join "@ROTID" P1 on P1.DocEntry=P2.DocEntry And P4.U_SEQU=P1.LineId 
Where P4.U_PORN =T0.U_PORN And P4.U_ITCD=T0.U_ITCD And P1.U_PRCO ='QUALITY' And P1.U_MPRS=T2.U_PRCO And P3.LineId=T5.LineId) 'Production Utilization Point',
((Select SUM(ISNULL(P3.U_TOAQ,0))
From "@TURNH" P4
Inner Join "@TURND" P3 On P3.DocEntry=P4.DocEntry 
Inner Join "@ROTIH" P2 On P2.U_ITEM=P4.U_ITCD
Inner Join "@ROTID" P1 on P1.DocEntry=P2.DocEntry And P4.U_SEQU=P1.LineId 
Where P4.U_PORN =T0.U_PORN And P4.U_ITCD=T0.U_ITCD And P1.U_PRCO ='QUALITY' And P1.U_MPRS=T2.U_PRCO And P3.LineId=T5.LineId)/
(Case When Sum(T5.U_EPAS)=0 then 1 Else SUM(T5.U_EPAS) End )*100) 'Quality Utilisation %',
Count(T5.U_SHFT) 'No Of Lots', 
(Select SUM(ISNULL(P3.U_ACLT,0))
From "@TURNH" P4
Inner Join "@TURND" P3 On P3.DocEntry=P4.DocEntry 
Inner Join "@ROTIH" P2 On P2.U_ITEM=P4.U_ITCD
Inner Join "@ROTID" P1 on P1.DocEntry=P2.DocEntry And P4.U_SEQU=P1.LineId 
Where P4.U_PORN =T0.U_PORN And P4.U_ITCD=T0.U_ITCD And P1.U_PRCO ='QUALITY' And P1.U_MPRS=T2.U_PRCO And P3.LineId=T5.LineId) 'Direct Ok' ,
(Select (SUM(Cast(P3.U_NOIQ as Int)))-(SUM(Cast(ISNULL(P3.U_ACLT,0) as Int)))
From "@TURNH" P4
Inner Join "@TURND" P3 On P3.DocEntry=P4.DocEntry 
Inner Join "@ROTIH" P2 On P2.U_ITEM=P4.U_ITCD
Inner Join "@ROTID" P1 on P1.DocEntry=P2.DocEntry And P4.U_SEQU=P1.LineId 
Where P4.U_PORN =T0.U_PORN And P4.U_ITCD=T0.U_ITCD And P1.U_PRCO ='QUALITY' And P1.U_MPRS=T2.U_PRCO And P3.LineId=T5.LineId) 'Rework',

(T2.U_CTPT*SUM(T5.U_EPAS))'Expected Production Value',
(T2.U_CTPT*(SUM(T5.U_OKPR)+ISNULL(SUM(T5.U_BREM),0))+(SUM(T5.U_REWO))) 'Actual Production Value',
(Select SUM(ISNULL(P3.U_TRAQ,0))
From "@TURNH" P4
Inner Join "@TURND" P3 On P3.DocEntry=P4.DocEntry 
Inner Join "@ROTIH" P2 On P2.U_ITEM=P4.U_ITCD
Inner Join "@ROTID" P1 on P1.DocEntry=P2.DocEntry And P4.U_SEQU=P1.LineId 
Where P4.U_PORN =T0.U_PORN And P4.U_ITCD=T0.U_ITCD And P1.U_PRCO ='QUALITY' And P1.U_MPRS=T2.U_PRCO And P3.LineId=T5.LineId)*T0.U_PRCT'Reject Value',
(Select SUM(ISNULL(P3.U_TOAQ,0))
From "@TURNH" P4
Inner Join "@TURND" P3 On P3.DocEntry=P4.DocEntry 
Inner Join "@ROTIH" P2 On P2.U_ITEM=P4.U_ITCD
Inner Join "@ROTID" P1 on P1.DocEntry=P2.DocEntry And P4.U_SEQU=P1.LineId 
Where P4.U_PORN =T0.U_PORN And P4.U_ITCD=T0.U_ITCD And P1.U_PRCO ='QUALITY' And P1.U_MPRS=T2.U_PRCO And P3.LineId=T5.LineId)*T2.U_CTPT 'Actual Production Value af QA',
(Select SUM(ISNULL(P3.U_TORE,0))
From "@TURNH" P4
Inner Join "@TURND" P3 On P3.DocEntry=P4.DocEntry 
Inner Join "@ROTIH" P2 On P2.U_ITEM=P4.U_ITCD
Inner Join "@ROTID" P1 on P1.DocEntry=P2.DocEntry And P4.U_SEQU=P1.LineId 
Where P4.U_PORN =T0.U_PORN And P4.U_ITCD=T0.U_ITCD And P1.U_PRCO ='QUALITY' And P1.U_MPRS=T2.U_PRCO And P3.LineId=T5.LineId)*(T2.U_CTPT/2)'Rework Value',
(((Select SUM(ISNULL(P3.U_TOAQ,0))
From "@TURNH" P4
Inner Join "@TURND" P3 On P3.DocEntry=P4.DocEntry 
Inner Join "@ROTIH" P2 On P2.U_ITEM=P4.U_ITCD
Inner Join "@ROTID" P1 on P1.DocEntry=P2.DocEntry And P4.U_SEQU=P1.LineId 
Where P4.U_PORN =T0.U_PORN And P4.U_ITCD=T0.U_ITCD And P1.U_PRCO ='QUALITY' And P1.U_MPRS=T2.U_PRCO And P3.LineId=T5.LineId)*T2.U_CTPT) -
((Select SUM(ISNULL(P3.U_TORE,0))
From "@TURNH" P4
Inner Join "@TURND" P3 On P3.DocEntry=P4.DocEntry 
Inner Join "@ROTIH" P2 On P2.U_ITEM=P4.U_ITCD
Inner Join "@ROTID" P1 on P1.DocEntry=P2.DocEntry And P4.U_SEQU=P1.LineId 
Where P4.U_PORN =T0.U_PORN And P4.U_ITCD=T0.U_ITCD And P1.U_PRCO ='QUALITY' And P1.U_MPRS=T2.U_PRCO And P3.LineId=T5.LineId)*(T2.U_CTPT/2))) 'Final Production Value',
AVG(T5.U_LOAE)'Lot Acceptance Efficency %'



/*
,(T2.U_CTPT*SUM(T5.U_OKPR))'Ok Prod Value', ISNULL(SUM(T5.U_BREM),0)'Testing Rejection',
Sum(T5.U_SERE)'Setting Rejection',Sum(T5.U_REJE)'Rejection',Sum(T5.U_VARI)'Shortage', (ISNULL(SUM(T5.U_BREM),0)+Sum(T5.U_SERE)+Sum(T5.U_REJE)+Sum(T5.U_VARI))*T0.U_PRCT'Rejs+Shortage Value',
--(ISNULL(SUM(T5.U_BREM),0)+Sum(T5.U_SERE)+Sum(T5.U_REJE)+Sum(T5.U_VARI))*(T0.U_ACTC/T0.U_TUQT)'Rejs+Shortage ActualValue',
(ISNULL(SUM(T5.U_BREM),0)+Sum(T5.U_SERE)+Sum(T5.U_REJE)+Sum(T5.U_VARI)+SUM(T5.U_OKPR)) 'Total Production Qty',
((ISNULL(SUM(T5.U_BREM),0)+Sum(T5.U_SERE)+Sum(T5.U_REJE)+Sum(T5.U_VARI))*T0.U_PRCT)+(T2.U_CTPT*SUM(T5.U_OKPR)) 'Total Production Value',
--(ISNULL(SUM(T5.U_BREM),0)+Sum(T5.U_SERE)+Sum(T5.U_REJE)+Sum(T5.U_VARI)+SUM(T5.U_OKPR))*(T0.U_ACTC/T0.U_TUQT)'Total Production ActualValue' ,
SUM(T5.U_TOTL) As 'TotalRework',



(Select SUM(ISNULL(P3.U_TOAQ,0))
From "@TURNH" P4
Inner Join "@TURND" P3 On P3.DocEntry=P4.DocEntry 
Inner Join "@ROTIH" P2 On P2.U_ITEM=P4.U_ITCD
Inner Join "@ROTID" P1 on P1.DocEntry=P2.DocEntry And P4.U_SEQU=P1.LineId 
Where P4.U_PORN =T0.U_PORN And P4.U_ITCD=T0.U_ITCD And P1.U_PRCO ='QUALITY' And P1.U_MPRS=T2.U_PRCO And P3.LineId=T5.LineId)*T2.U_CTPT 'Total Ok Af QA Value'     
,
(Select SUM(ISNULL(P3.U_TOAQ,0))
From "@TURNH" P4
Inner Join "@TURND" P3 On P3.DocEntry=P4.DocEntry 
Inner Join "@ROTIH" P2 On P2.U_ITEM=P4.U_ITCD
Inner Join "@ROTID" P1 on P1.DocEntry=P2.DocEntry And P4.U_SEQU=P1.LineId 
Where P4.U_PORN =T0.U_PORN And P4.U_ITCD=T0.U_ITCD And P1.U_PRCO ='QUALITY' And P1.U_MPRS=T2.U_PRCO And P3.LineId=T5.LineId)*(T0.U_ACTC/T0.U_TUQT)
'Total Ok Af QA ActualValue'    ,


(Select SUM(ISNULL(P3.U_TRAQ,0))
From "@TURNH" P4
Inner Join "@TURND" P3 On P3.DocEntry=P4.DocEntry 
Inner Join "@ROTIH" P2 On P2.U_ITEM=P4.U_ITCD
Inner Join "@ROTID" P1 on P1.DocEntry=P2.DocEntry And P4.U_SEQU=P1.LineId 
Where P4.U_PORN =T0.U_PORN And P4.U_ITCD=T0.U_ITCD And P1.U_PRCO ='QUALITY' And P1.U_MPRS=T2.U_PRCO And P3.LineId=T5.LineId)*T0.U_PRCT'Total Reject Af QA Value',

(Select SUM(ISNULL(P3.U_TRAQ,0))
From "@TURNH" P4
Inner Join "@TURND" P3 On P3.DocEntry=P4.DocEntry 
Inner Join "@ROTIH" P2 On P2.U_ITEM=P4.U_ITCD
Inner Join "@ROTID" P1 on P1.DocEntry=P2.DocEntry And P4.U_SEQU=P1.LineId 
Where P4.U_PORN =T0.U_PORN And P4.U_ITCD=T0.U_ITCD And P1.U_PRCO ='QUALITY' And P1.U_MPRS=T2.U_PRCO And P3.LineId=T5.LineId)*(T0.U_ACTC/T0.U_TUQT)
'Total Reject Af QA ActualValue'
*/

From "@TURNH" T0
Inner Join "@TURND" T5 On T0.DocEntry=T5.DocEntry
Inner Join "@ROTIH" T1 On T0.U_ITCD=T1.U_ITEM
Inner Join "@ROTID" T2 On T1.DocEntry= T2.DocEntry And T0.U_SEQU=T2.LineId
Inner Join OITM T4 On T4.ItemCode=T0.U_ITCD
Where T2.U_PRCO= 'TURNING' And T5.U_SHSD > @ToDate And T5.U_ENDD< @FromDate And T5.U_OPNA Is not Null
Group By T0.U_PORN,T0.U_ITCD,T4.ItemName,T5.U_OPNA,T5.LineId,T2.U_PRCO,T0.U_TUQT,T0.U_ACTC,T2.U_CTPT,T0.U_PRCT,T0.U_SEQU,T0.U_PQTY--,T0.U_POKP
)A
Group By A.Operator
End


Exec CIS_LotUtilisation_Report 