USE [MSPLNew_Live_@25062024]
GO
/****** Object:  StoredProcedure [dbo].[SBO_SP_TransactionNotification]    Script Date: 12/12/2024 5:34:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[SBO_SP_TransactionNotification] 

@object_type nvarchar(30), 				-- SBO Object Type
@transaction_type nchar(1),			-- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
@num_of_cols_in_key int,
@list_of_key_cols_tab_del nvarchar(255),
@list_of_cols_val_tab_del nvarchar(255)

AS

begin

-- Return values
declare @error  int				-- Result (0 for no error)
declare @error_message nvarchar (200) 		-- Error string to be displayed
select @error = 0
select @error_message = N'Ok'

--------------------------------------------------------------------------------------------------------------------------------

If @object_type = '202' and  @transaction_type IN ('A','U')
BEGIN 
if exists 
 (Select t0.DocEntry
from OWOR t0 
Left Join (Select Sum(m.Quantity) 'Qty',k.DocEntry,M.ItemCode
From ORDR k
Inner Join RDR1 M on k.DocEntry = M.DocEntry
Group by k.DocEntry,M.ItemCode)JJ on JJ.ItemCode = t0.ItemCode and jj.DocEntry = t0.OriginAbs
Where t0.DocEntry = @list_of_cols_val_tab_del and t0.PlannedQty > JJ.Qty) 
begin
set @error =100
set @error_message = 'Please Check Sales Order Quantity' 
end
End
--------------------------------Sandeep--------------------------------------------
If @object_type = '59' and @transaction_type in ('A','U')
Begin
IF Exists (SELECT t0.DocEntry 

					   FROM OWOR T0
                       INNER JOIN IGN1 T1 ON T1."BaseEntry" =T0."DocEntry"  AND T1."ItemCode"=T0."ItemCode" AND T1."BaseType"='202' 
					   Inner Join Oign t2 on t2.DocEntry = t1.DocEntry

					   Left Join (
					   Select (T0.PlannedQty*10)/100 'Qty',T1.DocEntry
					   FROM OWOR T0
                       INNER JOIN IGN1 T1 ON T1."BaseEntry" =T0."DocEntry"  AND T1."ItemCode"=T0."ItemCode" AND T1."BaseType"='202' 
					   Where T1.DocEntry =  @list_of_cols_val_tab_del)M on M.DocEntry = t2.DocEntry

					   WHERE T1.DocEntry =  @list_of_cols_val_tab_del  and  (T0.CmpltQty > (T0.PlannedQty)) and t1.BaseType = '202')						
			BEGIN
				SET @error = 1001
				SET @error_message = 'CAN NOT RECEIPT MORE THAN PLAN QTY!!!'
end 
end
----------------------------Sandeep-------------------------------
IF (@object_type = '60' AND @transaction_type = 'A') 
	BEGIN  
			IF EXISTS  (SELECT T0.DocEntry
						FROM IGE1 (NOLOCK) T0
						INNER JOIN WOR1 (NOLOCK) T1 ON T0.BaseEntry = T1.DocEntry AND T0.BaseType = '202'  
						AND T0.BaseLine = T1.LineNum
						WHERE T0.DocEntry = @list_of_cols_val_tab_del 
						AND ISNULL(T1.IssuedQty, 0.00) > ISNULL(T1.PlannedQty, 0.00)   )  
			BEGIN  
				SET @error = 1  
				SET @error_message = 'You can not issue more than planned !'  
			END  
	END 
-----------------------------Sandeep----------------------------------
If @object_type = '202' and @transaction_type in ('A','U')
Begin
IF Exists (
Select t0.DocEntry
from OWOR T0
Left Join(
Select Sum(B.BaseQty) AS 'ProdQty',Sum(D.Quantity) AS 'BomQty',
B.DocEntry,D.Code,b.ItemCode
from OWOR A
Inner Join WOR1 B on A.DocEntry = B.DocEntry
Left Join ITT1 D on D.Father = a.ItemCode and b.ItemCode = D.Code
where A.DocEntry = @list_of_cols_val_tab_del --and b.ItemType = '4'
Group By b.DocEntry,D.Code,b.ItemCode)M on M.DocEntry =  T0.DocEntry
where t0.DocEntry = @list_of_cols_val_tab_del and m.ProdQty <> m.BomQty)
Begin
Set @error = 30
Set @error_message = 'Base Quantity should be same as Bom Quantity'
end 
end
------------------------------Sandeep------------------------------------
IF (@object_type = '59' AND @transaction_type = 'A') 
	BEGIN  
			IF EXISTS (Select top 1 T1.Status From OWOR T1 inner join WOR1 T2
				 On T1.DocEntry=T2.DocEntry Where T1.DocEntry in (select  T3.BaseEntry from IGN1 T3 where T3.DocEntry =@list_of_cols_val_tab_del and T3.TranType is not null)
				 and (T1.U_oldProduction='Yes' or T2.U_Shortage='Yes')and ISNULL(T2.PlannedQty,0.00) <> ISNULL(T2.IssuedQty,0.00))
			Begin
			
			select @error =11, @error_message = 'Please check, Issue from production not yet done!'
			
			END  
	END  
--------------------------------Sandeep--------------------------------
If @object_type = '1250000001' and @transaction_type in ('A','U')
Begin
IF Exists ( SELECT T0.DocEntry

						FROM OWtQ K
						Inner JOin WTQ1 T0 on t0.DocEntry = K.DocEntry
						Inner join WTQ21 t2 on t2.DocEntry = t0.DocEntry
						Left join (
						Select l.DocNum,l.DocEntry,ll.ItemCode AS "Item",Sum(ll.PlannedQty) 'planQty'
						From  OWOR l
						INNER JOIN WOR1 ll ON l.DocEntry = ll.DocEntry
						Group by l.DocNum,l.DocEntry,ll.ItemCode )kk on kk.DocEntry = t2.RefDocEntr and kk.DocNum = t2.RefDocNum and kk.Item = t0.ItemCode 	
						left Join
						(Select k.RefDocNum,Sum(pp.Quantity) 'Qty' , pp.ItemCode
						FROM OWtQ p
						Inner JOin WTQ1 pp on p.DocEntry = pp.DocEntry
						Inner join WTQ21 k on k.DocEntry = pp.DocEntry
						Group by k.RefDocNum,pp.ItemCode)JJ on JJ.RefDocNum = kk.DocNum and jj.ItemCode = kk.Item
															 
					    WHERE k.DocEntry = @list_of_cols_val_tab_del and jj.Qty > kk.planQty)	
			BEGIN
				SET @error = 1001
				SET @error_message = 'Treanfer request Quantity is greater than plan Quantity'
end 
end
-------------------------------------------------------------------
IF @transaction_type IN ('A','U') AND (@object_type = '22')
	BEGIN	
		IF EXISTS (Select T0.Docentry From POR1 T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.TaxCode,'') = '')
		
		BEGIN 
			SELECT @error = 101, @error_message = 'TaxCode Is missing on Purchase Order '

		END
	END
------------------------------------------------------------------
	IF @transaction_type IN ('A','U') AND (@object_type = '22')
	BEGIN	
		IF EXISTS (Select T0.Docentry From POR1 T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.HsnEntry,'') = '' and t0.ItemType <> '4')
		
		BEGIN 
			SELECT @error = 101, @error_message = 'HSN Code Is missing on Purchase Order '

		END
	END
------------------------------------------------------------
IF @transaction_type IN ('A','U') AND (@object_type = '17')
	BEGIN	
		IF EXISTS (Select T0.Docentry From ORDR T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 101, @error_message = 'Project Is missing on Sales Order Header'

		END
	END

-----------------------------------------------------------
IF @transaction_type IN ('A','U') AND (@object_type = '17')

	BEGIN
		IF EXISTS (Select T0.DocEntry From RDR1 t0
		where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')

		BEGIN 
			SELECT @error = 102, @error_message = 'Project Is missing on Sales Order Row'

		END
	END
-------------------------Delivery------------------
IF @transaction_type IN ('A','U') AND (@object_type = '15')

	BEGIN
		IF EXISTS (Select T0.DocEntry From DLN1 t0
		where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')

		BEGIN 
			SELECT @error = 103, @error_message = 'Project Is missing on Delivery Row'

		END
	END
-----------------------------------------------------------
IF @transaction_type IN ('A','U') AND (@object_type = '15')
	BEGIN	
		IF EXISTS (Select T0.Docentry From ODLN T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 104, @error_message = 'Project Is missing on Delivery Header'

		END
	END
-----------------------------------------AR INVOICE-------------------------------------------------
IF @transaction_type IN ('A','U') AND (@object_type = '13')
	BEGIN	
		IF EXISTS (Select T0.Docentry From OINV T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 105, @error_message = 'Project Is missing on Invoice Header'

		END
	END
-----------------------------------------------------------
IF @transaction_type IN ('A','U') AND (@object_type = '13')
	BEGIN	
		IF EXISTS (Select T0.Docentry From INV1 T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 106, @error_message = 'Project Is missing on Invoice Rows'

		END
	END

-----------------------------CREDIT NOTE-----------------
IF @transaction_type IN ('A','U') AND (@object_type = '14')
	BEGIN	
		IF EXISTS (Select T0.Docentry From ORIN T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 105, @error_message = 'Project Is missing on Credit Note Header'

		END
	END
-----------------------------------------------------------
IF @transaction_type IN ('A','U') AND (@object_type = '14')
	BEGIN	
		IF EXISTS (Select T0.Docentry From RIN1 T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 106, @error_message = 'Project Is missing on Credit Note Rows'

		END
	END
----------------------------------------PURCHASE ORDER-----------------
IF @transaction_type IN ('A','U') AND (@object_type = '22')
	BEGIN	
	UPDATE T0 SET T0.Project=t1.Project From POR1 T0 Inner Join OPOR T1 On T1.DocEntry=T0.DocEntry Where T0.DocEntry = @list_of_cols_val_tab_del;
		IF EXISTS (Select T0.Docentry From POR1 T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 107, @error_message = 'Project Is missing on PO Rows'

		END
	END
---------------------------------------------------------
IF @transaction_type IN ('A','U') AND (@object_type = '22')
	BEGIN	
		IF EXISTS (Select T0.Docentry From OPOR T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 108, @error_message = 'Project Is missing on PO HEADER'

		END
	END
-------------------------------------------------------PURCHASE REQUEST--------------------------
IF @transaction_type IN ('A','U') AND (@object_type = '1470000113')
	BEGIN	
		IF EXISTS (Select T0.Docentry From PRQ1 T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 109, @error_message = 'Project Is missing on Purchase Request Rows'

		END
	END

--------------------------------------------
/*	IF @transaction_type IN ('A','U') AND (@object_type = '1470000113')
	BEGIN	
		IF EXISTS (Select T0.Docentry From OPRQ T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 109, @error_message = 'Project Is missing on Purchase Request Header'

		END
	END */
