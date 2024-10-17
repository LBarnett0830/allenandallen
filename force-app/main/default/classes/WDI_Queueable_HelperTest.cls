@IsTest (SeeAllData=false)

Private class WDI_Queueable_HelperTest {
    static testMethod void testinitvars() {
        WDI_Queueable_Helper.initvars();
    }

    static testMethod void testSetupEnvironment() {
        String expectedCabinet = '011';
        WDI_Queueable_Helper.WDI_environment newenv = new WDI_Queueable_Helper.WDI_environment();
        //System.assertEquals(newenv.WDI_Cabinet,expectedCabinet);
    }

    static testmethod void testgetURLfromDocrio_noURL() {
        Test.setMock(HttpCalloutMock.class, new WDIDAtaFactory.TestMockGetURLfromDocrioNoURL() );
        litify_docs__File_Info__c testFile = WDIDataFactory.createFileInfo();

        test.starttest();
        WDI_Queueable_Helper.getURLfromDocrio(testFile.Id);
        test.stoptest();
    }

    static testmethod void testgetURLfromDocrio() {
        Test.setMock(HttpCalloutMock.class, new WDIDAtaFactory.TestMockGetURLfromDocrio() );
        litify_docs__File_Info__c testFile = WDIDataFactory.createFileInfo();

        test.starttest();
        WDI_Queueable_Helper.getURLfromDocrio(testFile.Id);
        test.stoptest();
    }


    static testmethod void testgetBlobFromDocrio() {
        String testurl='https://www.example.com';
        Test.setMock(HttpCalloutMock.class, new WDIDAtaFactory.TestMockGetBLOBfromDocrio() );
        litify_docs__File_Info__c testFile = WDIDataFactory.createFileInfo();

        test.starttest();
        WDI_Queueable_Helper.getBLOBfromDocrio(testurl);
        test.stoptest();
    }

    static testmethod void testLOGINprocess() {
        Test.setMock(HttpCalloutMock.class, new WDIDAtaFactory.TestMockLOGInprocess() );

        test.starttest();
        WDI_Queueable_Helper.loginProcess();
        test.stoptest();
    }

    static testmethod void testLOGINprocessFailure() {
        Test.setMock(HttpCalloutMock.class, new WDIDAtaFactory.TestMockLOGInprocessError() );

        test.starttest();
        WDI_Queueable_Helper.loginProcess();
        test.stoptest();
    }

    static testmethod void testPROFILEprocess() {
        Test.setMock(HttpCalloutMock.class, new WDIDAtaFactory.TestMockPROFILEprocess() );

        test.starttest();
        WDI_Queueable_Helper.testPROFILEprocess();
        test.stoptest();
    }

    static testmethod void testPROFILEprocessError() {
        Test.setMock(HttpCalloutMock.class, new WDIDAtaFactory.TestMockPROFILEprocessError() );

        test.starttest();
        WDI_Queueable_Helper.testPROFILEprocess();
        test.stoptest();
    }

    static testmethod void testNEWFILEprocess() {
        WDI_Queueable_Helper.filename = 'TEST1.TXT';
        Test.setMock(HttpCalloutMock.class, new WDIDAtaFactory.TestMockNEWFILEprocess() );
        test.starttest();
        WDI_Queueable_Helper.NEWFILEprocess();
        test.stoptest();
    }

    static testmethod void testNEWFILEprocessError() {
        WDI_Queueable_Helper.filename = 'TEST1.TXT';
        Test.setMock(HttpCalloutMock.class, new WDIDAtaFactory.TestMockNEWFILEprocessError() );
        test.starttest();
        WDI_Queueable_Helper.NEWFILEprocess();
        test.stoptest();
    }

    static testmethod void testAEDTABLEprocess0() {
        Test.setMock(HttpCalloutMock.class, new WDIDAtaFactory.TestMockAEDTABLEprocess() );
        test.starttest();
        WDI_Queueable_Helper.AEDTABLEprocess(1,'TEST','TEST');
        WDI_Queueable_Helper.AEDTABLEprocess(4,'TEST','TEST');
        WDI_Queueable_Helper.AEDTABLEprocess(5,'TEST','TEST');
        WDI_Queueable_Helper.AEDTABLEprocess(6,'TEST','TEST');
        WDI_Queueable_Helper.AEDTABLEprocess(0,'TEST','TEST');
        test.stoptest();
    }

    static testmethod void testUPLOADIISprocess() {
        Test.setMock(HttpCalloutMock.class, new WDIDAtaFactory.TestMockUPLOADIISprocess() );
        WDI_Queueable_Helper.blobFile = Blob.valueof('This is a test');
        WDI_Queueable_Helper.fileName = 'TEST.TXT';
        test.starttest();
        WDI_Queueable_Helper.UPLOADIISprocess();
        test.stoptest();
    }

    static testmethod void testUPLOADIISprocessError() {
        Test.setMock(HttpCalloutMock.class, new WDIDAtaFactory.TestMockUPLOADIISprocessError() );
        WDI_Queueable_Helper.blobFile = Blob.valueof('This is a test');
        WDI_Queueable_Helper.fileName = 'TEST.TXT';
        test.starttest();
        WDI_Queueable_Helper.UPLOADIISprocess();
        test.stoptest();
    }

    static testmethod void testUPLOADWDprocess() {
        Test.setMock(HttpCalloutMock.class, new WDIDAtaFactory.TestMockUPLOADWDprocess() );
        test.starttest();
        WDI_Queueable_Helper.UPLOADWDprocess();
        test.stoptest();
    }

    static testmethod void testUPLOADWDprocessError() {
        Test.setMock(HttpCalloutMock.class, new WDIDAtaFactory.TestMockUPLOADWDprocessError() );
        test.starttest();
        WDI_Queueable_Helper.UPLOADWDprocess();
        test.stoptest();
    }

    static testmethod void testLOGOUTprocess() {
        Test.setMock(HttpCalloutMock.class, new WDIDAtaFactory.TestMockLOGOUTprocess() );
        test.starttest();
        WDI_Queueable_Helper.LOGOUTprocess();
        test.stoptest();
    }

    static testmethod void testLOGOUTprocessError() {
        Test.setMock(HttpCalloutMock.class, new WDIDAtaFactory.TestMockLOGOUTprocessError() );
        test.starttest();
        WDI_Queueable_Helper.LOGOUTprocess();
        test.stoptest();
    }
}