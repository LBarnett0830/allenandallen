@isTest (seealldata = false)
public class WDIBatchDeleteLitifyDocsTest {

    static testMethod void testMethod1() {
    //insert document(s) into Docrio
    List<litify_docs__File_Info__c> listOfDocs = new List<litify_docs__File_Info__c>();

    Account a1 = WDIDataFactory.createAccount();
    litify_pm__Matter__c m1 = WDIDataFactory.createMatter(a1);
    litify_docs__File_Info__c f1 = WDIDataFactory.createFileInfo('litify_pm__Matter__c',m1.Id);
    f1.WDI_Status__c = 'Success';
    update f1;

    Account a2 = WDIDataFactory.createAccount();
    litify_pm__Matter__c m2 = WDIDataFactory.createMatter(a2);
    litify_docs__File_Info__c f2 = WDIDataFactory.createFileInfo('litify_pm__Matter__c',m2.Id);
    f2.WDI_Status__c = 'Success';
    update f2;

    Set<Id> recIDs = new Set<Id>{f1.Id, f2.Id};
    
    //call the batch job
    Test.startTest();
    WDIBatchDeleteLitifyDocs obj = new WDIBatchDeleteLitifyDocs();
    Database.executeBatch(obj, 50);  //max batch size
    Test.stopTest();

    listOfDocs = [SELECT Id, Name 
                FROM litify_docs__File_Info__c
                WHERE Id IN: recIDs];
    
    system.debug('List of Docs:' + listOfDocs);
    System.assert(listOfDocs != null);

    } 
}