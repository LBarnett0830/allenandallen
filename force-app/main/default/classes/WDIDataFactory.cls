@isTest
public class WDIDataFactory {
    //returns 200 sucess status
    //used to mock callout responses
	public class AWSServiceTestSuccessfulResponseGenerator implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('{ "Test" : { "SignedUrl": "https://www.example.com" } }');
      response.setStatusCode(200);
      return response;
    }
  }

  public class TestMockGetURLfromDocrio implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('{ "Test" : { "signedURL": "https://www.example.com" } }');
      response.setStatusCode(200);
      return response;
    }
  }
  public class TestMockGetURLfromDocrioNoURL implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('{ "Test" : { "nothing": "https://www.example.com" } }');
      response.setStatusCode(200);
      return response;
    }
  }

  public class TestMockGetBLOBfromDocrio implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('This is a test');
      response.setStatusCode(200);
      return response;
    }
  }

  public class TestMockLOGINprocess implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('{ "Test" : { "session": "abcde" , "uploadFolderJSON":"https://www.example.com"} }');
      response.setStatusCode(200);
      return response;
    }
  }

  public class TestMockLOGINprocessError implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('{ "Test" : { "sessionxx": "abcde" , "uploadFolderJSONxx":"https://www.example.com"} }');
      response.setStatusCode(200);
      return response;
    }
  }

  public class TestMockPROFILEprocess implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('{ "Test" : { "errorCount": ""} }');
      response.setStatusCode(200);
      return response;
    }
  }

  public class TestMockPROFILEprocessError implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('{ "Test" : { "errorCount": "1"} }');
      response.setStatusCode(200);
      return response;
    }
  }


  public class TestMockNEWFILEprocess implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('{ "Test" : { "FileRN": "1" , "FileLID":"abcde"} }');     response.setStatusCode(200);
      return response;
    }
  }
  public class TestMockNEWFILEprocessError implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('{ "Test" : { "FileRNxx": "1" , "FileLIDxx":"abcde"} }');
      response.setStatusCode(200);
      return response;
    }
  }

  public class TestMockAEDTABLEprocess implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('{ "Test" : { "FileRN": "1" , "FileLID":"abcde"} }');     response.setStatusCode(200);
      return response;
    }
  }
  
  public class TestMockUPLOADIISprocess implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('{ "Test" : { "message": "Your file uploaded successfully" , "FileLID":"abcde"} }');     response.setStatusCode(200);
      return response;
    }
  }

  public class TestMockUPLOADIISprocessError implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('{ "Test" : { "message": "Your file did not upload successfully" , "FileLID":"abcde"} }');     response.setStatusCode(200);
      return response;
    }
  }

  public class TestMockUPLOADWDprocess implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('{ "Test" : { "errorCount": "" , "FileLID":"abcde"} }');     response.setStatusCode(200);
      return response;
    }
  }

  public class TestMockUPLOADWDprocessError implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('{ "Test" : { "errorCount": "1" , "FileLID":"abcde"} }');     response.setStatusCode(200);
      return response;
    }
  }


  public class TestMockLOGOUTprocess implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('{ "Test" : { "errorCount": "" , "FileLID":"abcde"} }');     response.setStatusCode(200);
      return response;
    }
  }

  public class TestMockLOGOUTprocessError implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('{ "Test" : { "errorCount": "1" , "FileLID":"abcde"} }');     response.setStatusCode(200);
      return response;
    }
  }
    //Creates one user of stipulated profile type
    public static User createUser(String profileName){
        Profile p = [SELECT Id FROM Profile WHERE Name=:profileName];
        String userNameString = 'test' + createRandomIdentifier(100000) + '@testorg.com';
        User u = new User(Alias = 'test', Email='testUser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=userNameString);
        insert u;
        return u;
    }
    //creates single File Info record with no fields set
    public static litify_docs__File_Info__c createFileInfo(){
        litify_docs__File_Info__c fileInfo = new litify_docs__File_Info__c();
        insert fileInfo;
        return fileInfo;
    }
    //Overloading so we can create file info with matter or intake set at creation
    public static litify_docs__File_Info__c createFileInfo(String relatedToAPI, Id relatedToId){
        litify_docs__File_Info__c testFileInfo = new litify_docs__File_Info__c(litify_docs__Related_To_Api_Name__c = relatedToAPI,
                                                                           litify_docs__Related_To__c = relatedToId);
        insert testFileInfo;
        return testFileInfo;
       
    }
    //creates single Account
    public static Account createAccount(){
        Account a = new Account(Name='test',
                                litify_pm__First_Name__c  = 'test',
                                litify_pm__Last_Name__c  = 'tester');
        insert a;
        return a;
        
    }
    //create single matter with no other fields. This will probably need to be modified in most orgs as they will
    //have more required fields
    public static litify_pm__Matter__c createMatter(Account a){
         litify_pm__Matter__c m = new litify_pm__Matter__c(litify_pm__Client__c = a.Id);
         insert m;
         return m;
    }

    //create single Intake with no other fields. This will probably need to be modified in most orgs as they will
    //have more required fields
    public static litify_pm__Intake__c createIntake(Account a){
        litify_pm__Intake__c i = new litify_pm__Intake__c(litify_pm__Client__c = a.Id);
        insert i;
        return i;
   }
    
    public static String createRandomIdentifier(Integer ceiling){
        Integer randomNumber = Integer.valueOf((Math.random() * ceiling));
        String numberString = String.valueOf(randomNumber);
        return numberString;
    }

    public static litify_pm__Case_Type__c createCaseType() {
      litify_pm__Case_Type__c ct = new litify_pm__Case_Type__c();
      ct.name = 'test';
      ct.litify_pm__ExternalId__c = 1;
      ct.litify_pm__Is_Available__c = true;

      insert ct;
      return ct;
    }
    
}