public with sharing class WDI_IntakeIframeExtension {
        private ApexPages.StandardController sc;
    
        public String fieldValue { get; set; }
        public String lookupValue { get; set; }
        public String cabinetNameValue { get; set; }
    
        public final litify_pm__Intake__c intakerec { get; set; }
    
        public WDI_IntakeIframeExtension(ApexPages.StandardController stdController) {
            this.sc = stdController;
            
            if (!Test.isRunningTest() ) {
                stdController.addFields(new List<String>{'WDI_ID__c'});
            }
            cabinetNameValue = WDI_Queueable_Helper.env.Cabinet_Name;
            system.debug('cabinetName:' + cabinetNameValue);
            this.intakerec = (litify_pm__Intake__c)stdController.getRecord();
            system.debug('Intake Rec:' + intakerec);
                fieldValue = '5';
                lookupValue = intakerec.WDI_ID__c;
            system.debug('fieldValue:' + fieldValue);
            system.debug('lookupValue:' + lookupValue);
        }
        
    }