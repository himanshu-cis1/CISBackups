USE [SHIVALIC_18_05_2024]
GO
/****** Object:  StoredProcedure [dbo].[SBO_SP_TransactionNotification]    Script Date: 13/12/2024 12:25:00 PM ******/
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
	-----------------------
	IF @transaction_type IN (N'A', N'U') AND (@Object_type = N'59')


Begin  
  
IF EXISTS(SELECT T1.DocEntry as 'DocEntry' FROM dbo.IGN1 T1  
INNER JOIN OWOR T2 ON  T1.BaseEntry=T2.DocEntry AND t1.BaseType=202 AND T1.TranType='C'
GROUP BY T1.DocEntry
HAVING  SUM(T2.PlannedQty) < SUM(T2.CmpltQty+T2.RjctQty)

 and T1.DocEntry = @list_of_cols_val_tab_del  )  
  
BEGIN  
  
SELECT @Error = 1, @error_message = 'RECEIVED QTY NOT MORE THAN PLANNED QTY  '  
  
END  
end
-------------
if @object_type = '202' and (@transaction_type = 'A' or @transaction_type = 'U')  
begin  
Declare @itemcode1 varchar(40) 
Declare @Salesord1 varchar(40) 
declare @Qty float
declare @QtyOld float
--DECLARE @Shotage NVARCHAR(10)

--set @Shotage =(select ISNULL(t0.U_ShortQty, 'N') from OWOR t0 where t0.DocEntry=@list_of_cols_val_tab_del)
set @itemcode1=(select t0.ItemCode from OWOR t0 where t0.DocEntry=@list_of_cols_val_tab_del)
set @Salesord1=(select t0.OriginAbs from OWOR t0 where t0.DocEntry=@list_of_cols_val_tab_del)
set @Qty=(select sum(t0.PlannedQty) from OWOR t0 where t0.OriginAbs=@Salesord1 and  t0.ItemCode =@itemcode1 and 
                t0.DocEntry=@list_of_cols_val_tab_del and t0.Status <>'C')
set @QtyOld= ISNULL((select sum(t0.PlannedQty) from OWOR t0 where t0.OriginAbs=@Salesord1 and  t0.ItemCode =@itemcode1 and 
                t0.DocEntry<>@list_of_cols_val_tab_del and t0.Status <>'C' ), 0)

	
		if  not Exists(select t0.docnum from ORDR t0 
		inner join RDR1 t1 on t0.DocEntry=t1.DocEntry
		where t0.DocEntry=@Salesord1 and t1.ItemCode=@itemcode1 and t1.Quantity >= (@Qty + @QtyOld)
		)
		AND EXISTS (SELECT T0.DocEntry
					FROM OWOR T0
					INNER JOIN OITM T2 ON T0.ItemCode = T2.ItemCode
					WHERE T0.DocEntry = @list_of_cols_val_tab_del AND T2.ItmsGrpCod NOT IN (106, 107) )
		begin  
			set @error  = 10001 
			Set @error_message ='Production Order Qty is more than Sales Order Qty or Selected item is not in sales order !'  
		end
	  
end
-------------------
/*IF @transaction_type IN ('A') AND (@Object_type = '20')
BEGIN
IF EXISTS (SELECT Count (*)FROM dbo.OPDN T0
INNER JOIN dbo.PDN1 T1 ON T1.DOCENTRY = T0.DocEntry
INNER JOIN dbo.POR1 T2 ON T2.DOCENTRY = T1.BaseEntry AND T1.ItemCode = T2.ItemCode AND T1.BaseLine = T2.LineNum
WHERE T1.BaseType = '22' AND T0.DOCENTRY = @list_of_cols_val_tab_del
GROUP BY T1.BaseEntry
HAVING SUM(T1.Quantity) > SUM(T2.OpenQty))
Begin
SELECT @Error = 10, @error_message = 'GRPO quantity is greater than PO quantity'
End
END*/
------------
iF (@object_type = '22' AND @transaction_type IN ('A','U'))


