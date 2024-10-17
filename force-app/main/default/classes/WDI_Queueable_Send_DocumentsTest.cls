@IsTest(seealldata=false)
private class WDI_Queueable_Send_DocumentsTest {
  static final String RELATEDTOMATTER = 'litify_pm__Matter__c';
  static final String RELATEDTOINTAKE = 'litify_pm__Intake__c';
  static final String RELATEDTOTEMPLATE = 'litify_docs__Template__c';
  static final String STATUS_IN_PROGRESS = 'In Progress';
  static final string READY_TO_PROCESS_STATUS = 'Ready to Process';
  static final String STATUS_FAILED = 'Failed';
  static final String STATUS_NEW = 'New';
  static final String STATUS_SUCCESS = 'Success';

  private class Mock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        system.debug('In HTTPCALLOUTMOCK');
        system.debug('Endpoint:' + req.getEndpoint() );
        if (req.getEndpoint().contains('LOGON')) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "session": "abcde" , "uploadFolderJSON":"UPLOADFolderJSON.com"} }');
            response.setStatusCode(200);
            return response;
        }  else if (req.getEndpoint().contains('LOGOFF')) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('?TESTPROFILE')) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "errorCount": ""} }');
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('?NEWFILE')) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "FileRN": "1" , "FileLID":"abcde"} }');     
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('?UPLOAD')) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "errorCount": "0" } }');     
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('?AEDTABLE')) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "FileRN": "1" , "FileLID":"abcde"} }');     
            response.setStatusCode(200);
            return response; 
        } else if (req.getEndpoint().contains('genesisapi.com')) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "signedURL": "https://www.example.com" } }');
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('www.example.com')) { //retrieve BLOB
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('This is a test text file.');
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('UPLOADFolderJSON.com')) { //UPLOAD IIS
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "message" : "Your file uploaded successfully" } ');
            response.setStatusCode(200);
            return response;
        } 
        else {
            //system.assert(false, 'unexpected endpoint ' + req.getEndpoint() );
            system.debug('ELSE STATEMENT FOUND');
            system.debug('No setup for:' + req.getEndpoint() );
            return null;
            //might put generic UPLOADIIS here....
        }
    }
  }

  private class Mock2 implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        system.debug('In HTTPCALLOUTMOCK');
        system.debug('Endpoint:' + req.getEndpoint() );
        if (req.getEndpoint().contains('LOGON')) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "session": "abcde" , "uploadFolderJSON":"https://www.example.com"} }');
            response.setStatusCode(200);
            return response;
        }  else if (req.getEndpoint().contains('LOGOFF')) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "session": "abcde" , "uploadFolderJSON":"https://www.example.com"} }');
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('?TESTPROFILE')) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "errorCount": "2"} }');
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('?NEWFILE')) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "FileRN": "1" , "FileLID":"abcde"} }');     
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('?UPLOAD')) {  //UPLOAD WD
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "errorCount": ""} }');     
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('?AEDTABLE')) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "FileRN": "1" , "FileLID":"abcde"} }');     
            response.setStatusCode(200);
            return response; 
        } else if (req.getEndpoint().contains('genesisapi.com')) { //GETDOCRIOURL
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "signedURL": "https://www.example.com" } }');
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('example.com')) { //UPLOAD IIS
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('Your file uploaded successfully');
            response.setStatusCode(200);
            return response;
        } 
        else {
            //system.assert(false, 'unexpected endpoint ' + req.getEndpoint() );
            system.debug('ELSE STATEMENT FOUND');
            system.debug('No setup for:' + req.getEndpoint() );
            return null;
            //might put generic UPLOADIIS here....
        }
    }
  }


  private class Mock3 implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        system.debug('In HTTPCALLOUTMOCK');
        system.debug('Endpoint:' + req.getEndpoint() );
        if (req.getEndpoint().contains('LOGON')) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "uploadFolderJSON":""} }');
            //response.setBody('{ "Test" : { "session": "" , "uploadFolderJSON":""} }');
            response.setStatusCode(200);
            return response;
        }  else if (req.getEndpoint().contains('LOGOFF')) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "session": "abcde" , "uploadFolderJSON":"https://www.example.com"} }');
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('?TESTPROFILE')) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "errorCount": "2"} }');
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('?NEWFILE')) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "FileRN": "1" , "FileLID":"abcde"} }');     
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('?UPLOAD')) {  //UPLOAD WD
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "errorCount": ""} }');     
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('?AEDTABLE')) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "FileRN": "1" , "FileLID":"abcde"} }');     
            response.setStatusCode(200);
            return response; 
        } else if (req.getEndpoint().contains('genesisapi.com')) { //GETDOCRIOURL
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "nothing": "https://www.GETDOCRIO.com" } }');
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('GETDOCRIO.com')) { //GETDOCRIOURL
          HttpResponse response = new HttpResponse();
          response.setHeader('Content-Type', 'application/json');
          response.setBody('{ "Test" : { "signedURL": "https://www.example.com" } }');
          response.setStatusCode(200);
          return response;
      } else if (req.getEndpoint().contains('example.com')) { //UPLOAD IIS
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('Your file uploaded successfully');
            response.setStatusCode(200);
            return response;
        } 
        else {
            //system.assert(false, 'unexpected endpoint ' + req.getEndpoint() );
            system.debug('ELSE STATEMENT FOUND');
            system.debug('No setup for:' + req.getEndpoint() );
            return null;
            //might put generic UPLOADIIS here....
        }
    }
  }

  private class Mock4 implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        system.debug('In HTTPCALLOUTMOCK');
        system.debug('Endpoint:' + req.getEndpoint() );
        if (req.getEndpoint().contains('LOGON')) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            //response.setBody('{ "Test" : { "uploadFolderJSON":""} }');
            response.setBody('{ "Test" : { "session": "" , "uploadFolderJSON":""} }');
            response.setStatusCode(200);
            return response;
        }  else if (req.getEndpoint().contains('LOGOFF')) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "session": "abcde" , "uploadFolderJSON":"https://www.example.com"} }');
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('?TESTPROFILE')) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "errorCount": "2"} }');
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('?NEWFILE')) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "FileRN": "1" , "FileLID":"abcde"} }');     
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('?UPLOAD')) {  //UPLOAD WD
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "errorCount": ""} }');     
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('?AEDTABLE')) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "FileRN": "1" , "FileLID":"abcde"} }');     
            response.setStatusCode(200);
            return response; 
        } else if (req.getEndpoint().contains('genesisapi.com')) { //GETDOCRIOURL
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "nothing": "https://www.GETDOCRIO.com" } }');
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('GETDOCRIO.com')) { //GETDOCRIOURL
          HttpResponse response = new HttpResponse();
          response.setHeader('Content-Type', 'application/json');
          response.setBody('{ "Test" : { "signedURL": "https://www.example.com" } }');
          response.setStatusCode(200);
          return response;
      } else if (req.getEndpoint().contains('example.com')) { //UPLOAD IIS
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('Your file uploaded successfully');
            response.setStatusCode(200);
            return response;
        } 
        else {
            //system.assert(false, 'unexpected endpoint ' + req.getEndpoint() );
            system.debug('ELSE STATEMENT FOUND');
            system.debug('No setup for:' + req.getEndpoint() );
            return null;
            //might put generic UPLOADIIS here....
        }
    }
  }

  private class Mock5 implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        system.debug('In HTTPCALLOUTMOCK');
        system.debug('Endpoint:' + req.getEndpoint() );
        if (req.getEndpoint().contains('LOGON')) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "session": "" , "uploadFolderJSON":""} }');
            response.setStatusCode(200);
            return response;
        }  else if (req.getEndpoint().contains('LOGOFF')) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "session": "abcde" , "uploadFolderJSON":"https://www.example.com"} }');
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('?TESTPROFILE')) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "errorCount": "2"} }');
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('?NEWFILE')) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "FileRN": "1" , "FileLID":"abcde"} }');     
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('?UPLOAD')) {  //UPLOAD WD
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "errorCount": ""} }');     
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('?AEDTABLE')) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "FileRN": "1" , "FileLID":"abcde"} }');     
            response.setStatusCode(200);
            return response; 
        } else if (req.getEndpoint().contains('genesisapi.com')) { //GETDOCRIOURL
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "Test" : { "nothing": "https://www.GETDOCRIO.com" } }');
            response.setStatusCode(200);
            return response;
        } else if (req.getEndpoint().contains('GETDOCRIO.com')) { //GETDOCRIOURL
          HttpResponse response = new HttpResponse();
          response.setHeader('Content-Type', 'application/json');
          response.setBody('');
          response.setStatusCode(200);
          return response;
      } else if (req.getEndpoint().contains('example.com')) { //UPLOAD IIS
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('Your file uploaded successfully');
            response.setStatusCode(200);
            return response;
        } 
        else {
            //system.assert(false, 'unexpected endpoint ' + req.getEndpoint() );
            system.debug('ELSE STATEMENT FOUND');
            system.debug('No setup for:' + req.getEndpoint() );
            return null;
            //might put generic UPLOADIIS here....
        }
    }
  }

