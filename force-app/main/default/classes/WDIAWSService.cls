public class WDIAWSService {

    //private static final litify_docs__Litify_Files_API_Fields__c API_FIELDS = litify_docs__Litify_Files_API_Fields__c.getOrgDefaults();
    //private static final litify_docs__Litify_Files_User_Access_Fields__c USER_ACCESS_FIELDS =
    //litify_docs__Litify_Files_User_Access_Fields__c.getValues(UserInfo.getUserId());

    //Private static WDI_Settings__c WDISettings = WDI_Settings__c.getOrgDefaults();
    //private static Portal_Settings__c portalSettingsUser = Portal_Settings__c.getValues(UserInfo.getUserId());
    //private static String awsPrefix = WDISettings.AWS_Endpoint__c;

    Private static String aws_org_info_prefix = 'https://2xm5rfl2q0.execute-api.us-east-2.amazonaws.com';
    Private static String aws_api_prefix = 'https://api.392248762292.genesisapi.com';

    private static final String COPY_ENDPOINT = '/copy';
  	private static final String FILES_ENDPOINT = '/v1/files';
  	private static final String FILES_COMPLETE_ENDPOINT = FILES_ENDPOINT + '/complete';
  	private static final String MERGE_ENDPOINT = '/merge';
  	private static final String MERGE_COMPLETE_ENDPOINT = MERGE_ENDPOINT + '/complete';
  	private static final String ORG_INFO_ENDPOINT = '/orginfo';
  	private static final String PREVIEW_ENDPOINT = '/preview';
  	private static final String SETUP_ENDPOINT = '/setup';
    private static final String VERSIONS_ENDPOINT = '/versions';    


    //this can be used in the place of Oauth. the SessionId method does not work in Lightning components
    //so this needs to be retrieved from a VF page. This method will be called every time 
    //so that we don't have to worry about a stale Id
    public static String getSessionId(){
        system.debug ('in getSessionId');
        String sessionId = UserInfo.getSessionId();
        //String sessionId = Page.WDIApiSessionId.getContent().toString();
		return sessionId;        
    }

    
    public static void deleteFiles(String fileIds) {
system.debug('In WDIAWSService.deleteFiles');
system.debug('List of files to delete:' + fileIds);
    String sessionId = getSessionId();

    HttpResponse httpResponse = null;
    Http http = new Http();

    HttpRequest request = new HttpRequest();
    request.setHeader('Authorization', 'Bearer ' + sessionId);
    request.setHeader('Content-Type', 'application/json');
    request.setMethod('DELETE');
    request.setEndpoint(aws_api_prefix + FILES_ENDPOINT + '?Ids=' + fileIds);
    request.setTimeout(45000);
system.debug('Calling request:' + request);

    httpResponse  = http.send(request);

    system.debug('response:' + httpResponse);
    system.debug('statusCode:' + httpResponse.getStatusCode());
    system.debug('response body:' + httpResponse.getbody());

	

  }
    
  /* 
  public static String getFileURL(String recId){
    System.debug('SCH recordId '+recId);
    String sessionId;
    // this is required to allow test class to complete
    if(!Test.isRunningTest()){
        sessionId = getSessionId();
    } else sessionId = 'bogus123';
    //String sessionId = getSessionId();
    System.debug('SCH session Id '+sessionId);
    //String sessionId = Page.Litify_docs__ApiSessionId.getContent().toString();
    Http http = new Http();
    HttpRequest request = new HttpRequest();
   
    request.setHeader('Authorization', 'Bearer ' + sessionId); // Note that we have the word Bearer and a space here and THEN the token
    request.setHeader('Content-Type', 'application/json');
    //request.setBody(REQUEST_BODY); // The body of the request this type of request has no body
    request.setMethod('GET'); // The HttpMethod to use	
    request.setEndpoint(awsPrefix + FILES_ENDPOINT + '?Id=' + recId);
    System.debug('GetFileURL Endpoint '+request.getEndpoint());
    
     sendRequest(request);
  }
*/
}