BEGIN
              IF EXISTS (SELECT *  FROM OPOR (NOLOCK) T0

                     INNER JOIN POR1 (NOLOCK) T1 ON T0.DocEntry = T1.DocEntry 

                    WHERE T0.DocEntry = @list_of_cols_val_tab_del and T1.BaseEntry is null and t0.UserSign2 Not In ('10','14')) 
                    IF EXISTS(SELECT POR1.DocEntry FROM POR1 WHERE ISNULL(POR1.BaseType, '') <> '')
                    BEGIN
                                           SET @error = 112

                                           SET @error_message = 'PO should based on the PR !'

                             END

                             END


-------------PO DRAFT 1
iF (@object_type = '112' AND @transaction_type IN ('A','U'))

 

BEGIN

              IF EXISTS (SELECT *  FROM ODRF (NOLOCK) T0

                     INNER JOIN DRF1 (NOLOCK) T1 ON T0.DocEntry = T1.DocEntry 

                    WHERE T0.DocEntry = @list_of_cols_val_tab_del and T1.BaseEntry is null and t0.UserSign2 Not In ('10','14') and t0.objtype = 22)
                    IF EXISTS(SELECT DRF1.DocEntry FROM DRF1 WHERE ISNULL(DRF1.BaseType, '') <> '' and drf1.ObjType = 22 )
                    BEGIN
                                           SET @error = 112

                                           SET @error_message = 'PO should based on the PR !'

                             END

                             END

--------
	---------------------------------
	/* IF (@object_type = '18' AND @transaction_type IN ('A','U'))

 

BEGIN

              IF EXISTS (SELECT *  FROM OPCH (NOLOCK) T0

                     INNER JOIN PCH1 (NOLOCK) T1 ON T0.DocEntry = T1.DocEntry 

                    WHERE T0.DocEntry = @list_of_cols_val_tab_del and T1.BaseEntry is null) 
                    IF EXISTS(SELECT PCH1.DocEntry FROM PCH1 WHERE ISNULL(PCH1.BaseType, '') <> '')
                    BEGIN
                                           SET @error = 112

                                           SET @error_message = 'AP should based on the GRPO !'

                             END

                             END */
	--------------------------------------
	/*IF @transaction_type IN (N'A', N'U') AND (@Object_type = N'20')
begin 
     if exists (SELECT T0.BaseEntry
      FROM [dbo].[PDN1] T0 INNER JOIN [dbo].[POR1] T1 ON T1.DOCENTRY = T0.BASEENTRY
     WHERE T0.BaseType = 22 AND T0.ItemCode = T1.ItemCode AND T0.BaseLine = T1.LineNum and T0.DOCENTRY =  @list_of_cols_val_tab_del
     GROUP BY T0.BaseEntry
	 HAVING SUM(T0.Quantity)> SUM(T1.Quantity))
     begin
          select @Error = 106, @error_message = 'GRPO Quantity  Should not greater than PO Quantity'
     end
end*/
---------------------------------------
IF @transaction_type IN (N'A', N'U') AND (@Object_type = N'22')  
	BEGIN   
		IF EXISTS (SELECT T0.BaseEntry,T0.Quantity
					FROM [dbo].[POR1] (NOLOCK) T0 
					INNER JOIN [dbo].[PRQ1] (NOLOCK) T1 ON T1.DocEntry = T0.BaseEntry AND T0.BaseLine = T1.LineNum  
					INNER JOIN [dbo].OPOR (NOLOCK) T2 ON T0.DocEntry = T2.DocEntry  
					--inner join [dbo].OITM (NOLOCK) T3 ON T1.ItemCode=T3.ITEMCODE
					
					WHERE T0.DOCENTRY = @list_of_cols_val_tab_del and t2.UserSign2 not in ('10') 
					 
					 	     
					
					GROUP BY T0.BaseEntry  ,t0.Quantity,t0.BaseOpnQty,t1.Quantity
					HAVING (T0.Quantity) > (T1.Quantity) --+(((T1.Quantity) *isnull(0,0.00))/100))
					
					 or (T0.Quantity) > ((T0.BaseOpnQty) + (((T0.BaseOpnQty) *isnull(0,0.00))/100))   )  
		BEGIN  
				SELECT @error = 10, @error_message = 'Purchase Order quantity is not greater than the PR Quantity'  
		END  
	END   
	
	-------------PO DRAFT 2
	IF @transaction_type IN (N'A', N'U') AND (@Object_type = N'112')  
	BEGIN   
		IF EXISTS (SELECT T0.BaseEntry,T0.Quantity
					FROM [dbo].[DRF1] (NOLOCK) T0 
					INNER JOIN [dbo].[PRQ1] (NOLOCK) T1 ON T1.DocEntry = T0.BaseEntry AND T0.BaseLine = T1.LineNum  
					INNER JOIN [dbo].ODRF (NOLOCK) T2 ON T0.DocEntry = T2.DocEntry  
					--inner join [dbo].OITM (NOLOCK) T3 ON T1.ItemCode=T3.ITEMCODE
					
					WHERE T0.DOCENTRY = @list_of_cols_val_tab_del and t2.UserSign2 not in ('10') and T2.ObjType = 22
					 
					 	     
					
					GROUP BY T0.BaseEntry  ,t0.Quantity,t0.BaseOpnQty,t1.Quantity
					HAVING (T0.Quantity) > (T1.Quantity) --+(((T1.Quantity) *isnull(0,0.00))/100))
					
					 or (T0.Quantity) > ((T0.BaseOpnQty) + (((T0.BaseOpnQty) *isnull(0,0.00))/100))   )  
		BEGIN  
				SELECT @error = 10, @error_message = 'Purchase Order quantity is not greater than the PR Quantity'  
		END  
	END 
	-----------------------------------------------------------------------
	----------------------------------------
	If @object_type='18' and @transaction_type='A'