----------------------------------------------------------------------------------------------
IF @transaction_type IN ('A','U') AND (@object_type = '20')
	BEGIN	
		IF EXISTS (Select T0.Docentry From PDN1 T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 111, @error_message = 'Project Is missing on GRPO Rows'

		END
	END
-----------------------------------------------------------
IF @transaction_type IN ('A','U') AND (@object_type = '20')
	BEGIN	
		IF EXISTS (Select T0.Docentry From OPDN T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 112, @error_message = 'Project Is missing on GRPO HEADER'

		END
	END
---------------------------------------------------------
IF @transaction_type IN ('A','U') AND (@object_type = '18')
	BEGIN	
		IF EXISTS (Select T0.Docentry From PCH1 T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 113, @error_message = 'Project Is missing on AP INVOICE Rows'

		END
	END
-----------------------------------------------------------
IF @transaction_type IN ('A','U') AND (@object_type = '18')
	BEGIN	
		IF EXISTS (Select T0.Docentry From OPCH T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 114, @error_message = 'Project Is missing on AP INVOICE HEADER'

		END
	END

-----------------------------------------------------------
IF @transaction_type IN ('A','U') AND (@object_type = '19')
	BEGIN	
		IF EXISTS (Select T0.Docentry From RPC1 T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 115, @error_message = 'Project Is missing on AP Debit note Rows'

		END
	END
-----------------------------------------------------------
IF @transaction_type IN ('A','U') AND (@object_type = '19')
	BEGIN	
		IF EXISTS (Select T0.Docentry From ORPC T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 116, @error_message = 'Project Is missing on AP Debit note HEADER'

		END
	END
-----------------------------------------------------------
IF @transaction_type IN ('A','U') AND (@object_type = '202')
BEGIN
	IF EXISTS(SELECT T0.DocEntry from OWOR t0
				Where T0.DocEntry = @list_of_cols_val_tab_del and isnull(t0.Project,'') = '')

			BEGIN
				SELECT @error = 117 ,@error_message = 'Project is missing on Production Header'
			END
END
------------------------------------------------------------------------

IF @transaction_type IN ('A','U') AND (@object_type = '60')
BEGIN 
	IF EXISTS(SELECT t1.DocEntry From IGE1 t1
				Where T1.DocEntry = @list_of_cols_val_tab_del and t1.basetype = 202 and  ISNULL(t1.Project,'') = '')

			BEGIN
				SELECT @error = 119 ,@error_message = 'Project is missing on Issue To Production Row'
			END
END
-----------------------------------------------------------------------------------------------------------

IF @transaction_type IN ('A','U') AND (@object_type = '59')
BEGIN 
	IF EXISTS(SELECT t1.DocEntry From IGN1 t1
				Where T1.DocEntry = @list_of_cols_val_tab_del and t1.basetype = 202 and  ISNULL(t1.Project,'') = '')

			BEGIN
				SELECT @error = 119 ,@error_message = 'Project is missing on Reciept From Production Row'
			END
END
---------------------------------------------------------------------------
/*IF @object_type ='22' AND @transaction_type IN ('A','U')
	BEGIN
		IF EXISTS(SELECT T0.DocEntry FROM OPOR
		inner Join POR1 T0 on t0.DocEntry = OPOR.DocEntry
		WHERE T0.DocEntry = @list_of_cols_val_tab_del AND T0.BaseType = -1 and opor.Series <> -1)
			BEGIN
				SET @error =1004
				SET @error_message = 'Purchase Order should be based on PR'
			END
		
	END*/
--------------------------------------------------------------
IF @object_type ='66' AND @transaction_type IN ('A','U')
	BEGIN
		IF EXISTS (SELECT t0.Code
		FROM OITT T0 WHERE T0.Code = @list_of_cols_val_tab_del AND Isnull(t0.U_Project,'') = '')
			BEGIN
				SET @error =1004
				SET @error_message = 'Please Enter Project '
			END
		
	END
	--------------------------------
	IF @object_type ='22' AND @transaction_type IN ('A','U')
	BEGIN
		IF EXISTS (SELECT t0.DocEntry
		FROM POR1 T0 WHERE T0.DocEntry = @list_of_cols_val_tab_del AND Isnull(t0.TaxCode,'') = '')
			BEGIN
				SET @error =1004
				SET @error_message = 'Please Enter Taxcode '
			END
		
	END
--------------------------------------------------
IF @object_type ='22' AND @transaction_type IN ('A','U')
	BEGIN
		IF EXISTS (SELECT t0.DocEntry
		FROM POR1 T0 WHERE T0.DocEntry = @list_of_cols_val_tab_del AND Isnull(t0.HsnEntry,'') = '' and t0.ItemType <> '4')
			BEGIN
				SET @error =1004
				SET @error_message = 'Please Enter HSN '
			END
		
	END
-----------------------------------------------
IF @object_type ='66' AND @transaction_type IN ('A','U')
	BEGIN
		IF EXISTS (SELECT t0.Code
		FROM OITT T0 WHERE T0.Code = @list_of_cols_val_tab_del AND isnull(t0.U_SlNo,'') = '')
			BEGIN
				SET @error =1004
				SET @error_message = 'Please Enter Sales Order No. '
			END
		
	END
	----------------------
	IF @object_type ='202' AND @transaction_type IN ('A','U')
	BEGIN
		IF EXISTS (SELECT t0.DocEntry
		FROM OWOR T0 WHERE T0.DocEntry = @list_of_cols_val_tab_del AND isnull(t0.OriginNum,'') = '')
			BEGIN
				SET @error =1004
				SET @error_message = 'Please Enter Sales Order No. '
			END
		
	END
--------------------------------------------------------------------------------------------------------------------------------
IF @object_type ='66' AND @transaction_type IN ('A','U')
	BEGIN
		IF EXISTS (SELECT t0.Code
		FROM OITT T0 WHERE T0.Code = @list_of_cols_val_tab_del AND isnull(t0.U_DrawingNo,'') = '')
			BEGIN
				SET @error =10041
				SET @error_message = 'Please Enter drawing No. '
			END
		
	END

IF @object_type ='66' AND @transaction_type IN ('A','U')
	BEGIN
		IF EXISTS (SELECT t0.Code
		FROM OITT T0 WHERE T0.Code = @list_of_cols_val_tab_del AND isnull(t0.U_DrawingDt,'') = '')
			BEGIN
				SET @error =10042
				SET @error_message = 'Please Enter drawing Dt '
			END
		
	END

IF @object_type ='66' AND @transaction_type IN ('A','U')
	BEGIN
		IF EXISTS (SELECT t0.Code
		FROM OITT T0 WHERE T0.Code = @list_of_cols_val_tab_del AND isnull(t0.U_DrwBy,'') = '')
			BEGIN
				SET @error =10043
				SET @error_message = 'Please Enter drawing by '
			END
		
	END
	-----------------------------------------------------------------
	/*IF @object_type ='66' AND @transaction_type IN ('A','U')
	BEGIN
	IF EXISTS
	(Select t0.Code from OITT t0
	where t0.Code = @list_of_cols_val_tab_del and t0.U_JOBAPP = 'YES' and t0.UserSign2 <> 8)
	BEGIN
				SET @error =10044
				SET @error_message = 'You Cannot Approve the BOM, Contact ADMIN '
	END
		
	END

	-------------------------------------------
	IF @object_type ='66' AND @transaction_type IN ('A','U')
	BEGIN
	IF EXISTS
	(Select t0.Code from OITT t0
	where t0.Code = @list_of_cols_val_tab_del and t0.U_JOBAPP = 'YES' and t0.UserSign <> 8)
	BEGIN
				SET @error =10045
				SET @error_message = 'You Cannot Approve the BOM, Contact ADMIN'
	END
		
	END

	---------------------------------------------
	IF @object_type ='202' AND @transaction_type IN ('A')
	BEGIN
	IF EXISTS
	(Select t0.DocEntry from OWOR t0
	Inner Join OITT t1 on t0.ItemCode = t1.Code
	Where T0.DocEntry = @list_of_cols_val_tab_del and ISnull(t1.U_JOBAPP,'No') <> 'YES'
	)
	BEGIN
				SET @error =20201
				SET @error_message = 'You Cannot ADD the Production Order, BOM is not approved,Contact ADMIN'
	END
		
	END*/

-------------------------------------------------
If @object_type = '18' and @transaction_type in ('A','U')
Begin
IF Exists (Select t0.DocEntry
From OPCH t0 
Inner join PCH1 t1 on t1.DocEntry = t0.DocEntry
Inner join OITM t2 on t2.ItemCode =  t1.ItemCode
Where t0.DocEntry = @list_of_cols_val_tab_del and t1.BaseType <> '20' and t0.CANCELED = 'N' and t0.DocType = 'I')
Begin
Set @error = 30
Set @error_message = 'AP should be based on the GRPO !'
end 
end

--------------------------------------------------------------------
If @object_type = '20' and @transaction_type in ('A','U')
Begin
IF Exists (Select t0.DocEntry
From OPDN t0 
Inner join PDN1 t1 on t1.DocEntry = t0.DocEntry
Inner join OITM t2 on t2.ItemCode =  t1.ItemCode
Where t0.DocEntry = @list_of_cols_val_tab_del and t1.BaseType <> '22' and t0.CANCELED = 'N')
Begin
Set @error = 303
Set @error_message = 'GRPO should be based on the PO !'
end 
end


-------------------------------------------------------------------------------
If @object_type = '13' and @transaction_type in ('A')
Begin
IF Exists (Select t0.DocEntry
From OINV t0 
Inner join INV1 t1 on t1.DocEntry = t0.DocEntry
Where t0.DocEntry = @list_of_cols_val_tab_del and T0.DocType='I' and t1.BaseType <> '15' and t0.CANCELED = 'N')
Begin
Set @error = 304
Set @error_message = 'AR invoice should be based on the Delivery !'
end 
end

-----------------------------------------------------------------------------

If @object_type = '15' and @transaction_type in ('A','U')
Begin
IF Exists (Select t0.DocEntry
From ODLN t0 
Inner join DLN1 t1 on t1.DocEntry = t0.DocEntry
Where t0.DocEntry = @list_of_cols_val_tab_del and t1.BaseType <> '17' and t0.CANCELED = 'N')
Begin
Set @error = 304
Set @error_message = 'Delivery should be based on the Sales Order !'
end 
END
--------------------------------------------------------------------------------
IF @transaction_type IN (N'A', N'U') AND (@Object_type = N'13')  
	BEGIN   
		IF EXISTS (SELECT T0.BaseEntry,T0.Quantity
					FROM [dbo].[INV1] (NOLOCK) T0 
					INNER JOIN [dbo].[dln1] (NOLOCK) T1 ON T1.DocEntry = T0.BaseEntry AND T0.BaseLine = T1.LineNum  
					INNER JOIN [dbo].OINV (NOLOCK) T2 ON T0.DocEntry = T2.DocEntry  
					--inner join [dbo].OITM (NOLOCK) T3 ON T1.ItemCode=T3.ITEMCODE
					
					WHERE T0.DOCENTRY = @list_of_cols_val_tab_del --and t2.UserSign2 not in (62) 
					 
					 	     
					
					GROUP BY T0.BaseEntry  ,t0.Quantity,t0.BaseOpnQty,t1.Quantity
					HAVING (T0.Quantity) > (T1.Quantity) --+(((T1.Quantity) *isnull(0,0.00))/100))
					
					 or (T0.Quantity) > ((T0.BaseOpnQty) + (((T0.BaseOpnQty) *isnull(0,0.00))/100)))  
		BEGIN  
				SELECT @error = 10, @error_message = 'Invoice quantity Can not be greater than the Delivery Quantity'  
		END  
	END
-------------------------------------------------------------------------------------------------
IF @transaction_type IN (N'A', N'U') AND (@Object_type = N'15')  
	BEGIN   
		IF EXISTS (SELECT T0.BaseEntry,T0.Quantity
					FROM [dbo].[dln1] (NOLOCK) T0 
					INNER JOIN [dbo].[RDR1] (NOLOCK) T1 ON T1.DocEntry = T0.BaseEntry AND T0.BaseLine = T1.LineNum  
					INNER JOIN [dbo].ODLN (NOLOCK) T2 ON T0.DocEntry = T2.DocEntry  
					--inner join [dbo].OITM (NOLOCK) T3 ON T1.ItemCode=T3.ITEMCODE
					
					WHERE T0.DOCENTRY = @list_of_cols_val_tab_del --and t2.UserSign2 not in (62) 
					 
					 	     
					
					GROUP BY T0.BaseEntry  ,t0.Quantity,t0.BaseOpnQty,t1.Quantity
					HAVING (T0.Quantity) > (T1.Quantity) --+(((T1.Quantity) *isnull(0,0.00))/100))
					
					 or (T0.Quantity) > ((T0.BaseOpnQty) + (((T0.BaseOpnQty) *isnull(0,0.00))/100)))  
		BEGIN  
				SELECT @error = 10, @error_message = 'Delivery quantity Can not be greater than the Sales order Quantity'  
		END  
	END

	---------------------------------------------------------------------------------------------------------------------
	IF @transaction_type IN ('A','U') AND @object_type in ('15')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry from DLN1 t0
				Inner Join RDR1 t1 on t0.BaseEntry =t1.DocEntry and t0.BaseLine = t1.LineNum
				iNNER jOIN odln T2 ON t0.DocEntry = T2.DocEntry
				Where t0.DocEntry = @list_of_cols_val_tab_del and t0.Price <> t1.Price AND T2.CANCELED = 'N'
				)
	BEGIN
	SELECT @error = 94,@error_message = 'Delivery Item Price Cannot be diffrent than Sales Order Item Price'
	END
	END
	--------------------------------------------------------------------------------------------------------------
		IF @transaction_type IN ('A','U') AND @object_type in ('13')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry from INV1 t0
				Inner Join DLN1 t1 on t0.BaseEntry =t1.DocEntry and t0.BaseLine = t1.LineNum
				Where t0.DocEntry = @list_of_cols_val_tab_del and t0.Price <> t1.Price
				)
	BEGIN
	SELECT @error = 95,@error_message = 'Invoice Item Price Cannot be diffrent than Delivery Item Price'
	END
	END
-----------------------------------------------------------------------
   IF @transaction_type IN ('A','U') AND @object_type in ('17')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry 
				from ORDR t0
				
				Where t0.DocEntry = @list_of_cols_val_tab_del and Isnull(t0.U_ProjectName,'') = ''
				)
	BEGIN
	SELECT @error = 95,@error_message = 'Please Enter Project Name'
	END
	END
---------------------------------------------------------------------
   IF @transaction_type IN ('A','U') AND @object_type in ('17')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry 
				from ORDR t0
				inner join RDR1 t1 on t1.DocEntry = t0.DocEntry
				Left join OCHP t2 on t2.AbsEntry = t1.HsnEntry
				
				Where t0.DocEntry = @list_of_cols_val_tab_del and Isnull(t2.ChapterID,'') = '' and t1.ItemType <> '4' 
				)
	BEGIN
	SELECT @error = 95,@error_message = 'Please Select HSN Code'
	END
	END