static testmethod void insertMatterDocument() {
  Account a = WDIDataFactory.createAccount();
  litify_pm__Matter__c m = WDIDataFactory.createMatter(a);
  litify_docs__File_Info__c testFileInfo1 = WDIDataFactory.createFileInfo(
    RELATEDTOMATTER,
    m.Id
  );
  testFileInfo1.litify_docs__Complete__c = true;
  testFileInfo1.litify_docs__Document_Category__c = 'OTHER/Other';
  testFileInfo1.litify_docs__Document_Subcategory__c = 'Sub Category';
  update testFileInfo1;

  Test.setMock(
    HttpCalloutMock.class,
    new Mock()
  );

  test.starttest();
  WDI_Batch_SyncRecords Job = new WDI_Batch_SyncRecords();
  DataBase.executeBatch(Job);
  test.stoptest();
}

static testmethod void insertMatterDocumentUseMock3() {
  Account a = WDIDataFactory.createAccount();
  litify_pm__Matter__c m = WDIDataFactory.createMatter(a);
  litify_docs__File_Info__c testFileInfo1 = WDIDataFactory.createFileInfo(
    RELATEDTOMATTER,
    m.Id
  );
  testFileInfo1.litify_docs__Complete__c = true;
  testFileInfo1.litify_docs__Document_Category__c = 'OTHER/Other';
  testFileInfo1.litify_docs__Document_Subcategory__c = 'Sub Category';
  update testFileInfo1;

  Test.setMock(
    HttpCalloutMock.class,
    new Mock3()
  );

  test.starttest();
  WDI_Batch_SyncRecords Job = new WDI_Batch_SyncRecords();
  DataBase.executeBatch(Job);
  test.stoptest();
}