BEGIN 
--If Exists (Select * from [dbo].[OPCH] T0 Inner Join PCH1 T1 On T0.DocEntry=T1.DocEntry
--Where T0.DocEntry = @list_of_cols_val_tab_del and T1.BaseEntry is null and T0.DocType='I' )
If Exists (Select T0.DocEntry from [dbo].[OPCH] T0 
			Inner Join PCH1 T1 On T0.DocEntry=T1.DocEntry
			Inner Join OITM T2 On T2.ItemCode=T1.ItemCode
			Where T0.DocEntry = @list_of_cols_val_tab_del and T1.BaseEntry is null and T0.DocType='I' 
			AND ISNULL(T2.InvntItem, 'N') <> 'N')
BEGIN
Select @error = -1,
@error_message = 'Please Raise GRN First'
End
End	
------------------------------
IF @transaction_type IN (N'A', N'U') AND (@Object_type = N'15')  
      BEGIN  
            IF EXISTS (SELECT T0.BaseEntry,T0.Quantity
                              FROM [dbo].DLN1 (NOLOCK) T0
                              INNER JOIN [dbo].RDR1 (NOLOCK) T1 ON T1.DocEntry = T0.BaseEntry AND T0.BaseLine = T1.LineNum AND T0.BaseType = '17'  
                              INNER JOIN [dbo].ODLN (NOLOCK) T2 ON T0.DocEntry = T2.DocEntry  
                              inner join [dbo].OITM (NOLOCK) T3 ON T1.ItemCode=T3.ITEMCODE
                              
                              WHERE T0.DOCENTRY = @list_of_cols_val_tab_del  
                              
                                        
                              
                             GROUP BY T0.BaseEntry  ,t0.Quantity,t0.BaseOpnQty,t1.Quantity,t1.BaseOpnQty
                              HAVING  (sum(t0.quantity) > (sum(T1.Quantity)+ sum(t1.Quantity)*3/100)))  
            BEGIN  
                        SELECT @error = 10, @error_message = 'Delivery quantity is greater SO quantity'  
            END  
      END
