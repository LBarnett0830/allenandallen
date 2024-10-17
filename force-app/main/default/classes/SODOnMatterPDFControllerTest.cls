@istest(seeAllData=true)
public class SODOnMatterPDFControllerTest {

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
      
        ApexPages.currentPage().getParameters().put('id', objMatter.Id);
        SODOnMatterPDFController obj = new SODOnMatterPDFController();
        
        test.stopTest();
    }
    
    
}