({
    init : function(component, event, helper) {
        if(document.referrer.indexOf(".lightning.force.com") > 0){
            component.set("v.recordUrlBase",'/one/one.app?#/sObject/');
            component.set("v.recordUrlBaseEnd",'/view');
        }
        else{
            component.set("v.isClassic",true);
            component.set("v.recordUrlBase",'/');
            component.set("v.recordUrlBaseEnd",'');
        }
        
        helper.getResolutionWrapper(component);
        var defaultFooter = document.getElementsByClassName('modal-footer');
        
    },
    
    
    handleUnBilledSelect : function(component, event, helper) { 
       
        component.set("v.showSpinner",true);
        
        //helper.updateExpenseBillingStatus(component,'Unbilled',event);
        var objUnbilledExpList= component.get("v.resolutionWrapper.unbilledExpenses");
        var expenseId =event.getSource().get('v.value');
        var writeOffAmount = component.get("v.resolutionWrapper.writeOffAmount");
        var noOfVoidBilled = component.get("v.resolutionWrapper.noOfVoidBilled");
        var noOfVoidUnBilled = component.get("v.resolutionWrapper.noOfVoidUnBilled");
        var totalPreBilledAmount = component.get("v.resolutionWrapper.totalPreBilledAmount");
        
        var objExpense;
        var expVoidedAmount=0;
        var objResolution = component.get("v.resolutionWrapper").objResolution;
        
        var contigencyFee= parseFloat(objResolution.Contingency_Fee__c==null?0:objResolution.Contingency_Fee__c) ;
        var feeWrittenOff = parseFloat(objResolution.Fees_Written_Off__c==null?0:objResolution.Fees_Written_Off__c);
        var clientDistribution= parseFloat(objResolution.Client_Distribution__c==null?0:objResolution.Client_Distribution__c);
        var firmDistribution =parseFloat(objResolution.Firm_Distribution__c ==null?0:objResolution.Firm_Distribution__c );
        var thirdPartyDistribution =parseFloat(objResolution.Third_Party_Distributions__c  ==null?0:objResolution.Third_Party_Distributions__c  );
        var totalDamages=parseFloat(objResolution.litify_pm__Total_Damages__c  ==null?0:objResolution.litify_pm__Total_Damages__c );
        var settlementVerdict=parseFloat(objResolution.litify_pm__Settlement_Verdict_Amount__c  ==null?0:objResolution.litify_pm__Settlement_Verdict_Amount__c ); 
        
        
        //litify_pm__Settlement_Verdict_Amount__c - Firm_Distribution__c - Third_Party_Distributions__c - litify_pm__Total_Damages__c
        var ExpenseValid;
        var voidedAmount=0;
        var totalVoidedAmount= component.get("v.resolutionWrapper.totalVoidedAmount");
        for(var i=0;i<objUnbilledExpList.length;i++){
            if(objUnbilledExpList[i].Id==expenseId){
                ExpenseValid = objUnbilledExpList[i];
                if(ExpenseValid.Void__c){
                    totalVoidedAmount = parseFloat(totalVoidedAmount==null?0:totalVoidedAmount) + parseFloat(ExpenseValid.Amount_after_Reductions__c);
                }
                break;
            }
        }
        var totalExp= parseFloat(totalPreBilledAmount==undefined?0:totalPreBilledAmount)+parseFloat(ExpenseValid.Amount_after_Reductions__c);
        var firmDistribution =contigencyFee+totalExp-totalVoidedAmount-feeWrittenOff;
        console.log(settlementVerdict-firmDistribution-thirdPartyDistribution-totalDamages);
        
        if(settlementVerdict-firmDistribution-thirdPartyDistribution-totalDamages>0){
            clientDistribution= settlementVerdict-firmDistribution-thirdPartyDistribution-totalDamages;
        }
        else{
            clientDistribution=0;
        }
        
       /* if( (clientDistribution + firmDistribution +thirdPartyDistribution+totalDamages).toFixed(2) >settlementVerdict.toFixed(2)){
            //Client_Distribution__c + Firm_Distribution__c + Third_Party_Distributions__c + litify_pm__Total_Damages__c  > litify_pm__Settlement_Verdict_Amount__c
            //litify_pm__Total_Expenses__c > Firm_Distribution__c + Voided_Hard_Costs__c + Voided_Soft_Costs__c + Fees_Written_Off__c - Contingency_Fee__c
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Total Distributions exceed Settlement Amount",
                "type": 'error'
            });
            toastEvent.fire();
            component.set("v.showSpinner",false);
            
        }*/
        
            for(var i=0;i<objUnbilledExpList.length;i++){
                if(objUnbilledExpList[i].Id==expenseId){
                    objExpense = objUnbilledExpList[i];
                    objUnbilledExpList.splice(i,1);
                    component.set("v.resolutionWrapper.unbilledExpenses",objUnbilledExpList);
                    if(objExpense.Void__c){
                        component.set("v.resolutionWrapper.noOfVoidBilled",parseInt(noOfVoidBilled)+1);
                        component.set("v.resolutionWrapper.noOfVoidUnBilled",parseInt(noOfVoidUnBilled)-1);
                        expVoidedAmount = parseFloat(objExpense.Amount_after_Reductions__c);
                    }
                    break;
                }
            }
            
            var objPrebilledExpList = component.get("v.resolutionWrapper.billedAndPreBilledExpenses");
            objPrebilledExpList.push(objExpense);
            
            /*objPrebilledExpList.sort(function(a,b){
            return new Date(b.litify_pm__Date__c) - new Date(a.litify_pm__Date__c);
        });
        */
            
            objPrebilledExpList.sort((a, b) => (a.Name > b.Name) ? 1 : -1);
            
            component.set("v.resolutionWrapper.billedAndPreBilledExpenses",objPrebilledExpList);
            
            
            totalPreBilledAmount = parseFloat(totalPreBilledAmount) + objExpense.Amount_after_Reductions__c;
            if(totalPreBilledAmount!=null){
                component.set("v.resolutionWrapper.totalPreBilledAmount",parseFloat(totalPreBilledAmount).toFixed(2));
                
            }
            
            component.set("v.resolutionWrapper.balanceAmount",parseFloat(totalPreBilledAmount-writeOffAmount).toFixed(2));
            
            var totalVoidedAmount = component.get("v.resolutionWrapper.totalVoidedAmount");
            component.set("v.resolutionWrapper.totalVoidedAmount", parseFloat(totalVoidedAmount)+expVoidedAmount);
            
            var noOfPreBilled = component.get("v.resolutionWrapper.noOfPreBilled");
            component.set("v.resolutionWrapper.noOfPreBilled",noOfPreBilled+1);
            
            var noOfUnBilled = component.get("v.resolutionWrapper.noOfUnBilled");
            component.set("v.resolutionWrapper.noOfUnBilled",noOfUnBilled-1);
            component.set("v.showSave",true);
            component.set("v.showSpinner",false);
        
        
        
        
    },
    
    handleAllUnBilledSelect : function(component, event, helper) {  
        component.set("v.showSpinner",true);
        component.set("v.showSave",true);
        
        var objUnbilledExpList= component.get("v.resolutionWrapper.unbilledExpenses");     
        var emptyUnbilledList = component.get("v.resolutionWrapper.unbilledExpenses"); 
        var objResolution = component.get("v.resolutionWrapper").objResolution;
        var contigencyFee= parseFloat(objResolution.Contingency_Fee__c==null?0:objResolution.Contingency_Fee__c) ;
        var feeWrittenOff = parseFloat(objResolution.Fees_Written_Off__c==null?0:objResolution.Fees_Written_Off__c);
        var clientDistribution= parseFloat(objResolution.Client_Distribution__c==null?0:objResolution.Client_Distribution__c);
        var firmDistribution =parseFloat(objResolution.Firm_Distribution__c ==null?0:objResolution.Firm_Distribution__c );
        var thirdPartyDistribution =parseFloat(objResolution.Third_Party_Distributions__c  ==null?0:objResolution.Third_Party_Distributions__c  );
        var totalDamages=parseFloat(objResolution.litify_pm__Total_Damages__c  ==null?0:objResolution.litify_pm__Total_Damages__c );
        var settlementVerdict=parseFloat(objResolution.litify_pm__Settlement_Verdict_Amount__c  ==null?0:objResolution.litify_pm__Settlement_Verdict_Amount__c ); 
        var totalVoidedAmount= component.get("v.resolutionWrapper.totalVoidedAmount");
        
        if(objUnbilledExpList.length>0){
            
            var writeOffAmount = component.get("v.resolutionWrapper.writeOffAmount");        
            var objPrebilledExpList = component.get("v.resolutionWrapper.billedAndPreBilledExpenses");
            var selectedUnbilledTotalAmount=0;
            var noOfSelectedItems = objUnbilledExpList.length;
            var noOfVoidBilled = component.get("v.resolutionWrapper.noOfVoidBilled");
            var noOfVoidUnBilled = component.get("v.resolutionWrapper.noOfVoidUnBilled");
            var newVoided=0;
            var totalVoidedAmount=0;
            
            for(var i=0;i<objUnbilledExpList.length;i++){
                var expense = objUnbilledExpList[i];
                selectedUnbilledTotalAmount = selectedUnbilledTotalAmount+ parseFloat(expense.Amount_after_Reductions__c);
                if(expense.Void__c){
                    totalVoidedAmount = parseFloat(totalVoidedAmount==null?0:totalVoidedAmount) + parseFloat(expense.Amount_after_Reductions__c);
                }
                
            }
            var totalPreBilledAmount = component.get("v.resolutionWrapper.totalPreBilledAmount");
            totalPreBilledAmount = parseFloat(totalPreBilledAmount) + selectedUnbilledTotalAmount;
            var totalExp= parseFloat(totalPreBilledAmount==undefined?0:totalPreBilledAmount);
            var firmDistribution =contigencyFee+totalExp-totalVoidedAmount-feeWrittenOff;
            
            if(settlementVerdict-firmDistribution-thirdPartyDistribution-totalDamages>0){
                clientDistribution= settlementVerdict-firmDistribution-thirdPartyDistribution-totalDamages;
            }
            else{
                clientDistribution=0;
            }
            
            /*if( (clientDistribution + firmDistribution +thirdPartyDistribution+totalDamages).toFixed(2) >settlementVerdict.toFixed(2)){
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Total Distributions exceed Settlement Amount",
                    "type": 'error'
                });
                toastEvent.fire();
                component.set("v.showSpinner",false);
            }*/
            
                for(var i=0;i<objUnbilledExpList.length;i++){
                    var expense = objUnbilledExpList[i];
                    objPrebilledExpList.push(expense);
                    if(expense.Void__c){
                        newVoided++;
                        totalVoidedAmount= totalVoidedAmount+ parseFloat(expense.Amount_after_Reductions__c);
                    }
                    
                }
                
                
                
                /*objPrebilledExpList.sort(function(a,b){
                return new Date(b.litify_pm__Date__c) - new Date(a.litify_pm__Date__c);
            });*/
                objPrebilledExpList.sort((a, b) => (a.Name > b.Name) ? 1 : -1);
                
                
                component.set("v.resolutionWrapper.noOfVoidUnBilled",0);
                component.set("v.resolutionWrapper.noOfVoidBilled",parseInt(noOfVoidBilled)+newVoided);
                component.set("v.resolutionWrapper.unbilledExpenses",component.get("v.resolutionWrapper.emptyExpenses"));        
                component.set("v.resolutionWrapper.billedAndPreBilledExpenses",objPrebilledExpList);
                component.set("v.resolutionWrapper.totalVoidedAmount", totalVoidedAmount);
                
                
                if(totalPreBilledAmount!=null){
                    console.log(parseFloat(totalPreBilledAmount).toFixed(2));            
                    component.set("v.resolutionWrapper.totalPreBilledAmount",parseFloat(totalPreBilledAmount).toFixed(2));
                    
                }
                
                component.set("v.resolutionWrapper.balanceAmount",parseFloat(totalPreBilledAmount-writeOffAmount).toFixed(2));
                
                var noOfPreBilled = component.get("v.resolutionWrapper.noOfPreBilled");
                component.set("v.resolutionWrapper.noOfPreBilled",noOfPreBilled+ noOfSelectedItems);
                
                component.set("v.resolutionWrapper.noOfUnBilled",0);
                component.set("v.showSpinner",false);
            
            var chkBox = document.getElementById('selectUnbilledAll');
            chkBox.checked = false;
            
            
            
        }
        
        component.set("v.showSpinner",false);
        
        
    },    
    
    handlePreBilledSelect : function(component, event, helper) {
        component.set("v.showSpinner",true);
        component.set("v.showSave",true);
        var objUnbilledExpList= component.get("v.resolutionWrapper.unbilledExpenses");   
        var objPrebilledExpList = component.get("v.resolutionWrapper.billedAndPreBilledExpenses");
        var expenseId =event.getSource().get('v.value');
        var writeOffAmount = component.get("v.resolutionWrapper.writeOffAmount");
        var noOfVoidBilled = component.get("v.resolutionWrapper.noOfVoidBilled");
        var noOfVoidUnBilled = component.get("v.resolutionWrapper.noOfVoidUnBilled");
        
        var objExpense;
        var expVoidedAmount=0;
        for(var i=0;i<objPrebilledExpList.length;i++){
            if(objPrebilledExpList[i].Id==expenseId){
                objExpense = objPrebilledExpList[i];
                objPrebilledExpList.splice(i,1);
                component.set("v.resolutionWrapper.billedAndPreBilledExpenses",objPrebilledExpList);
                if(objExpense.Void__c){
                    component.set("v.resolutionWrapper.noOfVoidBilled",parseInt(noOfVoidBilled)-1);
                    component.set("v.resolutionWrapper.noOfVoidUnBilled",parseInt(noOfVoidUnBilled)+1);
                    expVoidedAmount = parseFloat(objExpense.Amount_after_Reductions__c);
                }
                break;
            }
        }
        
        objUnbilledExpList.push(objExpense);
        /* objUnbilledExpList.sort(function(a,b){
            return new Date(b.litify_pm__Date__c) - new Date(a.litify_pm__Date__c);
        });*/
        objUnbilledExpList.sort((a, b) => (a.Name > b.Name) ? 1 : -1);
        
        
        component.set("v.resolutionWrapper.unbilledExpenses",objUnbilledExpList);
        var totalPreBilledAmount = component.get("v.resolutionWrapper.totalPreBilledAmount");
        totalPreBilledAmount = parseFloat(totalPreBilledAmount) - objExpense.Amount_after_Reductions__c;
        
        var totalVoidedAmount = component.get("v.resolutionWrapper.totalVoidedAmount");
        component.set("v.resolutionWrapper.totalVoidedAmount", parseFloat(totalVoidedAmount)-expVoidedAmount);
        
        
        component.set("v.resolutionWrapper.totalPreBilledAmount", parseFloat(totalPreBilledAmount).toFixed(2));
        var balance = parseFloat(totalPreBilledAmount)-parseFloat(writeOffAmount);
        component.set("v.resolutionWrapper.balanceAmount",balance.toFixed(2));
        
        var noOfPreBilled = component.get("v.resolutionWrapper.noOfPreBilled");
        component.set("v.resolutionWrapper.noOfPreBilled",noOfPreBilled-1);
        
        var noOfUnBilled = component.get("v.resolutionWrapper.noOfUnBilled");
        component.set("v.resolutionWrapper.noOfUnBilled",noOfUnBilled+1);
        component.set("v.showSpinner",false);
        
        var chkBox = document.getElementById('selectUnbilledAll');
        chkBox.checked = false;
    },
    
    handleAllPreBilledSelect : function(component, event, helper) {
        component.set("v.showSpinner",true);
        component.set("v.showSave",true);
        
        var objUnbilledExpList= component.get("v.resolutionWrapper.unbilledExpenses"); 
        var objPrebilledExpList = component.get("v.resolutionWrapper.billedAndPreBilledExpenses");
        var emptyUnbilledList = component.get("v.resolutionWrapper.unbilledExpenses"); 
        var objResolution = component.get("v.resolutionWrapper").objResolution;
        var contigencyFee= parseFloat(objResolution.Contingency_Fee__c==null?0:objResolution.Contingency_Fee__c) ;
        var feeWrittenOff = parseFloat(objResolution.Fees_Written_Off__c==null?0:objResolution.Fees_Written_Off__c);
        var clientDistribution= parseFloat(objResolution.Client_Distribution__c==null?0:objResolution.Client_Distribution__c);
        var firmDistribution =parseFloat(objResolution.Firm_Distribution__c ==null?0:objResolution.Firm_Distribution__c );
        var thirdPartyDistribution =parseFloat(objResolution.Third_Party_Distributions__c  ==null?0:objResolution.Third_Party_Distributions__c  );
        var totalDamages=parseFloat(objResolution.litify_pm__Total_Damages__c  ==null?0:objResolution.litify_pm__Total_Damages__c );
        var settlementVerdict=parseFloat(objResolution.litify_pm__Settlement_Verdict_Amount__c  ==null?0:objResolution.litify_pm__Settlement_Verdict_Amount__c ); 
        var totalVoidedAmount= component.get("v.resolutionWrapper.totalVoidedAmount");
        
        if(objPrebilledExpList.length>0){
            
            var writeOffAmount = component.get("v.resolutionWrapper.writeOffAmount");        
            
            var selectedUnbilledTotalAmount=0;
            var noOfSelectedItems = objPrebilledExpList.length;
            var noOfVoidBilled = component.get("v.resolutionWrapper.noOfVoidBilled");
            var noOfVoidUnBilled = component.get("v.resolutionWrapper.noOfVoidUnBilled");
            var newVoided=0;
            var totalVoidedAmount=0;
            
            for(var i=0;i<objPrebilledExpList.length;i++){
                var expense = objPrebilledExpList[i];
                selectedUnbilledTotalAmount = selectedUnbilledTotalAmount+ parseFloat(expense.Amount_after_Reductions__c);
                if(expense.Void__c){
                    totalVoidedAmount = parseFloat(totalVoidedAmount==null?0:totalVoidedAmount) + parseFloat(expense.Amount_after_Reductions__c);
                }
                
            }
            var totalPreBilledAmount = component.get("v.resolutionWrapper.totalPreBilledAmount");
            totalPreBilledAmount = parseFloat(totalPreBilledAmount) - selectedUnbilledTotalAmount;
            var totalExp= parseFloat(totalPreBilledAmount==undefined?0:totalPreBilledAmount);
            var firmDistribution =contigencyFee+totalExp-totalVoidedAmount-feeWrittenOff;
            
            if(settlementVerdict-firmDistribution-thirdPartyDistribution-totalDamages>0){
                clientDistribution= settlementVerdict-firmDistribution-thirdPartyDistribution-totalDamages;
            }
            else{
                clientDistribution=0;
            }
            
           /* if( (clientDistribution + firmDistribution +thirdPartyDistribution+totalDamages).toFixed(2) >settlementVerdict.toFixed(2)){
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Total Distributions exceed Settlement Amount",
                    "type": 'error'
                });
                toastEvent.fire();
                component.set("v.showSpinner",false);
            }*/
           // else{
                for(var i=0;i<objPrebilledExpList.length;i++){
                    var expense = objPrebilledExpList[i];
                    objUnbilledExpList.push(expense);
                    if(expense.Void__c){
                        newVoided++;
                        totalVoidedAmount= totalVoidedAmount+ parseFloat(expense.Amount_after_Reductions__c);
                    }
                    
                }
                
                
                
                /*objPrebilledExpList.sort(function(a,b){
                return new Date(b.litify_pm__Date__c) - new Date(a.litify_pm__Date__c);
            });*/
                objUnbilledExpList.sort((a, b) => (a.Name > b.Name) ? 1 : -1);
                
                
                component.set("v.resolutionWrapper.noOfVoidUnBilled",0);
                component.set("v.resolutionWrapper.noOfVoidBilled",parseInt(noOfVoidBilled)+newVoided);
                component.set("v.resolutionWrapper.billedAndPreBilledExpenses",component.get("v.resolutionWrapper.emptyExpenses"));        
                component.set("v.resolutionWrapper.unbilledExpenses",objUnbilledExpList);
                component.set("v.resolutionWrapper.totalVoidedAmount", totalVoidedAmount);
                
                
                if(totalPreBilledAmount!=null){
                    console.log(parseFloat(totalPreBilledAmount).toFixed(2));            
                    component.set("v.resolutionWrapper.totalPreBilledAmount",parseFloat(totalPreBilledAmount).toFixed(2));
                    
                }
                
                component.set("v.resolutionWrapper.balanceAmount",parseFloat(totalPreBilledAmount-writeOffAmount).toFixed(2));
                
                var noOfPreBilled = component.get("v.resolutionWrapper.noOfPreBilled");
                component.set("v.resolutionWrapper.noOfPreBilled",noOfPreBilled+ noOfSelectedItems);
                
                component.set("v.resolutionWrapper.noOfUnBilled",0);
                component.set("v.showSpinner",false);
            //}
            var chkBox = document.getElementById('selectBilledAll');
            chkBox.checked = false;
            
            
            
        }
         
         component.set("v.showSpinner",false);
         
     },
    
    handleUnBilledWriteOffSelect : function(component, event, helper) {  
        component.set("v.showSpinner",true);
        component.set("v.showSave",true);
        
        //helper.updateExpenseBillingStatus(component,'Unbilled',event);
        var objUnbilledWriteOffList= component.get("v.resolutionWrapper.unbilledWriteoffs");
        var expenseId =event.getSource().get('v.value');
        var writeOffAmount = component.get("v.resolutionWrapper.writeOffAmount");
        
        var objWriteOff;
        for(var i=0;i<objUnbilledWriteOffList.length;i++){
            if(objUnbilledWriteOffList[i].Id==expenseId){
                objWriteOff = objUnbilledWriteOffList[i];
                objUnbilledWriteOffList.splice(i,1);
                component.set("v.resolutionWrapper.unbilledWriteoffs",objUnbilledWriteOffList);
                break;
            }
        }
        writeOffAmount = parseFloat(writeOffAmount) + parseFloat(objWriteOff.Amount__c);
        component.set("v.resolutionWrapper.writeOffAmount",writeOffAmount.toFixed(2));
        
        var objPrebilledWriteOffList = component.get("v.resolutionWrapper.prebilledWriteoffs");
        objPrebilledWriteOffList.push(objWriteOff);
        
        objPrebilledWriteOffList.sort(function(a,b){
            return new Date(b.Date__c) - new Date(a.Date__c);
        });
        
        component.set("v.resolutionWrapper.prebilledWriteoffs",objPrebilledWriteOffList);
        
        var totalPreBilledAmount = component.get("v.resolutionWrapper.totalPreBilledAmount");
        
        component.set("v.resolutionWrapper.balanceAmount",parseFloat(totalPreBilledAmount-writeOffAmount).toFixed(2));
        
        var noOfPreBilled = component.get("v.resolutionWrapper.noOfPreBilledWriteOff");
        component.set("v.resolutionWrapper.noOfPreBilledWriteOff",noOfPreBilled+1);
        
        var noOfUnBilled = component.get("v.resolutionWrapper.noOfUnBilledWriteOff");
        component.set("v.resolutionWrapper.noOfUnBilledWriteOff",noOfUnBilled-1);
        component.set("v.showSpinner",false);
        
        
    },
    
    handleAllUnBilledWriteOffSelect : function(component, event, helper) {  
        component.set("v.showSpinner",true);
        
        var objUnbilledExpList= component.get("v.resolutionWrapper.unbilledWriteoffs");     
        var emptyUnbilledList = component.get("v.resolutionWrapper.unbilledWriteoffs");
        if(objUnbilledExpList.length>0){
            component.set("v.showSave",true);
            
            var writeOffAmount = component.get("v.resolutionWrapper.writeOffAmount");        
            var objPrebilledExpList = component.get("v.resolutionWrapper.prebilledWriteoffs");
            var selectedUnbilledTotalAmount=0;
            var noOfSelectedItems = objUnbilledExpList.length;
            for(var i=0;i<objUnbilledExpList.length;i++){
                var expense = objUnbilledExpList[i];
                selectedUnbilledTotalAmount = selectedUnbilledTotalAmount+ parseFloat(expense.Amount__c);
                objPrebilledExpList.push(expense);
                
            }
            objPrebilledExpList.sort(function(a,b){
                return new Date(b.Date__c) - new Date(a.Date__c);
            });
            
            component.set("v.resolutionWrapper.unbilledWriteoffs",component.get("v.resolutionWrapper.emptyExpenses"));        
            component.set("v.resolutionWrapper.prebilledWriteoffs",objPrebilledExpList);
            
            var totalPreBilledAmount = component.get("v.resolutionWrapper.totalPreBilledAmount");
            writeOffAmount = parseFloat(writeOffAmount) + selectedUnbilledTotalAmount;
            component.set("v.resolutionWrapper.writeOffAmount",parseFloat(writeOffAmount).toFixed(2));
            
            
            component.set("v.resolutionWrapper.balanceAmount",parseFloat(totalPreBilledAmount-writeOffAmount).toFixed(2));
            
            component.set("v.showSpinner",false);
            
            var chkBox = document.getElementById('selectUnbilledWriteOffAll');
            chkBox.checked = false;
            
            
            
        }
        
        component.set("v.showSpinner",false);
        
        
        
    },   
    
    handlePreBilledWriteOffSelect : function(component, event, helper) {
        component.set("v.showSpinner",true);
        component.set("v.showSave",true);
        var objUnbilledExpList= component.get("v.resolutionWrapper.unbilledWriteoffs");   
        var objPrebilledExpList = component.get("v.resolutionWrapper.prebilledWriteoffs");
        var expenseId =event.getSource().get('v.value');
        var writeOffAmount = component.get("v.resolutionWrapper.writeOffAmount");
        
        var objWriteOff;
        for(var i=0;i<objPrebilledExpList.length;i++){
            if(objPrebilledExpList[i].Id==expenseId){
                objWriteOff = objPrebilledExpList[i];
                objPrebilledExpList.splice(i,1);
                component.set("v.resolutionWrapper.prebilledWriteoffs",objPrebilledExpList);
                break;
            }
        }
        
        objUnbilledExpList.push(objWriteOff);
        objUnbilledExpList.sort(function(a,b){
            return new Date(b.Date__c) - new Date(a.Date__c);
        });
        
        component.set("v.resolutionWrapper.unbilledWriteoffs",objUnbilledExpList);
        writeOffAmount = parseFloat(writeOffAmount) - objWriteOff.Amount__c;
        
        var totalPreBilledAmount =  component.get("v.resolutionWrapper.totalPreBilledAmount");
        component.set("v.resolutionWrapper.writeOffAmount", parseFloat(writeOffAmount).toFixed(2));
        var balance = parseFloat(totalPreBilledAmount)-parseFloat(writeOffAmount);
        component.set("v.resolutionWrapper.balanceAmount",balance.toFixed(2));
        
        var noOfPreBilled = component.get("v.resolutionWrapper.noOfPreBilledWriteOff");
        component.set("v.resolutionWrapper.noOfPreBilledWriteOff",noOfPreBilled-1);
        
        var noOfUnBilled = component.get("v.resolutionWrapper.noOfUnBilledWriteOff");
        component.set("v.resolutionWrapper.noOfUnBilledWriteOff",noOfUnBilled+1);
        component.set("v.showSpinner",false);
        
        var chkBox = document.getElementById('selectUnbilledWriteOffAll');
        chkBox.checked = false;
        
    },
    
    
    handleWriteOnKeyPress : function(component, event, helper) {
        console.log(event.code);
        if(event.code=='Minus' || event.code=='NumpadSubtract'){
            event.preventDefault();
        }
        else{
            var objPrebilledExpList = component.get("v.resolutionWrapper.billedAndPreBilledExpenses");
            if(objPrebilledExpList.length>0){
                component.set("v.showSave",true);
            }
            
        }
    },
    
    handleWriteOffChange : function(component, event, helper) {
        
        if(component.get("v.resolutionWrapper")!=null && event.which != 45){
            var writeOffAmount = component.get("v.resolutionWrapper.writeOffAmount");
            var totalPreBillAmount = component.get("v.resolutionWrapper.totalPreBilledAmount");
            console.log(writeOffAmount);
            if(writeOffAmount!=null && writeOffAmount<0){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Invalid Amount.",
                    "type": 'error'
                });
                toastEvent.fire();
            }
            else if(parseFloat(writeOffAmount)> parseFloat(totalPreBillAmount)){
                var status= component.get("v.resolutionWrapper.objResolution.Statement_Status__c");
                if(status!='Final'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Amount written-off cannot be greater than total prebilled amount",
                        "type": 'error'
                    });
                    toastEvent.fire();
                }
                
            }
                else{
                    if(component.get("v.resolutionWrapper.objResolution.Statement_Status__c")!='Final'){
                        var balance = parseFloat(totalPreBillAmount)-parseFloat(writeOffAmount);
                        component.set("v.resolutionWrapper.balanceAmount",balance.toFixed(2));
                    }
                    
                    
                }
            
            
        }
        else{
            event.preventDefault();
        }
    },
    
    handleCancel : function(component, event, helper) {
        var isClassic=  component.get("v.isClassic");
        var resolutionId =component.get("v.recordId");
        if(isClassic){
            window.location='/'+resolutionId;
        }
        else{
            $A.get("e.force:closeQuickAction").fire();
        }
        
        
        
    },
    handleSave : function(component, event, helper){
        component.set("v.showConfirm",false);
        helper.saveResolution(component);
    },
    hideConfirmation : function(component, event, helper){
        component.set("v.showConfirm",false);
        component.set("v.showConfirmToSaveAndPrint",false);
    },
    showConfirmation : function(component, event, helper){
        component.set("v.showConfirm",true);
        
        
    },
    handlePrint : function(component, event, helper){
        if(component.get("v.showSave")==true){
            component.set("v.showConfirmToSaveAndPrint",true);            
        }
        else{            
            helper.saveAsPDF(component);            
            
        }
        
    },
    handleSaveAndPrint : function(component, event, helper){
        component.set("v.showConfirmToSaveAndPrint",false);
        helper.saveAndPrintResolution(component);
    },
    
})