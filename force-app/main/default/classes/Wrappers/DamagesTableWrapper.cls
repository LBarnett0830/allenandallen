public with sharing class DamagesTableWrapper {
    public List<litify_pm__Damage__c> availableDamages { get; set; }
    public List<litify_pm__Damage__c> selectedDamages { get; set; }
    @AuraEnabled
    public Double totalDamagesAmount { get; set; }
    
}