--------------------------------------------------------------------
   IF @transaction_type IN ('A','U') AND @object_type in ('17')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry 
				from ORDR t0
				inner join RDR1 t1 on t1.DocEntry = t0.DocEntry
				
				
				Where t0.DocEntry = @list_of_cols_val_tab_del and Isnull(t1.TaxCode,'') = ''
				)
	BEGIN
	SELECT @error = 95,@error_message = 'Please Select TaxCode'
	END
	END
-----------------------------
   IF @transaction_type IN ('A','U') AND @object_type in ('22')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry 
				from OPOR t0
				inner join POR1 t1 on t1.DocEntry = t0.DocEntry
				
				
				Where t0.DocEntry = @list_of_cols_val_tab_del and Isnull(t1.TaxCode,'') = ''
				)
	BEGIN
	SELECT @error = 95,@error_message = 'Please Select TaxCode'
	END
	END

--------------------------------------------------------------------------
   IF @transaction_type IN ('A','U') AND @object_type in ('17')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry 
				from ORDR t0
				inner join RDR1 t1 on t1.DocEntry = t0.DocEntry
				
				
				Where t0.DocEntry = @list_of_cols_val_tab_del and Isnull(t1.WhsCode,'') = ''
				)
	BEGIN
	SELECT @error = 95,@error_message = 'Please Select Warehouse'
	END
	END
