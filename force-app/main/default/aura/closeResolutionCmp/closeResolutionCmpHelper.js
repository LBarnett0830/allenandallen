({
    helperMethod : function() {
        
    },
    
    checkValidation :function(cmp){
        var resolutionId =cmp.get("v.recordId");
        
        var action = cmp.get('c.checkValidation');
        action.setParams({ 
            resolutionId : resolutionId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var msg='';
                var showError= false;
                var mapMsg = response.getReturnValue();
                if(mapMsg.negativeDestributions!=undefined){
                    msg = 'Negative Distributions not allowed.';
                    showError =true; 
                    
                }else if(mapMsg.attorneyNotFound!=undefined){
                    msg = "Principal Attorney or Claims User is required in related Matter";
                    showError =true;                    
                    
                }else if(mapMsg.noGLForOriginatingOffice!=undefined){
                    msg = 'Accounting variable not found for the Originating Office in related Intake record.';
                    showError =true;                   
                    
                }else if(mapMsg.noGLForServiceLine!=undefined){
                    msg = 'Accounting variable not found for the Service Line in related Case Type record.';
                    showError =true;                   
                    
                }else if(mapMsg.noGLForAttorney!=undefined){
                    msg = 'Accounting variable not found for the Attorney in related Attorney Split.';
                    showError =true;                   
                    
                }else if(mapMsg.AttSplitNotTally!=undefined){
                    msg = 'Attorney Splits do not add up to Total Fee Income.';
                    showError =true;                   
                    
                } else if(mapMsg.invalidCustomSettings!=undefined){
                    msg = "Values are not defined in 'Firm Ledger COS Fee Revenue GL Account' custom settings";
                    showError =true;                   
                    
                }else if(mapMsg.missingLiabilityGL!=undefined){
                    msg = "Invalid GL Account defined in 'Trust_Ledger_Debit_GL_Account' Custom Label";
                    showError =true;                   
                    
                }else if(mapMsg.projectNotFound!=undefined){
                    msg = "Project is not defined for the related Matter";
                    showError =true;                    
                    
                }else if(mapMsg.projectTaskNotFound!=undefined){
                    msg = "Default Project task is not defined for the related Project";
                    showError =true;                    
                    
                }else if(mapMsg.missingPartyInDamage!=undefined){
                    msg = "Provider is required for selected Damages records";
                    showError =true;                   
                    
                }else if(mapMsg.missingPartyInLien!=undefined){
                    msg = "Payee is required for selected Liens records";
                    showError =true;                  
                    
                }else if(mapMsg.missingResolutionDate!=undefined){
                    msg = "Resolution Date is required";
                    showError =true;                  
                    
                }else if(mapMsg.missingAccPeriod!=undefined){
                    msg = "Accounting Period must exist and be open";
                    showError =true;                  
                    
                }/*else if(mapMsg.clientDstAPNotCreated!=undefined){
                    msg = "Client Distribution Payable not created. Cannot Close Resolution";
                    showError =true;                  
                    
                }*/
                if(showError){
                    $A.get("e.force:closeQuickAction").fire();                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": msg,
                        "type": 'error'
                    });
                    toastEvent.fire();
                }else{
                    cmp.set("v.showCloseBtn",true);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getResolutionDetails : function(cmp) {
        console.log('resolutionId '+resolutionId);       
        cmp.set("v.showSpinner",true);
        
        var resolutionId =cmp.get("v.recordId");
        
        var action = cmp.get('c.getResolutionDetails');
        action.setParams({ 
            resolutionId : resolutionId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var objWrapper = response.getReturnValue();
                cmp.set("v.objWrapper", response.getReturnValue());
                var objResolution = objWrapper.objResolution;
                cmp.set("v.objResolution", objResolution);
                var attorneyCost = parseFloat(objResolution.litify_pm__Total_Expenses__c)- parseFloat(objResolution.Amount_Written_off__c==null?0:objResolution.Amount_Written_off__c);
                cmp.set("v.attorneyCost", attorneyCost.toFixed(2));
                
                var totalDistribution = parseFloat(objResolution.Attorney_Referrals__c==null?0:objResolution.Attorney_Referrals__c) + parseFloat(objResolution.Firm_Distribution_After_Referral_Fees__c==null?0:objResolution.Firm_Distribution_After_Referral_Fees__c)+parseFloat(objResolution.Third_Party_Distributions__c)+parseFloat(objResolution.Client_Distribution__c==null?0:objResolution.Client_Distribution__c);
                totalDistribution = totalDistribution + parseFloat(objResolution.litify_pm__Total_Damages__c==null?0:objResolution.litify_pm__Total_Damages__c) +  parseFloat(objResolution.Total_Liens__c==null?0:objResolution.Total_Liens__c);
                var clientDistribution = objResolution.Client_Distribution__c==null?0:objResolution.Client_Distribution__c;
                var firmDistribution = objResolution.Firm_Distribution__c==null?0:objResolution.Firm_Distribution__c;
                var thirdPartyDistribution = objResolution.Third_Party_Distributions__c==null?0:objResolution.Third_Party_Distributions__c;
                var totalDamages = objResolution.litify_pm__Total_Damages__c==null?0:objResolution.litify_pm__Total_Damages__c;
                var totalLiens = objResolution.Total_Liens__c==null?0:objResolution.Total_Liens__c;
                var escRow = objResolution.Escrow__c==null?0:objResolution.Escrow__c;
                var settlementVerdit = objResolution.litify_pm__Settlement_Verdict_Amount__c==null?0:objResolution.litify_pm__Settlement_Verdict_Amount__c;
                settlementVerdit =settlementVerdit.toFixed(2);
                
                cmp.set("v.totalDistribution", totalDistribution.toFixed(2));
                var showError=false;
                var msg='';
                if(objResolution.Status__c=='Closed'){
                    msg='Resolution is already closed';
                    showError = true;
                }else if(settlementVerdit >0 && settlementVerdit< (clientDistribution+firmDistribution+thirdPartyDistribution+totalDamages+totalLiens+escRow).toFixed(2) ){
                    msg='Client Distribution Amount cannot be Negative';
                    showError = true;
                }else if(objResolution.litify_pm__Matter__r.litify_pm__Primary_Intake__c==null || objResolution.litify_pm__Matter__r.litify_pm__Primary_Intake__c=='undefined'){
                    msg="Primary intake is required in related Matter \'s Intake record";
                    showError = true;
                }/*else if(objResolution.litify_pm__Matter__r.litify_pm__Primary_Intake__r.Originating_Office__c==null || objResolution.litify_pm__Matter__r.litify_pm__Primary_Intake__r.Originating_Office__c=='undefined'){
                    msg="Originating Office is required in related Matter \'s Intake record";
                    showError = true;
                }*/else if(objResolution.litify_pm__Matter__r.litify_pm__Case_Type__c==null ){
                    msg="Case Type record is required in related Matter";
                    showError = true;
                }else if(objResolution.litify_pm__Matter__r.litify_pm__Case_Type__r.Service_Line__c==null || objResolution.litify_pm__Matter__r.litify_pm__Case_Type__r.Service_Line__c=='undefined'){
                    msg="Service Line is required on related Case Type record";
                    showError = true;
                }else if(objResolution.Attorney_Splits__r ==undefined ){
                    msg="There must be at least one Attorney Split record";
                    showError = true;
                }/*else if(objResolution.Total_Shares__c!='100'){
                    msg="Total Percent Share must equal 100%";
                    showError = true;
                }*/else if(objResolution.Total_Debits__c!=undefined && objResolution.Total_Credits__c!=undefined  && parseFloat(objResolution.Total_Credits__c)!=parseFloat(objResolution.Total_Debits__c)){
                    msg="Total Debits must be equal to total Credits";
                    showError = true;
                }
                if(showError){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": msg,
                        "type": 'error'
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }else{
                    this.checkValidation(cmp);
                }
                
                
                if(objResolution.Status__c=='Final'){
                    cmp.set("v.headerName",'CLOSING STATEMENT' );
                }
                
                cmp.set("v.showSpinner",false);
                
            }
            else{
                cmp.set("v.showSpinner",false);
            }
            
        });
        $A.enqueueAction(action);
    },
    
    closeResolution : function(cmp) {
        console.log('resolutionId '+resolutionId);       
        cmp.set("v.showSpinner",true);
        
        var resolutionId =cmp.get("v.recordId");
        var confirmTrustBalance = cmp.get("v.confirmTrustBalance");
        var action = cmp.get('c.closeResolution');
        action.setParams({ 
            resolutionId : resolutionId,
            confirmTrustBalance :confirmTrustBalance
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var msg='';
            var showError= false;
            if(state == "SUCCESS") {
                
                var mapMsg = response.getReturnValue();
                
                if(mapMsg.success=='true'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Closure of the Resolution succeeded",
                        "type": 'success'
                    });
                    toastEvent.fire();
                    
                    $A.get("e.force:closeQuickAction").fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": resolutionId,
                        "slideDevName": "detail"
                        
                    });
                    navEvt.fire(); 
                }else  if(mapMsg.invalidTotalExpense=='true'){
                    msg =  "Total Expense Amount does not tally with selected Expenses";
                    showError =true;
                    
                }else  if(mapMsg.invalidCustomSettings=='true'){
                    msg =  "GL Accounts are not defined in Firm Ledger COS & Fee Revenue GL Account custom setting";
                    showError =true;
                    
                }else if(mapMsg.invalidCostRecovered=='true'){
                    msg =  "Total Distributions plus Flat Fee can't exceed Recovery amount";
                    showError =true;
                    
                }else if(mapMsg.invalidTCode=='true'){
                    msg =  "'"+tcode+ "'"+" TCode is Invalid";
                    showError =true;    
                    
                }else if(mapMsg.invalidGLInTCode=='true'){
                    showError =true;
                    msg = "No GL Account associated with Tcode "+"'"+tcode+"'"; 
                    
                }else if(mapMsg.error=='true'){
                    showError =true;
                    msg = "Error occured";                       
                }
                if(showError){
                    $A.get("e.force:closeQuickAction").fire();                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": msg,
                        "type": 'error'
                    });
                    toastEvent.fire();
                }else{
                    if(mapMsg.insufficientTrustBalance!=undefined){
                        cmp.set('v.showConfirmTrustBalance',true);                   
                    }
                }
                
            }
            
           cmp.set("v.showSpinner",false);
           
            
        });
        $A.enqueueAction(action);
    },
    
    
})