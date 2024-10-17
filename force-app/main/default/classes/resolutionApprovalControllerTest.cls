@isTest
public class resolutionApprovalControllerTest {
    @testSetup
    public static void testsetup(){
        
        Account objAcc = new Account();
        objAcc.Name = 'test';
        objAcc.litify_pm__Last_Name__c = 'test lName';
        insert objAcc;
        
        
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
        
        list<AcctSeed__GL_Account__c>listGL = new list<AcctSeed__GL_Account__c>();
        AcctSeed__GL_Account__c objACCGL = new AcctSeed__GL_Account__c(
            Name = '1200-Client Costs Advanced',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            Department__c = dep.id,
            AcctSeed__Sub_Type_2__c = 'Cash');
        listGL.add(objACCGL);
        
        listGL.add(new AcctSeed__GL_Account__c(
            Name = label.Project_task_Revenue_GL_Account,
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            Department__c = dep.id,
            AcctSeed__Sub_Type_2__c = 'Cash'));
        
        insert listGL;
        
        
        litify_pm__Matter__c objMatter = new litify_pm__Matter__c();
        objMatter.litify_pm__Client__c = objAcc.id;
        insert objMatter;
        
        litify_pm__Matter_Team_Role__c objRole = new litify_pm__Matter_Team_Role__c(Name='Attorney');
        insert objRole;
        litify_pm__Matter_Team_Member__c matterTeamMem = new litify_pm__Matter_Team_Member__c();
        matterTeamMem.Name='Test';
        matterTeamMem.litify_pm__Matter__c = objMatter.id;
        matterTeamMem.litify_pm__User__c = userinfo.getUserId();
        matterTeamMem.litify_pm__Role__c = objRole.id;
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
                litify_pm__Amount__c = 101,
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
                litify_pm__Amount__c = 2000,
                litify_pm__Date__c = system.today(),
                litify_pm__Matter__c = objMatter.id,
                litify_pm__ExpenseType2__c = type.id,
                litify_pm__lit_Invoice__c ='test3',
                Stage__c = 'In-Process'
            )
        );
        insert expList;
        
        list<AcctSeed__Accounting_Variable__c>listGLVariables = new  list<AcctSeed__Accounting_Variable__c>();
        AcctSeed__Accounting_Variable__c objGLV2 = new AcctSeed__Accounting_Variable__c(name='Location var',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 2');
        AcctSeed__Accounting_Variable__c objGLV3 = new AcctSeed__Accounting_Variable__c(name='Department var',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 3');
        listGLVariables.add(objGLV2);
        listGLVariables.add(objGLV3);
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(name='Richmond',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 2'));
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(name='test1',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 1'));
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(name='test4',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 4'));
        
        insert listGLVariables;            
        
        litify_pm__Resolution__c objResolution = new litify_pm__Resolution__c(litify_pm__Matter__c = objMatter.id,litify_pm__Settlement_Verdict_Amount__c=100,litify_pm__Total_Damages__c =100);
        insert objResolution;
        
    }
    
    public static testmethod void checkValidationTest(){
        List<litify_pm__Resolution__c>listResolution = [select id,Status__c,litify_pm__Matter__c from litify_pm__Resolution__c];
        list<Account>listAccount = [select id from Account];
        
        listResolution[0].Status__c='';
        update listResolution[0];
        ApexPages.currentPage().getParameters().put('Id',listResolution[0].id);
        resolutionApprovalController objCon = new resolutionApprovalController();
        objCon.checkValidation();
        
        listResolution[0].Status__c='In-Process';
        update listResolution[0];
        ApexPages.currentPage().getParameters().put('Id',listResolution[0].id);
        resolutionApprovalController objCon1= new resolutionApprovalController();
        objCon1.checkValidation();
        
        listResolution[0].litify_pm__Matter__c=null;
        update listResolution[0];
        ApexPages.currentPage().getParameters().put('Id',listResolution[0].id);
        resolutionApprovalController objCon2= new resolutionApprovalController();
        objCon2.checkValidation();
        
        List<litify_pm__Matter__c>listMatter = [select id,litify_pm__Principal_Attorney__c from litify_pm__Matter__c];
        listResolution[0].litify_pm__Matter__c=listMatter[0].id;
        listResolution[0].litify_pm__Settlement_Verdict_Amount__c =-10;
        listResolution[0].litify_pm__Total_Damages__c =null;
        update listResolution[0];
        ApexPages.currentPage().getParameters().put('Id',listResolution[0].id);
        resolutionApprovalController objCon3= new resolutionApprovalController();
        objCon3.checkValidation();
        
        list<user>listUser = [select id from user];
        listMatter[0].litify_pm__Principal_Attorney__c = listUser[0].id;
        update  listMatter[0];
        
        listResolution[0].litify_pm__Settlement_Verdict_Amount__c =100;
        update    listResolution[0];
        ApexPages.currentPage().getParameters().put('Id',listResolution[0].id);
        resolutionApprovalController objCon4= new resolutionApprovalController();
        objCon4.checkValidation();
        
        List<Attorney_Split__c>listSplit = new list<Attorney_Split__c>(); 
        listSplit.add(new Attorney_Split__c(
            Attorney__c=listUser[0].id,Resolution__c =  listResolution[0].id
        ));
        insert listSplit;
        ApexPages.currentPage().getParameters().put('Id',listResolution[0].id);
        resolutionApprovalController objCon5= new resolutionApprovalController();
        objCon5.checkValidation();
        
        litify_pm__Intake__c objIntake = new litify_pm__Intake__c(
            litify_pm__Client__c = listAccount[0].id,
            litify_pm__Matter__c = listMatter[0].id
        );
        insert objIntake;
        listMatter[0].litify_pm__Primary_Intake__c=objIntake.Id;
        update listMatter[0];
        ApexPages.currentPage().getParameters().put('Id',listResolution[0].id);
        resolutionApprovalController objCon6= new resolutionApprovalController();
        objCon6.checkValidation();
        
        objIntake.Originating_Office__c ='Richmond';
        update objIntake;
        listMatter[0].litify_pm__Primary_Intake__c=objIntake.Id;
        update listMatter[0];
        ApexPages.currentPage().getParameters().put('Id',listResolution[0].id);
        resolutionApprovalController objCon7= new resolutionApprovalController();
        objCon7.checkValidation();
        
        litify_pm__Case_Type__c objCaseType = new litify_pm__Case_Type__c(litify_pm__Is_Available__c=true,litify_pm__ExternalId__c =10);
        insert objCaseType;
        listMatter[0].litify_pm__Case_Type__c=objCaseType.id;
        update listMatter[0];
        resolutionApprovalController objCon8= new resolutionApprovalController();
        objCon8.checkValidation();
        
        
        objCaseType.Service_Line__c='PI';
        update objCaseType;
        resolutionApprovalController objCon9= new resolutionApprovalController();
        objCon9.checkValidation();
        
        AcctSeed__Accounting_Variable__c objGLV2 = new AcctSeed__Accounting_Variable__c(name='PI',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 1');
        resolutionApprovalController objCon10= new resolutionApprovalController();
        objCon10.checkValidation();
        
        objCon8.resolutionId=listResolution[0].id;
        objCon8.redirectToDetail();
        
        objCon8.processExpenseApproval();
        
        
    }
    
}