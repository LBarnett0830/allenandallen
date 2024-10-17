/*
Description : depositSlipController
Author      : Cmentor/ Sampath Suranji
Date		: 07/21/2020
*/
public class depositSlipWrapper {
    
    @auraEnabled 
    public Trust_Deposit__c objTrustDeposit{get;set;}
    
    @auraEnabled
    public list<depositSlipCRWrapper>listTrustCRWrapper{get;set;}
    
    @auraEnabled 
    public Trust_Cash_Receipt__c objEmptyTrustCR{get;set;}
    
    @auraEnabled 
    public decimal CRTotal{get;set;}
    
    @auraEnabled 
    public integer noOfCR{get;set;}
    
    @auraEnabled
    public depositSlipCRWrapper objTrustCRWrapper{get;set;}
    
    
    
}