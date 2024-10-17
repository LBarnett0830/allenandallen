public with sharing class WDI_MatterIframeExtension {
    private ApexPages.StandardController sc;

    public String fieldValue { get; set; }
    public String lookupValue { get; set; }
    public String cabinetNameValue { get; set; }

    public final litify_pm__Matter__c matterrec { get; set; }

    public WDI_MatterIframeExtension(ApexPages.StandardController stdController) {
        this.sc = stdController;
        
        if (!Test.isRunningTest() ) {
            stdController.addFields(new List<String>{'litify_pm__Primary_Intake__c','WDI_ID__c'});
        }
        cabinetNameValue = WDI_Queueable_Helper.env.Cabinet_Name;
        this.matterrec = (litify_pm__Matter__c)stdController.getRecord();
        system.debug('Matter Rec:' + matterrec);
        String intake = matterrec.litify_pm__Primary_Intake__c;
        if (String.isblank(intake)) {
            fieldValue = '6';
            lookupValue = matterrec.WDI_ID__c;
        } else {
            fieldValue = '5';
            lookupValue = matterrec.WDI_ID__c;
        }
    }
    
}