----------------------------------------------------------------------------
   IF @transaction_type IN ('A','U') AND @object_type in ('22')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry 
				from OPOR t0
				inner join POR1 t1 on t1.DocEntry = t0.DocEntry
				
				
				Where t0.DocEntry = @list_of_cols_val_tab_del and Isnull(t1.WhsCode,'') = '' and t1.ItemType <> '4' 
				)
	BEGIN
	SELECT @error = 95,@error_message = 'Please Select Warehouse'
	END
	End

----------------------------------------------------
	   IF @transaction_type IN ('A','U') AND @object_type in ('22')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry 
				from OPOR t0
	
				Where t0.DocEntry = @list_of_cols_val_tab_del and Isnull(t0.U_Packing_Charge,'') = ''
				)
	BEGIN
	SELECT @error = 95,@error_message = 'Please Select Packing Charge'
	END
	End
----------------------------------------------------
	   IF @transaction_type IN ('A','U') AND @object_type in ('22')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry 
				from OPOR t0
	
				Where t0.DocEntry = @list_of_cols_val_tab_del and Isnull(t0.U_Freight_Charge,'') = ''
				)
	BEGIN
	SELECT @error = 95,@error_message = 'Please Select Freight Charge'
	END
	End
-------------------------------------------------------------------------------------------------------------
   IF @transaction_type IN ('A','U') AND @object_type in ('112')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry 
				from ODRF t0
				inner join DRF1 t1 on t1.DocEntry = t0.DocEntry
				
				
				Where t0.DocEntry = @list_of_cols_val_tab_del and Isnull(t1.WhsCode,'') = '' and t0.objtype = 17 and t0.DocType = 'I'
				)
	BEGIN
	SELECT @error = 95,@error_message = 'Please Select Warehouse'
	END
	END
----------------------------------------------------------------------------
   IF @transaction_type IN ('A','U') AND @object_type in ('112')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry 
				from ODRF t0
				inner join DRF1 t1 on t1.DocEntry = t0.DocEntry
				
				
				Where t0.DocEntry = @list_of_cols_val_tab_del and Isnull(t1.WhsCode,'') = '' and t0.objtype = 22 and t0.DocType = 'I'
				)
	BEGIN
	SELECT @error = 95,@error_message = 'Please Select Warehouse'
	END
	End
----------------------------------------------------------------------
   IF @transaction_type IN ('A','U') AND @object_type in ('112')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry 
				from ODRF t0
				inner join DRF1 t1 on t1.DocEntry = t0.DocEntry

				Where t0.DocEntry = @list_of_cols_val_tab_del and Isnull(t1.TaxCode,'') = '' and t0.objtype = 17
				)
	BEGIN
	SELECT @error = 95,@error_message = 'Please Select TaxCode'
	END
	END
-----------------------------
   IF @transaction_type IN ('A','U') AND @object_type in ('112')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry 
				from ODRF t0
				inner join DRF1 t1 on t1.DocEntry = t0.DocEntry

				Where t0.DocEntry = @list_of_cols_val_tab_del and Isnull(t1.TaxCode,'') = '' and t0.objtype = 22
				)
	BEGIN
	SELECT @error = 95,@error_message = 'Please Select TaxCode'
	END
	END
-------------------------------------------------------------------------------
   IF @transaction_type IN ('A','U') AND @object_type in ('22')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry 
				from OPOR t0
				inner join Crd1 t1 on t1.CardCode  = t0.CardCode and t0.ShipToCode = t1.Address and t1.AdresType =  'S'

				Where t0.DocEntry = @list_of_cols_val_tab_del and Isnull(t1.GSTRegnNo,'') = ''
				)
	BEGIN
	SELECT @error = 95,@error_message = 'Please Enter GST No. ShipTo'
	END
	END
