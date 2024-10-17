@isTest
public class cancelExpenseControllerTest {
    @testSetup static void methodName() {
        List<AcctSeed__GL_Account__c> glAccounts1 = new List<AcctSeed__GL_Account__c>();
        // 0
        glAccounts1.add(
            new AcctSeed__GL_Account__c(
                Name = '1201-Consignment Inventory',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Inventory'
            )
        );
        // 1
        glAccounts1.add(
            new AcctSeed__GL_Account__c(
                Name = 'testgl',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Liabilities',
                AcctSeed__Sub_Type_2__c = 'Intercompany AP'
            )
        );
        // 2
        glAccounts1.add(
            new AcctSeed__GL_Account__c(
                Name = '5000-Cost of Goods Sold',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'COGS',
                AcctSeed__Sub_Type_2__c = 'COGS'
            )
        );
        
        // 3
        glAccounts1.add(
            new AcctSeed__GL_Account__c(
                Name = '2051-Unearned Revenue-Long-term',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Liabilities',
                AcctSeed__Sub_Type_2__c = 'Unearned Revenue-Long-term'
            )
        );
        
        // 4
        glAccounts1.add(
            new AcctSeed__GL_Account__c(
                Name = '2052-Unearned Revenue-Current',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Liabilities',
                AcctSeed__Sub_Type_2__c = 'Unearned Revenue-Current'
            )
        );
        
        // 5
        glAccounts1.add(
            new AcctSeed__GL_Account__c(
                Name = '4051-Warranty Income',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Revenue',
                AcctSeed__Sub_Type_1__c = 'Gross Sales',
                AcctSeed__Sub_Type_2__c = 'Warranty Income'
            )
        );
        
        // 6
        glAccounts1.add(
            new AcctSeed__GL_Account__c(
                Name = '4007-Sales Return Reserve',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Revenue',
                AcctSeed__Sub_Type_1__c = 'Sales Return Reserve',
                AcctSeed__Sub_Type_2__c = 'Sales Return Reserve'
            )
        );
        
        // 7
        glAccounts1.add(
            new AcctSeed__GL_Account__c(
                Name = '6690-Bad Debt Expense',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Bad Debt Expense',
                AcctSeed__Sub_Type_2__c = 'Bad Debt Expense'
            )
        );
        
        insert glAccounts1;
        
        
        List<AcctSeed__GL_Account__c> glAccounts = new List<AcctSeed__GL_Account__c>();
        // 0
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1000-Cash',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Bank__c = true,
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash'
            )
        );
        
        // 1
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1050-Unapplied Cash',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash'                
            )
        );
        
        // 2
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1200-Accounts Receivable',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'              
            )
        );
        
        // 3
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1600-Work In Process',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'      
            )
        );
        
        // 4
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '2000-Accounts Payable',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Liabilities',
                AcctSeed__Sub_Type_2__c = 'Current Liabilities'    
            )
        );          
        
        // 5
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '2010-Vouchers Payable',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Liabilities',
                AcctSeed__Sub_Type_2__c = 'Current Liabilities'    
            )
        );  
        
        // 6
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '2020-Accrued Expenses',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Liabilities',
                AcctSeed__Sub_Type_2__c = 'Current Liabilities'    
            )
        );
        
        
        // 7
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '3000-Owners Equity',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Owners Equity',
                AcctSeed__Sub_Type_2__c = 'Equity'      
            )
        );
        
        // 8
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '3050-Retained Earnings',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Owners Equity',
                AcctSeed__Sub_Type_2__c = 'Equity'  
            )
        );
        
        // 9
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '3060-Current Year Earnings',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Owners Equity',
                AcctSeed__Sub_Type_2__c = 'Equity'  
            )
        );
        
        // 10
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '4000-Product Revenue',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Revenue',
                AcctSeed__Sub_Type_1__c = 'Product Revenue',
                AcctSeed__Sub_Type_2__c = 'Product Family 1'    
            )
        );
        
        // 11
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '4010-Services Revenue',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Revenue',
                AcctSeed__Sub_Type_1__c = 'Service Revenue',
                AcctSeed__Sub_Type_2__c = 'Service Family 1'    
            )
        );
        
        // 12
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '5000-Cost of Goods Sold',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
                AcctSeed__Sub_Type_2__c = 'Materials'
            )
        );
        
        // 13
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '5010-Inventory Cost Variance',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
                AcctSeed__Sub_Type_2__c = 'Materials'
            )
        );
        
        // 14
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '5040-Vendor Payment Discounts',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
                AcctSeed__Sub_Type_2__c = 'Materials'
            )
        );
        
        // 15
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '5050-Labor',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
                AcctSeed__Sub_Type_2__c = 'Salaries & Wages'
            )
        );
        
        // 16
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '6000-Marketing Expense',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Sales & Marketing',
                AcctSeed__Sub_Type_2__c = 'Marketing Events'
            )
        );
        
        // 17
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '7000-Facilities Expense',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Facilities',
                AcctSeed__Sub_Type_2__c = 'Rent'        
            )
        );
        
        // 18
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '7050-Telecomunications',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Facilities',
                AcctSeed__Sub_Type_2__c = 'Utilities'            
            )
        );
        
        // 19
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = 'zLabor Clearing',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense'            
            )
        );      
        
        // 20
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = 'zProject Labor',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense'            
            )
        );    
        
        // 21
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '4900-Customer Payment Discounts',
                AcctSeed__Active__c = true,
                AcctSeed__Bank__c = false,
                AcctSeed__Type__c = 'Revenue',
                AcctSeed__Sub_Type_1__c = 'Product Revenue',
                AcctSeed__Sub_Type_2__c = 'Product Family 1'          
            )
        );
        
        // 22
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1500-Inventory',
                AcctSeed__Active__c = true,
                AcctSeed__Bank__c = false,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'          
            )
        );
        
        insert glAccounts;
        
        List<AcctSeed__GL_Account__c> glAccountsExpense = new List<AcctSeed__GL_Account__c>();
        
        // 0
        glAccountsExpense.add(
            new AcctSeed__GL_Account__c(
                Name = '6050-Travel Expenses',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Expense_Report_Name__c = 'Travel Expenses',
                AcctSeed__Billing_Description__c = 'Travel Expenses',
                AcctSeed__TM_Revenue_Conversion__c = glAccounts[11].Id,
                AcctSeed__Sub_Type_1__c = 'Sales & Marketing',
                AcctSeed__Sub_Type_2__c = 'Sales Travel'
            )
        );
        
        // 1
        glAccountsExpense.add(
            new AcctSeed__GL_Account__c(
                Name = '6060-Meals and Entertainment',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Used_In_Expense_Reports__c = true,
                AcctSeed__Expense_Report_Name__c = 'Meals and Entertainment',
                AcctSeed__Billing_Description__c = 'Meals and Entertainment',
                AcctSeed__TM_Revenue_Conversion__c = glAccounts[11].Id,
                AcctSeed__Sub_Type_1__c = 'Sales & Marketing',
                AcctSeed__Sub_Type_2__c = 'Sales Travel'  
            )
        );
        
        // 2
        glAccountsExpense.add(
            new AcctSeed__GL_Account__c(
                Name = '6070-Mileage',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Used_In_Expense_Reports__c = true,
                AcctSeed__Expense_Report_Name__c = 'Mileage',
                AcctSeed__Billing_Description__c = 'Mileage',
                AcctSeed__Mileage_Account__c = true,
                AcctSeed__Mileage_Rate__c = .52,
                AcctSeed__TM_Revenue_Conversion__c = glAccounts[11].Id,
                AcctSeed__Sub_Type_1__c = 'Sales & Marketing',
                AcctSeed__Sub_Type_2__c = 'Sales Travel'          
            )
        );
        
        insert glAccountsExpense;
        glAccounts.addAll(glAccountsExpense);
        
        
        
        List<AcctSeed__Billing_Format__c> billingFormats = new List<AcctSeed__Billing_Format__c>();
        billingFormats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Billing Product',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingServiceModernPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__Type__c = 'Billing',
                AcctSeed__Sort_Field__c = 'Name'
            )
        );  
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Billing Service',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingServiceModernPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__Type__c = 'Billing',
                AcctSeed__Sort_Field__c = 'Name'
            )
        );      
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Billing Outstanding Statment',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingServiceModernPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Outstanding Statement'
            )
        );    
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Billing Activity Statment',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingServiceModernPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Activity Statement'  
            )
        );
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Default Packing Slip',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingServiceModernPDF',
                AcctSeed__Default_Email_Template__c = 'Billing_Email_Template',
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Packing Slip'  
            )
        );
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Default Purchase Orde',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingServiceModernPDF',
                AcctSeed__Default_Email_Template__c = 'Billing_Email_Template',
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Purchase Order'  
            )
        );
        
        insert billingFormats;
        
        List<AcctSeed__Ledger__c> ledgers = new List<AcctSeed__Ledger__c>();
        
        ledgers.add(
            new AcctSeed__Ledger__c(
                Name = 'Actual',
                AcctSeed__Type__c = 'Transactional',
                AcctSeed__Default_Bank_Account__c = glAccounts[0].Id,
                AcctSeed__Default_Billing_Format__c = billingFormats[0].Id,
                AcctSeed__Billing_Outstanding_Statement_Format__c = billingFormats[2].Id,
                AcctSeed__Billing_Activity_Statement_Format__c = billingFormats[3].Id,
                AcctSeed__Default_Purchase_Order_Format__c = billingFormats[5].id,
                AcctSeed__Default_Packing_Slip_Format__c  = billingFormats[4].id
            )
        );
        
        
        ledgers.add(
            new AcctSeed__Ledger__c(
                Name = 'Budget',
                AcctSeed__Type__c = 'Budget',
                AcctSeed__Default_Bank_Account__c = glAccounts[0].Id,
                AcctSeed__Default_Billing_Format__c = billingFormats[0].Id,
                AcctSeed__Billing_Outstanding_Statement_Format__c = billingFormats[2].Id,
                AcctSeed__Billing_Activity_Statement_Format__c = billingFormats[3].Id,
                AcctSeed__Default_Purchase_Order_Format__c = billingFormats[5].id,
                AcctSeed__Default_Packing_Slip_Format__c  = billingFormats[4].id
            )
        );
        
        insert ledgers;
        
        List<AcctSeed__Accounting_Period__c> lstAccountingPeriod = new List<AcctSeed__Accounting_Period__c>();
        Date currentDate = Date.newInstance(2018, 9,1);
        
        for(Integer i = 0; i < 36; i++){
            
            AcctSeed__Accounting_Period__c objAccountingPeriod = new AcctSeed__Accounting_Period__c();
            
            objAccountingPeriod.AcctSeed__Start_Date__c = currentDate.addMonths(i);
            objAccountingPeriod.AcctSeed__End_Date__c = objAccountingPeriod.AcctSeed__Start_Date__c.addMonths(1).toStartOfMonth() - 1;
            objAccountingPeriod.Name = objAccountingPeriod.AcctSeed__Start_Date__c.year() + '-' + (string.valueOf(objAccountingPeriod.AcctSeed__Start_Date__c.month()).length() == 1?'0':'') + objAccountingPeriod.AcctSeed__Start_Date__c.month();
            lstAccountingPeriod.add(objAccountingPeriod);
        }
        
        insert lstAccountingPeriod;
        
        List<AcctSeed__Accounting_Settings__c> settings = new List<AcctSeed__Accounting_Settings__c>();
        
        settings.add(
            new AcctSeed__Accounting_Settings__c(
                AcctSeed__AR_Control_GL_Account__c = glAccounts[2].Id,
                AcctSeed__AP_Control_GL_Account__c = glAccounts[4].Id,
                AcctSeed__Labor_GL_Account__c = glAccounts[19].Id,
                AcctSeed__Payment_Discount_GL_Account__c = glAccounts[14].Id,
                AcctSeed__Unapplied_Cash_GL_Account__c = glAccounts[1].Id,
                AcctSeed__Retained_Earnings_GL_Account__c = glAccounts[8].Id,
                AcctSeed__Default_Ledger__c = ledgers[0].Id,
                AcctSeed__Default_Bank_Account__c = glAccounts[0].Id,
                AcctSeed__Revenue_GL_Account__c = glAccounts[10].Id,
                AcctSeed__Default_Project_Task_Labor_GL_Account__c = glAccounts[20].Id,
                AcctSeed__Default_Billing_Format__c = billingFormats[0].Id,
                AcctSeed__Billing_Outstanding_Statement_Format__c = billingFormats[2].Id,
                AcctSeed__Billing_Activity_Statement_Format__c = billingFormats[3].Id,                          
                AcctSeed__Current_Year_Earnings_GL_Account__c = glAccounts[9].Id,
                AcctSeed__Enable_Product_Costing__c = true,
                AcctSeed__Work_in_Process_GL_Account__c = glAccounts[3].Id,
                AcctSeed__Vouchers_Payable_GL_Account__c = glAccounts[5].Id,
                AcctSeed__Inventory_Variance_GL_Account__c =  glAccounts[13].Id,
                AcctSeed__Customer_Payment_Adjustment_GL_Account__c = glAccounts[21].Id,
                AcctSeed__Display_Billable_Flag_in_Time_Card_Entry__c = true,
                AcctSeed__Enable_Billing_Period_Sensitive_Aging__c = true,
                AcctSeed__Enable_AP_Period_Sensitive_Aging__c = true
            )
        );
        insert settings;
        
    }
    
    @isTest
    static void testMethod1(){
        
        test.startTest();
        Account ObjAccount = new Account();        
        ObjAccount.Name = 'Test Account For Project';
        ObjAccount.litify_pm__Last_Name__c ='test name';
        ObjAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Litify Individual').getRecordTypeId();
        ObjAccount.AcctSeed__Accounting_Active__c = True;
        ObjAccount.AcctSeed__Accounting_Type__c = 'Customer and Vendor';
        insert ObjAccount;
        
        litify_pm__Matter__c objMatter = new litify_pm__Matter__c();
        objMatter.litify_pm__Client__c = ObjAccount.Id;        
        insert objMatter;
        
        litify_pm__Expense__c objExpense = new litify_pm__Expense__c();
        objExpense.litify_pm__Date__c = system.today();
        objExpense.Stage__c = 'In-Process';
        objExpense.litify_pm__Amount__c = 50;
        objExpense.litify_pm__Matter__c = objMatter.Id;
        objExpense.Billing_Status__c = 'Billed';
        objExpense.Origin__c ='ATO';
        insert objExpense;
        
        //objExpense.Stage__c = 'Cancelled';
        //update objExpense;
        
        System.debug('Stsge=====>'+objExpense.Stage__c);
        
        PageReference pageRef = Page.cancelExpense;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',objExpense.Id);
        
        ApexPages.StandardController ExpenseController = new ApexPages.StandardController(objExpense);        
        cancelExpenseController controller = new cancelExpenseController(ExpenseController);
        controller.checkValidation();
        controller.redirectToDetail();
        controller.redirectToList();
        
        test.stopTest();
    }
    
    @isTest
    static void testMethod2(){
        Account ObjAccount = new Account();        
        ObjAccount.Name = 'Test Account For Project';
        ObjAccount.litify_pm__Last_Name__c ='test name';
        ObjAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Litify Individual').getRecordTypeId();
        ObjAccount.AcctSeed__Accounting_Active__c = True;
        ObjAccount.AcctSeed__Accounting_Type__c = 'Customer and Vendor';
        insert ObjAccount;
        
        litify_pm__Matter__c objMatter = new litify_pm__Matter__c();
        objMatter.litify_pm__Client__c = ObjAccount.Id;
        insert objMatter;
        
        litify_pm__Expense__c objExpense = new litify_pm__Expense__c();
        objExpense.litify_pm__Date__c = system.today();
        //objExpense.Stage__c = 'Approved';
        objExpense.litify_pm__Amount__c = 50;
        objExpense.litify_pm__Matter__c = objMatter.Id;
        objExpense.Billing_Status__c = 'Billed';
        objExpense.Stage__c = 'In-Process';
        objExpense.Origin__c = 'Litify';
        insert objExpense;
        System.debug('Stsge=====>'+objExpense.Stage__c);
        
        List<AcctSeed__Accounting_Period__c> acctPeriod =[select id from AcctSeed__Accounting_Period__c];
        List<AcctSeed__Ledger__c> ledger =[select id from AcctSeed__Ledger__c];
        List<AcctSeed__GL_Account__c> glAccounts =[select Id from AcctSeed__GL_Account__c];
        
        List<AcctSeed__Account_Payable__c> invoiceList = new List<AcctSeed__Account_Payable__c>();
        
        AcctSeed__Account_Payable__c invoice = new AcctSeed__Account_Payable__c(
            AcctSeed__Payee_Reference__c = '1',
            AcctSeed__Vendor__c = ObjAccount.Id,
            AcctSeed__Accounting_Period__c = acctPeriod[0].Id,
            AcctSeed__Ledger__c = ledger[0].Id,
            AcctSeed__Status__c = 'Approved' 
            
        );
        invoice.Expense_Type__c ='Trust';
        invoiceList.add(invoice);
        
        insert invoiceList;
        
		List<AcctSeed__Account_Payable_Line__c> newPayLineList = new List<AcctSeed__Account_Payable_Line__c>();
        
        AcctSeed__Account_Payable_Line__c newPayLine = new AcctSeed__Account_Payable_Line__c();
        newPayLine.AcctSeed__Account_Payable__c = invoiceList[0].id;
        newPayLine.AcctSeed__Expense_GL_Account__c =glAccounts[1].id;
        newPayLine.AcctSeed__Amount__c=20;
        //newPayLine.AcctSeed__Unit_Cost__c =20;
        newPayLine.Expense__c =objExpense.id;
        newPayLineList.add(newPayLine);
        
        insert newPayLineList;
        
        AcctSeed.PostResult[] postResults = AcctSeed.AccountPayablePostService.postAccountPayables(invoiceList);
        for (AcctSeed.PostResult theResult : postResults) {
            if (theResult.isSuccess) {
                System.debug('Successfully posted account payable: ' + theResult.id);
            } 
            else {
                System.debug('Error posting account payable ' + theResult.id);
                for (AcctSeed.PostResult.PostErrorResult errorResult: theResult.errors) {
                    System.debug('Error status code ' + errorResult.statusCode);
                    System.debug('Error message ' + errorResult.message);
                }
            }
        }

        
        PageReference pageRef = Page.cancelExpense;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',objExpense.Id);
        
        ApexPages.StandardController ExpenseController = new ApexPages.StandardController(objExpense);        
        cancelExpenseController controller = new cancelExpenseController(ExpenseController);
        controller.checkValidation();
        controller.redirectToDetail();
        controller.redirectToList();
    }
    
    @isTest
    static void testMethod3(){
        Account ObjAccount = new Account();        
        ObjAccount.Name = 'Test Account For Project';
        ObjAccount.litify_pm__Last_Name__c ='test name';
        ObjAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Litify Individual').getRecordTypeId();
        ObjAccount.AcctSeed__Accounting_Active__c = True;
        ObjAccount.AcctSeed__Accounting_Type__c = 'Customer and Vendor';
        insert ObjAccount;
        
        litify_pm__Matter__c objMatter = new litify_pm__Matter__c();
        objMatter.litify_pm__Client__c = ObjAccount.Id;
        insert objMatter;
        
        litify_pm__Expense__c objExpense = new litify_pm__Expense__c();
        objExpense.litify_pm__Date__c = system.today();
        //objExpense.Stage__c = 'Approved';
        objExpense.litify_pm__Amount__c = 50;
        objExpense.litify_pm__Matter__c = objMatter.Id;
        //objExpense.Billing_Status__c = 'Billed';
        objExpense.Stage__c = 'In-Process';
        objExpense.Origin__c = 'Litify';
        insert objExpense;
        System.debug('Stsge=====>'+objExpense.Stage__c);
        objExpense.Stage__c = 'Approved';
        objExpense.Billing_Status__c = 'Billed';
        update objExpense;
        
        PageReference pageRef = Page.cancelExpense;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',objExpense.Id);
        
        ApexPages.StandardController ExpenseController = new ApexPages.StandardController(objExpense);        
        cancelExpenseController controller = new cancelExpenseController(ExpenseController);
        controller.checkValidation();
        controller.redirectToDetail();
        controller.redirectToList();
    }
    
}