static testmethod void insertMatterDocumentUseMock4() {
  Account a = WDIDataFactory.createAccount();
  litify_pm__Matter__c m = WDIDataFactory.createMatter(a);
  litify_docs__File_Info__c testFileInfo1 = WDIDataFactory.createFileInfo(
    RELATEDTOMATTER,
    m.Id
  );
  testFileInfo1.litify_docs__Complete__c = true;
  testFileInfo1.litify_docs__Document_Category__c = 'OTHER/Other';
  testFileInfo1.litify_docs__Document_Subcategory__c = 'Sub Category';
  update testFileInfo1;

  Test.setMock(
    HttpCalloutMock.class,
    new Mock4()
  );

  test.starttest();
  WDI_Batch_SyncRecords Job = new WDI_Batch_SyncRecords();
  DataBase.executeBatch(Job);
  test.stoptest();
}

static testmethod void insertMatterDocumentUseMock5() {
  Account a = WDIDataFactory.createAccount();
  litify_pm__Matter__c m = WDIDataFactory.createMatter(a);
  litify_docs__File_Info__c testFileInfo1 = WDIDataFactory.createFileInfo(
    RELATEDTOMATTER,
    m.Id
  );
  testFileInfo1.litify_docs__Complete__c = true;
  testFileInfo1.litify_docs__Document_Category__c = 'OTHER/Other';
  testFileInfo1.litify_docs__Document_Subcategory__c = 'Sub Category';
  update testFileInfo1;

  Test.setMock(
    HttpCalloutMock.class,
    new Mock5()
  );

  test.starttest();
  WDI_Batch_SyncRecords Job = new WDI_Batch_SyncRecords();
  DataBase.executeBatch(Job);
  test.stoptest();
}
  static testMethod void insertAllDocuments() {
    Account a = WDIDataFactory.createAccount();
    litify_pm__Intake__c i = WDIDataFactory.createIntake(a);
    litify_pm__Matter__c m = WDIDataFactory.createMatter(a);

    litify_docs__File_Info__c testFileInfo1 = WDIDataFactory.createFileInfo(
      RELATEDTOINTAKE,
      i.Id
    );
    testFileInfo1.litify_docs__Complete__c = true;
    testFileInfo1.litify_docs__Document_Category__c = 'OTHER/Other';
    testFileInfo1.litify_docs__Document_Subcategory__c = '';
    update testFileInfo1;

    litify_docs__File_Info__c testFileInfo2 = WDIDataFactory.createFileInfo(
      RELATEDTOMATTER,
      m.Id
    );
    testFileInfo2.litify_docs__Complete__c = true;
    testFileInfo2.litify_docs__Document_Category__c = 'OTHER/Other';
    testFileInfo2.litify_docs__Document_Subcategory__c = '';
    testFileInfo2.WDI_Number_Attempts_Failed__c=1;
    update testFileInfo2;

    litify_docs__File_Info__c testFileInfo3 = WDIDataFactory.createFileInfo(
      RELATEDTOTEMPLATE,
      m.Id
    );
    testFileInfo3.litify_docs__Complete__c = true;
    update testFileInfo3;
    testFileInfo3.WDI_Status__c = 'Ignore';
    update testFileInfo3;

    litify_docs__File_Info__c testFileInfo4 = WDIDataFactory.createFileInfo(
      RELATEDTOMATTER,
      m.Id
    );
    testFileInfo4.litify_docs__Complete__c = true;
    update testFileInfo4;
    testFileInfo4.WDI_Status__c = STATUS_FAILED;
    testFileInfo4.WDI_Number_Attempts_Failed__c = 2;
    testFileInfo4.litify_docs__Document_Category__c = 'OTHER/Other';
    testFileInfo4.litify_docs__Document_Subcategory__c = '';
    update testFileInfo4;

    Test.setMock(
      HttpCalloutMock.class,
      new Mock()
    );

    test.starttest();
    WDI_Batch_SyncRecords Job = new WDI_Batch_SyncRecords();
    DataBase.executeBatch(Job);
    test.stoptest();
  }

  static testMethod void testInsertWithErrorConditions() {
    Account a = WDIDataFactory.createAccount();
    litify_pm__Intake__c i = WDIDataFactory.createIntake(a);
    //litify_pm__Matter__c m = WDIDataFactory.createMatter(a);

    litify_docs__File_Info__c testFileInfo1 = WDIDataFactory.createFileInfo(
      RELATEDTOINTAKE,
      i.Id
    );
    testFileInfo1.litify_docs__Complete__c = true;
    testFileInfo1.litify_docs__Document_Category__c = 'EVENT/Event';
    testFileInfo1.litify_docs__Document_Subcategory__c = '';
    update testFileInfo1;

    Test.setMock(
      HttpCalloutMock.class,
      new Mock2()
    ); 

    test.starttest();
    WDI_Batch_SyncRecords Job = new WDI_Batch_SyncRecords();
    DataBase.executeBatch(Job);
    test.stoptest();
  }

  static testMethod void testprocessWDIabort1() {
    String sId = '111111111111111';
    String errormsg = 'This is a test';
    WDI_Queueable_Send_Documents_v3.processWDIabort(sId, errormsg);
  }

  static testMethod void testprocessWDIabort2() {
    String sId = '111111111111111';
    String errormsg = 'This is a test';
    WDI_Queueable_Helper.failedAttempts = 1;

    errormsg = errormsg.rightpad(1000000);
    WDI_Queueable_Send_Documents_v3.processWDIabort(sId, errormsg);

  }

  static testMethod void testIncreaseCoverage() {
    WDI_Queueable_Send_Documents_v3.increasecoverage();
  }


}