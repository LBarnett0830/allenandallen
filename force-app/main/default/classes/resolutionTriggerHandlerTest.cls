@isTest
public class resolutionTriggerHandlerTest {

    @testSetup
    public static void testsetup(){

        Account objAcc = new Account();
        objAcc.Name = 'test';
        objAcc.litify_pm__Last_Name__c = 'test lName';
        insert objAcc;


        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        List<User> listUser = new List<User>();
        // 0
        listUser.add(
                        new User(Alias = 'test0', Email='test0@testorg.com',
                                EmailEncodingKey='UTF-8', LastName='TestLast0', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = p.Id,
                     TimeZoneSidKey='America/Los_Angeles', UserName='test0@testorg1.com', Expense_Approval_Limit__c = 50000
                        )
        );
        Insert listUser;

        litify_pm__Matter__c objMatter = new litify_pm__Matter__c();
        objMatter.litify_pm__Client__c = objAcc.id;
        objMatter.litify_pm__Principal_Attorney__c = listUser[0].id;
        objMatter.ATO_Case_Number__c = 'TestClass';
        insert objMatter;

        litify_pm__Matter_Team_Role__c objRole = new litify_pm__Matter_Team_Role__c(Name='Attorney');
        insert objRole;
        litify_pm__Matter_Team_Member__c matterTeamMem = new litify_pm__Matter_Team_Member__c();
        matterTeamMem.Name='TestClass';
        matterTeamMem.litify_pm__Matter__c = objMatter.id;
        matterTeamMem.litify_pm__User__c = userinfo.getUserId();
        matterTeamMem.litify_pm__Role__c = objRole.id;
        insert matterTeamMem;
        
        List<litify_pm__Expense_Type__c>listExpType= new  List<litify_pm__Expense_Type__c>();
        litify_pm__Expense_Type__c type = new litify_pm__Expense_Type__c();
        type.Category__c = 'Hard Cost';
        type.Name = 'TestClass';
        listExpType.add(type);
        
        litify_pm__Expense_Type__c type2 = new litify_pm__Expense_Type__c();
        type2.Category__c = 'Soft Cost';
        listExpType.add(type2);
        type2.Name = 'TestClass';
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
                litify_pm__ExpenseType2__c = type2.id,
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
        
        litify_pm__Resolution__c objResolution = new litify_pm__Resolution__c(litify_pm__Matter__c = objMatter.id,litify_pm__Attorney_Credited__c = listUser[0].id);
        insert objResolution;
        
    }
    
    @isTest static void testAll(){
        test.startTest();
        
        List<litify_pm__Expense__c> expList = [select Id,Name,stage__c,Interim_Approval__c,litify_pm__Matter__c FROM litify_pm__Expense__c];
        List<litify_pm__Resolution__c>listResolution = [select id,litify_pm__Matter__c,litify_pm__Matter__r.litify_pm__Principal_Attorney__c from litify_pm__Resolution__c];
        
        List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
        Approval.ProcessSubmitRequest objAppReq = new Approval.ProcessSubmitRequest();
        objAppReq.setComments('Submitting request for approval.');
        objAppReq.setObjectId(listResolution[0].id);
        objAppReq.setSubmitterId(UserInfo.getUserId());
        //objAppReq.setProcessDefinitionNameOrId('Expense_Approval_ProcessV1');
        objAppReq.setNextApproverIds(new list<id>{listResolution[0].litify_pm__Matter__r.litify_pm__Principal_Attorney__c}); 
        approvalRequestList.add(objAppReq);
        
        Approval.process(approvalRequestList);
        
        listResolution[0].Status__c ='Approved';
        listResolution[0].litify_pm__Settlement_Verdict_Amount__c =10;
        update listResolution[0];        
        
    }

    @Istest
    static void testDamageUpdates(){
        //testsetup();
        Test.startTest(); 
        List<litify_pm__Resolution__c> listResolution = [
            SELECT 
                id,litify_pm__Matter__c,litify_pm__Matter__r.litify_pm__Principal_Attorney__c 
            FROM 
                litify_pm__Resolution__c
            ];

        List<litify_pm__Damage__c> toCreate = new List<litify_pm__Damage__c>();
        //Damage 1
        litify_pm__Damage__c damage1 = new litify_pm__Damage__c(
            Resolution__c = listResolution[0].Id,
            litify_pm__Matter__c = listResolution[0].litify_pm__Matter__c,
            litify_pm__Amount_Billed__c = 10000.00,
            Name = 'Test Damage 1');
        toCreate.add(damage1);
        //Damage 2
        litify_pm__Damage__c damage2 = new litify_pm__Damage__c(
            Resolution__c = listResolution[0].Id,
            litify_pm__Matter__c = listResolution[0].litify_pm__Matter__c,
            litify_pm__Amount_Billed__c = 20000.00,
            Name = 'Test Damage 2');
        toCreate.add(damage2);
        //Damage 3 - Escrow Damage
        litify_pm__Damage__c damage3 = new litify_pm__Damage__c(
            Resolution__c = listResolution[0].Id,
            litify_pm__Matter__c = listResolution[0].litify_pm__Matter__c,
            litify_pm__Amount_Billed__c = 5000.00,
            Name = 'Test Damage 3 - Escrow',
            Escrow__c = true);
        toCreate.add(damage3);

        
        insert toCreate;
        Test.stopTest();
    }

    private static List<String> getPermissionNames(){
        return new List<String>{
            'Trust_Deposits_and_Trust_Cash_Receipts_Read_Only',
            'Issue_Tracker',
            'SMS_Interact_Conversation_User',
            'SMS_Interact_Permission_Set',
            'SMS_Converse_Conversation_User_Extra',
            'View_Sortable_Data_Grids',
            'Litify_Matter_User_Custom',
            'AP_Only_for_Dept_Approvers',
            'Create_and_Edit_Reports',
            'View_Sortable_Data_Grids_New',
            'Winter_21_Questionnaires_Access',
            'Docs_End_User_Custom',
            'Winter_21_Features_Access',
            'Litify_Apex_Class_Access',
            'DocuSign_Sender',
            'DocuSign_User',
            'Litify_Intake_User_Unmanaged',
            'Docs_End_User',
            'AS_View_Only',
            'Document_Approval',
            'Litify_Documents_User',
            'Litify_Calendar_Rules_User',
            'Report_Builder',
            'Docrio_Email_End_User',
            'ARC_Apex_VF_Permission_Set',
            'EinsteinAnalyticsPlusUser',
            'AnalyticsViewOnlyUser',
            'Archiver_View_Archived_Records',
            'Export',
            'Med_Pay',
            'Litify_V29_Permission_Set',
            'DocuSign_User',
            'SSO_Allen_Employee',
            'Lightning_Console',
            'CRM_Analytics_User'
        };
    }
    
}