----------------------------------------------------------------------------
   IF @transaction_type IN ('A','U') AND @object_type in ('22')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry 
				from OPOR t0
				inner join Crd1 t1 on t1.CardCode  = t0.CardCode and t0.PayToCode = t1.Address and t1.AdresType =  'B'

				Where t0.DocEntry = @list_of_cols_val_tab_del and Isnull(t1.GSTRegnNo,'') = ''
				)
	BEGIN
	SELECT @error = 95,@error_message = 'Please Enter GST No.Bill To'
	END
	END
-------------------------------------------------------------------------------
   IF @transaction_type IN ('A','U') AND @object_type in ('17')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry 
				from ORDR t0
				inner join Crd1 t1 on t1.CardCode  = t0.CardCode and t0.ShipToCode = t1.Address and t1.AdresType =  'S'

				Where t0.DocEntry = @list_of_cols_val_tab_del and Isnull(t1.GSTRegnNo,'') = ''
				)
	BEGIN
	SELECT @error = 95,@error_message = 'Please Enter GST No. ShipTo'
	END
	END
----------------------------------------------------------------------------
   IF @transaction_type IN ('A','U') AND @object_type in ('17')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry 
				from ORDR t0
				inner join Crd1 t1 on t1.CardCode  = t0.CardCode and t0.PayToCode = t1.Address and t1.AdresType =  'B'

				Where t0.DocEntry = @list_of_cols_val_tab_del and Isnull(t1.GSTRegnNo,'') = ''
				)
	BEGIN
	SELECT @error = 95,@error_message = 'Please Enter GST No.Bill To'
	END
	END

---------------------------------------------------------------
   IF @transaction_type IN ('A','U') AND @object_type in ('112')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry 
				from ODRF t0
				inner join Crd1 t1 on t1.CardCode  = t0.CardCode and t0.PayToCode = t1.Address and t1.AdresType =  'B' and t0.ObjType = 22

				Where t0.DocEntry = @list_of_cols_val_tab_del and Isnull(t1.GSTRegnNo,'') = ''
				)
	BEGIN
	SELECT @error = 95,@error_message = 'Please Enter GST No.Bill To'
	END
	END
-------------------------------------------------------------------------
   IF @transaction_type IN ('A','U') AND @object_type in ('112')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry 
				from ODRF t0
				inner join Crd1 t1 on t1.CardCode  = t0.CardCode and t0.ShipToCode = t1.Address and t1.AdresType =  'S' and t0.ObjType = 22
				Where t0.DocEntry = @list_of_cols_val_tab_del and Isnull(t1.GSTRegnNo,'') = ''
				)
	BEGIN
	SELECT @error = 95,@error_message = 'Please Enter GST No. Ship To'
	END
	END
-------------------------------------------------------------------------------
   IF @transaction_type IN ('A','U') AND @object_type in ('17')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry 
				from ODRF t0
				inner join Crd1 t1 on t1.CardCode  = t0.CardCode and t0.ShipToCode = t1.Address and t1.AdresType =  'S'

				Where t0.DocEntry = @list_of_cols_val_tab_del and Isnull(t1.GSTRegnNo,'') = ''
				)
	BEGIN
	SELECT @error = 95,@error_message = 'Please Enter GST No. ShipTo'
	END
	END
----------------------------------------------------------------------------
   IF @transaction_type IN ('A','U') AND @object_type in ('17')
	BEGIN
	IF EXISTS(
				Select t0.DocEntry 
				from ODRF t0
				inner join Crd1 t1 on t1.CardCode  = t0.CardCode and t0.PayToCode = t1.Address and t1.AdresType =  'B'

				Where t0.DocEntry = @list_of_cols_val_tab_del and Isnull(t1.GSTRegnNo,'') = ''
				)
	BEGIN
	SELECT @error = 95,@error_message = 'Please Enter GST No.Bill To'
	END
	END

-------------------------------------------------Invoice Approval_NEW-------------------------------------

IF @object_type='18' and @transaction_type IN ('A','U')
BEGIN
If 0 < (select count(PCH1.ItemCode) from OPCH inner join PCH1 on OPCH.DocEntry=PCH1.DocEntry

 INNER JOIN dbo.TK_PO_AP_AMTDIFF ON dbo.OPCH.DocEntry = dbo.TK_PO_AP_AMTDIFF.DocEntry 
                                                
left  join OPDN on OPDN.DocEntry=PCH1.BaseEntry and OPDN.ObjType=PCH1.BaseType
left join PDN1 on PDN1.DocEntry=OPDN.DocEntry and PDN1.ItemCode=PCH1.ItemCode

left  join OPOR on OPOR.DocEntry=PDN1.BaseEntry and OPOR.ObjType=PDN1.BaseType
left join POR1 on POR1.DocEntry=OPOR.DocEntry and POR1.ItemCode=PCH1.ItemCode
where PCH1.Price>POR1.Price and OPCH.DocEntry=@list_of_cols_val_tab_del and dbo.tk_PO_AP_AMTDIFF.AmtDiff>100)
 

 Begin
         IF EXISTS
(SELECT DocEntry  FROM OPCH 
WHERE OPCH.U_ForApprov != 'Y'  AND
OPCH.DocEntry = @list_of_cols_val_tab_del)
begin
        SET @error = 1001

        SET @error_message = 'select approval for invoice'

 end

    End
    End

-------------------------01072024 POPRICE HIGHT THEN AP PRICE-----------------------------------------

IF @object_type='18' and @transaction_type IN ('A','U')

BEGIN
If 0 < (select count(PCH1.ItemCode) from OPCH inner join PCH1 on OPCH.DocEntry=PCH1.DocEntry

 INNER JOIN dbo.tk_PORateMT500HighAPRate ON dbo.OPCH.DocEntry = dbo.tk_PORateMT500HighAPRate.DocEntry 
                 
				
--where  OPCH.DocEntry='28344'

where  OPCH.DocEntry=@list_of_cols_val_tab_del

)
 

 Begin
         IF EXISTS
(SELECT DocEntry  FROM OPCH 
WHERE OPCH.U_ForApprov != 'Y'  
AND OPCH.DocEntry = @list_of_cols_val_tab_del
--and OPCH.DocEntry='28344'
)
begin
        SET @error = 1002

        SET @error_message = 'select approval for invoice'

		--print 'select approval for invoice'

 end

    End
    End
	--------------------------------Invoice Approval WITHOUT PO GRPO-----------------------------------------------------------------
	
