@isTest
public class lookupControllerTest {
    static testMethod void testLookupField() {
        List<string> returnFields = new List<string> {'Name'};
        Account objAcc = new Account();
        objAcc.Name = 'test';
        objAcc.litify_pm__Last_Name__c = 'test lName';
        insert objAcc;
        
        lookupController.getObjectDetails('Account');
        lookupController.GetRecentRecords('Account', returnFields, 5,'');
        lookupController.SearchRecords('Account', returnFields, returnFields, '', 'Name', 'ASC', 5, 'CreatedDate > 2001-01-01T00:00:01Z');
        lookupController.GetRecord('Account', returnFields, objAcc.Id);
    }
    
}