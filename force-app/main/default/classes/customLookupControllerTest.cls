@isTest(seeAllData=true)
public class customLookupControllerTest {
    static testMethod void testLookupField() {
        try{
            List<string> returnFields = new List<string> {'Name'};
                
            List<Account>listAcc = [SELECT Id FROM Account LIMIT 1];
            if(listAcc.size()>0){
                
                customLookupController.getObjectDetails('Account');
                customLookupController.GetRecentRecords('Account', returnFields, 5,'');
                customLookupController.SearchRecords('Account', returnFields, returnFields, '', 'Name', 'ASC', 5, 'CreatedDate > 2001-01-01T00:00:01Z');
                customLookupController.GetRecord('Account', returnFields, listAcc[0].Id);
            }
        }
        catch(Exception ex){}
        
    }
}