IF @object_type='18' and @transaction_type IN ('A','U')
BEGIN
If EXISTS (SELECT        POHead.DocNum AS [PO Num], POHead.DocDate AS [PO Date], POHead.CardCode AS [BP COde], POHead.CardName AS Vender, POHead.NumAtCard AS [Project No], APHead.NumAtCard AS [Bill No], 
                         APHead.DocDate AS [AP Date], POLine.ItemCode AS POItemCode, ItmMstr.ItemName, GRLine.ItemCode AS GRItemCode, ISNULL(POLine.Quantity, 0) AS [PO Qty], ISNULL(POLine.PriceBefDi, 0) AS PORate, 
                         POLine.DiscPrcnt AS [Discount %], POLine.Price AS [Discounted PORate], ISNULL(POLine.LineTotal, 0) AS Amount, APLine.Quantity AS [AP Qty], APLine.PriceBefDi AS APRate, APLine.DiscPrcnt, 
                         APLine.Price AS [Discounted APRate], APLine.Quantity * APLine.Price AS APAmount, ISNULL(POLine.Price, 0) * APLine.Quantity AS [POAmount As per APQty], APLine.Quantity * APLine.Price - ISNULL(POLine.Price, 
                         0) * APLine.Quantity AS Difference, 
                         CASE WHEN POLine.PriceBefDi < GRLine.PriceBefDi THEN 'Due to AP ItemPrice Higher Than PO                            ItemPrice' WHEN POLine.DiscPrcnt > GRLine.DiscPrcnt THEN 'Due to AP Rate Discount Lower Than PO Rate Discount'
                          WHEN POLine.PriceBefDi > GRLine.PriceBefDi THEN 'Due to PO ItemPrice Higher Than AP                            ItemPrice' WHEN POLine.DiscPrcnt < GRLine.DiscPrcnt THEN 'Due to PO Rate Discount Lower Than AP Rate Discount'
                          WHEN ISNULL(POLine.ItemCode,0)!=GRLine.ItemCode THEN 'WITHOUT PO ITEM ADD' ELSE 'Roundoff' END AS Reason, APHead.DocEntry
FROM            dbo.OPOR AS POHead INNER JOIN
                         dbo.POR1 AS POLine ON POHead.DocEntry = POLine.DocEntry 
						 
						 LEFT OUTER JOIN
                         
						 dbo.OITM AS ItmMstr ON POLine.ItemCode = ItmMstr.ItemCode RIGHT OUTER JOIN
                         dbo.OCRD AS BPMstr ON POHead.CardCode = BPMstr.CardCode RIGHT OUTER JOIN
                         dbo.PDN1 AS GRLine ON GRLine.BaseType = 22 AND GRLine.BaseEntry = POLine.DocEntry AND GRLine.BaseLine = POLine.LineNum LEFT OUTER JOIN
                         dbo.OPDN AS GRHead ON GRHead.DocEntry = GRLine.DocEntry LEFT OUTER JOIN
                         dbo.PCH1 AS APLine ON APLine.BaseType = 20 AND APLine.BaseEntry = GRLine.DocEntry AND APLine.BaseLine = GRLine.LineNum LEFT OUTER JOIN
                         dbo.OPCH AS APHead ON APHead.DocEntry = APLine.DocEntry
						 INNER JOIN dbo.tk_PO_AP_AMTDIFF ON APHead.DocEntry = dbo.tk_PO_AP_AMTDIFF.DocEntry
WHERE ISNULL(POLine.ItemCode,0)!=GRLine.ItemCode AND APHead.DocEntry=@list_of_cols_val_tab_del and dbo.tk_PO_AP_AMTDIFF.AmtDiff>500
GROUP BY POHead.DocNum, POHead.DocDate, POHead.CardCode, POHead.CardName, POHead.NumAtCard, GRHead.DocNum, GRHead.DocDate, APHead.NumAtCard, APHead.DocDate, POLine.ItemCode, 
                         ItmMstr.ItemName, POLine.Quantity, POLine.PriceBefDi, POLine.DiscPrcnt, POLine.Price, POLine.LineTotal, GRLine.LineNum, GRLine.Quantity, GRLine.PriceBefDi, GRLine.DiscPrcnt, GRLine.Price, 
                         GRLine.ItemCode, GRLine.LineTotal, APLine.LineNum, APLine.Quantity, APLine.PriceBefDi, APLine.DiscPrcnt, APLine.Price, APLine.LineTotal, APHead.DocEntry, GRLine.BaseEntry, POLine.DocEntry)
 
  Begin
         IF EXISTS
(SELECT DocEntry  FROM OPCH 
WHERE OPCH.U_ForApprov != 'Y'  AND
OPCH.DocEntry = @list_of_cols_val_tab_del)
begin
        SET @error = 1001

        SET @error_message = 'select approval for invoice'

 end

    End
    End

	-------------------------------------------------------------------------------------------------------------------------------
IF @object_type='20' and @transaction_type IN ('A','U')
BEGIN
IF EXISTS 
(
Select t0.DocEntry from OPDN t0
Where t0.DocEntry = @list_of_cols_val_tab_del and isnull(t0.U_GateEntryNo,'') = ''
)

Begin
SET @error = 777

        SET @error_message = 'Please Enter Gate Entry No. in UDF'

END
END
---------------------------------------------------------------------------------------------------------------------------
IF @object_type='20' and @transaction_type IN ('A','U')
BEGIN
IF EXISTS 
(
Select t0.DocEntry from OPDN t0
Where t0.DocEntry = @list_of_cols_val_tab_del and isnull(t0.U_GateEntryDate,'') = ''
)

Begin
SET @error = 778

        SET @error_message = 'Please Enter Gate Entry Date. in UDF'

END
END

------------------------------------------------------------------------------------------
IF @object_type='22' and @transaction_type IN ('A','U')
BEGIN
IF EXISTS
(
Select a.docentry,b.ItemCode from OPOR a
Inner join por1 b on a.DocEntry = b.DocEntry
Inner join oitm c on b.ItemCode = c.ItemCode
Inner Join OITW d on b.ItemCode = d.ItemCode and b.WhsCode = d.WhsCode
where a.DocEntry = @list_of_cols_val_tab_del and  c.MaxLevel < (b.Quantity + d.OnHand) and isnull(c.MaxLevel,0.00) <> 0.00
)
BEGIN
SET @error = 654
SET @error_message = 'Itemcode quantity is exceeding the maximum level'

END
END


------------------------------------------------------------------------------------------

IF @object_type='67' and @transaction_type IN ('A','U')
BEGIN
IF EXISTS
(
SELECT a.DocEntry From owtr a
Inner Join Wtr1 b on a.DocEntry = b.DocEntry
Where a.DocEntry = @list_of_cols_val_tab_del and b.FromWhsCod in ('RGP','JW') and ISNULL(a.U_challan,'') = '') 

BEGIN
SET @error = 6701
SET @error_message = 'Please Enter RGP Or Jobwork challan No. in the Respective Field'

END
END
----------------------------------------
 IF @object_type = '112' and @transaction_type in ('A', 'U')

BEGIN

If Exists (Select T0.DocEntry from ODRF T0 
Inner Join DRF1 T1 on T0.DocEntry = T1.DocEntry

Where isnull(T1.TaxCode ,'')= '' And T1.ObjType = '22' And T0.DocEntry =@list_of_cols_val_tab_del ) 

BEGIN

Select @error = -1, 
@error_message = 'ERROR: TaxCode Should not be blank'

END

END



IF @object_type = '112' and @transaction_type in ('A', 'U')

BEGIN

If Exists (Select T0.DocEntry from ODRF T0 
Inner Join DRF1 T1 on T0.DocEntry = T1.DocEntry
Inner Join OITM T2 on t2.ItemCode=T1.ItemCode

Where isnull(T1.HsnEntry ,'')= '' and T2.ItmsGrpCod<>'119'  And T1.ObjType = '22' And T0.DocEntry =@list_of_cols_val_tab_del ) 

BEGIN

Select @error = -1, 
@error_message = 'ERROR: HSN Should not be blank'

END

END

IF @object_type = '112' and @transaction_type in ('A', 'U')

BEGIN

If Exists (Select T0.DocEntry from ODRF T0 
Inner Join DRF1 T1 on T0.DocEntry = T1.DocEntry
Inner Join OITM T2 on t2.ItemCode=T1.ItemCode

Where isnull(T1.SacEntry ,'')= '' and T2.ItmsGrpCod='119'  And T1.ObjType = '22' And T0.DocEntry =@list_of_cols_val_tab_del ) 

BEGIN

Select @error = -1, 
@error_message = 'ERROR: HSN Should not be blank'

END

END

IF @object_type = '112' and @transaction_type in ('A', 'U')

BEGIN

If Exists (Select T0.DocEntry from ODRF T0 
Inner Join DRF1 T1 on T0.DocEntry = T1.DocEntry

Where isnull(T1.PriceBefDi ,0)= 0  And T1.ObjType = '22' And T0.DocEntry =@list_of_cols_val_tab_del ) 

BEGIN

