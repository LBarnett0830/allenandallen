@istest(seealldata=false)

public with sharing class WDI_IntakeiframeExtensionTest {

    private static testmethod void testextension1() {
        Account a = WDIDataFactory.createAccount();
        litify_pm__Matter__c m = WDIDataFactory.createMatter(a); 
        litify_pm__Intake__c i = WDIDataFactory.createIntake(a);
        m.litify_pm__Primary_Intake__c = i.id;
        //m.WDI_WDI__c = 'TEST';
        update m;



        PageReference pageRef = Page.WDI_Iframe_Intake;
        test.setcurrentPage(pageRef);

        pageRef.getParameters().put('Id',String.valueof(i.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(i);

        WDI_IntakeIframeExtension runtest = new WDI_IntakeIframeExtension(sc);

    }

    
}