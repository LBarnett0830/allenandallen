@isTest
private class deleteExpenseControllerTest {
    
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
        dep.External_ID__c='50';
        Insert dep;
        
        list<AcctSeed__GL_Account__c>listGl = new list<AcctSeed__GL_Account__c>();
        listGL.add(new AcctSeed__GL_Account__c(
            Name = label.Project_task_Revenue_GL_Account,
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            Department__c = dep.id,
            AcctSeed__Sub_Type_2__c = 'Cash'));
        insert listGL;
        
        litify_pm__Matter__c objMatter = new litify_pm__Matter__c();
        objMatter.litify_pm__Client__c = ObjAccount.Id;
        insert objMatter;
        
        litify_pm__Expense__c objExpense = new litify_pm__Expense__c();
        objExpense.litify_pm__Date__c = system.today();
        objExpense.Stage__c = 'Approved';
        objExpense.litify_pm__Amount__c = 50;
        objExpense.litify_pm__Matter__c = objMatter.Id;
        objExpense.Billing_Status__c = 'Billed';
        objExpense.Stage__c = 'In-Process';
        insert objExpense;
        
        PageReference pageRef = Page.deleteExpense;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',objExpense.Id);
        
        ApexPages.StandardController ExpenseController = new ApexPages.StandardController(objExpense);        
        deleteExpenseController controller = new deleteExpenseController(ExpenseController);
        controller.checkValidation();
        controller.redirectToDetail();
        controller.redirectToList();
        test.stopTest();
    }
}