Select @error = -1, 
@error_message = 'ERROR: Price Should not be blank'

END

END

IF @object_type = '112' and @transaction_type in ('A', 'U')

BEGIN

If Exists (Select T0.DocEntry from ODRF T0 
Inner Join DRF1 T1 on T0.DocEntry = T1.DocEntry

Where isnull(T1.Project ,'')= ''  And T1.ObjType = '22' And T0.DocEntry =@list_of_cols_val_tab_del ) 

BEGIN

Select @error = -1, 
@error_message = 'ERROR: Row Level Project Should not be blank'

END

END


IF @object_type = '112' and @transaction_type in ('A', 'U')

BEGIN

If Exists (Select T0.DocEntry from ODRF T0 
Inner Join DRF1 T1 on T0.DocEntry = T1.DocEntry

Where isnull(T0.Project ,'')= ''  And T1.ObjType = '22' And T0.DocEntry =@list_of_cols_val_tab_del ) 

BEGIN

Select @error = -1, 
@error_message = 'ERROR: Header Level Project Should not be blank'

END

END


IF @object_type = '112' and @transaction_type in ('A', 'U')

BEGIN

If Exists (Select T0.DocEntry from ODRF T0 
Inner Join DRF1 T1 on T0.DocEntry = T1.DocEntry

Where isnull(T1.WhsCode ,'')= ''  And T1.ObjType = '22' And T0.DocEntry =@list_of_cols_val_tab_del and t0.DocType = 'I' ) 

BEGIN

Select @error = -1, 
@error_message = 'ERROR: Warehouse Should not be blank'

END
end
------------------------Sandeep---------------------------
/*IF (@object_type = '67' and @transaction_type in ('A','U'))

BEGIN
IF EXISTS (Select t0.DocEntry
         From OWTR t0
		 Inner Join WTR1  t2 on t2.DocEntry =t0.DocEntry
		 Left Join NNM1 t1 On t1.Series = t0.Series
         where t0.DocEntry = @list_of_cols_val_tab_del and t1.SeriesName = 'JW2425' and  t2.FromWhsCod Not IN ('RM','JW')) 
		
BEGIN 
SET @error = 257
SET @error_message = 'Please select Correct Warehouse'
END

Else IF EXISTS (Select t0.DocEntry
         From OWTR t0
		 Inner Join WTR1  t2 on t2.DocEntry =t0.DocEntry
		 Left Join NNM1 t1 On t1.Series = t0.Series
         where t0.DocEntry = @list_of_cols_val_tab_del and t1.SeriesName = 'JW2425' and  t2.WhsCode Not IN ('RM','JW')) 
BEGIN 
SET @error = 257
SET @error_message = 'Please select Correct Warehouse'

End
END
------------------------------------------------
IF (@object_type = '67' and @transaction_type in ('A','U'))

BEGIN
IF EXISTS (Select t0.DocEntry
         From OWTR t0
		 Inner Join WTR1  t2 on t2.DocEntry =t0.DocEntry
		 Left Join NNM1 t1 On t1.Series = t0.Series
         where t0.DocEntry = @list_of_cols_val_tab_del  and  t2.FromWhsCod IN ('RM','JW') and t1.SeriesName Not IN ('JW2425')) 
		
BEGIN 
SET @error = 257
SET @error_message = 'Please select Correct Series'
END

Else IF EXISTS (Select t0.DocEntry
         From OWTR t0
		 Inner Join WTR1  t2 on t2.DocEntry =t0.DocEntry
		 Left Join NNM1 t1 On t1.Series = t0.Series
         where t0.DocEntry = @list_of_cols_val_tab_del and t2.WhsCode IN ('RM','JW') and t1.SeriesName Not IN ('JW2425') ) 
BEGIN 
SET @error = 257
SET @error_message = 'Please select Correct Series'

End
END 
*/
------------------------Sandeep---------------------------
IF (@object_type = '67' and @transaction_type in ('A','U'))

BEGIN
IF EXISTS (Select t0.DocEntry
         From OWTR t0
		 Inner Join WTR1  t2 on t2.DocEntry =t0.DocEntry
		 Left Join NNM1 t1 On t1.Series = t0.Series
         where t0.DocEntry = @list_of_cols_val_tab_del and t1.SeriesName = 'JW2425' and  (t2.FromWhsCod Not IN ('RM') OR  t2.WhsCode Not In ('JW'))) 
		
BEGIN 

SET @error = 257
SET @error_message = 'Please select Correct Warehouse'
END

Else IF EXISTS (Select t0.DocEntry
         From OWTR t0
		 Inner Join WTR1  t2 on t2.DocEntry = t0.DocEntry
		 Left Join NNM1 t1 On t1.Series = t0.Series
         where t0.DocEntry = @list_of_cols_val_tab_del and t1.SeriesName = 'JWIN2425' and  (t2.FromWhsCod Not IN ('JW') OR t2.WhsCode Not In ('RM'))) 
BEGIN 
SET @error = 258
SET @error_message = 'Please select Correct Warehouse'

End
END

----------------------------------------------------------
IF (@object_type = '67' and @transaction_type in ('A','U'))

BEGIN
IF EXISTS (Select t0.DocEntry
         From OWTR t0
		 Inner Join WTR1  t2 on t2.DocEntry =t0.DocEntry
		 Left Join NNM1 t1 On t1.Series = t0.Series
         where t0.DocEntry = @list_of_cols_val_tab_del  and  t2.FromWhsCod IN ('RM') and t2.WhsCode In ('JW') and t1.SeriesName Not IN ('JW2425')) 
		
BEGIN 
SET @error = 257
SET @error_message = 'Please select Correct Series (JW2425)'
END

Else IF EXISTS (Select t0.DocEntry
         From OWTR t0
		 Inner Join WTR1  t2 on t2.DocEntry =t0.DocEntry
		 Left Join NNM1 t1 On t1.Series = t0.Series
         where t0.DocEntry = @list_of_cols_val_tab_del and  t2.FromWhsCod IN ('JW') and t2.WhsCode In ('RM') and t1.SeriesName Not IN ('JWIN2425') ) 
BEGIN 
SET @error = 257
SET @error_message = 'Please select Correct Series (JWIN2425)'
End


Else IF EXISTS (Select t0.DocEntry
         From OWTR t0
		 Inner Join WTR1  t2 on t2.DocEntry =t0.DocEntry
		 Left Join NNM1 t1 On t1.Series = t0.Series
         where t0.DocEntry = @list_of_cols_val_tab_del and  t2.FromWhsCod IN ('JW') and t2.WhsCode IN ('RM') and t1.SeriesName IN ('JWIN2425') 
		 and (isnull(t2.BaseType,-1) = -1)) 

BEGIN 
SET @error = 257
SET @error_message = 'It should be based on the base document and series should be JWIN2425'

End
END 
-------------------------------------------------------
iF (@object_type = '22' AND @transaction_type IN ('A','U'))

BEGIN
       IF EXISTS (SELECT t0.DocEntry

			  FROM OPOR T0
              INNER JOIN POR1 T1 ON T0.DocEntry = T1.DocEntry 
			  Left join NNM1 t2 on t2.Series = t0.Series

                    WHERE T0.DocEntry = @list_of_cols_val_tab_del and (Isnull(T1.BaseType,'') = ''  OR T1.BaseType Not In (1470000113)) 
					and t2.SeriesName = 'POGN2425' and t0.DocDate >= '20240924' and  T1.ItemType <> '4') 
           
                    BEGIN
                                           SET @error = 112
                                           SET @error_message = 'PO should based on the PR !'

                             END
                             END

