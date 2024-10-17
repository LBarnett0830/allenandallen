/*
For closeResolutionController, closeResolutionWrapper

Updated by:Impak/Dave Williams
Date: 12/22/2021
Description:  Close negative dist Resolution if Collection/Discharge Resolution Type

*/
@istest(seeAllData=true)// We have a post to chatter at Matter insert
public class closeResolutionControllerTest {
    
    public static testmethod void checkValidation(){
        test.startTest();
        
        list<Account>listAcc =new list<Account>();        
        listAcc.add(new Account(
            Name = 'test',
            litify_pm__Last_Name__c = 'test lName'));
        
        Id vendorRecTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider Contact Information').getRecordTypeId();
        listAcc.add( new Account(
            recordTypeId=vendorRecTypeId,
            AcctSeed__Accounting_Type__c='Vendor',
            Name = 'Vendor',
            AcctSeed__Accounting_Active__c =true,
            litify_pm__Last_Name__c = 'test')
                   );
        listAcc.add( new Account(
            recordTypeId=vendorRecTypeId,
            AcctSeed__Accounting_Type__c='Vendor',
            Name = label.Firm_Distribution_Account_AAA,
            AcctSeed__Accounting_Active__c =true,
            litify_pm__Last_Name__c = 'test')
                   );
        insert listAcc;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        List<User> userList = new List<User>();
        // 0 
        userList.add(
            new User(Alias = 'test0', Email='test0@testorg.com', 
                     EmailEncodingKey='UTF-8', LastName='TestLast0', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = p.Id, 
                     TimeZoneSidKey='America/Los_Angeles', UserName='test0@testorg1.com'
                    )
        );
        Insert userList;
        
        
        Department__c dep = new Department__c();
        dep.Director__c = userList[0].id;
        Insert dep;
        
        list<AcctSeed__GL_Account__c>listGL = new list<AcctSeed__GL_Account__c>();
        
        litify_pm__Matter__c objMatter = new litify_pm__Matter__c();
        objMatter.litify_pm__Client__c = listAcc[1].id;
        objMatter.litify_pm__Contingency_Fee_Rate__c=10;
        
        insert objMatter;
        
        system.debug(objMatter.Id);
        
        litify_pm__Matter_Team_Role__c objTeamRole = new litify_pm__Matter_Team_Role__c(Name='Attorney');
        insert objTeamRole;
        litify_pm__Matter_Team_Member__c matterTeamMem = new litify_pm__Matter_Team_Member__c();
        matterTeamMem.Name='Test';
        matterTeamMem.litify_pm__Matter__c = objMatter.id;
        matterTeamMem.litify_pm__User__c = userinfo.getUserId();
        matterTeamMem.litify_pm__Role__c = objTeamRole.id;
        insert matterTeamMem;
        
        List<litify_pm__Expense_Type__c>listExpType= new  List<litify_pm__Expense_Type__c>();
        litify_pm__Expense_Type__c type = new litify_pm__Expense_Type__c();
        type.Category__c = 'Hard Cost';
        listExpType.add(type);
        
        litify_pm__Expense_Type__c type2 = new litify_pm__Expense_Type__c();
        type2.Category__c = 'Soft Cost';
        listExpType.add(type2);
        insert listExpType;
        
        
        
        List<AcctSeed__Ledger__c> ledgers = [select id from AcctSeed__Ledger__c where  AcctSeed__Type__c = 'Transactional' or AcctSeed__Type__c = 'Budget'];
        
        list<AcctSeed__Accounting_Variable__c>listGLVariables = new  list<AcctSeed__Accounting_Variable__c>();
        AcctSeed__Accounting_Variable__c objGLV2 = new AcctSeed__Accounting_Variable__c(name='Location var',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 2');
        AcctSeed__Accounting_Variable__c objGLV3 = new AcctSeed__Accounting_Variable__c(name='Department var',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 3');
        listGLVariables.add(objGLV2);
        listGLVariables.add(objGLV3);
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(name='Richmond',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 2'));
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(name='test1',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 1'));
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(name='test4',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 4'));
        listGLVariables.add( new AcctSeed__Accounting_Variable__c(name='PI',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 1'));
        
        insert listGLVariables; 
        
        
        litify_pm__Resolution__c objResolution = new litify_pm__Resolution__c(
            Hard_Costs__c=200,
            Soft_Costs__c=100,
            litify_pm__Total_Expenses__c=300,
            litify_pm__Matter__c = objMatter.id,
            litify_pm__Settlement_Verdict_Amount__c=500000,
            litify_pm__Total_Damages__c =100,
            AAAA_Fee_Rate__c=10
        );
        
        insert objResolution;
        
        litify_pm__Role__c objRole = new litify_pm__Role__c(litify_pm__Party__c=listAcc[1].Id,litify_pm__Matter__c=objMatter.Id);
        insert objRole;
        
        litify_pm__Damage__c objDamage = new litify_pm__Damage__c( litify_pm__Amount_Billed__c=100,litify_pm__Matter__c=objMatter.id,litify_pm__Provider__c = objRole.Id);
        insert objDamage;
        objDamage.Resolution__c=objResolution.id;
        update objDamage;
        
        litify_pm__Lien__c lien = new litify_pm__Lien__c();
        lien.Resolution__c=objResolution.id;
        lien.litify_pm__lit_Comments__c ='Test Comment';
        lien.litify_pm__lit_Amount__c =10;
        lien.litify_pm__lit_Reductions__c = 5.7;
        lien.Date_Issued__c =system.today();
        lien.litify_pm__lit_Matter__c =objMatter.id;
        lien.litify_pm__lit_Payee__c = objRole.id;
        lien.Type__c ='Lien';
        lien.Payee_Party__c = listAcc[1].Id;
        insert lien;  
        
        Referral_Fee__c objReferral = new Referral_Fee__c(Account__c=listAcc[1].Id,Resolution__c=objResolution.Id,Fee_Rate__c=10);
        insert objReferral;
        
        closeResolutionController.checkValidation(objResolution.id);        
        
        
        litify_pm__Intake__c objIntake = new litify_pm__Intake__c(
            litify_pm__Client__c = listAcc[0].id,
            litify_pm__Matter__c = objMatter.id,
            Originating_Office__c ='Richmond'
        );
        insert objIntake;
        objMatter.litify_pm__Primary_Intake__c=objIntake.Id;
        closeResolutionController.checkValidation(objResolution.id);
        system.debug('111');
        
        litify_pm__Case_Type__c objCaseType = new litify_pm__Case_Type__c(litify_pm__Is_Available__c=true,litify_pm__ExternalId__c =10,Service_Line__c='PI');
        insert objCaseType;
        objMatter.litify_pm__Case_Type__c=objCaseType.id;
        
        update objMatter;
        closeResolutionController.checkValidation(objResolution.id);
        system.debug('22');
        
        list<user>listUser = [select id,Alias from user where alias='test0' limit 1];        
        
        closeResolutionController.checkValidation(objResolution.id);
        system.debug('33');
        
        
        AcctSeed__Accounting_Variable__c objVarAlias= new AcctSeed__Accounting_Variable__c(name='test0',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 4');
        insert objVarAlias;
        closeResolutionController.checkValidation(objResolution.id); 
        system.debug('444');
        AcctSeed__Accounting_Variable__c objVar4= new AcctSeed__Accounting_Variable__c(name='PI',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 4');
        insert objVar4;
        closeResolutionController.checkValidation(objResolution.id);
        
        
        
    }
    
    public static testmethod void getResolutionDetails(){
        
        test.startTest();
        list<Account>listAcc =new list<Account>();        
        listAcc.add(new Account(
            Name = 'test',
            litify_pm__Last_Name__c = 'test lName'));
        
        Id vendorRecTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider Contact Information').getRecordTypeId();
        listAcc.add( new Account(
            recordTypeId=vendorRecTypeId,
            AcctSeed__Accounting_Type__c='Vendor',
            Name = 'Vendor',
            AcctSeed__Accounting_Active__c =true,
            litify_pm__Last_Name__c = 'test')
                   );
        listAcc.add( new Account(
            recordTypeId=vendorRecTypeId,
            AcctSeed__Accounting_Type__c='Vendor',
            Name = label.Firm_Distribution_Account_AAA,
            AcctSeed__Accounting_Active__c =true,
            litify_pm__Last_Name__c = 'test')
                   );
        insert listAcc;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        List<User> userList = new List<User>();
        // 0 
        userList.add(
            new User(Alias = 'test0', Email='test0@testorg.com', 
                     EmailEncodingKey='UTF-8', LastName='TestLast0', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = p.Id, 
                     TimeZoneSidKey='America/Los_Angeles', UserName='test0@testorg1.com'
                    )
        );
        Insert userList;
        
        
        Department__c dep = new Department__c();
        dep.Director__c = userList[0].id;
        Insert dep;
        
        list<AcctSeed__GL_Account__c>listGL = new list<AcctSeed__GL_Account__c>();
        
        
        
        litify_pm__Matter__c objMatter = new litify_pm__Matter__c();
        objMatter.litify_pm__Client__c = listAcc[1].id;
        objMatter.litify_pm__Contingency_Fee_Rate__c=10;
        
        insert objMatter;
        
        system.debug(objMatter.Id);
        
        litify_pm__Matter_Team_Role__c objTeamRole = new litify_pm__Matter_Team_Role__c(Name='Attorney');
        insert objTeamRole;
        litify_pm__Matter_Team_Member__c matterTeamMem = new litify_pm__Matter_Team_Member__c();
        matterTeamMem.Name='Test';
        matterTeamMem.litify_pm__Matter__c = objMatter.id;
        matterTeamMem.litify_pm__User__c = userinfo.getUserId();
        matterTeamMem.litify_pm__Role__c = objTeamRole.id;
        insert matterTeamMem;
        
        List<litify_pm__Expense_Type__c>listExpType= new  List<litify_pm__Expense_Type__c>();
        litify_pm__Expense_Type__c type = new litify_pm__Expense_Type__c();
        type.Category__c = 'Hard Cost';
        listExpType.add(type);
        
        litify_pm__Expense_Type__c type2 = new litify_pm__Expense_Type__c();
        type2.Category__c = 'Soft Cost';
        listExpType.add(type2);
        insert listExpType;
        
        List<AcctSeed__Ledger__c> ledgers = [select id from AcctSeed__Ledger__c where  AcctSeed__Type__c = 'Transactional' or AcctSeed__Type__c = 'Budget'];
        
        list<AcctSeed__Accounting_Variable__c>listGLVariables = new  list<AcctSeed__Accounting_Variable__c>();
        AcctSeed__Accounting_Variable__c objGLV2 = new AcctSeed__Accounting_Variable__c(name='Location var',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 2');
        AcctSeed__Accounting_Variable__c objGLV3 = new AcctSeed__Accounting_Variable__c(name='Department var',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 3');
        listGLVariables.add(objGLV2);
        listGLVariables.add(objGLV3);
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(name='Richmond',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 2'));
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(name='test1',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 1'));
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(name='test4',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 4'));
        listGLVariables.add( new AcctSeed__Accounting_Variable__c(name='PI',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 1'));
        
        insert listGLVariables; 
        
        
        
        litify_pm__Resolution__c objResolution = new litify_pm__Resolution__c(
            Hard_Costs__c=200,
            Soft_Costs__c=100,
            litify_pm__Total_Expenses__c=300,
            litify_pm__Matter__c = objMatter.id,
            litify_pm__Settlement_Verdict_Amount__c=500000,
            litify_pm__Total_Damages__c =100,
            AAAA_Fee_Rate__c=10
        );
        
        insert objResolution;
        
        litify_pm__Role__c objRole = new litify_pm__Role__c(litify_pm__Party__c=listAcc[1].Id,litify_pm__Matter__c=objMatter.Id);
        insert objRole;
        
        litify_pm__Damage__c objDamage = new litify_pm__Damage__c( litify_pm__Amount_Billed__c=100,litify_pm__Matter__c=objMatter.id,litify_pm__Provider__c = objRole.Id);
        insert objDamage;
        objDamage.Resolution__c=objResolution.id;
        update objDamage;
        
        litify_pm__Lien__c lien = new litify_pm__Lien__c();
        lien.Resolution__c=objResolution.id;
        lien.litify_pm__lit_Comments__c ='Test Comment';
        lien.litify_pm__lit_Amount__c =10;
        lien.litify_pm__lit_Reductions__c = 5.7;
        lien.Date_Issued__c =system.today();
        lien.litify_pm__lit_Matter__c =objMatter.id;
        lien.litify_pm__lit_Payee__c = objRole.id;
        lien.Type__c ='Lien';
        lien.Payee_Party__c = listAcc[1].Id;
        insert lien;  
        
        Referral_Fee__c objReferral = new Referral_Fee__c(Account__c=listAcc[1].Id,Resolution__c=objResolution.Id,Fee_Rate__c=10);
        insert objReferral;
        
        litify_pm__Intake__c objIntake = new litify_pm__Intake__c(
            litify_pm__Client__c = listAcc[0].id,
            litify_pm__Matter__c = objMatter.id,
            Originating_Office__c ='Richmond'
        );
        insert objIntake;
        objMatter.litify_pm__Primary_Intake__c=objIntake.Id;
        
        litify_pm__Case_Type__c objCaseType = new litify_pm__Case_Type__c(litify_pm__Is_Available__c=true,litify_pm__ExternalId__c =10,Service_Line__c='PI');
        insert objCaseType;
        objMatter.litify_pm__Case_Type__c=objCaseType.id;
        
        update objMatter;
        closeResolutionController.getResolutionDetails(objResolution.id);
        test.stopTest();
    }
    
    public static testmethod void closeResolution(){
        test.startTest();
        
        list<Account>listAcc =new list<Account>();        
        listAcc.add(new Account(
            Name = 'test',
            litify_pm__Last_Name__c = 'test lName'));
        
        Id vendorRecTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider Contact Information').getRecordTypeId();
        listAcc.add( new Account(
            recordTypeId=vendorRecTypeId,
            AcctSeed__Accounting_Type__c='Vendor',
            Name = 'Vendor',
            AcctSeed__Accounting_Active__c =true,
            litify_pm__Last_Name__c = 'test')
                   );
        listAcc.add( new Account(
            recordTypeId=vendorRecTypeId,
            AcctSeed__Accounting_Type__c='Vendor',
            Name = label.Firm_Distribution_Account_AAA,
            AcctSeed__Accounting_Active__c =true,
            litify_pm__Last_Name__c = 'test')
                   );
        insert listAcc;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        List<User> userList = new List<User>();
        // 0 
        userList.add(
            new User(Alias = 'test0', Email='test0@testorg.com', 
                     EmailEncodingKey='UTF-8', LastName='TestLast0', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = p.Id, 
                     TimeZoneSidKey='America/Los_Angeles', UserName='test0@testorg1.com'
                    )
        );
        Insert userList;
        
        
        Department__c dep = new Department__c();
        dep.Director__c = userList[0].id;
        Insert dep;
        
        list<AcctSeed__GL_Account__c>listGL = new list<AcctSeed__GL_Account__c>();
        
        
        Firm_Ledger_COS_Fee_Revenue_GL_Account__c obj = new Firm_Ledger_COS_Fee_Revenue_GL_Account__c(Fee_Revenue_GL_Account__c='4000-Fee Income',Hard_Cost_Advanced__c='1200-Client Costs Advanced',Soft_Cost_Reimbursed__c='4500-Litigation Exp Reimbursed',Trust_Receivable_GL_Account__c='1151-Trust Receivable',Open_case_expenses_GL_Account__c='1000-Cash - Operating');
        obj.name='AAA';
        //insert obj;
        
        
        litify_pm__Matter__c objMatter = new litify_pm__Matter__c();
        objMatter.litify_pm__Client__c = listAcc[1].id;
        objMatter.litify_pm__Contingency_Fee_Rate__c=10;
        
        insert objMatter;
        
        system.debug(objMatter.Id);
        
        litify_pm__Matter_Team_Role__c objTeamRole = new litify_pm__Matter_Team_Role__c(Name='Attorney');
        insert objTeamRole;
        litify_pm__Matter_Team_Member__c matterTeamMem = new litify_pm__Matter_Team_Member__c();
        matterTeamMem.Name='Test';
        matterTeamMem.litify_pm__Matter__c = objMatter.id;
        matterTeamMem.litify_pm__User__c = userinfo.getUserId();
        matterTeamMem.litify_pm__Role__c = objTeamRole.id;
        insert matterTeamMem;
        
        List<litify_pm__Expense_Type__c>listExpType= new  List<litify_pm__Expense_Type__c>();
        litify_pm__Expense_Type__c type = new litify_pm__Expense_Type__c();
        type.Category__c = 'Hard Cost';
        listExpType.add(type);
        
        litify_pm__Expense_Type__c type2 = new litify_pm__Expense_Type__c();
        type2.Category__c = 'Soft Cost';
        listExpType.add(type2);
        insert listExpType;
        
        List<litify_pm__Expense__c> expList = new List<litify_pm__Expense__c>();
        //0
        expList.add(
            new litify_pm__Expense__c(
                litify_pm__Amount__c = 200,
                litify_pm__Date__c = system.today(),
                litify_pm__Matter__c = objMatter.id,
                litify_pm__ExpenseType2__c = type.id,
                litify_pm__lit_Invoice__c ='test1',
                Stage__c = 'In-Process'
            )
        );
        
        //1
        expList.add(
            new litify_pm__Expense__c(
                litify_pm__Amount__c = 9000,
                litify_pm__Date__c = system.today(),
                litify_pm__Matter__c = objMatter.id,
                litify_pm__ExpenseType2__c = type.id,
                litify_pm__lit_Invoice__c ='test2',
                Stage__c = 'In-Process'
            )
        );
        //2
        expList.add(
            new litify_pm__Expense__c(
                litify_pm__Amount__c = 100,
                litify_pm__Date__c = system.today(),
                litify_pm__Matter__c = objMatter.id,
                litify_pm__ExpenseType2__c = type2.id,
                litify_pm__lit_Invoice__c ='test3',
                Stage__c = 'In-Process'
            )
        );
        // insert expList;
        
        
        
        List<AcctSeed__Ledger__c> ledgers = [select id from AcctSeed__Ledger__c where  AcctSeed__Type__c = 'Transactional' or AcctSeed__Type__c = 'Budget'];
        
        list<AcctSeed__Accounting_Variable__c>listGLVariables = new  list<AcctSeed__Accounting_Variable__c>();
        AcctSeed__Accounting_Variable__c objGLV2 = new AcctSeed__Accounting_Variable__c(name='Location var',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 2');
        AcctSeed__Accounting_Variable__c objGLV3 = new AcctSeed__Accounting_Variable__c(name='Department var',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 3');
        listGLVariables.add(objGLV2);
        listGLVariables.add(objGLV3);
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(name='Richmond',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 2'));
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(name='test1',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 1'));
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(name='test4',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 4'));
        listGLVariables.add( new AcctSeed__Accounting_Variable__c(name='PI',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 1'));
        
        insert listGLVariables; 
        
        litify_pm__Resolution__c objResolution = new litify_pm__Resolution__c(
            Hard_Costs__c=200,
            Soft_Costs__c=100,
            //litify_pm__Total_Expenses__c=300,
            litify_pm__Matter__c = objMatter.id,
            litify_pm__Settlement_Verdict_Amount__c=500000,
            litify_pm__Total_Damages__c =100,
            AAAA_Fee_Rate__c=10
        );
        
        insert objResolution;
        
        litify_pm__Role__c objRole = new litify_pm__Role__c(litify_pm__Party__c=listAcc[1].Id,litify_pm__Matter__c=objMatter.Id);
        insert objRole;
        
        litify_pm__Damage__c objDamage = new litify_pm__Damage__c( litify_pm__Amount_Billed__c=100,litify_pm__Matter__c=objMatter.id,litify_pm__Provider__c = objRole.Id);
        insert objDamage;
        objDamage.Resolution__c=objResolution.id;
        update objDamage;
        
        expList[0].Resolution__c=objResolution.id;
        expList[0].Billing_Status__c='Pre-Billed';
        expList[2].Resolution__c=objResolution.id;
        expList[2].Billing_Status__c='Pre-Billed';
        //update expList;
        
        
        litify_pm__Lien__c lien = new litify_pm__Lien__c();
        lien.Resolution__c=objResolution.id;
        lien.litify_pm__lit_Comments__c ='Test Comment';
        lien.litify_pm__lit_Amount__c =10;
        lien.litify_pm__lit_Reductions__c = 5.7;
        lien.Date_Issued__c =system.today();
        lien.litify_pm__lit_Matter__c =objMatter.id;
        lien.litify_pm__lit_Payee__c = objRole.id;
        lien.Payee_Party__c = listAcc[1].Id;
        lien.Type__c ='Lien';
        insert lien;  
        
        Referral_Fee__c objReferral = new Referral_Fee__c(Account__c=listAcc[1].Id,Resolution__c=objResolution.Id,Fee_Rate__c=10);
        insert objReferral;
        
        
        litify_pm__Intake__c objIntake = new litify_pm__Intake__c(
            litify_pm__Client__c = listAcc[0].id,
            litify_pm__Matter__c = objMatter.id,
            Originating_Office__c ='Richmond'
        );
        insert objIntake;
        objMatter.litify_pm__Primary_Intake__c=objIntake.Id;
        
        litify_pm__Case_Type__c objCaseType = new litify_pm__Case_Type__c(litify_pm__Is_Available__c=true,litify_pm__ExternalId__c =10,Service_Line__c='PI');
        insert objCaseType;
        objMatter.litify_pm__Case_Type__c=objCaseType.id;
        
        update objMatter;
        
        list<user>listUser = [select id,Alias from user where alias='test0' limit 1];
        
        List<Attorney_Split__c>listSplit = new list<Attorney_Split__c>(); 
        listSplit.add(new Attorney_Split__c(
            Attorney__c=listUser[0].id,
            Resolution__c =  objResolution.id,
            Share__c=1
        ));
        // insert listSplit;
        
        Distribution__c objDistribution = new Distribution__c();
        objDistribution.Account__c =listAcc[0].id;
        objDistribution.Amount__c =100;
        objDistribution.Resolution__c=objResolution.id;
        insert objDistribution;
        
        closeResolutionController.closeResolution(objResolution.id,false);
        closeResolutionController.closeResolution(objResolution.id,true);
        test.stopTest();
    }
    
    public static testmethod void createFinalStatementPdf(){
        list<litify_pm__Resolution__c>listResolution = [select id,name from litify_pm__Resolution__c limit 1];
        
        closeResolutionController.objResolution=listResolution[0];
        closeResolutionController.createFinalStatementPdf();
        
    }
    
    public static testmethod void closeResolutionWrapper(){
        closeResolutionWrapper objWrp =new closeResolutionWrapper();
        closeResolutionWrapper.JEWrapper objJE= new closeResolutionWrapper.JEWrapper();
        string gl1=objJE.GLVariable1; 
        string gl2=objJE.GLVariable2; 
        string gl4=objJE.GLVariable4; 
        string GLName=objJE.GLName; 
        decimal debit = objJE.debit;
        decimal credit = objJE.credit;
        objWrp.listJELineWrapper = new  list<closeResolutionWrapper.JEWrapper>{objJE};
            }
}