public class resolutionDamagesAndLiensWrapper {
    

    @AuraEnabled
    public litify_pm__Resolution__c currentResolution { get; set; }
    @AuraEnabled
    public List<litify_pm__Damage__c> availableDamages{get;set;}
    
    @AuraEnabled
    public List<litify_pm__Damage__c> selectedDamages{get;set;} 

    /**
     * Used Damages
     */
    @AuraEnabled
    public List<litify_pm__Damage__c> usedDamages { get; set; }

    @AuraEnabled
    public List<litify_pm__Lien__c> availableLienes{get;set;}
    
    @AuraEnabled
    public List<litify_pm__Lien__c> selectedLienes{get;set;}   

    /**
     * Used Liens
     */
    @AuraEnabled
    public List<litify_pm__Lien__c> usedLienes { get; set; }

    
    @AuraEnabled
    public litify_pm__Resolution__c objResolution{get;set;}
    
    @AuraEnabled
    public List<litify_pm__Damage__c> emptyDamages{get;set;}  
    
     @AuraEnabled
    public List<litify_pm__Lien__c> emptyLienes{get;set;}    
    
    
    @AuraEnabled
    public double totalDamagesAmount{get;set;}
    
     @AuraEnabled
    public double totalLienesAmount{get;set;}
    
    @AuraEnabled
    public decimal noOfPreBilled{get;set;}
    
    @AuraEnabled
    public decimal noOfSelected{get;set;}
    
    @AuraEnabled
    public decimal noOfUnSelected{get;set;}
    
    @AuraEnabled
    public decimal noOfPreBilledWriteOff{get;set;}    
    
    
    @AuraEnabled
    public decimal noOfUnBilledWriteOff{get;set;}   
    
    
    @AuraEnabled
    public double balanceAmount{get;set;}
    
   /* public resolutionDamagesAndLiensWrapper(List<litify_pm__Damage__c> availableDamages,List<litify_pm__Damage__c> selectedDamages){
        this.availableDamages = availableDamages;
        this.selectedDamages = selectedDamages;
        noOfSelected = selectedDamages.size();
        noOfUnSelected = availableDamages.size();
        
        this.emptyDamages = new List<litify_pm__Damage__c> ();
        this.emptyLienes = new List<litify_pm__Lien__c> ();
        
    }
    public resolutionDamagesAndLiensWrapper(){}
*/
}