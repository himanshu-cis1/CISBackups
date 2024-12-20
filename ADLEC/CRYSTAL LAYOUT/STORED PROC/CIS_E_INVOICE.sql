USE [Novateur]
GO
/****** Object:  StoredProcedure [dbo].[CIS_E_INVOICE]    Script Date: 17/12/2024 3:29:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[CIS_E_INVOICE]
(
	 @FromDate DATETIME,
	 @ToDate DATETIME
)
AS 
BEGIN 
		SELECT * 
FROM (
		--SALES TRNSACTION=======================================================================================================================================================================================
		select DISTINCT 
		'' "IRN", '' "IRNDate", '' "TaxScheme", (SELECT T101.Comments FROM OINV T101 WHERE T0.DocEntry = T101.DocEntry AND T101.CANCELED = 'Y')	 "CancellationReason",	''	"CancellationRemarks",	T0.U_SupplyType	"SupplyType", T0.U_DocCate "DocCategory" ,
		T0.U_DocumentType 'DocumentType',
		 T0.DocNum "DocumentNumber", FORMAT(T0.DocDate,'yyyyMMdd')"DocumentDate",
		 (select case when sum(t8.RvsChrgPrc )>0  then 'Y' else 'N' end from INV4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in (-120,-100,-110) ) "ReverseChargeFlag",
		 t3.LocGSTN "SupplierGSTIN",'' "SupplierTradeName", (SELECT CompnyName FROM OADM) "SupplierLegalName",(SELECT CompnyAddr FROM OADM)	"SupplierAddress1",	(SELECT CompnyAddr FROM OADM) "SupplierAddress2",
		 (SELECT CompnyAddr FROM OADM) "SupplierLocation",
		(SELECT ZipCode FROM ADM1 ) "SupplierPincode", CAST((SELECT OCST.GSTCode FROM OADM INNER JOIN OCST ON OADM.State = OCST.Code AND OADM.Country = OCST.Country)AS CHAR) "SupplierStateCode", '' "SupplierPhone",
		'' "SupplierEmail",(SELECT CRD1.U_Bill_GSTNo FROM CRD1 WHERE  T0.CARDCODE=CRD1.CARDCODE AND T0.PayToCode =CRD1.Address AND CRD1.AdresType='B')"CustomerGSTIN",T0.CardName "CustomerTradeName",
		 T0.CardName "CustomerLegalName",T0.Address	"CustomerAddress1",T0.Address2	"CustomerAddress2",
		 T0.Address "CustomerLocation",CASE WHEN T0.U_SupplyType IN  ('EXPT', 'EXPWT') THEN  '999999' ELSE T3.ZipCodeB END "CustomerPincode", 
		 CASE WHEN T0.U_SupplyType IN  ('EXPT', 'EXPWT') THEN  '96' ELSE LEFT((SELECT CRD1.U_Bill_GSTNo FROM CRD1 WHERE  T0.CARDCODE=CRD1.CARDCODE AND T0.PayToCode =CRD1.Address AND CRD1.AdresType='B'),2) END "CustomerStateCode",
		CASE WHEN T0.U_SupplyType IN  ('EXPT', 'EXPWT') THEN  '96' ELSE LEFT((SELECT CRD1.U_Bill_GSTNo FROM CRD1 WHERE  T0.CARDCODE=CRD1.CARDCODE AND T0.PayToCode =CRD1.Address AND CRD1.AdresType='B'),2) END	"BillingPOS",
		 '' "CustomerPhone",'' "CustomerEmail",'' "DispatcherGSTIN",(SELECT CompnyName FROM OADM) "DispatcherTradeName",(SELECT CompnyAddr FROM OADM)	"DispatcherAddress1",(SELECT CompnyAddr FROM OADM)	"DispatcherAddress2",


		(SELECT CompnyAddr FROM OADM) "DispatcherLocation",(SELECT ZipCode FROM ADM1) "DispatcherPincode", (SELECT OCST.GSTCode FROM OADM INNER JOIN OCST ON OADM.State = OCST.Code AND OADM.Country = OCST.Country) "DispatcherStateCode",
		'' "ShipToGSTIN", '' "ShipToTradeName",T0.CardName "ShipToLegalName",T0.Address2	"ShipToAddress1",T0.Address2 "ShipToAddress2",

		 T0.Address2 "ShipToLocation",
		CASE WHEN T0.U_SupplyType IN  ('EXPT', 'EXPWT') THEN  '999999' 
		ELSE  
		(SELECT CRD1.ZipCode FROM CRD1  WHERE CRD1.CardCode = T0.CardCode AND CRD1.Address = T0.ShipToCode AND CRD1.AdresType = 'S') END "ShipToPincode",
		 CASE WHEN T0.U_SupplyType IN  ('EXPT', 'EXPWT') THEN  '96' ELSE LEFT(T3.BpGSTN,2) END "ShipToStateCode",T1.VisOrder+1	"ItemSerialNumber",	
		'' "ProductSerialNumber", T1.ItemCode	"ProductName",T1.Dscription "ProductDescription",
		 CASE WHEN (select ItemClass from oitm where t1.ItemCode = ItemCode) = 1 THEN 'Y' ELSE 'N' End "IsService",REPLACE(T6.ChapterID,'.','')	"HSN",
		'' "Barcode",'' "BatchName", '' "BatchExpiryDate", '' "WarrantyDate",''	"OrderLineReference",
		 '' "AttributeName", '' "AttributeValue", '' "OriginCountry",T1.unitMsr	"UQC",T1.Quantity "Quantity",

		''	"FreeQuantity",	T1.Price "UnitPrice",	T1.LineTotal	"ItemAmount",	''	"ItemDiscount",	''	"PreTaxAmount", T1.Quantity*T1.Price	"ItemAssessableAmount",	
		(select distinct T8.TaxRate from INV4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-120 ) and t1.LineNum=t8.LineNum and t8.RelateType=1) "IGSTRate",
		isnull((select sum(T8.TaxSum) from INV4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-120 ) and t1.LineNum=t8.LineNum  and t8.RelateType=1),0) "IGSTAmount",
		(select  distinct (T8.TaxRate) from INV4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-100) and t1.LineNum=t8.LineNum and t8.RelateType=1  ) "CGSTRate",
		isnull((select sum(T8.TaxSum) from INV4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-100 ) and t1.LineNum=t8.LineNum  and t8.RelateType=1),0) "CGSTAmount",
		(select  distinct (T8.TaxRate) from INV4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-110) and t1.LineNum=t8.LineNum and t8.RelateType=1  ) "SGSTRate",
		isnull((select sum(T8.TaxSum) from INV4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-110) and t1.LineNum=t8.LineNum  and t8.RelateType=1),0)"SGSTAmount",


		' '	"CessAdvaloremRate",'0'	"CessAdvaloremAmount",' '	"CessSpecificRate",	'0'	"CessSpecificAmount",








		'0' "StateCessAdvaloremRate",	'0'	"StateCessAdvaloremAmount",	'0'	"StateCessSpecificRate",	'0'	"StateCessSpecificAmount",
		(SELECT SUM(A.TaxSum) FROM INV4 A WHERE A.DocEntry = T1.DocEntry AND A.LineNum = T1.LineNum AND A.staType = 9 AND A.RelateType = 1 )	"ItemOtherCharges",	T1.LineTotal+T1.VatSum	"TotalItemAmount",	
		''	"InvoiceOtherCharges",T0.TotalExpns+(SELECT SUM(LineTotal) FROM INV1 WHERE INV1.DocEntry = T1.DocEntry) "InvoiceAssessableAmount",
		ISNULL((Select (case when  sum(x.RvsChrgTax)<=0  then sum(x.TaxSum)/t0.DocRate else 0 end) From INV4 x Where x.DocEntry = t0.DocEntry and x.staType = -120 ),0) "InvoiceIGSTAmount",	
		ISNULL((Select (case when  sum(x.RvsChrgTax)<=0  then sum(x.TaxSum)/t0.DocRate else 0 end) From INV4 x Where x.DocEntry = t0.DocEntry and x.staType = -100 ),0) "InvoiceCGSTAmount",	
		ISNULL((Select (case when  sum(x.RvsChrgTax)<=0  then sum(x.TaxSum)/t0.DocRate else 0 end) From INV4 x Where x.DocEntry = t0.DocEntry and x.staType = -110 ),0) "InvoiceSGSTAmount",
		'' "InvoiceCessAdvaloremAmount",	'0' "InvoiceCessSpecificAmount",	'0'	"InvoiceStateCessAdvaloremAmount",	'0'	"InvoiceStateCessSpecificAmount",	t0.DocTotal "InvoiceValue",
		''	"RoundOff",
		''	"TotalInvoiceValue(InWords)",	''	"TCSFlagIncomeTax",	''	"TCSRateIncomeTax",	''	"TCSAmountIncomeTax",	''	"CustomerPANOrAadhaar",	
		''	"CurrencyCode",	''	"CountryCode",	''	"InvoiceValueFC",'' "PortCode",
		'' "ShippingBillNumber",
		'' "ShippingBillDate",

			''	"InvoiceRemarks",	''	"InvoicePeriodStartDate",	''	"InvoicePeriodEndDate",	''	"PreceedingInvoiceNumber",''	"PreceedingInvoiceDate",


		''	"OtherReference",			''	"ReceiptAdviceReference",	''	"ReceiptAdviceDate",	 ''	"TenderReference",	

		''	"ContractReference",	''	"ExternalReference",	''	"ProjectReference",	''	"CustomerPOReferenceNumber",	''	"CustomerPOReferenceDate",''	"PayeeName",

			''	"ModeOfPayment",	''	"BranchOrIFSCCode",	''	"PaymentTerms",	''	"PaymentInstruction",
		''	"CreditTransfer",	''	"DirectDebit",	''	"CreditDays",	''	"PaidAmount",	''	"BalanceAmount",	''	"PaymentDueDate",
		''	"AccountDetail",' '	"EcomGSTIN",	''	"EcomTransactionID",	''	"SupportingDocURL",	''	"SupportingDocument",'' "AdditionalInformation",
		''	"TransactionType",	''	"SubSupplyType", ''	"OtherSupplyTypeDescription",	''	"TransporterID",	''	"TransporterName",	''	"TransportMode",	''	"TransportDocNo",	
		''	"TransportDocDate",	''	"Distance",	''	"VehicleNo",	''	"VehicleType",	((SELECT RIGHT('00' + CAST(DATEPART(mm, t0.DocDate) AS varchar(2)), 2)) + CAST(DATEPART(YYYY, t0.DocDate) as varchar(4))) "ReturnPeriod",
		''	"OriginalDocumentType",	'' "OriginalCustomerGSTIN",''	"DifferentialPercentageFlag",	''	"Section7OfIGSTFlag",	
		''	"ClaimRefundFlag",	''	"AutoPopulateToRefund",	'' "CRDRPreGST",'' "CustomerType",T0.CardCode "CustomerCode",T1.ItemCode "ProductCode",t5.U_FGSUBGRP "CategoryOfProduct",
		CASE WHEN ISNULL(T0.VatSum,'0') = '0' THEN '' ELSE 'T1' END	"ITCFlag",
		''	"StateApplyingCess",(SELECT CASE WHEN T3.ImpORExp='Y' THEN T1.LineTotal ELSE '0.00' END ) "FOB",	'0'	"ExportDuty",
		''	"ExchangeRate",'' "ReasonForCreditDebitNote",' '	"TCSFlagGST",	''	"TCSIGSTAmount",	''	"TCSCGSTAmount",
		''	"TCSSGSTAmount",''	"TDSFlagGST",		''	"TDSIGSTAmount",	''	"TDSCGSTAmount",	''	"TDSSGSTAmount",	''	"UserID",		
		''	"CompanyCode",' '	"SourceIdentifier",	' '	"SourceFileName",t4.TanOfficer "PlantCode",'AD' "Division", ' '	"SubDivision",

			''	"Location",	''	"SalesOrganisation",	''	"DistributionChannel",' '	"ProfitCentre1",	 ' '	"ProfitCentre2",	''	"ProfitCentre3",	''	"ProfitCentre4",
		''	"ProfitCentre5",	''	"ProfitCentre6",	''	"ProfitCentre7",	''	"ProfitCentre8",	''	"GLAssessableValue",	
		''	"GLIGST",	''	"GLCGST",	''	"GLSGST",	''	"GLAdvaloremCess",	''	"GLSpecificCess",	''	"GLStateCessAdvalorem",	
		''	"GLStateCessSpecific",	''	"GLPostingDate",	''	"SalesOrderNumber",	''	"EWBNumber",	''	"EWBDate",t8.Number          "AccountingVoucherNumber",
		t8.refdate "AccountingVoucherDate",	

		''	"DocumentReferenceNumber",			
		''	"CustomerTAN",' '	"UserDefinedField1",	 
		' '	"UserDefinedField2",	 ' '	"UserDefinedField3",	 ' '	"UserDefinedField4",	 ' '	"UserDefinedField5",	 ' '	"UserDefinedField6",	 ' '	"UserDefinedField7",	 
		' '	"UserDefinedField8",	 ' '	"UserDefinedField9",	 ' '	"UserDefinedField10",	 ' '	"UserDefinedField11",	 ' '	"UserDefinedField12",	 ' '	"UserDefinedField13",	 
		' '	"UserDefinedField14",	 ' '	"UserDefinedField15",	 ' '	"UserDefinedField16",	 ' '	"UserDefinedField17",	 ' '	"UserDefinedField18",	 ' '	"UserDefinedField19",	 
		' '	"UserDefinedField20",	 ' '	"UserDefinedField21",	 ' '	"UserDefinedField22",	 ' '	"UserDefinedField23",	 ' '	"UserDefinedField24",	 ' '	"UserDefinedField25",	 
		' '	"UserDefinedField26",	 ' '	"UserDefinedField27",	 ' '	"UserDefinedField28",	 ' '	"UserDefinedField29",	 ' '	"UserDefinedField30"

		from 
 
		oinv t0 
		inner join INV1 T1 ON T0.DocEntry=T1.DocEntry
		INNER JOIN INV12 T3 ON T1.DocEntry=T3.DocEntry
		INNER JOIN OLCT T4 ON T1.LocCode=T4.Code
		inner join inv4 t9 on t1.DocEntry =t9.DocEntry and t9.staType in (-120,-100,-110)  and t9.RelateType=1 AND  T1.LineNum=T9.LineNum
		LEFT OUTER JOIN OITM T5 on T5.ItemCode = T1.ItemCode AND T0.DocType = 'I'
		LEFT OUTER JOIN OCHP T6 on T6.AbsEntry = T5.ChapterID
		LEFT OUTER JOIN OSAC T7 on T1.SacEntry = T7.AbsEntry
		left outer join ojdt t8 on t0.TransId=t8.TransId and t8.TransType=13
		INNER JOIN OCRD T10 ON T0.CardCode = T10.CardCode
		WHERE  T0.DocDate between @Fromdate and @ToDate AND T0.Series not in (466,482,483,485)

		UNION ALL
		--====Sale Freight==================================================================================================================================================================================================
		select DISTINCT 
		'' "IRN", '' "IRNDate", '' "TaxScheme", (SELECT T101.Comments FROM OINV T101 WHERE T0.DocEntry = T101.DocEntry AND T101.CANCELED = 'Y') "CancellationReason",	''	"CancellationRemarks",	T0.U_SupplyType	"SupplyType", T0.U_DocCate "DocCategory" ,
		T0.U_DocumentType  'DocumentType',
		 T0.DocNum "DocumentNumber",FORMAT(T0.DocDate,'yyyyMMdd') "DocumentDate",
		 (select case when sum(t8.RvsChrgPrc )>0  then 'Y' else 'N' end from INV4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in (-120,-100,-110) ) "ReverseChargeFlag",
		 t3.LocGSTN "SupplierGSTIN",'' "SupplierTradeName", 
		 (SELECT CompnyName FROM OADM) "SupplierLegalName",
		 (SELECT CompnyAddr FROM OADM)	"SupplierAddress1",	(SELECT CompnyAddr FROM OADM) "SupplierAddress2",
		 (SELECT CompnyAddr FROM OADM) "SupplierLocation",
		(SELECT ZipCode FROM ADM1 ) "SupplierPincode",CAST((SELECT OCST.GSTCode FROM OADM INNER JOIN OCST ON OADM.State = OCST.Code AND OADM.Country = OCST.Country)AS CHAR) "SupplierStateCode", '' "SupplierPhone",
		'' "SupplierEmail",(SELECT CRD1.U_Bill_GSTNo FROM CRD1 WHERE  T0.CARDCODE=CRD1.CARDCODE AND T0.PayToCode =CRD1.Address AND CRD1.AdresType='B')"CustomerGSTIN",T0.CardName "CustomerTradeName",
		 T0.CardName "CustomerLegalName",T0.Address	"CustomerAddress1",T0.Address2	"CustomerAddress2",

		 T0.Address "CustomerLocation",CASE WHEN T0.U_SupplyType IN  ('EXPT', 'EXPWT') THEN  '999999' ELSE T3.ZipCodeB END "CustomerPincode", CASE WHEN T0.U_SupplyType IN  ('EXPT', 'EXPWT') THEN  '96' ELSE LEFT((SELECT CRD1.U_Bill_GSTNo FROM CRD1 WHERE  T0.CARDCODE=CRD1.CARDCODE AND T0.PayToCode =CRD1.Address AND CRD1.AdresType='B'),2) END	"CustomerStateCode",
		 CASE WHEN T0.U_SupplyType IN  ('EXPT', 'EXPWT') THEN  '96' ELSE LEFT((SELECT CRD1.U_Bill_GSTNo FROM CRD1 WHERE  T0.CARDCODE=CRD1.CARDCODE AND T0.PayToCode =CRD1.Address AND CRD1.AdresType='B'),2) END "BillingPOS",
		 '' "CustomerPhone",'' "CustomerEmail",'' "DispatcherGSTIN",(SELECT CompnyName FROM OADM) "DispatcherTradeName",(SELECT CompnyAddr FROM OADM)	"DispatcherAddress1",(SELECT CompnyAddr FROM OADM)	"DispatcherAddress2",


		(SELECT CompnyAddr FROM OADM) "DispatcherLocation",(SELECT ZipCode FROM ADM1) "DispatcherPincode", (SELECT OCST.GSTCode FROM OADM INNER JOIN OCST ON OADM.State = OCST.Code AND OADM.Country = OCST.Country) "DispatcherStateCode",
		'' "ShipToGSTIN", '' "ShipToTradeName",T0.CardName "ShipToLegalName",T0.Address2	"ShipToAddress1",T0.Address2 "ShipToAddress2",

		 T0.Address2 "ShipToLocation",
		CASE WHEN T0.U_SupplyType IN  ('EXPT', 'EXPWT') THEN  '999999' 
		ELSE  
		(SELECT CRD1.ZipCode FROM CRD1  WHERE CRD1.CardCode = T0.CardCode AND CRD1.Address = T0.ShipToCode AND CRD1.AdresType = 'S') END "ShipToPincode",CASE WHEN T0.U_SupplyType IN  ('EXPT', 'EXPWT') THEN  '96' ELSE LEFT(T3.BpGSTN,2) END "ShipToStateCode",1 "ItemSerialNumber",	
		'' "ProductSerialNumber", ''	"ProductName",(select OEXD.ExpnsName from OEXD where t9.ExpnsCode=OEXD.ExpnsCode) "ProductDescription",
		 'N' "IsService",
		  REPLACE((SELECT TOP 1 T22.[ChapterID] FROM INV1 T00  
					INNER JOIN OITM T11 ON T00.[ItemCode] = T11.[ItemCode] 
					LEFT JOIN OCHP T22 ON T11.[ChapterID] = T22.[AbsEntry] 
					WHERE T00.[DocEntry] = T1.DocEntry),'.','')	"HSN",
		'' "Barcode",'' "BatchName", '' "BatchExpiryDate", '' "WarrantyDate",''	"OrderLineReference",
		 '' "AttributeName", '' "AttributeValue", '' "OriginCountry",'NOS'	"UQC",1.00 "Quantity",
 
		''	"FreeQuantity",	(SELECT SUM(LineTotal) FROM INV3 WHERE DocEntry = T0.DocEntry AND ExpnsCode = 2 ) "UnitPrice",	(SELECT SUM(LineTotal) FROM INV3 WHERE DocEntry = T0.DocEntry AND ExpnsCode = 2 )	"ItemAmount",	
		'0'	"ItemDiscount",	'0'	"PreTaxAmount", (SELECT SUM(LineTotal) FROM INV3 WHERE DocEntry = T0.DocEntry AND ExpnsCode = 2 )	"ItemAssessableAmount",	
		(select distinct T8.TaxRate from INV4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-120 ) and t8.RelateType=3) "IGSTRate",
		isnull((select sum(T8.TaxSum) from INV4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-120 )  and t8.RelateType=3),0) "IGSTAmount",
		(select  distinct (T8.TaxRate) from INV4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-100) and t1.LineNum=t8.LineNum and t8.RelateType=1  ) "CGSTRate",
		isnull((select sum(T8.TaxSum) from INV4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-100 )  and t8.RelateType=3),0) "CGSTAmount",
		(select  distinct (T8.TaxRate) from INV4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-110) and t8.RelateType=3  ) "SGSTRate",
		isnull((select sum(T8.TaxSum) from INV4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-110) and t8.RelateType=3),0)"SGSTAmount",
		' '	"CessAdvaloremRate",'0'	"CessAdvaloremAmount",' '	"CessSpecificRate",	'0'	"CessSpecificAmount",
		'0' "StateCessAdvaloremRate",	'0'	"StateCessAdvaloremAmount",	'0'	"StateCessSpecificRate",	'0'	"StateCessSpecificAmount",
		(SELECT SUM(A.TaxSum) FROM INV4 A WHERE A.DocEntry = T1.DocEntry AND A.staType = 9 AND A.RelateType = 3 ) "ItemOtherCharges",	
		isnull((select sum(T8.TaxSum) from INV4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-120 )  and t8.RelateType=3),0)+
		isnull((select sum(T8.TaxSum) from INV4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-100 )  and t8.RelateType=3),0)+
		isnull((select sum(T8.TaxSum) from INV4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-110) and t8.RelateType=3),0)+
		ISNULL((SELECT SUM(A.TaxSum) FROM INV4 A WHERE A.DocEntry = T1.DocEntry AND A.staType = 9 AND A.RelateType = 3 ),0)+
		ISNULL((SELECT SUM(LineTotal) FROM INV3 WHERE DocEntry = T0.DocEntry AND ExpnsCode = 2 ),0)

			"TotalItemAmount",	
		''	"InvoiceOtherCharges",T0.TotalExpns+(SELECT SUM(LineTotal) FROM INV1 WHERE INV1.DocEntry = T1.DocEntry ) "InvoiceAssessableAmount",
		ISNULL((Select (case when  sum(x.RvsChrgTax)<=0  then sum(x.TaxSum)/t0.DocRate else 0 end) From INV4 x Where x.DocEntry = t0.DocEntry and x.staType = -120),0) "InvoiceIGSTAmount",	
		ISNULL((Select (case when  sum(x.RvsChrgTax)<=0  then sum(x.TaxSum)/t0.DocRate else 0 end) From INV4 x Where x.DocEntry = t0.DocEntry and x.staType = -100 ),0) "InvoiceCGSTAmount",	
		ISNULL((Select (case when  sum(x.RvsChrgTax)<=0  then sum(x.TaxSum)/t0.DocRate else 0 end) From INV4 x Where x.DocEntry = t0.DocEntry and x.staType = -110),0) "InvoiceSGSTAmount",

		'' "InvoiceCessAdvaloremAmount",	'0' "InvoiceCessSpecificAmount",	'0'	"InvoiceStateCessAdvaloremAmount",	'0'	"InvoiceStateCessSpecificAmount",	t0.DocTotal "InvoiceValue",
		''	"RoundOff",
		''	"TotalInvoiceValue(InWords)",	''	"TCSFlagIncomeTax",	''	"TCSRateIncomeTax",	''	"TCSAmountIncomeTax",	''	"CustomerPANOrAadhaar",	
		''	"CurrencyCode",	''	"CountryCode",	''	"InvoiceValueFC",'' "PortCode",
		'' "ShippingBillNumber",
		'' "ShippingBillDate",

			''	"InvoiceRemarks",	''	"InvoicePeriodStartDate",	''	"InvoicePeriodEndDate",	''	"PreceedingInvoiceNumber",''	"PreceedingInvoiceDate",


		''	"OtherReference",			''	"ReceiptAdviceReference",	''	"ReceiptAdviceDate",	  ''	"TenderReference",	
		''	"ContractReference",	''	"ExternalReference",	''	"ProjectReference",	''	"CustomerPOReferenceNumber",	''	"CustomerPOReferenceDate",''	"PayeeName",

			''	"ModeOfPayment",	''	"BranchOrIFSCCode",	''	"PaymentTerms",	''	"PaymentInstruction",
		''	"CreditTransfer",	''	"DirectDebit",	''	"CreditDays",	''	"PaidAmount",	''	"BalanceAmount",	''	"PaymentDueDate",
		''	"AccountDetail",' '	"EcomGSTIN",	''	"EcomTransactionID",	''	"SupportingDocURL",	''	"SupportingDocument",'' "AdditionalInformation",
		''	"TransactionType",	''	"SubSupplyType", ''	"OtherSupplyTypeDescription",	''	"TransporterID",	''	"TransporterName",	''	"TransportMode",	''	"TransportDocNo",	
		''	"TransportDocDate",	''	"Distance",	''	"VehicleNo",	''	"VehicleType",	
		((SELECT RIGHT('00' + CAST(DATEPART(mm, t0.DocDate) AS varchar(2)), 2)) + CAST(DATEPART(YYYY, t0.DocDate) as varchar(4))) "ReturnPeriod",
		''	"OriginalDocumentType",	'' "OriginalCustomerGSTIN",''	"DifferentialPercentageFlag",	''	"Section7OfIGSTFlag",	
		''	"ClaimRefundFlag",	''	"AutoPopulateToRefund",	'' "CRDRPreGST",'' "CustomerType",T0.CardCode "CustomerCode",'' "ProductCode",'' "CategoryOfProduct",CASE WHEN ISNULL(T0.VatSum,'0') = '0' THEN '' ELSE 'T1' END	"ITCFlag",
		''	"StateApplyingCess",(SELECT CASE WHEN T3.ImpORExp='Y' THEN T1.LineTotal ELSE '0.00' END ) "FOB",	'0'	"ExportDuty",
		''	"ExchangeRate",'' "ReasonForCreditDebitNote",' '	"TCSFlagGST",	''	"TCSIGSTAmount",	''	"TCSCGSTAmount",
		''	"TCSSGSTAmount",''	"TDSFlagGST",		''	"TDSIGSTAmount",	''	"TDSCGSTAmount",	''	"TDSSGSTAmount",	''	"UserID",		
		''	"CompanyCode",' '	"SourceIdentifier",	' '	"SourceFileName",t4.TanOfficer "PlantCode",'AD' "Division", ' '	"SubDivision",

			''	"Location",	''	"SalesOrganisation",	''	"DistributionChannel",' '	"ProfitCentre1",	 ' '	"ProfitCentre2",	''	"ProfitCentre3",	''	"ProfitCentre4",
		''	"ProfitCentre5",	''	"ProfitCentre6",	''	"ProfitCentre7",	''	"ProfitCentre8",	''	"GLAssessableValue",	
		''	"GLIGST",	''	"GLCGST",	''	"GLSGST",	''	"GLAdvaloremCess",	''	"GLSpecificCess",	''	"GLStateCessAdvalorem",	
		''	"GLStateCessSpecific",	''	"GLPostingDate",	''	"SalesOrderNumber",	''	"EWBNumber",	''	"EWBDate",t8.Number          "AccountingVoucherNumber",
		t8.refdate "AccountingVoucherDate",	

		''	"DocumentReferenceNumber",			
		''	"CustomerTAN",' '	"UserDefinedField1",	 
		' '	"UserDefinedField2",	 ' '	"UserDefinedField3",	 ' '	"UserDefinedField4",	 ' '	"UserDefinedField5",	 ' '	"UserDefinedField6",	 ' '	"UserDefinedField7",	 
		' '	"UserDefinedField8",	 ' '	"UserDefinedField9",	 ' '	"UserDefinedField10",	 ' '	"UserDefinedField11",	 ' '	"UserDefinedField12",	 ' '	"UserDefinedField13",	 
		' '	"UserDefinedField14",	 ' '	"UserDefinedField15",	 ' '	"UserDefinedField16",	 ' '	"UserDefinedField17",	 ' '	"UserDefinedField18",	 ' '	"UserDefinedField19",	 
		' '	"UserDefinedField20",	 ' '	"UserDefinedField21",	 ' '	"UserDefinedField22",	 ' '	"UserDefinedField23",	 ' '	"UserDefinedField24",	 ' '	"UserDefinedField25",	 
		' '	"UserDefinedField26",	 ' '	"UserDefinedField27",	 ' '	"UserDefinedField28",	 ' '	"UserDefinedField29",	 ' '	"UserDefinedField30"
		from 
 
		oinv t0 
		inner join INV1 T1 ON T0.DocEntry=T1.DocEntry
		INNER JOIN INV12 T3 ON T1.DocEntry=T3.DocEntry
		INNER JOIN OLCT T4 ON T1.LocCode=T4.Code
		inner join inv4 t9 on t1.DocEntry =t9.DocEntry and t9.staType in (-120,-100,-110)  and t9.RelateType=3 --AND  T1.LineNum=T9.LineNum
		LEFT OUTER JOIN OITM T5 on T5.ItemCode = T1.ItemCode AND T0.DocType = 'I'
		LEFT OUTER JOIN OCHP T6 on T6.AbsEntry = T5.ChapterID
		LEFT OUTER JOIN OSAC T7 on T1.SacEntry = T7.AbsEntry
		left outer join ojdt t8 on t0.TransId=t8.TransId and t8.TransType=13
		INNER JOIN OCRD T10 ON T0.CardCode = T10.CardCode
		where T0.DocDate between @Fromdate and @ToDate  AND T0.Series not in (466,482,483,485)
		group by t4.TanCirNo,t4.TanWardNo,t1.AcctCode,t0.DocDate,t3.LocGSTN,t0.Series,t0.ObjType,t0.DocNum,t0.CardCode,t0.PayToCode,t0.ShipToCode,t3.StateB,t3.StateS,t3.CountryB,t3.CountryS,t3.BpStateCod,t3.BpCountry,
		t3.ImpORExp,t1.LineTotal,t9.ExpnsCode,t9.BaseSum,t9.staType,t9.StaCode,t9.TaxRate,t0.DocEntry,t0.DocTotal,t8.Number,t8.RefDate, t4.TanOfficer,T1.LineNum,T3.BpGSTType,T0.CardName
		,T0.Address,T0.Address2,T3.BpGSTN,T0.DocType,T0.Comments ,CAST(T10.AliasName AS NVARCHAR(MAX)),T3.ZipCodeB,T0.VatSum,T0.U_DocumentType,T0.U_SupplyType,T0.U_DocCate,
		T5.ChapterID,T1.DocEntry,T0.TotalExpns,t0.DocRate

		UNION ALL
		--SALES RETURN TRNSACTION=======================================================================================================================================================================================
		select DISTINCT 
		'' "IRN", '' "IRNDate", '' "TaxScheme",(SELECT T101.Comments FROM ORIN T101 WHERE T0.DocEntry = T101.DocEntry AND T101.CANCELED = 'Y') "CancellationReason",	''	"CancellationRemarks",	T0.U_SupplyType	"SupplyType", T0.U_DocCate "DocCategory", T0.U_DocumentType 'DocumentType',
		 T0.DocNum "DocumentNumber",FORMAT(T0.DocDate,'yyyyMMdd') "DocumentDate",
		 (select case when sum(t8.RvsChrgPrc )>0  then 'Y' else 'N' end from RIN4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in (-120,-100,-110) ) "ReverseChargeFlag",
		 t3.LocGSTN "SupplierGSTIN",'' "SupplierTradeName", (SELECT CompnyName FROM OADM) "SupplierLegalName",(SELECT CompnyAddr FROM OADM)	"SupplierAddress1",	(SELECT CompnyAddr FROM OADM) "SupplierAddress2",
		 (SELECT CompnyAddr FROM OADM) "SupplierLocation",
		(SELECT ZipCode FROM ADM1 ) "SupplierPincode", CAST((SELECT OCST.GSTCode FROM OADM INNER JOIN OCST ON OADM.State = OCST.Code AND OADM.Country = OCST.Country)AS CHAR) "SupplierStateCode", '' "SupplierPhone",
		'' "SupplierEmail",(SELECT CRD1.U_Bill_GSTNo FROM CRD1 WHERE  T0.CARDCODE=CRD1.CARDCODE AND T0.PayToCode =CRD1.Address AND CRD1.AdresType='B')"CustomerGSTIN",T0.CardName "CustomerTradeName",
		 T0.CardName "CustomerLegalName",T0.Address	"CustomerAddress1",T0.Address2	"CustomerAddress2",

		 T0.Address "CustomerLocation",CASE WHEN T0.U_SupplyType IN  ('EXPT', 'EXPWT') THEN  '999999' ELSE T3.ZipCodeB END "CustomerPincode",CASE WHEN T0.U_SupplyType IN  ('EXPT', 'EXPWT') THEN  '96' ELSE LEFT((SELECT CRD1.U_Bill_GSTNo FROM CRD1 WHERE  T0.CARDCODE=CRD1.CARDCODE AND T0.PayToCode =CRD1.Address AND CRD1.AdresType='B'),2) END	"CustomerStateCode",
		 CASE WHEN T0.U_SupplyType IN  ('EXPT', 'EXPWT') THEN  '96' ELSE LEFT((SELECT CRD1.U_Bill_GSTNo FROM CRD1 WHERE  T0.CARDCODE=CRD1.CARDCODE AND T0.PayToCode =CRD1.Address AND CRD1.AdresType='B'),2) END	"BillingPOS",
		 '' "CustomerPhone",'' "CustomerEmail",'' "DispatcherGSTIN",(SELECT CompnyName FROM OADM) "DispatcherTradeName",(SELECT CompnyAddr FROM OADM)	"DispatcherAddress1",(SELECT CompnyAddr FROM OADM)	"DispatcherAddress2",


		(SELECT CompnyAddr FROM OADM) "DispatcherLocation",(SELECT ZipCode FROM ADM1) "DispatcherPincode", (SELECT OCST.GSTCode FROM OADM INNER JOIN OCST ON OADM.State = OCST.Code AND OADM.Country = OCST.Country) "DispatcherStateCode",
		'' "ShipToGSTIN", '' "ShipToTradeName",T0.CardName "ShipToLegalName",T0.Address2	"ShipToAddress1",T0.Address2 "ShipToAddress2",

		 T0.Address2 "ShipToLocation",
		CASE WHEN T0.U_SupplyType IN  ('EXPT', 'EXPWT') THEN  '999999' 
		ELSE  
		(SELECT CRD1.ZipCode FROM CRD1  WHERE CRD1.CardCode = T0.CardCode AND CRD1.Address = T0.ShipToCode AND CRD1.AdresType = 'S') END "ShipToPincode",CASE WHEN T0.U_SupplyType IN  ('EXPT', 'EXPWT') THEN  '96' ELSE LEFT(T3.BpGSTN,2) END "ShipToStateCode",T1.VisOrder+1	"ItemSerialNumber",	
		'' "ProductSerialNumber", T1.ItemCode	"ProductName",T1.Dscription "ProductDescription",
		 CASE WHEN (select ItemClass from oitm where t1.ItemCode = ItemCode) = 1 THEN 'Y' ELSE 'N' End "IsService",REPLACE(T6.ChapterID,'.','')	"HSN",
		'' "Barcode",'' "BatchName", '' "BatchExpiryDate", '' "WarrantyDate",''	"OrderLineReference",
		 '' "AttributeName", '' "AttributeValue", '' "OriginCountry",T1.unitMsr	"UQC",T1.Quantity "Quantity",

		''	"FreeQuantity",	T1.Price "UnitPrice",	T1.LineTotal	"ItemAmount",	''	"ItemDiscount",	''	"PreTaxAmount", T1.Quantity*T1.Price	"ItemAssessableAmount",	
		(select distinct T8.TaxRate from RIN4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-120 ) and t1.LineNum=t8.LineNum and t8.RelateType=1) "IGSTRate",
		isnull((select sum(T8.TaxSum) from RIN4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-120 ) and t1.LineNum=t8.LineNum  and t8.RelateType=1),0) "IGSTAmount",
		(select  distinct (T8.TaxRate) from INV4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-100) and t1.LineNum=t8.LineNum and t8.RelateType=1  ) "CGSTRate",
		isnull((select sum(T8.TaxSum) from RIN4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-100 ) and t1.LineNum=t8.LineNum  and t8.RelateType=1),0) "CGSTAmount",
		(select  distinct (T8.TaxRate) from RIN4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-110) and t1.LineNum=t8.LineNum and t8.RelateType=1  ) "SGSTRate",
		isnull((select sum(T8.TaxSum) from RIN4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-110) and t1.LineNum=t8.LineNum  and t8.RelateType=1),0) "SGSTAmount",


		' '	"CessAdvaloremRate",'0'	"CessAdvaloremAmount",' '	"CessSpecificRate",	'0'	"CessSpecificAmount",








		'0' "StateCessAdvaloremRate",	''	"StateCessAdvaloremAmount",	'0'	"StateCessSpecificRate",	'0'	"StateCessSpecificAmount",
		(SELECT SUM(A.TaxSum) FROM INV4 A WHERE A.DocEntry = T1.DocEntry AND A.LineNum = T1.LineNum AND A.staType = 9 AND A.RelateType = 1 )	"ItemOtherCharges",	T1.LineTotal+T1.VatSum	"TotalItemAmount",	
		''	"InvoiceOtherCharges",T0.TotalExpns+(SELECT SUM(LineTotal) FROM RIN1 WHERE RIN1.DocEntry = T1.DocEntry ) "InvoiceAssessableAmount",
		ISNULL((Select (case when  sum(x.RvsChrgTax)<=0  then sum(x.TaxSum)/t0.DocRate else 0 end) From RIN4 x Where x.DocEntry = t0.DocEntry and x.staType = -120 ),0) "InvoiceIGSTAmount",	
		ISNULL((Select (case when  sum(x.RvsChrgTax)<=0  then sum(x.TaxSum)/t0.DocRate else 0 end) From RIN4 x Where x.DocEntry = t0.DocEntry and x.staType = -100 ),0) "InvoiceCGSTAmount",	
		ISNULL((Select (case when  sum(x.RvsChrgTax)<=0  then sum(x.TaxSum)/t0.DocRate else 0 end) From RIN4 x Where x.DocEntry = t0.DocEntry and x.staType = -110 ),0) "InvoiceSGSTAmount",
		'' "InvoiceCessAdvaloremAmount",	'0' "InvoiceCessSpecificAmount",	'0'	"InvoiceStateCessAdvaloremAmount",	'0'	"InvoiceStateCessSpecificAmount",	t0.DocTotal "InvoiceValue",
		''	"RoundOff",
		''	"TotalInvoiceValue(InWords)",	''	"TCSFlagIncomeTax",	''	"TCSRateIncomeTax",	''	"TCSAmountIncomeTax",	''	"CustomerPANOrAadhaar",	
		''	"CurrencyCode",	''	"CountryCode",	''	"InvoiceValueFC",'' "PortCode",
		'' "ShippingBillNumber",
		'' "ShippingBillDate",

			''	"InvoiceRemarks",	''	"InvoicePeriodStartDate",	''	"InvoicePeriodEndDate",	CAST(T0.RevRefNo AS CHAR)	"PreceedingInvoiceNumber",FORMAT(t0.RevRefDate,'yyyyMMdd')	"PreceedingInvoiceDate",


		''	"OtherReference",			''	"ReceiptAdviceReference",	''	"ReceiptAdviceDate",	 ''	"TenderReference",	

		''	"ContractReference",	''	"ExternalReference",	''	"ProjectReference",	''	"CustomerPOReferenceNumber",	''	"CustomerPOReferenceDate",''	"PayeeName",

			''	"ModeOfPayment",	''	"BranchOrIFSCCode",	''	"PaymentTerms",	''	"PaymentInstruction",
		''	"CreditTransfer",	''	"DirectDebit",	''	"CreditDays",	''	"PaidAmount",	''	"BalanceAmount",	''	"PaymentDueDate",
		''	"AccountDetail",' '	"EcomGSTIN",	''	"EcomTransactionID",	''	"SupportingDocURL",	''	"SupportingDocument",'' "AdditionalInformation",
		''	"TransactionType",	''	"SubSupplyType", ''	"OtherSupplyTypeDescription",	''	"TransporterID",	''	"TransporterName",	''	"TransportMode",	''	"TransportDocNo",	
		''	"TransportDocDate",	''	"Distance",	''	"VehicleNo",	''	"VehicleType",	((SELECT RIGHT('00' + CAST(DATEPART(mm, t0.DocDate) AS varchar(2)), 2)) + CAST(DATEPART(YYYY, t0.DocDate) as varchar(4))) "ReturnPeriod",
		''	"OriginalDocumentType",	'' "OriginalCustomerGSTIN",''	"DifferentialPercentageFlag",	''	"Section7OfIGSTFlag",
		''	"ClaimRefundFlag",	''	"AutoPopulateToRefund",	'' "CRDRPreGST",'' "CustomerType",T0.CardCode "CustomerCode",T1.ItemCode "ProductCode",t5.U_FGSUBGRP "CategoryOfProduct",CASE WHEN ISNULL(T0.VatSum,'0') = '0' THEN '' ELSE 'T1' END	"ITCFlag",
		''	"StateApplyingCess",(SELECT CASE WHEN T3.ImpORExp='Y' THEN T1.LineTotal ELSE '0.00' END ) "FOB",	'0'	"ExportDuty",
		''	"ExchangeRate",'' "ReasonForCreditDebitNote",' '	"TCSFlagGST",	''	"TCSIGSTAmount",	''	"TCSCGSTAmount",
		''	"TCSSGSTAmount",''	"TDSFlagGST",		''	"TDSIGSTAmount",	''	"TDSCGSTAmount",	''	"TDSSGSTAmount",	''	"UserID",		
		''	"CompanyCode",' '	"SourceIdentifier",	' '	"SourceFileName",t4.TanOfficer "PlantCode",'AD' "Division", ' '	"SubDivision",

			''	"Location",	''	"SalesOrganisation",	''	"DistributionChannel",' '	"ProfitCentre1",	 ' '	"ProfitCentre2",	''	"ProfitCentre3",	''	"ProfitCentre4",
		''	"ProfitCentre5",	''	"ProfitCentre6",	''	"ProfitCentre7",	''	"ProfitCentre8",	''	"GLAssessableValue",	
		''	"GLIGST",	''	"GLCGST",	''	"GLSGST",	''	"GLAdvaloremCess",	''	"GLSpecificCess",	''	"GLStateCessAdvalorem",	
		''	"GLStateCessSpecific",	''	"GLPostingDate",	''	"SalesOrderNumber",	''	"EWBNumber",	''	"EWBDate",t8.Number          "AccountingVoucherNumber",
		t8.refdate "AccountingVoucherDate",	

		''	"DocumentReferenceNumber",			
		''	"CustomerTAN",' '	"UserDefinedField1",	 
		' '	"UserDefinedField2",	 ' '	"UserDefinedField3",	 ' '	"UserDefinedField4",	 ' '	"UserDefinedField5",	 ' '	"UserDefinedField6",	 ' '	"UserDefinedField7",	 
		' '	"UserDefinedField8",	 ' '	"UserDefinedField9",	 ' '	"UserDefinedField10",	 ' '	"UserDefinedField11",	 ' '	"UserDefinedField12",	 ' '	"UserDefinedField13",	 
		' '	"UserDefinedField14",	 ' '	"UserDefinedField15",	 ' '	"UserDefinedField16",	 ' '	"UserDefinedField17",	 ' '	"UserDefinedField18",	 ' '	"UserDefinedField19",	 
		' '	"UserDefinedField20",	 ' '	"UserDefinedField21",	 ' '	"UserDefinedField22",	 ' '	"UserDefinedField23",	 ' '	"UserDefinedField24",	 ' '	"UserDefinedField25",	 
		' '	"UserDefinedField26",	 ' '	"UserDefinedField27",	 ' '	"UserDefinedField28",	 ' '	"UserDefinedField29",	 ' '	"UserDefinedField30"

		from 
 
		ORIN t0 
		inner join RIN1 T1 ON T0.DocEntry=T1.DocEntry
		INNER JOIN RIN12 T3 ON T1.DocEntry=T3.DocEntry
		INNER JOIN OLCT T4 ON T1.LocCode=T4.Code
		inner join RIN4 t9 on t1.DocEntry =t9.DocEntry and t9.staType in (-120,-100,-110)  and t9.RelateType=1 AND  T1.LineNum=T9.LineNum
		LEFT OUTER JOIN OITM T5 on T5.ItemCode = T1.ItemCode AND T0.DocType = 'I'
		LEFT OUTER JOIN OCHP T6 on T6.AbsEntry = T5.ChapterID
		LEFT OUTER JOIN OSAC T7 on T1.SacEntry = T7.AbsEntry
		left outer join ojdt t8 on t0.TransId=t8.TransId and t8.TransType=14
		INNER JOIN OCRD T10 ON T0.CardCode = T10.CardCode
		WHERE  T0.DocDate between @Fromdate and @ToDate  AND T0.Series not in (466,482,483,485)

		UNION ALL
		--====Sale Freight Return ==================================================================================================================================================================================================
		select DISTINCT 
		'' "IRN", '' "IRNDate", '' "TaxScheme", (SELECT T101.Comments FROM ORIN T101 WHERE T0.DocEntry = T101.DocEntry AND T101.CANCELED = 'Y') "CancellationReason",	''	"CancellationRemarks",	T0.U_SupplyType	"SSupplyType", T0.U_DocCate "DocCategory" ,
		T0.U_DocumentType  'DocumentType',
		 T0.DocNum "DocumentNumber",FORMAT(T0.DocDate,'yyyyMMdd') "DocumentDate",
		 (select case when sum(t8.RvsChrgPrc )>0  then 'Y' else 'N' end from RIN4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in (-120,-100,-110) ) "ReverseChargeFlag",
		 t3.LocGSTN "SupplierGSTIN",'' "SupplierTradeName", 
		 (SELECT CompnyName FROM OADM) "SupplierLegalName",
		 (SELECT CompnyAddr FROM OADM)	"SupplierAddress1",	(SELECT CompnyAddr FROM OADM) "SupplierAddress2",
		 (SELECT CompnyAddr FROM OADM) "SupplierLocation",
		(SELECT ZipCode FROM ADM1 ) "SupplierPincode",CAST((SELECT OCST.GSTCode FROM OADM INNER JOIN OCST ON OADM.State = OCST.Code AND OADM.Country = OCST.Country)AS CHAR) "SupplierStateCode", '' "SupplierPhone",
		'' "SupplierEmail",(SELECT CRD1.U_Bill_GSTNo FROM CRD1 WHERE  T0.CARDCODE=CRD1.CARDCODE AND T0.PayToCode =CRD1.Address AND CRD1.AdresType='B')"CustomerGSTIN",T0.CardName "CustomerTradeName",
		 T0.CardName "CustomerLegalName",T0.Address	"CustomerAddress1",T0.Address2	"CustomerAddress2",

		 T0.Address "CustomerLocation", CASE WHEN T0.U_SupplyType IN  ('EXPT', 'EXPWT') THEN  '999999' ELSE T3.ZipCodeB END "CustomerPincode",CASE WHEN T0.U_SupplyType IN  ('EXPT', 'EXPWT') THEN  '96' ELSE LEFT((SELECT CRD1.U_Bill_GSTNo FROM CRD1 WHERE  T0.CARDCODE=CRD1.CARDCODE AND T0.PayToCode =CRD1.Address AND CRD1.AdresType='B'),2) END	"CustomerStateCode",
		CASE WHEN T0.U_SupplyType IN  ('EXPT', 'EXPWT') THEN  '96' ELSE LEFT((SELECT CRD1.U_Bill_GSTNo FROM CRD1 WHERE  T0.CARDCODE=CRD1.CARDCODE AND T0.PayToCode =CRD1.Address AND CRD1.AdresType='B'),2) END	"BillingPOS",
		 '' "CustomerPhone",'' "CustomerEmail",'' "DispatcherGSTIN",(SELECT CompnyName FROM OADM) "DispatcherTradeName",(SELECT CompnyAddr FROM OADM)	"DispatcherAddress1",(SELECT CompnyAddr FROM OADM)	"DispatcherAddress2",


		(SELECT CompnyAddr FROM OADM) "DispatcherLocation",(SELECT ZipCode FROM ADM1) "DispatcherPincode", (SELECT OCST.GSTCode FROM OADM INNER JOIN OCST ON OADM.State = OCST.Code AND OADM.Country = OCST.Country) "DispatcherStateCode",
		'' "ShipToGSTIN", '' "ShipToTradeName",T0.CardName "ShipToLegalName",T0.Address2	"ShipToAddress1",T0.Address2 "ShipToAddress2",

		 T0.Address2 "ShipToLocation",
		CASE WHEN T0.U_SupplyType IN  ('EXPT', 'EXPWT') THEN  '999999' 
		ELSE  
		(SELECT CRD1.ZipCode FROM CRD1  WHERE CRD1.CardCode = T0.CardCode AND CRD1.Address = T0.ShipToCode AND CRD1.AdresType = 'S') END "ShipToPincode",CASE WHEN T0.U_SupplyType IN  ('EXPT', 'EXPWT') THEN  '96' ELSE LEFT(T3.BpGSTN,2) END "ShipToStateCode",	 1	"ItemSerialNumber",	
		'' "ProductSerialNumber", ''	"ProductName",(select OEXD.ExpnsName from OEXD where t9.ExpnsCode=OEXD.ExpnsCode) "ProductDescription",
		 'N' "IsService", 
		 REPLACE((SELECT TOP 1 T22.[ChapterID] FROM RIN1 T00  
					INNER JOIN OITM T11 ON T00.[ItemCode] = T11.[ItemCode] 
					LEFT JOIN OCHP T22 ON T11.[ChapterID] = T22.[AbsEntry] 
					WHERE T00.[DocEntry] = T1.DocEntry),'.','')	"HSN",
		'' "Barcode",'' "BatchName", '' "BatchExpiryDate", '' "WarrantyDate",''	"OrderLineReference",
		 '' "AttributeName", '' "AttributeValue", '' "OriginCountry",'NOS'	"UQC",1.00 "Quantity",

		''	"FreeQuantity",	(SELECT SUM(LineTotal) FROM RIN3 WHERE DocEntry = T0.DocEntry AND ExpnsCode = 3 ) "UnitPrice",	(SELECT SUM(LineTotal) FROM RIN3 WHERE DocEntry = T0.DocEntry AND ExpnsCode = 3 )	"ItemAmount",	
		'0'	"ItemDiscount",	'0'	"PreTaxAmount", (SELECT SUM(LineTotal) FROM RIN3 WHERE DocEntry = T0.DocEntry AND ExpnsCode = 3 )	"ItemAssessableAmount",	
		(select distinct T8.TaxRate from RIN4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-120 ) and t8.RelateType=3) "IGSTRate",
		isnull((select sum(T8.TaxSum) from RIN4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-120 )  and t8.RelateType=3),0) "IGSTAmount",
		(select  distinct (T8.TaxRate) from INV4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-100) and t1.LineNum=t8.LineNum and t8.RelateType=1  ) "CGSTRate",
		isnull((select sum(T8.TaxSum) from RIN4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-100 )  and t8.RelateType=3),0) "CGSTAmount",
		(select  distinct (T8.TaxRate) from RIN4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-110) and t8.RelateType=3  ) "SGSTRate",
		ISNULL((select sum(T8.TaxSum) from RIN4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-110) and t8.RelateType=3),0)"SGSTAmount",
		' '	"CessAdvaloremRate",'0'	"CessAdvaloremAmount",' '	"CessSpecificRate",	'0'	"CessSpecificAmount",
		'0' "StateCessAdvaloremRate",	'0'	"StateCessAdvaloremAmount",	'0'	"StateCessSpecificRate",	'0'	"StateCessSpecificAmount",
		(SELECT SUM(A.TaxSum) FROM RIN4 A WHERE A.DocEntry = T1.DocEntry AND A.staType = 9 AND A.RelateType = 3 )	"ItemOtherCharges",
		isnull((select sum(T8.TaxSum) from RIN4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-120 )  and t8.RelateType=3),0)+
		isnull((select sum(T8.TaxSum) from RIN4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-100 )  and t8.RelateType=3),0)+
		ISNULL((select sum(T8.TaxSum) from RIN4 t8 where T8.DocEntry = t0.DocEntry and t8.staType in(-110) and t8.RelateType=3),0)+
		ISNULL((SELECT SUM(A.TaxSum) FROM INV4 A WHERE A.DocEntry = T1.DocEntry AND A.staType = 9 AND A.RelateType = 3 ),0)+
		ISNULL((SELECT SUM(LineTotal) FROM RIN3 WHERE DocEntry = T0.DocEntry AND ExpnsCode = 3),0)
		
		"TotalItemAmount",	
		''	"InvoiceOtherCharges",T0.TotalExpns+(SELECT SUM(LineTotal) FROM RIN1 WHERE RIN1.DocEntry = T1.DocEntry ) "InvoiceAssessableAmount",
		ISNULL((Select (case when  sum(x.RvsChrgTax)<=0  then sum(x.TaxSum)/t0.DocRate else 0 end) From RIN4 x Where x.DocEntry = t0.DocEntry and x.staType = -120 ),0) "InvoiceIGSTAmount",	
		ISNULL((Select (case when  sum(x.RvsChrgTax)<=0  then sum(x.TaxSum)/t0.DocRate else 0 end) From RIN4 x Where x.DocEntry = t0.DocEntry and x.staType = -100 ),0) "InvoiceCGSTAmount",	
		ISNULL((Select (case when  sum(x.RvsChrgTax)<=0  then sum(x.TaxSum)/t0.DocRate else 0 end) From RIN4 x Where x.DocEntry = t0.DocEntry and x.staType = -110 ),0) "InvoiceSGSTAmount",

		'' "InvoiceCessAdvaloremAmount",	'0' "InvoiceCessSpecificAmount",	'0'	"InvoiceStateCessAdvaloremAmount",	'0'	"InvoiceStateCessSpecificAmount",	t0.DocTotal "InvoiceValue",
		''	"RoundOff",
		''	"TotalInvoiceValue(InWords)",	''	"TCSFlagIncomeTax",	''	"TCSRateIncomeTax",	''	"TCSAmountIncomeTax",	''	"CustomerPANOrAadhaar",	
		''	"CurrencyCode",	''	"CountryCode",	''	"InvoiceValueFC",'' "PortCode",
		'' "ShippingBillNumber",
		'' "ShippingBillDate",

			''	"InvoiceRemarks",	''	"InvoicePeriodStartDate",	''	"InvoicePeriodEndDate",	CAST(T0.RevRefNo AS CHAR)	"PreceedingInvoiceNumber",FORMAT(t0.RevRefDate,'yyyyMMdd')	"PreceedingInvoiceDate",


		''	"OtherReference",			''	"ReceiptAdviceReference",	''	"ReceiptAdviceDate", ''	"TenderReference",	

		''	"ContractReference",	''	"ExternalReference",	''	"ProjectReference",	''	"CustomerPOReferenceNumber",	''	"CustomerPOReferenceDate",''	"PayeeName",

			''	"ModeOfPayment",	''	"BranchOrIFSCCode",	''	"PaymentTerms",	''	"PaymentInstruction",
		''	"CreditTransfer",	''	"DirectDebit",	''	"CreditDays",	''	"PaidAmount",	''	"BalanceAmount",	''	"PaymentDueDate",
		''	"AccountDetail",' '	"EcomGSTIN",	''	"EcomTransactionID",	''	"SupportingDocURL",	''	"SupportingDocument",'' "AdditionalInformation",
		''	"TransactionType",	''	"SubSupplyType", ''	"OtherSupplyTypeDescription",	''	"TransporterID",	''	"TransporterName",	''	"TransportMode",	''	"TransportDocNo",	
		''	"TransportDocDate",	''	"Distance",	''	"VehicleNo",	''	"VehicleType",	
		((SELECT RIGHT('00' + CAST(DATEPART(mm, t0.DocDate) AS varchar(2)), 2)) + CAST(DATEPART(YYYY, t0.DocDate) as varchar(4))) "ReturnPeriod",
		''	"OriginalDocumentType",	'' "OriginalCustomerGSTIN",''	"DifferentialPercentageFlag",	''	"Section7OfIGSTFlag",	
		''	"ClaimRefundFlag",	''	"AutoPopulateToRefund",	'' "CRDRPreGST",'' "CustomerType",T0.CardCode "CustomerCode",'' "ProductCode",'' "CategoryOfProduct",CASE WHEN ISNULL(T0.VatSum,'0') = '0' THEN '' ELSE 'T1' END	"ITCFlag",
		''	"StateApplyingCess",(SELECT CASE WHEN T3.ImpORExp='Y' THEN T1.LineTotal ELSE '0.00' END ) "FOB",	'0'	"ExportDuty",
		''	"ExchangeRate",'' "ReasonForCreditDebitNote",' '	"TCSFlagGST",	''	"TCSIGSTAmount",	''	"TCSCGSTAmount",
		''	"TCSSGSTAmount",''	"TDSFlagGST",		''	"TDSIGSTAmount",	''	"TDSCGSTAmount",	''	"TDSSGSTAmount",	''	"UserID",		
		''	"CompanyCode",' '	"SourceIdentifier",	' '	"SourceFileName",t4.TanOfficer "PlantCode",'AD' "Division", ' '	"SubDivision",

			''	"Location",	''	"SalesOrganisation",	''	"DistributionChannel",' '	"ProfitCentre1",	 ' '	"ProfitCentre2",	''	"ProfitCentre3",	''	"ProfitCentre4",
		''	"ProfitCentre5",	''	"ProfitCentre6",	''	"ProfitCentre7",	''	"ProfitCentre8",	''	"GLAssessableValue",	
		''	"GLIGST",	''	"GLCGST",	''	"GLSGST",	''	"GLAdvaloremCess",	''	"GLSpecificCess",	''	"GLStateCessAdvalorem",	
		''	"GLStateCessSpecific",	''	"GLPostingDate",	''	"SalesOrderNumber",	''	"EWBNumber",	''	"EWBDate",t8.Number          "AccountingVoucherNumber",
		t8.refdate "AccountingVoucherDate",	

		''	"DocumentReferenceNumber",			
		''	"CustomerTAN",' '	"UserDefinedField1",	 
		' '	"UserDefinedField2",	 ' '	"UserDefinedField3",	 ' '	"UserDefinedField4",	 ' '	"UserDefinedField5",	 ' '	"UserDefinedField6",	 ' '	"UserDefinedField7",	 
		' '	"UserDefinedField8",	 ' '	"UserDefinedField9",	 ' '	"UserDefinedField10",	 ' '	"UserDefinedField11",	 ' '	"UserDefinedField12",	 ' '	"UserDefinedField13",	 
		' '	"UserDefinedField14",	 ' '	"UserDefinedField15",	 ' '	"UserDefinedField16",	 ' '	"UserDefinedField17",	 ' '	"UserDefinedField18",	 ' '	"UserDefinedField19",	 
		' '	"UserDefinedField20",	 ' '	"UserDefinedField21",	 ' '	"UserDefinedField22",	 ' '	"UserDefinedField23",	 ' '	"UserDefinedField24",	 ' '	"UserDefinedField25",	 
		' '	"UserDefinedField26",	 ' '	"UserDefinedField27",	 ' '	"UserDefinedField28",	 ' '	"UserDefinedField29",	 ' '	"UserDefinedField30"
		from 
 
		ORIN t0 
		inner join RIN1 T1 ON T0.DocEntry=T1.DocEntry
		INNER JOIN RIN12 T3 ON T1.DocEntry=T3.DocEntry
		INNER JOIN OLCT T4 ON T1.LocCode=T4.Code
		inner join RIN4 t9 on t1.DocEntry =t9.DocEntry and t9.staType in (-120,-100,-110)  and t9.RelateType=3 --AND  T1.LineNum=T9.LineNum
		LEFT OUTER JOIN OITM T5 on T5.ItemCode = T1.ItemCode AND T0.DocType = 'I'
		LEFT OUTER JOIN OCHP T6 on T6.AbsEntry = T5.ChapterID
		LEFT OUTER JOIN OSAC T7 on T1.SacEntry = T7.AbsEntry
		left outer join ojdt t8 on t0.TransId=t8.TransId and t8.TransType=14
		INNER JOIN OCRD T10 ON T0.CardCode = T10.CardCode
		where T0.DocDate between @Fromdate and @ToDate  AND T0.Series not in (466,482,483,485)
		group by t4.TanCirNo,t4.TanWardNo,t1.AcctCode,t0.DocDate,t3.LocGSTN,t0.Series,t0.ObjType,t0.DocNum,t0.CardCode,t0.PayToCode,t0.ShipToCode,t3.StateB,t3.StateS,t3.CountryB,t3.CountryS,t3.BpStateCod,t3.BpCountry,
		t3.ImpORExp,t1.LineTotal,t9.ExpnsCode,t9.BaseSum,t9.staType,t9.StaCode,t9.TaxRate,t0.DocEntry,t0.DocTotal,t8.Number,t8.RefDate, t4.TanOfficer,T1.LineNum,T3.BpGSTType,T0.CardName
		,T0.Address,T0.Address2,T3.BpGSTN,T0.DocType,T0.Comments ,CAST(T10.AliasName AS NVARCHAR(MAX)),T3.ZipCodeB,T0.VatSum,T0.U_DocumentType,T0.U_SupplyType,T0.U_DocCate,T1.DocEntry,
		T0.RevRefNo,T0.RevRefDate,T5.ChapterID, T0.TotalExpns,t0.DocRate
	
	) A order by a.DocumentNumber,a.ItemSerialNumber

END 