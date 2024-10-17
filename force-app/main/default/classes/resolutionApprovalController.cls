/*
Author: Cmentor/Sampath Suranji
Date  :06/04/2020
Description : resolutionApprovalController for Resolution Submit for approval custom button
*/
//TODO: Update Total Damages Due Amount to reflect Total Damages for all non escrowed Damages
//TODO: Updated Total Liens Due Amount to equal total Liens for all non escrowed Liens.
public without sharing class resolutionApprovalController {
    public string resolutionId{get;set;}
    public string errorMsg{get;set;}    
    public boolean showSuccess{get;set;}
    public boolean showError{get;set;}
    public litify_pm__Resolution__c objResolution{ get; set;}
    
    
    public resolutionApprovalController(){
        string recId = ApexPages.currentPage().getParameters().get('id');
        if(!string.isEmpty(recId)){
            resolutionId = recId;
        }
    }
    
    public void checkValidation(){
        try{
            showError = false;
            set<string>listAccVariables1= new set<string>();
            set<string>listAccVariables2= new set<string>();
            set<string>listAccVariables3= new set<string>();
            set<string>listAccVariables4= new set<string>();
            
            if(!string.isEmpty(resolutionId)){
                list<litify_pm__Resolution__c>listResolution =[select id,Status__c,litify_pm__Resolution_Date__c,litify_pm__Matter__c,litify_pm__Matter__r.litify_pm__Principal_Attorney__c,litify_pm__Matter__r.litify_pm__Client__c,litify_pm__Settlement_Verdict_Amount__c,Total_Allocated__c
                                                               ,Total_Shares__c,litify_pm__Matter__r.litify_pm__Primary_Intake__c ,litify_pm__Matter__r.litify_pm__Primary_Intake__r.Originating_Office__c,litify_pm__Matter__r.litify_pm__Case_Type__c,litify_pm__Matter__r.litify_pm__Case_Type__r.Service_Line__c 
                                                               from litify_pm__Resolution__c where id =:resolutionId];
                
                for(AcctSeed__Accounting_Variable__c accVariables:[select id,name,AcctSeed__Type__c from AcctSeed__Accounting_Variable__c]){
                    
                    if(accVariables.AcctSeed__Type__c=='GL Account Variable 4'){
                        //Attorney
                        listAccVariables4.add(accVariables.name);
                    }
                    else if(accVariables.AcctSeed__Type__c=='GL Account Variable 3'){
                        listAccVariables3.add(accVariables.name);
                    }
                    else if(accVariables.AcctSeed__Type__c=='GL Account Variable 2'){
                        //Location
                        listAccVariables2.add(accVariables.name);
                    }
                    else if(accVariables.AcctSeed__Type__c=='GL Account Variable 1'){
                        listAccVariables1.add(accVariables.name);
                    }
                }
                
                if(listResolution.size()>0){
                    objResolution = listResolution[0];
                    
                    
                    List<Attorney_Split__c>listAttorneySplit = [select id,Share__c,Attorney__c,Attorney__r.Alias from Attorney_Split__c where Resolution__c=:resolutionId];
                    
                    
                    if(objResolution.Status__c!='In-Process'  ){
                        showError = true;
                        errorMsg = 'Resolution record is not in a valid Stage to Submit for approval';
                    }                    
                    else  if(objResolution.litify_pm__Matter__c==null ){
                        showError = true;
                        errorMsg = 'Matter is Required';
                    } 
                    else  if(objResolution.litify_pm__Settlement_Verdict_Amount__c<=0 ){
                        showError = true;
                        errorMsg = 'Settlement/Verdict Amount must be greater than 0';
                    }                    
                    
                    else  if(objResolution.litify_pm__Settlement_Verdict_Amount__c!=objResolution.Total_Allocated__c ){
                        showError = true;
                        errorMsg = 'Total Allocated must be equal Settlement/Verdict Amount';
                    }
                    else  if(objResolution.litify_pm__Matter__r.litify_pm__Principal_Attorney__c==null ){
                        showError = true;
                        errorMsg = 'Principal Attorney is required in related Matter.';
                    }
                    
                    else if(listAttorneySplit.size()==0  ){
                        showError = true;
                        errorMsg = 'There must be at least one Attorney Split record';
                    }
                    else if(objResolution.Total_Shares__c!=100){
                        showError = true;
                        errorMsg = 'Total Share of Attroney Split must equal to 100%';
                    }
                    else if(objResolution.litify_pm__Matter__r.litify_pm__Primary_Intake__c==null){
                        showError = true;
                        errorMsg = 'Intake value is required in related Matter.';
                    }
                    else if(string.isempty(objResolution.litify_pm__Matter__r.litify_pm__Primary_Intake__r.Originating_Office__c) ){
                        showError = true;
                        errorMsg = 'Originating Office is required in related Matter \'s Intake record';
                    }
                    else if(objResolution.litify_pm__Matter__r.litify_pm__Case_Type__c==null){
                        showError = true;
                        errorMsg = 'Case Type value is required.';
                    }
                    else if(string.isempty(objResolution.litify_pm__Matter__r.litify_pm__Case_Type__r.Service_Line__c) ){
                        showError = true;
                        errorMsg = 'Service Line is required on related Case Type record';
                    }
                    else if(!listAccVariables2.contains(objResolution.litify_pm__Matter__r.litify_pm__Primary_Intake__r.Originating_Office__c)){
                        showError = true;
                        errorMsg = 'Accounting variable not found for the Originating Office in related Intake record.';
                    }
                    else if(!listAccVariables1.contains(objResolution.litify_pm__Matter__r.litify_pm__Case_Type__r.Service_Line__c)){
                        showError = true;
                        errorMsg = 'Accounting variable not found for the Service Line in related Case Type record.';
                    }
                    if(!showError){
                        for(Attorney_Split__c objSplit:listAttorneySplit){
                            if(!listAccVariables4.contains(objSplit.Attorney__r.Alias)){
                                showError = true;
                                errorMsg = 'Accounting variable not found for the Attorney in related Attorney Split.';
                                break;
                            }
                        }
                    }
                    
                    if(!showError){
                        processExpenseApproval();
                    }
                }
                
            }
            
        }
        catch(Exception ex){}
        
    }
    
    public void processExpenseApproval(){
        savepoint sp;
        try{
            sp= database.setSavepoint();
            
            
            List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
            Approval.ProcessSubmitRequest objAppReq = new Approval.ProcessSubmitRequest();
            objAppReq.setComments('Submitting request for approval.');
            objAppReq.setObjectId(resolutionId);
            objAppReq.setSubmitterId(UserInfo.getUserId());
            //objAppReq.setProcessDefinitionNameOrId('Expense_Approval_ProcessV1');
            objAppReq.setNextApproverIds(new list<id>{objResolution.litify_pm__Matter__r.litify_pm__Principal_Attorney__c}); 
            approvalRequestList.add(objAppReq);
            
            Approval.process(approvalRequestList);
            
            
            showSuccess =true;
        }
        catch(Exception ex){
            if(sp!=null){
                database.rollback(sp);
            }
            showError = true;
            errorMsg = 'Error occured, Please contact the salesforce Administrator.';
        }
    }
    
    public PageReference redirectToDetail(){
        PageReference pg ;
        try
        {
            if(!string.isEmpty(resolutionId)){
                system.debug('recordId '+resolutionId);
                pg= new PageReference('/'+resolutionId);
                pg.setRedirect(true);
                return pg;
            }
            
        }
        catch(Exception ex){}
        return pg;
        
    }
    
}