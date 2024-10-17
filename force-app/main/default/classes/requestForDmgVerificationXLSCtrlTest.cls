@isTest(seeAllData=true)//since we have a flow in the Matter which is posting to chatter(Chatter: New Matter for Legal Team)
public class requestForDmgVerificationXLSCtrlTest {
    
    public static testmethod void testAll(){
        
        List<Account> listAcc = new List<Account>();
        listAcc.add(  new Account(
            litify_pm__First_Name__c ='Account 1', 
            litify_pm__Last_Name__c ='Last Name 1',
            BillingCity = 'New York',
            BillingCountry = 'United States',
            BillingStreet = 'Avenue',
            BillingPostalCode = '12412'
        ));
        listAcc.add(  new Account(
            litify_pm__First_Name__c ='Account 2', 
            litify_pm__Last_Name__c ='Last Name 2',
            BillingCity = 'New York',
            BillingCountry = 'United States',
            BillingStreet = 'Avenue',
            BillingPostalCode = '2222'
        ));        
        listAcc.add(  new Account(
            litify_pm__First_Name__c ='Account 3', 
            litify_pm__Last_Name__c ='Last Name 2',
            BillingCity = 'New York',
            BillingCountry = 'United States',
            BillingStreet = 'Avenue',
            BillingPostalCode = '3322'
        ));        
        insert listAcc;
        
        List<AcctSeed__GL_Account__c> listGLAcc = new List<AcctSeed__GL_Account__c>();
        
        listGLAcc.add(
            new AcctSeed__GL_Account__c(
                Name = label.Project_task_Revenue_GL_Account,
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Inventory'
            )
        );
        //insert listGLAcc;
        
        List<litify_pm__Matter__c> listMatters = new List<litify_pm__Matter__c>();
        listMatters.add( new litify_pm__Matter__c(
            litify_pm__Client__c = listAcc[0].Id
        ));
        
        insert listMatters;   
        
        list<litify_pm__Role__c>listRoles= new list<litify_pm__Role__c>(); 
        listRoles.add( new litify_pm__Role__c(
            litify_pm__Party__c=listAcc[1].Id,
            litify_pm__Matter__c=listMatters[0].Id
        ));
        listRoles.add( new litify_pm__Role__c(
            litify_pm__Party__c=listAcc[2].Id,
            litify_pm__Matter__c=listMatters[0].Id
        ));
        insert listRoles;
        
        List<litify_pm__Request__c> listRequests = new List<litify_pm__Request__c>();
        listRequests.add( new litify_pm__Request__c(
            litify_pm__Matter__c = listMatters[0].Id,
            Assigned_To__c=userinfo.getUserId(),
            Submit_to_Accounting__c=true
        ));
        insert listRequests;
        
        
        List<litify_pm__Damage__c> listDamages = new List<litify_pm__Damage__c>();
        listDamages.add( new litify_pm__Damage__c(
            litify_pm__Matter__c = listMatters[0].Id,
            Damage_Verification_Request_Date__c=system.Date.today()
        ));
        listDamages.add( new litify_pm__Damage__c(
            litify_pm__Matter__c = listMatters[0].Id,
            Damage_Verification_Request_Date__c=system.Date.today()
        ));
        listDamages.add( new litify_pm__Damage__c(
            litify_pm__Matter__c = listMatters[0].Id,
            Damage_Verification_Request_Date__c=system.Date.today(),
            litify_pm__Provider__c =listRoles[0].Id
        ));
        listDamages.add( new litify_pm__Damage__c(
            litify_pm__Matter__c = listMatters[0].Id,
            Damage_Verification_Request_Date__c=system.Date.today(),
            litify_pm__Provider__c =listRoles[1].Id
        ));
        
        insert listDamages;
        
        requestForDmgVerificationXLSController objCon = new requestForDmgVerificationXLSController();
    }
}