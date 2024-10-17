@isTest
public class closingStatementControllerTest {
     
    @isTest
    static void testMethod1(){
        
        List<litify_pm__Resolution__c> resObjList = new List<litify_pm__Resolution__c>();
        
        litify_pm__Resolution__c resObj =  new litify_pm__Resolution__c();
        resObj.Status__c = 'In-Process';
        resObj.litify_pm__Resolution_Type__c = 'Mediation';
        resObjList.add(resObj);
        
        insert resObjList;
        
        closingStatementController.generateStatement(string.ValueOf(resObjList[0].id), 'Rough');
        
        closingStatementController.generateStatement(string.ValueOf(resObjList[0].id), 'Else Part');
       
    }

}