------------------------------------------------------------------------------------------------
/*IF (@object_type = '18' and @transaction_type in ('A','U'))

BEGIN
Declare @DOCT nvarchar(5)
SET @DOCT = (Select a.Doctype from OPCH a where a.DocEntry = @list_of_cols_val_tab_del )

IF @DOCT = 'I'



BEGIN
Declare @PONUM int

SET @PONUM = (Select Distinct ISNULL(t0.DocEntry,0) from OPCH a 
				Inner Join PCH1 b on a.DocEntry = b.DocEntry
				InNer Join PDN1 c on b.BaseEntry = C.DocEntry and b.BaseLine = c.LineNum
				Inner Join OPOR t0 on c.BaseEntry = t0.DocEntry
				Where A.DocEntry = @list_of_cols_val_tab_del)

Declare @DIPO Int
					
SET @DIPO = (
			Select distinct ISNULL(t3.DocEntry,0) from OPOR t0
			Inner Join PoR1 t1 on t0.DocEntry = t1.DocEntry
			Inner Join DPO1 t2 on t1.DocEntry = t2.BaseEntry and t1.LineNum = t2.BaseLine
			Inner Join ODPO t3 on t2.DocEntry = t3.DocEntry
			where t0.DocEntry = @PONUM
			)

Declare @DINV Int

SET @DINV = (
			Select Distinct ISNULL(a.Baseabs,0) from OPCH b
			Left Join PCH9	a on a.DocEntry = b.DocEntry
			left Join PCH1 c on a.DocEntry = c.DocEntry
			where b.DocEntry = @list_of_cols_val_tab_del
			)

IF @PONUM != 0 and @DIPO != 0 and @DINV != @DIPO

BEGIN 
SET @error = 1801
SET @error_message = 'Please Attatch the Down Payment Invoice'

End
END

ELSE IF @DOCT = 'S'
BEGIN
Declare @PONUM2 int

SET @PONUM2 = (Select Distinct ISNULL(t0.DocEntry,0) from OPCH a 
				Inner Join PCH1 b on a.DocEntry = b.DocEntry
				InNer Join POR1 c on b.BaseEntry = C.DocEntry and b.BaseLine = c.LineNum
				Inner Join OPOR t0 on c.DocEntry = t0.DocEntry
				Where A.DocEntry = @list_of_cols_val_tab_del and a.Doctype = 'S')

Declare @DIPO2 Int
					
SET @DIPO2 = (
			Select distinct ISNULL(t3.DocEntry,0) from OPOR t0
			Inner Join PoR1 t1 on t0.DocEntry = t1.DocEntry
			Inner Join DPO1 t2 on t1.DocEntry = t2.BaseEntry and t1.LineNum = t2.BaseLine
			Inner Join ODPO t3 on t2.DocEntry = t3.DocEntry
			where t0.DocEntry = @PONUM2
			)

Declare @DINV2 Int

SET @DINV2 = (
			Select Distinct ISNULL(a.Baseabs,0) from OPCH b
			Left Join PCH9	a on a.DocEntry = b.DocEntry
			left Join PCH1 c on a.DocEntry = c.DocEntry
			where b.DocEntry = @list_of_cols_val_tab_del
			)

IF @PONUM2 != 0 and @DIPO2 != 0 and @DINV2 != @DIPO

BEGIN 
SET @error = 1802
SET @error_message = 'Please Attatch the Down Payment Invoice'

End
END



END
*/

DECLARE @APENT int,
@POENT int	, @DPENTRY int , @DPENTRY_ATT int
IF (@object_type = '18' and @transaction_type in ('A','U'))

BEGIN
Declare @DOCT nvarchar(5)
SET @DOCT = (Select a.Doctype from OPCH a where a.DocEntry = @list_of_cols_val_tab_del )

Declare @Itms int
SET @Itms = (Select distinct top(1) b.ItmsGrpCod  from PCH1 a inner join OITM b on a.ItemCode =b.ItemCode where a.DocEntry = @list_of_cols_val_tab_del )

IF @DOCT = 'I' and @Itms <> 119
BEGIN
			Select @APENT = L.APENT, @POENT = l.PO_ENT,@DPENTRY = l.DPENTRY,@DPENTRY_ATT =  L.DPENTRY_ATT FROM 
			(Select Distinct a.DocEntry'APENT',isnull(t0.DocEntry,0) 'PO_ENT',ISNULL(M.DPENTRY,0) 'DPENTRY',N.DPENTRY_ATT from OPCH a 
				Inner Join PCH1 b on a.DocEntry = b.DocEntry
			LEFT Join PDN1 c on b.BaseEntry = C.DocEntry and b.BaseLine = c.LineNum and b.BaseType = c.ObjType
				LEFT Join OPOR t0 on c.BaseEntry = t0.DocEntry and c.BaseType = t0.ObjType

				LEFT JOIN (Select distinct t0.DocEntry,ISNULL(t3.DocEntry,0) 'DPENTRY' from OPOR t0
			Inner Join PoR1 t1 on t0.DocEntry = t1.DocEntry
			Inner Join DPO1 t2 on t1.DocEntry = t2.BaseEntry and t1.LineNum = t2.BaseLine
			Inner Join ODPO t3 on t2.DocEntry = t3.DocEntry
			) M on t0.DocEntry = M.DocEntry

			LEFT JOIN  (Select Distinct b.DocEntry,ISNULL(a.Baseabs,0) 'DPENTRY_ATT' from OPCH b
			Left Join PCH9	a on a.DocEntry = b.DocEntry
			left Join PCH1 c on a.DocEntry = c.DocEntry
			where b.DocEntry = @list_of_cols_val_tab_del ) N on a.DocEntry = N.DocEntry

			where a.DocEntry = @list_of_cols_val_tab_del) L
IF 	@POENT != 0 AND @DPENTRY != 0 AND @DPENTRY != @DPENTRY_ATT
begin
SET @error = 1801
SET @error_message = 'Please SELECT CORRECT Downpayment Invoice/request '
END
End

ELSE IF @DOCT = 'S' or @Itms = 119
BEGIN
			Select @APENT = L.APENT, @POENT = l.PO_ENT,@DPENTRY = l.DPENTRY,@DPENTRY_ATT =  L.DPENTRY_ATT FROM 
			(Select Distinct a.DocEntry'APENT',isnull(t0.DocEntry,0) 'PO_ENT',ISNULL(M.DPENTRY,0) 'DPENTRY',N.DPENTRY_ATT 
				from OPCH a 
				Inner Join PCH1 b on a.DocEntry = b.DocEntry
			    LEFT Join POR1 c on b.BaseEntry = C.DocEntry and b.BaseLine = c.LineNum and b.BaseType = c.ObjType
				LEFT Join OPOR t0 on c.DocEntry = t0.DocEntry 

				LEFT JOIN (Select distinct t0.DocEntry,ISNULL(t3.DocEntry,0) 'DPENTRY' from OPOR t0
				Inner Join PoR1 t1 on t0.DocEntry = t1.DocEntry
				Inner Join DPO1 t2 on t1.DocEntry = t2.BaseEntry and t1.LineNum = t2.BaseLine
				Inner Join ODPO t3 on t2.DocEntry = t3.DocEntry
				) M on t0.DocEntry = M.DocEntry

				LEFT JOIN  (Select Distinct b.DocEntry,ISNULL(a.Baseabs,0) 'DPENTRY_ATT' from OPCH b
				Left Join PCH9	a on a.DocEntry = b.DocEntry
				left Join PCH1 c on a.DocEntry = c.DocEntry
				where b.DocEntry = @list_of_cols_val_tab_del) N on a.DocEntry = N.DocEntry

			where a.DocEntry = @list_of_cols_val_tab_del) L
			IF 	@POENT != 0 AND @DPENTRY != 0 AND @DPENTRY != @DPENTRY_ATT
begin
SET @error = 1802
SET @error_message = 'Please SELECT CORRECT Downpayment Invoice/request '
END
End

end






---------------------------------------------------------------------------------------------------------------
-- Select the return values
select @error, @error_message

end