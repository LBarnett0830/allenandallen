trigger WDIFileInfoTrigger on litify_docs__File_Info__c (before update, after update) {
    public static final string IN_PROGRESS_STATUS = 'In Progress';
    public static final string READY_TO_PROCESS_STATUS = 'Ready to Process';
    public static final string STATUS_IGNORE = 'Ignore';
    public static final string STATUS_IGNORE_ORIGIN_MERGE = 'Ignore - Docrio Merge File';
    public static final string STATUS_IGNORE_FILESIZE = 'Ignore - filesize too large';
    public static final string TEMPLATE_API_NAME = 'litify_docs__Template__c';
    public static final string LIMIT_FILE_1 = 'PLACEHOLDER.TXT';
    public static final string LIMIT_FILE_2 = 'TEMPORARY FILE.DOCX';
    public static Boolean checkFileSize = WDI_Queueable_Helper.env.fileSizeCheckEnabled;
    public static Boolean FilesizePopup = WDI_Queueable_Helper.env.FilesizePopup;
    public static Boolean FilesizeNotification = WDI_Queueable_Helper.env.FilesizeNotification;
    public static Decimal maxFileSize = WDI_Queueable_Helper.env.maxFileSize;
    if (test.isRunningTest() ) {
        maxFileSize = 1;
    }
    public static Boolean ignoreTemplateEnabled = WDI_Queueable_Helper.env.ignoreTemplateEnabled;
    public static Boolean limitFilesToProcess = WDI_Queueable_Helper.env.LimitFilesToProcess;
    public String newBody;
    CustomNotificationType CNtype = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'WDI_Integration_Notification'];

    if (Trigger.isBefore && Trigger.isUpdate) {
            system.debug('In before update');
                        
            for (litify_docs__File_Info__c newRec : Trigger.new) {
                litify_docs__File_Info__c oldRec = Trigger.oldmap.get(newRec.ID);

                system.debug('before boolean');
                Boolean previousVersion = oldRec.litify_docs__Complete__c;
                Boolean newVersion = newRec.litify_docs__Complete__c;
                system.debug('prev version:' + previousVersion + '  newVersion:' + newVersion);
                system.debug('before if');

                if (!previousVersion && newVersion ) {
                    newRec.WDI_Status__c = READY_TO_PROCESS_STATUS;
                    if (ignoreTemplateEnabled || test.isRunningTest()) {
                        if (newRec.litify_docs__Related_To_Api_Name__c == TEMPLATE_API_NAME) {

                            newRec.WDI_Status__c = STATUS_IGNORE;
                        } else  if (String.isnotblank(newRec.litify_docs__Origin_Merge_Template__c)  ) {
                            newRec.WDI_Status__c = STATUS_IGNORE_ORIGIN_MERGE;
                        }
                    }
                    if (limitFilesToProcess || test.isRunningTest() ) {
                        //Only allow 2 files - placeholder.txt and Temporary file.docx 5/8/2022 used for File Migration
                        String sourceFileName = newRec.name.toUppercase();
                        system.debug('LimtFilesToProcess:' + limitFilesToProcess + '    Filename:' + sourceFilename);
                        if (!(sourceFileName == LIMIT_FILE_1) && !(sourceFileName == LIMIT_FILE_2) ) {
                            system.debug('LIMIT FILENAME to Process - SET STATUS TO : ' + STATUS_IGNORE);
                            newRec.WDI_Status__c = STATUS_IGNORE;
                        } else {
                            system.debug('filename:' + sourceFilename + ' is OK to process...');
                        }
                    }
                    if (checkFileSize || test.isRunningTest() ) {

                        system.debug('Reviewing status based on filesize');
                        if ( newRec.litify_docs__File_Size__c > maxFileSize) {
                            newRec.WDI_Status__c = STATUS_IGNORE_FILESIZE;
                            if (FilesizeNotification  || test.isRunningTest()) {
                                //throw new AuraHandledException('Filesize too large!');
                                system.debug('file too large');
                                system.debug('filesize:' + newRec.litify_docs__File_Size__c);
                                system.debug('max filesize:' + maxFileSize);
                                system.debug('****************************');
                                // throw exception
                                //throw new AuraHandledException('Filesize too large!');
                                //throw new illegalArgumentException('Filesize too large - unable to upload to Worldox.');
                                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                                newBody = 'The filesize of your document (' + newRec.name;
                                newBody += ') is too large to send to Worldox through Salesforce. You must manually upload the document to Worldox.';
                                notification.setBody(newBody);
                                notification.setTitle('Worldox Integration Warning!');
                                notification.setSenderId(Userinfo.getUserId());
                                
                                notification.setNotificationTypeId(CNtype.id);
                                notification.setTargetId(newRec.litify_docs__Related_To__c); // target object id
                                notification.send(new Set<String> { Userinfo.getUserId() });
                            }
                            if (FilesizePopup  || test.isRunningTest()) {
                                WDI_Queueable_Helper.WdiPlatformEventClass newnot = new WDI_Queueable_Helper.WdiPlatformEventClass();
                                newnot.UserId = Userinfo.getUserId();
                                newnot.IntakeId = '';
                                newnot.MatterId = '';
                                newnot.errorMessage = 'The filesize of your document (' + newRec.name + ') is too large to send to Worldox through Salesforce. You must manually upload the document to Worldox.';
                                
                                WDI_Queueable_Helper.processPlatformEvent(newnot);
                            }
                            


                        }

                    }
                    
            }            
            
        }
    }

}