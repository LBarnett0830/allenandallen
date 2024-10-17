@IsTest (seealldata=false)

    private class WDIFileInfoTriggerTest {
        static final String RELATEDTOMATTER = 'litify_pm__Matter__c';
        static final String RELATEDTOINTAKE = 'litify_pm__Intake__c';
        static final String RELATEDTOTEMPLATE = 'litify_docs__Template__c';

        static testMethod void insertMatterDocument() {

            Account a = WDIDataFactory.createAccount();
            litify_pm__Matter__c m = WDIDataFactory.createMatter(a);

            litify_docs__File_Info__c testFileInfo = WDIDataFactory.createFileInfo(RELATEDTOMATTER,m.Id);
            test.starttest();
            testFileInfo.litify_docs__Complete__c = true;
            UPDATE testFileInfo;
            test.stoptest();
        }

        static testMethod void insertTemplateDocument() {

            Account a = WDIDataFactory.createAccount();
            litify_pm__Matter__c m = WDIDataFactory.createMatter(a);

            litify_docs__File_Info__c testFileInfo = WDIDataFactory.createFileInfo(RELATEDTOTEMPLATE,m.Id);
            test.starttest();
            testFileInfo.litify_docs__Complete__c = true;
            UPDATE testFileInfo;
            test.stoptest();
        }

        static testMethod void insertlargeDocument() {

            Account a = WDIDataFactory.createAccount();
            litify_pm__Matter__c m = WDIDataFactory.createMatter(a);

            litify_docs__File_Info__c testFileInfo = WDIDataFactory.createFileInfo(RELATEDTOTEMPLATE,m.Id);
            testFileInfo.litify_docs__File_Size__c = 111111111;
            
            test.starttest();
            testFileInfo.litify_docs__Complete__c = true;
            UPDATE testFileInfo;
            test.stoptest();
        }

    }