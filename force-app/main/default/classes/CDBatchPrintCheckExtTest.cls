@isTest
public class CDBatchPrintCheckExtTest {
    
    @testSetup
    public static void testsetup(){
        AcctSeed__Cash_Disbursement_Batch__c cashBatch = new AcctSeed__Cash_Disbursement_Batch__c(
            Name = 'Test Batch');
        insert cashBatch;
        
        // insert 1 Account
        Account acct = new Account(
            Name = 'Test Account',
            litify_pm__Last_Name__c = 'test lName');
        insert acct;
        
        // 1 Cash GL-Account
        
        AcctSeed__GL_Account__c cashGL = new AcctSeed__GL_Account__c(
            Name = '1000-Cash - Operating ',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Bank__c = true,
            AcctSeed__Sub_Type_1__c = 'Assets',
            AcctSeed__Sub_Type_2__c = 'Cash');
        insert CashGL;
        
        
        // insert 4 billing formats
        AcctSeed__Billing_Format__c[] billingFormats = new List<AcctSeed__Billing_Format__c>();
        billingFormats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Billing Product',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__Type__c = 'Billing',
                AcctSeed__Sort_Field__c = 'Name'
            )
        );
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Billing Service',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__Type__c = 'Billing',
                AcctSeed__Sort_Field__c = 'Name'
            )
        );
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Billing Outstanding Statement',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Outstanding Statement'
            )
        );
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Billing Activity Statement',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Activity Statement'
            )
        );
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Purchase Order',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__Type__c = 'Purchase Order',
                AcctSeed__Sort_Field__c = 'Name'
            )
        );
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Packing Slip',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__Type__c = 'Packing Slip',
                AcctSeed__Sort_Field__c = 'Name'
            )
        );
        
        insert billingFormats;
        
        // insert 1 Accounting Period
        AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(
            Name = '1991-10',
            AcctSeed__Start_Date__c = Date.newinstance(1991, 10, 1),
            AcctSeed__End_Date__c = Date.newinstance(1991, 10, 31),
            AcctSeed__Status__c = 'Open');
        insert acctPeriod;
        
        // insert 1 Ledger records
        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c(
            Name = 'Actual',
            AcctSeed__Type__c = 'Transactional',
            AcctSeed__Default_Bank_Account__c = CashGL.id,
            AcctSeed__Default_Billing_Format__c = billingFormats[0].Id,
            AcctSeed__Billing_Outstanding_Statement_Format__c = billingFormats[2].Id,
            AcctSeed__Billing_Activity_Statement_Format__c = billingFormats[3].Id,
            AcctSeed__Default_Purchase_Order_Format__c = billingFormats[4].Id,
            AcctSeed__Default_Packing_Slip_Format__c = billingFormats[5].Id);
        insert ledger;
        
        // --- START HERE ---
        // Create CASH Disbursement RECORD
        
        AcctSeed__Cash_Disbursement__c cashD = new AcctSeed__Cash_Disbursement__c(
            AcctSeed__Cash_Disbursement_Batch__c = cashBatch.id,
            AcctSeed__Amount__c = 123456789.75,
            AcctSeed__Type__c = 'Check',
            AcctSeed__Vendor__c = acct.id,
            AcctSeed__Bank_Account__c = CashGL.Id,
            AcctSeed__Accounting_Period__c = acctPeriod.Id,
            AcctSeed__Ledger__c = ledger.id
        );
        
        insert CashD;
    }
    
    public static testmethod void testConstructor(){
        list<AcctSeed__Cash_Disbursement_Batch__c>listCDBatch = [select id from AcctSeed__Cash_Disbursement_Batch__c];
        Apexpages.StandardController std = new  Apexpages.StandardController(listCDBatch[0]);
        CDBatchPrintCheckExt objCon = new CDBatchPrintCheckExt(std);
        
    }
    public static testmethod void testAnountInWords(){
        list<AcctSeed__Cash_Disbursement_Batch__c>listCDBatch = [select id from AcctSeed__Cash_Disbursement_Batch__c];
        Apexpages.StandardController std = new  Apexpages.StandardController(listCDBatch[0]);
        CDBatchPrintCheckExt objCon = new CDBatchPrintCheckExt(std);
        
        objCon.AnountInWords(11);
        objCon.AnountInWords(12);
        objCon.AnountInWords(13);
        objCon.AnountInWords(14);
        objCon.AnountInWords(15);
        objCon.AnountInWords(16);
        objCon.AnountInWords(17);
        objCon.AnountInWords(18);
        objCon.AnountInWords(19);
        objCon.AnountInWords(20);
        objCon.AnountInWords(30);
        objCon.AnountInWords(40);
        objCon.AnountInWords(50);
        objCon.AnountInWords(60);
        objCon.AnountInWords(70);
        objCon.AnountInWords(80);
        objCon.AnountInWords(90);
        
    }
}