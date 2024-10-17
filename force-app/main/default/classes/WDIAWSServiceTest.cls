@IsTest(seeAllData=false)
private class WDIAWSServiceTest {
  static testMethod void testDeleteFiles() {
      Test.setMock(HttpCalloutMock.class, new WDIDataFactory.AWSServiceTestSuccessfulResponseGenerator() );
      litify_docs__File_Info__c testFile = WDIDataFactory.createFileInfo();

    test.starttest();
    WDIAWSService.deleteFiles(testFile.Id);
    test.stoptest();
  }
}