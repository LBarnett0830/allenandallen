public with sharing class WDI_Queueable_Helper {
  public static String session { get; set; }
  public static String uploadURL { get; set; }
  public static String newFileRC { get; set; }
  public static String newFileID { get; set; }
  public static String wdFileName { get; set; }
  public static String endpoint { get; set; }
  public static string idToProcess { get; set; }
  public static string WDI_Id { get; set; }
  public static string WDI_Name { get; set; }
  public static string WDI_MatterID { get; set; }
  public static string WDI_Matter_Name { get; set; }
  public static string WDI_Owner_Initials { get; set; }
  public static string WDI_Owner_Name { get; set; }
  public static string fileType { get; set; }
  public static string fileName { get; set; }
  public static blob blobFile { get; set; }
  public static string doc_category { get; set; }
  public static string doc_Subcategory { get; set; }
  public static string doc_related_to_api_name { get; set; }
  public static Integer failedAttempts { get; set; }
  //public static string stepresponse { get; set; }

  //public static string url = 'https://wdweb.allenandallen.com';
  public static boolean booleanLogout = true;
  //private static String aws_api_prefix //= 'https://api.392248762292.genesisapi.com';

  public static final String FILES_ENDPOINT = '/v1/files';
  public static final string urlLOGOFF = '/cgi-bin/wdwebcgi.exe?LOGOFF';
  public static final string urlLOGON = '/cgi-bin/wdwebcgi.exe?LOGON';
  public static final string urlTESTPROFILE = '/cgi-bin/wdwebcgi.exe?TESTPROFILE';
  public static final string urlNEWFILE = '/cgi-bin/wdwebcgi.exe?NEWFILE';
  public static final string urlUPLOAD = '/cgi-bin/wdwebcgi.exe?UPLOAD';
  public static final string urlAED = '/cgi-bin/wdwebcgi.exe?AEDTABLE';

  public static void initvars() {
    uploadURL = '';
    newFileRC = '';
    newFileID = '';
    wdFileName = '';
    WDI_Id = '';
    WDI_Name = '';
    WDI_Matter_Name = '';
    WDI_MatterID = '';
    fileType = '';
    doc_Subcategory = '';
    doc_category = '';
    failedAttempts = 0;
  }

  public static WDI_Environment env {
    get {
      if (env == null) {
        WDI_Environment env = new WDI_Environment();
        List<WDI__mdt> envList = new List<WDI__mdt>();

        try {
          envList = [
            SELECT
              Integration_Enabled__c,
              Integration_AED_Update_Enabled__c,
              Delete_Enabled__c,
              Scheduled_Interval__c,
              WDI_Cabinet__c,
              Cabinet_Name__c,
              WDI_Password__c,
              WDI_Username__c,
              WDI_URL__c,
              GenesisURL__c,
              Integration_Throttle__c,
              Filesize_Check_enabled__c,
              Max_Filesize__c,
              Ignore_Template_Enabled__c,
              Filesize_Notification__c,
              Filesize_Popup__c,
              Limit_Files_to_Process__c

            FROM WDI__mdt
            WHERE DeveloperName = 'Default'
          ];
          if (envlist.size() == 1) {
            env.Integration_Enabled = envlist[0].Integration_Enabled__c;
            env.AED_Integration_Enabled = envList[0].Integration_AED_Update_Enabled__c;
            env.Delete_Enabled = envList[0].Delete_Enabled__c;
            env.Scheduled_Interval = (integer) envlist[0].Scheduled_Interval__c;
            env.WDI_Cabinet = envlist[0].WDI_Cabinet__c;
            env.Cabinet_Name = envlist[0].Cabinet_Name__c;
            env.WDI_Password = envlist[0].WDI_Password__c;
            env.WDI_Username = envlist[0].WDI_Username__c;
            env.WDI_URL = envlist[0].WDI_URL__c;
            env.GENESIS_URL = envlist[0].GenesisURL__c;
            env.Integration_Throttle = envlist[0].Integration_Throttle__c;
            env.fileSizeCheckEnabled = envlist[0].Filesize_Check_enabled__c;
            env.maxFileSize = envlist[0].Max_Filesize__c;
            env.IgnoreTemplateEnabled = envlist[0].Ignore_Template_Enabled__c;
            env.FilesizePopup = envlist[0].Filesize_Popup__c;
            env.FilesizeNotification = envlist[0].Filesize_Notification__c;
            env.LimitFilesToProcess = envlist[0].Limit_Files_to_Process__c;
            return env;
          } else {
            //do nothing, env will be null.
          }
        } catch (exception e) {
          system.debug('Error in set Environment:' + e.getmessage());
        }
      }
      return env;
    }
    set;
  }

  public static string getURLfromDocrio(String recId) {
    string newURL = null;
    try {
      Http http = new Http();
      HttpRequest request = new HttpRequest();
      String SalesforceSessionId = UserInfo.getSessionId();
      request.setHeader('Authorization', 'Bearer ' + SalesforceSessionId); // Note that we have the word Bearer and a space here and THEN the token
      request.setHeader('Content-Type', 'application/json');
      request.setMethod('GET'); // The HttpMethod to use
      request.setEndpoint(env.GENESIS_URL + FILES_ENDPOINT + '?Id=' + recId);
      request.setTimeout(120000); //2 minute

      HttpResponse response = http.send(request);
      system.debug('Request:' + request.toString());
      System.debug('Response Body: ' + response.getBody());

      newURL = WDI_Queueable_Helper.findToken('signedURL', response.getBody());
      if (String.isBlank(newURL) ) {
        newURL = 'Error:  URL not found in Docrio for ID ' + recId;
      }
    } catch (Exception e) {
      newURL = 'Error: ' + e.getmessage();
    }
    return newURL;
  }

  public static string getBLOBfromDocrio(string docrioURL) {
    string responseString = 'Success';
    try {
      //getblob from URL from Docrio
      system.debug('**********');
      system.debug('**********');
      system.debug('Calling getBlob');
      system.debug('**********');
      system.debug('**********');
      blobFile = null;
      Http http = new Http();
      HttpRequest request = new HttpRequest();
      request.setEndpoint(docrioURL);
      request.setMethod('GET');
      request.setHeader('Content-Type', 'application/pdf');
      request.setCompressed(true);
      request.setTimeout(120000);

      HttpResponse response = http.send(request);
      system.debug('Request:' + request.toString());
      system.debug('Response Status:' + response.getStatus());
      blobFile = response.getBodyAsBlob();
      system.debug('Size of blob:' + blobFile.size());
      if (blobFile.size() == 0 ) {
        responseString='Error in retrieving file from Docrio';
        
      }
    } catch (exception e) {
      system.debug('Error in retrieving file from Docrio:' + e.getMessage());
      responseString = 'Error in retrieving file from Docrio:' + e.getMessage();
    }
    return responseString;
  }

  /****************
          *****************
          Step 1 - Logon Worldox
          *****************

          To call from Developer Console - Execute Anonymous window:
          WDI_Queueable_Helper.LOGINprocess();

          *****************/
  public static string LOGINprocess() {
    String stepresponse = 'Success';
    try {
      HttpRequest req = new HttpRequest();
      endpoint = env.WDI_URL + urlLOGON;
      req.setEndpoint(endpoint);
      req.setMethod('POST');
            
      req.setHeader('Accept-Encoding', 'gzip, deflate, br');
      req.setTimeout(120000);
      Http http = new Http();
      restbodyLOGIN loginBody = new restbodyLOGIN();
      loginBody.wd_Server_Name_Value = '*';
      loginBody.wd_Server_Password_Value = '*';
      loginBody.HTMLONOK = '/v4/authentication/login.json';
      loginBody.HTMLONFAIL = '/v4/authentication/login.json';

      loginBody.wd_User_Code_Value = env.WDI_Username;
      loginBody.wd_User_Password_Value = env.WDI_Password;

      String payload = 'HTMLONOK=' + EncodingUtil.urlEncode(loginBody.HTMLONOK,'UTF-8');
      payload += '&HTMLONFAIL=' + EncodingUtil.urlEncode(loginBody.HTMLONFAIL,'UTF-8');
      payload += '&wd_User_Code_Value=' + EncodingUtil.urlEncode(loginBody.wd_User_Code_Value,'UTF-8');
      payload += '&wd_User_Password_Value=' + EncodingUtil.urlEncode(loginBody.wd_User_Password_Value,'UTF-8');
      system.debug('Payload:' + payload);
      req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
      req.setBody(payload);

      //req.setHeader('Content-Type', 'application/json;charset=UTF-8');
      //req.setBody(JSON.serialize(loginBody));
      HttpResponse response = http.send(req);
      String html = response.getBody();

      system.debug('Header Body:' + req.getBody() );
      system.debug('Response Body:' + html );

      session = findToken('session', html);
      uploadURL = findtoken('uploadFolderJSON', html);

      if (string.isblank(session) || string.isblank(uploadURL)) {
        stepResponse = 'Error. Response Body:' + response.getBody();
      } else {
        //pause for 5 seconds and allow the IIS server to create the folder structure
        Long startTime = DateTime.now().getTime();
        Long finalTime = DateTime.now().getTime();
        Long millisecondsToWiat = 5000; // 5 seconds
        while (finalTime - StartTime < millisecondsToWiat) {
          finalTime = DateTime.now().getTime();
        }
      }
    } catch (exception e) {
      system.debug('Error in LOGON callout: ' + e.getMessage());
      stepresponse = 'Error in LOGON Callout:' + e.getMessage();
    }
    return stepresponse;
  }

  /*****************
                  Step TESTPROFILE
                  *****************
                  *****************/
  public static string TESTPROFILEprocess() {
    String stepresponse = 'Success';
    if (string.isblank(WDI_Owner_Initials) ) {
      stepresponse = 'User Initials are not configured';
      return stepresponse;
    }

    try {
      system.debug('**********');
      system.debug('Calling TESTPROFILE');
      HttpRequest req = new HttpRequest();

      req.setMethod('GET');
      req.setHeader('Content-Type', 'application/json;charset=UTF-8');
      req.setHeader('Accept-Encoding', 'gzip, deflate, br');
      req.setTimeout(120000);
      Http http = new Http();
      restbodyTESTPROFILE TESTPROFILEbody = new restbodyTESTPROFILE();

      TESTPROFILEbody.HtmlOnOK = '/v4/testprofile/test-profile.json';
      TESTPROFILEbody.HtmlOnFail = '/v4/testprofile/test-profile.json';
      TESTPROFILEbody.wd_SID = session;
      TESTPROFILEbody.Wd_File_Field1_Value = WDI_Owner_Initials;
      TESTPROFILEbody.Wd_File_Field2_Value = ''; //'999999-100';
      TESTPROFILEbody.Wd_File_Field3_Value = doc_category;
      TESTPROFILEbody.Wd_File_Field4_Value = WDI_Owner_Initials;
      TESTPROFILEbody.Wd_File_Field5_Value = WDI_Id;
      TESTPROFILEbody.Wd_File_Field6_Value = WDI_MatterId;
      TESTPROFILEbody.Wd_File_ProfileGroup_Value = env.WDI_Cabinet;

      endpoint = env.WDI_URL + urlTESTPROFILE + buildHeaderTESTPROFILE(TESTPROFILEbody);
      debugshowlongline('endpoint', endpoint);
      req.setEndpoint(endpoint);
      //reqtp.setBody(JSON.serialize(TestprofileBody));
      req.setHeader('Content-Length', '0');
      HttpResponse response = http.send(req);
      String html = response.getBody();
      System.debug('Request: ' + req.toString());
      System.debug('Request body:' + req.getBody());
      System.debug('Response Status:' + response.getStatus());
      System.debug('Response Body: ' + response.getBody());

      //Need to determine if error is because of fields 5 and 6 - run AEDTable Update
      String temp = findToken('errorCount', html);
      if (string.ISnotBLANK(temp)) {
        if (integer.valueof(temp) >= 1) {
          stepresponse = 'AED Error: ' + response.getBody();
        }
      }
    } catch (exception e) {
      system.debug('Error in TESTPROFILE callout: ' + e.getMessage());
      stepresponse = 'error in TESTPROFILE callout:' + e.getMessage();
    }
    return stepresponse;
  }

  /*****************
                  Step NEWFILE
                  *****************
                  *****************/
  public static string NEWFILEprocess() {
    String stepresponse = 'Success';
    try {
      system.debug('**********');
      system.debug('**********');
      system.debug('Calling NEWFILE');
      HttpRequest req = new HttpRequest();

      system.debug('newfile Process');
      system.debug('filename before:' + filename);
      filename = wdiFormatString(filename.deleteWhitespace() );
      system.debug('filename after:' + filename);
      req.setMethod('GET');
      req.setTimeout(120000);
      //reqNF.setHeader('Content-Type','application/json;charset=UTF-8');
      req.setHeader('Accept-Encoding', 'gzip, deflate, br');
      Http http = new Http();
      restbodyNEWFILE rbNEWFILE = new restbodyNEWFILE();

      rbNEWFILE.HtmlOnOK = '/v4/fileActions/Newfile.json';
      rbNEWFILE.HtmlOnFail = '/v4/fileActions/Newfile.json';
      rbNEWFILE.wd_SID = session;
      rbNEWFILE.Wd_File_Field1_Value = WDI_Owner_Initials;
      rbNEWFILE.Wd_File_Field2_Value = '';  //'999999-100';
      rbNEWFILE.Wd_File_Field3_Value = doc_category;
      rbNEWFILE.Wd_File_Field4_Value = WDI_Owner_Initials;
      rbNEWFILE.Wd_File_Field5_Value = WDI_Id;
      rbNEWFILE.Wd_File_Field6_Value = WDI_MatterId;
      rbNEWFILE.Wd_File_ProfileGroup_Value = env.WDI_Cabinet;
      rbNEWFILE.Wd_File_Xname_Value = fileName; //file description (no spaces allowed 
      rbNEWFILE.Wd_File_StatusFlags_Value = '0'; // Security Flag ID
      rbNEWFILE.wd_File_Filename_Value = fileName; //uploaded filename

      endpoint = env.WDI_URL + urlNEWFILE + buildHeaderNEWFILE(rbNEWFILE);
      req.setEndpoint(endpoint);

      debugshowlongline('endpoint', endpoint);

      HttpResponse response = http.send(req);
      String html = response.getBody();
      System.debug('Request: ' + req.toString());
      System.debug('Request body:' + req.getBody());
      System.debug('Response Status:' + response.getStatus());
      System.debug('Response Body: ' + response.getBody());

      newFileRC = findToken('FileRN', html);
      newFileID = findToken('FileLID', html);
      if (String.isblank(newFileRC) || String.isblank(newFileID)) {
        stepresponse = 'Error in NEWFILE' + response.getBody();
      }
    } catch (exception e) {
      system.debug('Error in NEWFILE callout: ' + e.getMessage());
      stepresponse = 'error in NEWFILE callout: ' + e.getMessage();
    }
    return stepresponse;
  }

  /*****************
                  Step AEDTABLE
                  *****************
                  *****************/
  public static string AEDTABLEprocess(
    Integer fieldnum,
    string fieldValue,
    string fieldDescription
  ) {
    String stepresponse = 'Success';
    try {
      system.debug('**********');
      system.debug('**********');
      system.debug('Calling AEDTABLEprocess');
      HttpRequest req = new HttpRequest();

      req.setMethod('GET');
      req.setTimeout(120000);
      //req.setHeader('Content-Type','application/json;charset=UTF-8');
      req.setHeader('Accept-Encoding', 'gzip, deflate, br');
      Http http = new Http();
      restbodyAEDTABLE rb = new restbodyAEDTABLE();

      rb.HtmlOnOK = '/v4/fileActions/fileStatus.json';
      rb.HtmlOnFail = '/v4/fileActions/fileStatus.json';
      rb.wd_SID = session;
      rb.Wd_File_ProfileGroup_Value = env.WDI_Cabinet;
      rb.wd_FIELD_NUMBER_VALUE = string.valueof(fieldnum);

      if (fieldnum == 1) {
        rb.wd_FILE_FIELD1_VALUE = fieldValue;
        rb.wd_FILE_FIELD1DESC_VALUE = fieldDescription;
      } else if (fieldnum == 4) {
        rb.wd_FILE_FIELD4_VALUE = fieldValue;
        rb.wd_FILE_FIELD4DESC_VALUE = fieldDescription;
      } else if (fieldnum == 5) {
        rb.wd_FILE_FIELD5_VALUE = fieldValue;
        rb.wd_FILE_FIELD5DESC_VALUE = fieldDescription;
      } else if (fieldnum == 6) {
        rb.wd_FILE_FIELD6_VALUE = fieldValue;
        rb.wd_FILE_FIELD6DESC_VALUE = fieldDescription;
      } else {
        stepresponse = 'failure, invalid field number ' + fieldnum;
        return stepresponse;
      }

      endpoint = env.WDI_URL + urlAED + buildHeaderAEDTABLE(rb);
      req.setEndpoint(endpoint);

      debugshowlongline('endpoint', endpoint);

      HttpResponse response = http.send(req);
      String html = response.getBody();
      System.debug('Request: ' + req.toString());
      System.debug('Request body:' + req.getBody());
      System.debug('Response Status:' + response.getStatus());
      System.debug('Response Body: ' + response.getBody());

      //newFileRC = findToken('FileRN', html);
      //newFileID = findToken('FileLID', html);
    } catch (exception e) {
      system.debug('Error in AEDTABLE callout: ' + e.getMessage());
      stepresponse = 'error AEDTABLE callout: ' + e.getMessage();
    }
    return stepresponse;
  }

  /*****************
                  Step AEDTABLE
                  *****************
                  *****************/
                  public static string AEDTABLEprocessField6(
                    Integer fieldnum,
                    string field6Value,
                    string field6Description,
                    String field5Value,
                    String field5Description
                  ) {
                    String stepresponse = 'Success';
                    try {
                      system.debug('**********');
                      system.debug('**********');
                      system.debug('Calling AEDTABLEprocess');
                      HttpRequest req = new HttpRequest();
                
                      req.setMethod('GET');
                      req.setTimeout(120000);
                      //req.setHeader('Content-Type','application/json;charset=UTF-8');
                      req.setHeader('Accept-Encoding', 'gzip, deflate, br');
                      Http http = new Http();
                      restbodyAEDTABLE rb = new restbodyAEDTABLE();
                
                      rb.HtmlOnOK = '/v4/fileActions/fileStatus.json';
                      rb.HtmlOnFail = '/v4/fileActions/fileStatus.json';
                      rb.wd_SID = session;
                      rb.Wd_File_ProfileGroup_Value = env.WDI_Cabinet;
                      rb.wd_FIELD_NUMBER_VALUE = string.valueof(fieldnum);
                
                      if (fieldnum == 6) {
                        rb.wd_FILE_FIELD6_VALUE = field6Value;
                        rb.wd_FILE_FIELD6DESC_VALUE = field6Description;
                        rb.wd_FILE_FIELD5_VALUE = field5Value;
                        rb.wd_FILE_FIELD5DESC_VALUE = field5Description;
                      } else {
                        stepresponse = 'failure, invalid field number ' + fieldnum;
                        return stepresponse;
                      }
                
                      endpoint = env.WDI_URL + urlAED + buildHeaderAEDTABLE(rb);
                      req.setEndpoint(endpoint);
                
                      debugshowlongline('endpoint', endpoint);
                
                      HttpResponse response = http.send(req);
                      String html = response.getBody();
                      System.debug('Request: ' + req.toString());
                      System.debug('Request body:' + req.getBody());
                      System.debug('Response Status:' + response.getStatus());
                      System.debug('Response Body: ' + response.getBody());
                
                      //newFileRC = findToken('FileRN', html);
                      //newFileID = findToken('FileLID', html);
                    } catch (exception e) {
                      system.debug('Error in AEDTABLE callout: ' + e.getMessage());
                      stepresponse = 'Error in AEDTABLE callout: ' + e.getMessage();
                    }
                    return stepresponse;
                  }

  /*****************
                  Step UPLOAD (IIS)
                  *****************
                  *****************/
  public static string UPLOADIISprocess() {
    String stepresponse = 'Success';
    try {
      system.debug('******************************');
      system.debug('******************************');
      system.debug('Calling UPLOAD (IIS)');
      system.debug('******************************');
      system.debug('******************************');

      HttpRequest req = new HttpRequest();
      req.setMethod('POST');
      req.setTimeout(120000);
      Http http = new Http();
      endpoint = env.WDI_URL + uploadURL;
      debugshowlongline('endpoint', endpoint);
      req.setEndpoint(endpoint);

      //string contentType = WDI_formdata.GetContentType();
      //string contentType = fileType;
      String contentType =
        'multipart/form-data; boundary=' + WDI_formdata.Boundary;
      string form64 = '';
      //Blob attachBody = blob.valueof(fileContent);
      //String filename = 'text.txt';
      //adding documents metadata or properties

      //form64 += WDI_formdata.append('key','Value');
      //form64 += WDI_formdata.append('key','value');
      system.debug('Blob:' + blobFile);
      system.debug('filename:' + filename);
      blob formBlob = WDI_FormData.makeBlobWithFile(
        'file',
        blobFile,
        fileName,
        form64
      );
      string contentLength = string.valueOf(formBlob.size());
      req.setBodyAsBlob(formBlob);
      req.setHeader('Content-Type', contentType);
      req.setHeader('Content-Length', contentLength);
      req.setHeader('Accept', '*/*');
      req.setHeader('Accept-Encoding', 'gzip, deflate, br');
      req.setHeader('Connection', 'keep-alive');

      system.debug('Header - Content-Type:' + contentType);
      system.debug('Header - Content-Length:' + contentLength);
      system.debug('Header - Accept:' + '*/*');
      system.debug('Header - Connection:' + 'keep-alive');

      HttpResponse response = http.send(req);
      //String html = response.getBody();
      System.debug('Request: ' + req.toString());

      if (fileType == 'text/plain') {
        System.debug('Request body:' + req.getBody());
      }
      String html = response.getBody();
      System.debug('Response Status:' + response.getStatus());
      system.debug('Response headers --------------------');
      string[] headerkeys = response.getHeaderKeys();
      Map<string, string> headers = new Map<string, string>();
      for (string s : headerkeys) {
        headers.put(s, response.getHeader(s));
        system.debug('header: ' + s + '  value: ' + response.getHeader(s));
      }
      debugshowlongline(
        'Response Body for UPLOAD IIS------------------:',
        response.getBody()
      );
      //Need to determine if error 
      String temp = findToken('message', html);
      if (temp == 'Your file uploaded successfully') {
        //do nothing, all is well
      } else {
        stepresponse = 'Error in UPLOAD (IIS)' + response.getBody();
      }
    } catch (exception e) {
      system.debug('Error in UPLOAD (IIS) callout: ' + e.getMessage());
      stepresponse = 'Error in UPLOAD (IIS) callout: ' + e.getMessage();
    }
    return stepresponse;
  }

  /*****************
                  Step UPLOAD (WD)
                  *****************
                  *****************/
  public static string UPLOADWDprocess() {
    String stepresponse = 'Success';
    try {
      system.debug('******************************');
      system.debug('******************************');
      system.debug('Calling UPLOAD (WD)');
      system.debug('******************************');
      system.debug('******************************');
      HttpRequest req = new HttpRequest();

      req.setMethod('GET');
      req.setTimeout(120000);
      req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
      req.setHeader('Accept-Encoding', 'gzip, deflate, br');
      Http http = new Http();
      restbodyUPLOAD rbUPLOAD = new restbodyUPLOAD();
      rbUPLOAD.HtmlOnOK = '/v4/fileActions/uploadVerb.json';
      rbUPLOAD.HtmlOnFail = '/v4/fileActions/uploadVerb.json';
      rbUPLOAD.wd_SID = session;
      rbUPLOAD.Wd_File_Xname_Value = fileName; //file description (no spaces allowed - build funciton to strip blanks)
      rbUPLOAD.Wd_File_StatusFlags_Value = '0'; // Security Flag ID
      rbUPLOAD.wd_File_Filename_Value = fileName; //uploaded filename
      rbUPLOAD.Wd_List_RecNum = newFileRC;
      rbUPLOAD.wd_List_ID = newFileID;
      rbUPLOAD.Wd_File_ProfileGroup_Value = env.WDI_Cabinet;
      rbUPLOAD.Wd_File_Path_Filter = '';
      endpoint = env.WDI_URL + urlUPLOAD + buildHeaderUPLOAD(rbUPLOAD);
      req.setEndpoint(endpoint);

      debugshowlongline('endpoint', endpoint);

      HttpResponse response = http.send(req);
      String html = response.getBody();
      System.debug('Request: ' + req.toString());
      System.debug('Request body:' + req.getBody());
      System.debug('Response Status:' + response.getStatus());
      debugshowlongline('Response Body for UPLOAD WD:', response.getBody());
      
            //Need to determine if error 
            String temp = findToken('errorCount', html);
            if (string.ISnotBLANK(temp)) {
              if (integer.valueof(temp) >= 1) {
                stepresponse = 'Error in UPLOAD(WD)' + response.getBody();
              }
            }
    } catch (exception e) {
      system.debug('Error in UPLOAD (WD) callout: ' + e.getMessage());
      stepresponse = 'Error in UPLOAD(WD) callout:' + e.getMessage();
    }
    return stepresponse;
  }

  /*****************
                  LAST STEP - call logout
                  *****************
                  *****************/
  public static string LOGOUTprocess() {
    String stepresponse = 'Success';
    if (String.isblank(session)) {
      //if session is blank, login process was not successfull earlier, so do not try to logoff
      return stepresponse;
    }

    try {
      if (booleanLogout) {
        system.debug('******************************');
        system.debug('******************************');
        system.debug('Calling REST LOGOFF');
        system.debug('******************************');
        system.debug('******************************');
        HttpRequest req2 = new HttpRequest();
        String endpoint = 'https://wdweb.allenandallen.com/cgi-bin/wdwebcgi.exe?LOGOFF';
        //req2.setEndpoint('https://wdweb.allenandallen.com/cgi-bin/wdwebcgi.exe?LOGOFF');
        req2.setMethod('POST');
        req2.setTimeout(120000);
        req2.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req2.setHeader('Accept-Encoding', 'gzip, deflate, br');
        Http http = new Http();
        restbodyLOGOUT logoutBody = new restbodyLOGOUT();
        logoutBody.HTMLOnFail = 'v4/authentication/logoffFail.json';
        logoutBody.HTMLOnOK = '';
        logoutBody.wd_SID = session;
        endpoint += buildHeaderLOGOFF(logoutBody);
        req2.setEndpoint(endpoint);
        //req2.setBody(JSON.serialize(logoutBody));
        req2.setHeader('Content-Length', '0');
        HttpResponse response2 = http.send(req2);

        System.debug('Request: ' + req2.toString());
        System.debug('Request body:' + req2.getBody());
        System.debug('Response Status:' + response2.getStatus());
        system.debug('Response Body:' + response2.getbody());
      }
    } catch (exception e) {
      system.debug('Error in LOGOFF callout: ' + e.getMessage());
      stepresponse = 'Error in LOGOFF callout: ' + e.getMessage();
    }
    return stepresponse;
  }

  Public Static void processPlatformEvent(WdiPlatformEventClass rec) {
     List<WDI_Message_Event__e> listOfEvents = new List<WDI_Message_Event__e>();
     WDI_Message_Event__e me = new WDI_Message_Event__e();
     me.UserID__c = rec.UserId;
     me.IntakeId__c = rec.IntakeId;
     me.MatterId__c = rec.MatterId;
     me.Message__c = rec.errorMessage;
     ListOfEvents.add(me);

     List<Database.SaveResult> results = EventBus.publish(listOfEvents);
  }

  //CallSecondProcessToUpdateToDeleteFlag job = new QueueableExampleOne();

  public class restbodyLOGIN {
    public string wd_Server_Name_Value;
    public string wd_Server_Password_Value;
    public string HTMLONOK;
    public string HTMLONFAIL;
    public string wd_User_Code_Value;
    public string wd_User_Password_Value;
  }

  public class restbodyLOGOUT {
    public string wd_SID;
    public string HTMLOnOK;
    public string HTMLOnFail;
  }

  public class restbodyTESTPROFILE {
    public string wd_SID;
    public string HtmlOnOK;
    public string HtmlOnFail;
    public string Wd_File_Field1_Value;
    public string Wd_File_Field2_Value;
    public string Wd_File_Field3_Value;
    public string Wd_File_Field4_Value;
    public string Wd_File_Field5_Value;
    public string Wd_File_Field6_Value;
    public string Wd_File_Field7_Value;
    public string Wd_File_ProfileGroup_Value;
    public string wd_File_Path_Filter;
  }

  public class restbodyNEWFILE {
    public string wd_SID;
    public string HtmlOnOK;
    public string HtmlOnFail;
    public string Wd_File_Field1_Value;
    public string Wd_File_Field2_Value;
    public string Wd_File_Field3_Value;
    public string Wd_File_Field4_Value;
    public string Wd_File_Field5_Value;
    public string Wd_File_Field6_Value;
    public string Wd_File_Field7_Value;
    public string Wd_File_ProfileGroup_Value;
    public string Wd_File_Path_Filter;
    public string Wd_File_Xname_Value; //file description
    public string Wd_File_StatusFlags_Value; // Security Flag ID
    public string wd_File_Filename_Value; //uploaded filename
  }

  public class restbodyUPLOAD {
    public string wd_SID;
    public string HtmlOnOK;
    public string HtmlOnFail;
    public string Wd_List_RecNum;
    public string wd_List_ID;
    public string Wd_File_ProfileGroup_Value;
    public string Wd_File_Path_Filter;
    public string Wd_File_Xname_Value; //file description
    public string Wd_File_StatusFlags_Value; // Security Flag ID
    public string wd_File_Filename_Value; //uploaded filename
  }

  public class restbodyAEDTABLE {
    public string wd_SID;
    public string HtmlOnOK;
    public string HtmlOnFail;
    public string wd_FILE_PROFILEGROUP_VALUE;
    public string wd_FIELD_NUMBER_VALUE;
    public string wd_FILE_FIELD1_VALUE;
    public string wd_FILE_FIELD2_VALUE;
    public string wd_FILE_FIELD3_VALUE;
    public string wd_FILE_FIELD4_VALUE;
    public string wd_FILE_FIELD5_VALUE;
    public string wd_FILE_FIELD6_VALUE;
    public string wd_FILE_FIELD7_VALUE;
    public string wd_FILE_FIELD1DESC_VALUE;
    public string wd_FILE_FIELD2DESC_VALUE;
    public string wd_FILE_FIELD3DESC_VALUE;
    public string wd_FILE_FIELD4DESC_VALUE;
    public string wd_FILE_FIELD5DESC_VALUE;
    public string wd_FILE_FIELD6DESC_VALUE;
    public string wd_FILE_FIELD7DESC_VALUE;
  }

  public class documentMetadata {
    public string newFileRC;
    public string newFileID;
    public string wdFileName;
    public string endpoint;
    public string idToProcess;
    public string fileType;
    public string fileName;
    public blob blobFile;
    public string doc_category;
    public string doc_Subcategory;
    public string doc_related_to_api_name;
    public Integer failedAttempts;
    public string authorInitials; //field 1 and field 4
    public string authorFullName;
  }

  public class WDI_environment {
    public boolean Integration_Enabled;
    public boolean AED_Integration_Enabled;
    public boolean Delete_Enabled;
    public Integer Scheduled_Interval;
    public string WDI_Cabinet;
    public string WDI_Password;
    public string WDI_Username;
    public string WDI_URL;
    public string GENESIS_URL;
    public Decimal Integration_Throttle;
    public String Cabinet_Name;
    public boolean fileSizeCheckEnabled;
    public Decimal maxFileSize;
    public boolean IgnoreTemplateEnabled;
    public Boolean FilesizeNotification;
    public Boolean FilesizePopup;
    public Boolean LimitFilesToProcess;
  }

  public static string buildHeaderLOGOFF(restbodyLOGOUT rec) {
    String res = '';
    res = '&wd_SID=' + rec.wd_SID;
    res += '&HTMLOnOK=' + rec.HTMLOnOK;
    res += '&HtmlOnFail=' + rec.HTMLOnOK;
    return res;
  }

  public static string buildHeaderTESTPROFILE(restbodyTESTPROFILE rec) {
    string res = '';
    res = '&wd_SID=' + rec.wd_SID;
    res += '&HtmlOnOK=' + rec.HtmlOnOK;
    res += '&HtmlOnFail=' + rec.HtmlOnFail;
    res += '&Wd_File_Field1_Value=' + rec.Wd_File_Field1_Value;
    res += '&Wd_File_Field2_Value=' + rec.Wd_File_Field2_Value;
    res += '&Wd_File_Field3_Value=' + rec.Wd_File_Field3_Value;
    res += '&Wd_File_Field4_Value=' + rec.Wd_File_Field4_Value;
    res += '&Wd_File_Field5_Value=' + rec.Wd_File_Field5_Value;
    if (String.isNotBlank(rec.wd_FILE_FIELD6_VALUE)) {
      res += '&wd_FILE_FIELD6_VALUE=' + wdiFormatString(rec.wd_FILE_FIELD6_VALUE); //== null? '':rec.wd_FILE_FIELD6_VALUE;
    }
    res += '&Wd_File_Field7_Value=';
    //res += '&Wd_File_Field7_Value=' + rec.Wd_File_Field7_Value == null? '':rec.Wd_File_Field7_Value ;
    res += '&Wd_File_ProfileGroup_Value=' + rec.Wd_File_ProfileGroup_Value;
    res += '&wd_File_Path_Filter=';

    return res;
  }

  public static string buildHeaderUPLOAD(restbodyUPLOAD rec) {
    string res = '';
    res = '&wd_SID=' + rec.wd_SID;
    res += '&HtmlOnOK=' + rec.HtmlOnOK;
    res += '&HtmlOnFail=' + rec.HtmlOnFail;
    res += '&Wd_File_ProfileGroup_Value=' + rec.Wd_File_ProfileGroup_Value;
    res += '&wd_File_Path_Filter=' + rec.Wd_file_Path_filter;
    res += '&Wd_File_Xname_Value=' + rec.Wd_File_Xname_Value;
    res += '&Wd_File_StatusFlags_Value=' + rec.Wd_File_StatusFlags_Value;
    res += '&wd_File_Filename_Value=' + rec.wd_File_Filename_Value;
    res += '&Wd_List_RecNum=' + rec.Wd_List_RecNum;
    res += '&wd_List_ID=' + rec.wd_List_ID;
    return res;
  }

  public static string buildHeaderNEWFILE(restbodyNEWFILE rec) {
    string res = '';
    res = '&wd_SID=' + rec.wd_SID;
    res += '&HtmlOnOK=' + rec.HtmlOnOK;
    res += '&HtmlOnFail=' + rec.HtmlOnFail;
    res += '&Wd_File_Field1_Value=' + rec.Wd_File_Field1_Value;
    res += '&Wd_File_Field2_Value=' + rec.Wd_File_Field2_Value;
    res += '&Wd_File_Field3_Value=' + rec.Wd_File_Field3_Value;
    res += '&Wd_File_Field4_Value=' + rec.Wd_File_Field4_Value;
    res += '&Wd_File_Field5_Value=' + rec.Wd_File_Field5_Value;
    if (String.isNotBlank(rec.wd_FILE_FIELD6_VALUE)) {
      res += '&wd_FILE_FIELD6_VALUE=' + wdiFormatString(rec.wd_FILE_FIELD6_VALUE); //== null? '':rec.wd_FILE_FIELD6_VALUE;
    }
    //res += '&Wd_File_Field7_Value=' + rec.Wd_File_Field7_Value == null? '':rec.Wd_File_Field7_Value ;
    //res += '&Wd_File_Field7_Value=' + rec.Wd_File_Field7_Value == null? '':rec.Wd_File_Field7_Value ;
    res += '&Wd_File_Field7_Value=';
    res += '&Wd_File_ProfileGroup_Value=' + rec.Wd_File_ProfileGroup_Value;
    res += '&Wd_File_Xname_Value=' + rec.Wd_File_Xname_Value;
    res += '&Wd_File_StatusFlags_Value=' + rec.Wd_File_StatusFlags_Value;
    res += '&wd_FILE_FILENAME_VALUE=' + rec.wd_File_Filename_Value;

    return res;
  }

  public static string buildHeaderAEDTABLE(restbodyAEDTABLE rec) {
    String res = '';
    res = '&wd_SID=' + rec.wd_SID;
    res += '&HTMLOnOK=' + rec.HTMLOnOK;
    res += '&HtmlOnFail=' + rec.HtmlOnFail;
    res += '&wd_FILE_PROFILEGROUP_VALUE=' + rec.wd_FILE_PROFILEGROUP_VALUE;
    res += '&wd_FIELD_NUMBER_VALUE=' + rec.wd_FIELD_NUMBER_VALUE;
    res += '&wd_FILE_FIELD1_VALUE=' + wdiFormatString(rec.wd_FILE_FIELD1_VALUE); // == null? '':rec.wd_FILE_FIELD1_VALUE;
    res += '&wd_FILE_FIELD2_VALUE=' + wdiFormatString(rec.wd_FILE_FIELD2_VALUE); //== null? '':rec.wd_FILE_FIELD2_VALUE;
    res += '&wd_FILE_FIELD3_VALUE=' + wdiFormatString(rec.wd_FILE_FIELD3_VALUE); // == null? '':rec.wd_FILE_FIELD3_VALUE;
    res += '&wd_FILE_FIELD4_VALUE=' + wdiFormatString(rec.wd_FILE_FIELD4_VALUE); // == null? '':rec.wd_FILE_FIELD4_VALUE;
    res += '&wd_FILE_FIELD5_VALUE=' + wdiFormatString(rec.wd_FILE_FIELD5_VALUE); // == null? '':rec.wd_FILE_FIELD5_VALUE;
    if (String.isNotBlank(rec.wd_FILE_FIELD6_VALUE)) {
      res += '&wd_FILE_FIELD6_VALUE=' + wdiFormatString(rec.wd_FILE_FIELD6_VALUE); //== null? '':rec.wd_FILE_FIELD6_VALUE;
    }
    
    res += '&wd_FILE_FIELD7_VALUE=' + wdiFormatString(rec.wd_FILE_FIELD7_VALUE); // == null? '':rec.wd_FILE_FIELD7_VALUE;
    res +=
      '&wd_FILE_FIELD1DESC_VALUE=' +
      wdiFormatString(rec.wd_FILE_FIELD1DESC_VALUE);
    res +=
      '&wd_FILE_FIELD2DESC_VALUE=' +
      wdiFormatString(rec.wd_FILE_FIELD2DESC_VALUE);
    res +=
      '&wd_FILE_FIELD3DESC_VALUE=' +
      wdiFormatString(rec.wd_FILE_FIELD3DESC_VALUE);
    res +=
      '&wd_FILE_FIELD4DESC_VALUE=' +
      wdiFormatString(rec.wd_FILE_FIELD4DESC_VALUE);
    res +=
      '&wd_FILE_FIELD5DESC_VALUE=' +
      wdiFormatString(rec.wd_FILE_FIELD5DESC_VALUE);
    res +=
      '&wd_FILE_FIELD6DESC_VALUE=' +
      wdiFormatString(rec.wd_FILE_FIELD6DESC_VALUE);
    res +=
      '&wd_FILE_FIELD7DESC_VALUE=' +
      wdiFormatString(rec.wd_FILE_FIELD7DESC_VALUE);
    return res;
  }

  public static String findToken(String searchToken, String jsonString) {
    boolean more = true;
    system.debug('In findToken, looking for:' + searchToken);
    //system.debug('In the JSON:' + jsonString);
    string found = '';
    try {
      JSONParser parser = JSON.createParser(jsonString);
      while (parser.nextToken() != null && more) {
        if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
          String fieldName = parser.getText();
          //system.debug('FieldName:' + fieldName);
          //system.debug('fieldName:' + fieldName);
          if (fieldName == searchToken) {
            parser.nextToken();
            found = parser.getText();
            system.debug('Found:' + found);
            more = false;
          }
        }
      }
    } catch (Exception e) {
      System.debug('Error in Find Token:' + e.getmessage());
      found = e.getmessage();
    }
    return found;
  }

  Public class WdiPlatformEventClass {
    public String UserId;
    public String IntakeId;
    public String MatterId;
    public String errorMessage;
  }

  public static String lookupCategory(String s) {
    String response = '';
    if (String.isblank(s)) {
      response = 'OTHER';
    } else {
      String s1 = s.substringBefore('/');
      If (s1 == s) {
        response = 'OTHER';
      } else {
        response = s1;
      }
    }
    return response;
  }

  public static String wdiFormatString(String s1) {
    string result = '';
    if (!String.isBlank(s1)) {
      result = s1.replace(':','-');
      result = result.replace('/','-');
      result = result.replace(';','-');
      result = result.replace('&',' ');
      result = result.replace('+','-');
      result = result.replace('#','-');
      result = result.replace('\'','-');
      result = result.replace('\"','-');
      result = result.replace('\\','-');
      //result = result.replace('%','-');
      result = result.replace('!','-');

    }

    return result;
  }

  public static String wdiFixFilename(String s1) {
    string result = s1;
    Integer i=0;
    Integer j=0;  //used to make sure don't get into infinite loop
    Boolean more = true;
    if (!String.isBlank(s1)) {
      //if there is a period in the string, but is not within 5 characters of the end, remove it
      while (more && j < 100 ) {
        i = result.indexof('.', i);
        if (i == -1) {
          more = false;
        } else  if (i < result.length() - 5) {
          result = result.replaceFirst('[.]' , '-');
        } else {
          more = false;
        }
        j++;
      }
      i = result.lastindexOf('.');
      //i = -1 if there is no period in string, which means no extension
      //automatically add .msg to filename
      if ( i == -1) {
        result = result + '.msg';
      }
    }

    return result;
  }
/*
  // parameters
  public static void retrieveAuthorInitials(id OwnerID, documentMetadata rec) {
    List<User> userList = new List<User>();

    try {
      userList = [SELECT Id, initials__c, name FROM User WHERE Id = :OwnerID];
      if (userList.size() == 1) {
        rec.authorInitials = userList[0].initials__c;
        rec.authorFullName = userList[0].name;
      }
    } catch (exception e) {
      system.debug('error retrieving user details' + e.getmessage());
    }
    return;
  }
  */

  private static void debugshowlongline(string fieldname, string s) {
    system.debug('*******************' + fieldname);
    boolean more = true;
    Integer i = 1;
    while (more) {
      if (s.length() < (100 * i)) {
        system.debug(s.mid(((i * 100) - 100), 100));
        more = false;
      } else {
        system.debug(s.mid(((i * 100) - 100), 100));
        i++;
      }
    }
    system.debug('*******************' + fieldname);
  }
}