-------------------------------------------------------------------------------------------------------------------------------------
-----------------------------PROJECT_MANDATORY------29/02/2024--------
---------Sales ORDER
IF @transaction_type IN ('A','U') AND (@object_type = '17')
	BEGIN	
		IF EXISTS (Select T0.Docentry From ORDR T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 101, @error_message = 'Project Is missing on Sales Order Header'

		END
	END


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


IF @transaction_type IN ('A','U') AND (@object_type = '13')
	BEGIN	
		IF EXISTS (Select T0.Docentry From INV1 T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 106, @error_message = 'Project Is missing on Invoice Rows'

		END
	END

-------------------------------------------------------CREDIT NOTE-----------------
IF @transaction_type IN ('A','U') AND (@object_type = '14')
	BEGIN	
		IF EXISTS (Select T0.Docentry From ORIN T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 105, @error_message = 'Project Is missing on Credit Note Header'

		END
	END


IF @transaction_type IN ('A','U') AND (@object_type = '14')
	BEGIN	
		IF EXISTS (Select T0.Docentry From RIN1 T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 106, @error_message = 'Project Is missing on Credit Note Rows'

		END
	END

--------------------------------------------------------------PURCHASE ORDER-----------------


IF @transaction_type IN ('A','U') AND (@object_type = '22')
	BEGIN	
		IF EXISTS (Select T0.Docentry From POR1 T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 107, @error_message = 'Project Is missing on PO Rows'

		END
	END
	---------------------------------------------------------------------------
	IF @transaction_type IN ('A','U') AND (@object_type = '112')
	BEGIN	
		IF EXISTS (Select T0.Docentry From DRF1 T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '' and t0.ObjType = 22)
		
		BEGIN 
			SELECT @error = 107, @error_message = 'Project Is missing on PO Rows'

		END
	END
	---------------------------------------------------------------------------

IF @transaction_type IN ('A','U') AND (@object_type = '22')
	BEGIN	
		IF EXISTS (Select T0.Docentry From OPOR T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 108, @error_message = 'Project Is missing on PO HEADER'

		END
	END
	----------------------------------------------------------------------------------
	IF @transaction_type IN ('A','U') AND (@object_type = '112')
	BEGIN	
		IF EXISTS (Select T0.Docentry From ODRF T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '' and t0.ObjType = 22)
		
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

/*IF @transaction_type IN ('A','U') AND (@object_type = '1470000113')
	BEGIN	
		IF EXISTS (Select T0.Docentry From OPRQ T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 110, @error_message = 'Project Is missing on Purchase Request HEADER'

		END
	END*/
----------------------------------------------------------------------------------------------

IF @transaction_type IN ('A','U') AND (@object_type = '20')
	BEGIN	
		IF EXISTS (Select T0.Docentry From PDN1 T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 111, @error_message = 'Project Is missing on GRPO Rows'

		END
	END

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

IF @transaction_type IN ('A','U') AND (@object_type = '19')
	BEGIN	
		IF EXISTS (Select T0.Docentry From ORPC T0
		Where T0.DocEntry = @list_of_cols_val_tab_del and ISNULL(t0.Project,'') = '')
		
		BEGIN 
			SELECT @error = 116, @error_message = 'Project Is missing on AP Debit note HEADER'

		END
	END

-------------------------------------------------------------------------------------


/*IF @transaction_type IN ('A','U') AND (@object_type = '202')
BEGIN
	IF EXISTS(SELECT T0.DocEntry from OWOR t0
				Where T0.DocEntry = @list_of_cols_val_tab_del and isnull(t0.Project,'') = '')

			BEGIN
				SELECT @error = 117 ,@error_message = 'Project is missing on Production Header'
			END
END*/




/*IF @transaction_type IN ('A','U') AND (@object_type = '202')
BEGIN
	IF EXISTS(SELECT T0.DocEntry from WOR1 t0
				Where T0.DocEntry = @list_of_cols_val_tab_del and isnull(t0.Project,'') = '')

			BEGIN
				SELECT @error = 117 ,@error_message = 'Project is missing on Production Rows'
			END
END*/
---------------------------------------------------------------------------------------------------

IF @transaction_type IN ('A','U') AND (@object_type = '202')
BEGIN
	IF EXISTS(SELECT T0.DocEntry from OWOR t0
				Where T0.DocEntry = @list_of_cols_val_tab_del and isnull(t0.Project,'') = '')

			BEGIN
				SELECT @error = 117 ,@error_message = 'Project is missing on Production Header'
			END
END




/*IF @transaction_type IN ('A','U') AND (@object_type = '202')
BEGIN
	IF EXISTS(SELECT t0.DocEntry from OWOR t0
				Inner JOIN WOR1 t1 on t0.DocEntry = t1.DocEntry --and isnull(t1.ItemCode,0) <> 0
				Where T0.DocEntry = @list_of_cols_val_tab_del and  isnull(t1.ItemCode,'') <> ''   and isnull(t1.Project,'') = '' )

			BEGIN
				SELECT @error = 118 ,@error_message = 'Project is missing on Production Rows'
			END
END*/

------------------------------------------------------------------------

IF @transaction_type IN ('A','U') AND (@object_type = '60')
BEGIN 
	IF EXISTS(SELECT t1.DocEntry From IGE1 t1
				Where T1.DocEntry = @list_of_cols_val_tab_del and t1.basetype = 202 and  ISNULL(t1.Project,'') = '')

			BEGIN
				SELECT @error = 119 ,@error_message = 'Project is missing on Issue To Production Row'
			END
END

/*IF @transaction_type IN ('A','U') AND (@object_type = '60')
BEGIN 
	IF EXISTS(SELECT t1.DocEntry From OIGE t1
	Inner Join IGE1 t2 on t1.Docentry = t2.DocEntry
				Where T1.DocEntry = @list_of_cols_val_tab_del and t2.BaseEntry=202 and ISNULL(t1.Project,'') = '')

			BEGIN
				SELECT @error = 120 ,@error_message = 'Project is missing on Issue To Production Header'
			END
END*/

-----------------------------------------------------------------------------------------------------------

IF @transaction_type IN ('A','U') AND (@object_type = '59')
BEGIN 
	IF EXISTS(SELECT t1.DocEntry From IGN1 t1
				Where T1.DocEntry = @list_of_cols_val_tab_del and t1.basetype = 202 and  ISNULL(t1.Project,'') = '')

			BEGIN
				SELECT @error = 119 ,@error_message = 'Project is missing on Reciept From Production Row'
			END
END

/*IF @transaction_type IN ('A','U') AND (@object_type = '59')
BEGIN 
	IF EXISTS(SELECT t1.DocEntry From OIGN t1
	Inner Join IGN1 t2 on t1.Docentry = t2.DocEntry
				Where T1.DocEntry = @list_of_cols_val_tab_del and t2.BaseEntry=202 and ISNULL(t1.Project,'') = '')

			BEGIN
				SELECT @error = 120 ,@error_message = 'Project is missing on Reciept From Production Header'
			END
END	*/


-------------------------------
IF @transaction_type IN ('A', 'U') AND (@Object_type = '20')  
      BEGIN  
            IF EXISTS (SELECT T0.BaseEntry,T0.Quantity
                              FROM [dbo].PDN1 (NOLOCK) T0
                              INNER JOIN [dbo].POR1 (NOLOCK) T1 ON T1.DocEntry = T0.BaseEntry AND T0.BaseLine = T1.LineNum --AND T0.BaseType = '17'  
                              INNER JOIN [dbo].OPDN (NOLOCK) T2 ON T0.DocEntry = T2.DocEntry  
                              inner join [dbo].OITM (NOLOCK) T3 ON T1.ItemCode=T3.ITEMCODE
                              
                              WHERE T0.DOCENTRY = @list_of_cols_val_tab_del  
                              
                                        
                              
                             GROUP BY T0.BaseEntry,t0.Quantity,t0.BaseOpnQty,t1.Quantity,t1.BaseOpnQty--,t0.ItemCode,t1.OpenQty
                              HAVING (Sum(t0.Quantity) > Sum(t1.Quantity)) )
            BEGIN  
                        SELECT @error = 112, @error_message = 'GRPO Quantity is greater than PO quantity'  
            END  
      END


---------------------------Sandeep-------------------------
If @object_type = '59' and @transaction_type in ('A','U')
Begin
IF Exists (SELECT T0.DocEntry
              
						FROM OIGN K
						Inner JOin IGN1 T0 on t0.DocEntry = K.DocEntry
						INNER JOIN OWOR T1 ON T1.DocEntry = T0.BaseEntry AND T1.ObjType = T0.BaseType AND T1.ItemCode = T0.ItemCode
						INNER JOIN WOR1 T2 ON T2.DocEntry = T1.DocEntry
						WHERE T0.DocEntry = @list_of_cols_val_tab_del	and K.UserSign2 Not In ('1')				
						GROUP BY T0.DocEntry
						HAVING SUM(ISNULL(T2.IssuedQty, 0)) = 0)
			BEGIN
				SET @error = 1001
				SET @error_message = 'Issue for Production has been not done completely.'
end 
end
--------------------------------------------------------------------------------------------------------------------------------

-- Select the return values
select @error, @error_message

end 