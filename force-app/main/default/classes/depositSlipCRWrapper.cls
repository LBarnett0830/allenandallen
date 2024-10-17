/*
Description : depositSlipCRWrapper used in depositSlipController
Author      : Cmentor/ Sampath Suranji
Date		: 07/22/2020
*/
public class depositSlipCRWrapper {
    @auraEnabled 
    public string id{get;set;}
    @auraEnabled 
    public string name{get;set;}
    @auraEnabled 
    public string matterId{get;set;}
    @auraEnabled 
    public string matterName{get;set;}
    @auraEnabled 
    public string payorId{get;set;}
    @auraEnabled 
    public string payorName{get;set;}
    @auraEnabled 
    public string reference{get;set;}
    @auraEnabled 
    public decimal amount{get;set;}
    @auraEnabled 
    public string depositType{get;set;}
    
    /*public depositSlipCRWrapper(){}
    public depositSlipCRWrapper(string id,string name,string matterId,string matterName,string payorId,string payorName,string reference,decimal amount){
        this.id= id;
        this.name= name;
        this.matterId= matterId;
        this.matterName= matterName;
        this.payorId= payorId;
        this.payorName= payorName;
        this.reference= reference;
        this.amount= amount;
    }
*/    
    
}