@isTest
public without sharing class GetRecordLockStatusTest {
   
    @isTest
    public static void CanGetRecordLockStatus () {

        //create record

        Account testAct1 = new Account();
        testAct1.Name = 'testAccount1';
        testAct1.litify_pm__Last_Name__c = 'LastName Test';
        testAct1.litify_pm__First_Name__c = 'FirstNameTest';
        insert testAct1;

        
        //lock it
        Approval.lock(testAct1.Id);

        //call GetRecordLockStatus
        GetRecordLockStatus.Request testReq = new GetRecordLockStatus.Request();
        testReq.recordId = testAct1.Id;
       
        List<GetRecordLockStatus.Request> reqList = new List<GetRecordLockStatus.Request>();
        reqList.add(testReq);

        List<GetRecordLockStatus.Response> getstatusResponseList = GetRecordLockStatus.GetStatus(reqList);
         
        //inspect result

        System.assertEquals(getstatusResponseList[0].locked,true);
       


    }

}