/*
Author: Cmentor/ Sampath Suranji
Date   : 06/02/2020
Description : costRecoveryController for Cost recovery Screen in Resolution

Updated by : 4Converge/Dave Williams
Date       : 10/5/2024
Description: Revisions for using Balance_Due__c on Damages instead of managed field Amount_Due__c
*/
public without sharing class costRecoveryController {
    @AuraEnabled
    public static resolutionExpensesWrapper getAllRecords(string resolutionId){
        System.debug('resolutionId '+resolutionId);
        
        try{
            
            string matterId='';
            List<litify_pm__Resolution__c> listResolution =[select id,name,Status__c,litify_pm__Matter__c,litify_pm__Matter__r.Name,litify_pm__Matter__r.litify_pm__Display_Name__c,Firm_Distribution__c,litify_pm__Total_Damages__c,Third_Party_Distributions__c,Client_Distribution__c,
                                                            Total_Liens__c, litify_pm__Settlement_Verdict_Amount__c,litify_pm__Total_Expenses__c ,Contingency_Fee__c ,Voided_Hard_Costs__c,Voided_Soft_Costs__c , Fees_Written_Off__c
                                                            from litify_pm__Resolution__c where id=:resolutionId];
            if(listResolution.size()>0){
                
                matterId = listResolution[0].litify_pm__Matter__c;
                //consider as Billed/Pre-Billed
                List<litify_pm__Expense__c> listBilledPrebilled = [select id,name,litify_pm__Date__c,litify_pm__Matter__c,litify_pm__Matter__r.Name,litify_pm__Amount__c,Amount_after_Reductions__c, Expense_Category__c,Billing_Status__c,Resolution__c,litify_pm__ExpenseType2__c,litify_pm__ExpenseType2__r.Name ,Void__c,Resolution__r.Name
                    from litify_pm__Expense__c  where litify_pm__Matter__c=:matterId and (Billing_Status__c='Pre-Billed' OR Billing_Status__c='Billed' )  and Resolution__c= :resolutionId   order by name];

                List<litify_pm__Expense__c> listRecovered = [select id,name,litify_pm__Date__c,litify_pm__Matter__c,litify_pm__Matter__r.Name,litify_pm__Amount__c,Amount_after_Reductions__c, Expense_Category__c,Billing_Status__c,Resolution__c,litify_pm__ExpenseType2__c,litify_pm__ExpenseType2__r.Name ,Void__c,Resolution__r.Name
                    from litify_pm__Expense__c  where litify_pm__Matter__c=:matterId and (Billing_Status__c='Pre-Billed' OR Billing_Status__c='Billed' )  and Resolution__c!= :resolutionId   order by name];

                List<litify_pm__Expense__c> listUnbilled = [select id,name,litify_pm__Date__c,litify_pm__Matter__c,litify_pm__Matter__r.Name,litify_pm__Amount__c,Amount_after_Reductions__c,Expense_Category__c,Billing_Status__c,Resolution__c,litify_pm__ExpenseType2__c,litify_pm__ExpenseType2__r.Name,Void__c,Resolution__r.Name
                    from litify_pm__Expense__c where litify_pm__Matter__c=:matterId  and (Billing_Status__c='Unbilled' OR Billing_Status__c='') AND (Stage__c='Approved' OR Stage__c='N/A' OR Stage__c='N/A-SoftCost' OR Stage__c='N/A-File')   order by name];
                
                List<litify_pm__Expense__c> listBilled = [select id,name,litify_pm__Date__c,litify_pm__Matter__c,litify_pm__Matter__r.Name,litify_pm__Amount__c,Amount_after_Reductions__c,Expense_Category__c,Billing_Status__c,Resolution__c,litify_pm__ExpenseType2__c ,litify_pm__ExpenseType2__r.Name,Void__c,Resolution__r.Name
                    from litify_pm__Expense__c where litify_pm__Matter__c=:matterId and Billing_Status__c='Billed'   and Resolution__c= :resolutionId   order by name];
                
                //If need, we can remove below multiple aggregations>> get two lists(one from filter by Resolution and other filter by Matter) then loop each and based on the if conditions 
                //can calculate below total amounts, but it'll cause performance issues since we can have hundreds of expenses for a given matter
                AggregateResult ARDamage = [select sum(Balance_Due__c)totalAmount from litify_pm__Damage__c where Resolution__c=:resolutionId];
                
                AggregateResult ARBilledPreBilled = [select sum(Amount_after_Reductions__c)totalAmount from litify_pm__Expense__c where Resolution__c=:resolutionId and (Billing_Status__c='Pre-Billed' OR Billing_Status__c='Billed' ) ];
                
                AggregateResult ARBilled = [select sum(Amount_after_Reductions__c)totalAmount from litify_pm__Expense__c where Resolution__c=:resolutionId and Billing_Status__c='Billed' ];
                
                AggregateResult ARVoidBilledPreBilledCount = [select count(Amount_after_Reductions__c)total from litify_pm__Expense__c where Resolution__c=:resolutionId and (Billing_Status__c='Billed' or Billing_Status__c='Pre-Billed')   and Void__c=true ];
                
                AggregateResult ARVoidUnBilled = [select count(Amount_after_Reductions__c)total from litify_pm__Expense__c where litify_pm__Matter__c=:matterId and Billing_Status__c='Unbilled'  and Void__c=true ];
                
                AggregateResult ARVoided = [select sum(Amount_after_Reductions__c)totalAmount from litify_pm__Expense__c where litify_pm__Matter__c=:matterId and  Void__c=true AND (Stage__c='Approved' OR Stage__c='N/A' OR Stage__c='N/A-SoftCost' OR Stage__c='N/A-File')];
                
                AggregateResult ARVoidBilledPreBilled = [select sum(Amount_after_Reductions__c)totalAmount from litify_pm__Expense__c where Resolution__c=:resolutionId and (Billing_Status__c='Billed' or Billing_Status__c='Pre-Billed')   and Void__c=true ];
                
                AggregateResult ARUnapproved = [select count(id)total from litify_pm__Expense__c where litify_pm__Matter__c=:matterId  and (Stage__c='In-Process' or Stage__c='Pending Approval')];
                
                resolutionExpensesWrapper objWrapper = new resolutionExpensesWrapper();//(listUnbilled,listBilledPrebilled);
                objWrapper.unbilledExpenses = listUnbilled;
                objWrapper.preBilledExpenses = listBilledPrebilled;
                /* objWrapper.onOtherResolution = listRecovered; */
                objWrapper.billedAndPreBilledExpenses = listBilledPrebilled;
                objWrapper.emptyExpenses = new  List<litify_pm__Expense__c>();
                
                if(listBilled.size()>0){
                    objWrapper.billedExpenses =listBilled;
                }
                if(listResolution.size()>0){
                    objWrapper.objResolution =listResolution[0];
                    //objWrapper.matterName = listResolution[0].litify_pm__Matter__r.Name;
                    // objWrapper.matterDisplayName = listResolution[0].litify_pm__Matter__r.litify_pm__Display_Name__c;
                }
                objWrapper.totalPreBilledAmount =  (decimal) ARBilledPreBilled.get('totalAmount')==null? 0 : ((decimal) ARBilledPreBilled.get('totalAmount')).setScale(2) ;
                
                objWrapper.totalBilledAmount =  (decimal) ARBilled.get('totalAmount')==null? 0 : ((decimal) ARBilled.get('totalAmount')).setScale(2) ;
                
                objWrapper.totalVoidedAmount=  ((decimal) ARVoidBilledPreBilled.get('totalAmount'))==null? 0 : ((decimal) ARVoidBilledPreBilled.get('totalAmount')).setScale(2) ;
                
                //objWrapper.totalDamagedAmount =  (decimal) ARDamage.get('totalAmount')==null? 0 : ((decimal) ARDamage.get('totalAmount')).setScale(2) ;
                objWrapper.totalDamagedAmount = listResolution[0].litify_pm__Total_Damages__c;
                
                objWrapper.noOfUnapproved =  (decimal) ARUnapproved.get('total')==null? 0 : ((decimal) ARUnapproved.get('total')).setScale(2) ;
                
                
                //Update totdal Damage Amount in resolution
                listResolution[0].litify_pm__Total_Damages__c = objWrapper.totalDamagedAmount;
                Update listResolution[0];
                
                objWrapper.noOfVoidUnBilled=  ((decimal) ARVoidUnBilled.get('total'))==null? 0 : ((decimal) ARVoidUnBilled.get('total')).setScale(2) ;
                objWrapper.noOfVoidBilled=  ((decimal) ARVoidBilledPreBilledCount.get('total'))==null? 0 : ((decimal) ARVoidBilledPreBilledCount.get('total')).setScale(2) ;
                
                return objWrapper;
            }
            
        }
        catch(Exception ex){}
        return null;
    }
    
    
    @AuraEnabled
    public static resolutionExpensesWrapper updateExpenseBillingStatus(string resolutionId,string expenseId, string billingStatus ){
        
        try{
            List<litify_pm__Expense__c> listResolution = [select id,name,litify_pm__Date__c,litify_pm__Matter__c,litify_pm__Amount__c,Amount_after_Reductions__c,Resolution__r.Name
            from litify_pm__Expense__c where id=:expenseId  limit 1];
            if(listResolution.size()>0){
                if(billingStatus=='Unbilled'){
                    listResolution[0].Billing_Status__c = 'Pre-Billed';
                }
                else{
                    listResolution[0].Billing_Status__c = 'Unbilled';
                }
                
                update listResolution[0];
                
                resolutionExpensesWrapper objWrapper = getAllRecords(resolutionId);
                return objWrapper;
            }
            
        }
        catch(Exception ex){}
        return null;
    }
    
    @AuraEnabled
    public static map<string,string> saveResolution(string resolutionId,resolutionExpensesWrapper objWrapper ){
        Savepoint sp;
        map<string,string> mapMsg = new map<string,string>();
        try{
            List<litify_pm__Resolution__c> listResolution =[select id,litify_pm__Matter__c,litify_pm__Matter__r.Name,litify_pm__Matter__r.litify_pm__Display_Name__c,litify_pm__Total_Expenses__c from litify_pm__Resolution__c where id=:resolutionId];
            if(listResolution.size()>0){
                string matterId = listResolution[0].litify_pm__Matter__c;
                decimal totalSoftCost=0,totalHardCost=0,totalVoidedSoftCost=0,totalVoidedHardCost=0;
                sp= database.setSavepoint();
                List<litify_pm__Expense__c> listExpenseToUpdate = new   List<litify_pm__Expense__c>();
                
                for(litify_pm__Expense__c  prebilledExpense : objWrapper.billedAndPreBilledExpenses){
                    system.debug('Expense_Category__c '+prebilledExpense.Expense_Category__c );
                    if(prebilledExpense.Billing_Status__c != 'Pre-Billed'){
                        prebilledExpense.Billing_Status__c = 'Pre-Billed';
                        prebilledExpense.Resolution__c = resolutionId;
                        listExpenseToUpdate.add(prebilledExpense);
                        
                    }
                    if(prebilledExpense.Expense_Category__c=='Hard Cost'){
                        totalHardCost= totalHardCost+ prebilledExpense.Amount_after_Reductions__c;
                        if(prebilledExpense.Void__c){
                            totalVoidedHardCost  = totalVoidedHardCost+ prebilledExpense.Amount_after_Reductions__c;
                        }
                    }
                    else if(prebilledExpense.Expense_Category__c=='Soft Cost'){
                        totalSoftCost= totalSoftCost+ prebilledExpense.Amount_after_Reductions__c;
                        if(prebilledExpense.Void__c){
                            totalVoidedSoftCost = totalVoidedSoftCost+ prebilledExpense.Amount_after_Reductions__c;
                        }
                    }
                    
                }
                
                
                for(litify_pm__Expense__c  unbilledExpense : objWrapper.unbilledExpenses){
                    if(  unbilledExpense.Billing_Status__c == 'Pre-Billed'){
                        unbilledExpense.Billing_Status__c = 'Unbilled';
                        unbilledExpense.Resolution__c = null;
                        listExpenseToUpdate.add(unbilledExpense);
                    }
                    
                }
                
                
                if(listExpenseToUpdate.size()>0){
                    update listExpenseToUpdate;
                }                
                
                if(objWrapper.totalPreBilledAmount!=null){
                    listResolution[0].litify_pm__Total_Expenses__c = decimal.valueOf( objWrapper.totalPreBilledAmount);
                }
                listResolution[0].Soft_Costs__c= totalSoftCost;
                listResolution[0].Hard_Costs__c= totalHardCost;
                listResolution[0].Voided_Soft_Costs__c =totalVoidedSoftCost;
                listResolution[0].Voided_Hard_Costs__c =totalVoidedHardCost;
                update listResolution[0];
                 mapMsg.put('success','true');
            }
            
            
        }
        catch(Exception ex){
            if(sp!=null){
                database.rollback(sp);
            }
            mapMsg.put('error','true');
        }
        return mapMsg;
    }
    
    @AuraEnabled
    public static void savePdf(string resolutionId){
        try{
            List<litify_pm__Resolution__c> listResolution =[select id,Name,litify_pm__Matter__c,litify_pm__Matter__r.Name from litify_pm__Resolution__c where id=:resolutionId];
            if(listResolution.size()>0){
                
                List<Attachment>attachmentToInsert = new List<Attachment>();
                PageReference objPdfStatement =  page.clientStatementPDF;
                objPdfStatement.getParameters().put('id',resolutionId);            
                
                Blob pdfStatementBlob;
                if(system.Test.isRunningTest()){
                    pdfStatementBlob = blob.valueOf('test');
                }
                else{
                    pdfStatementBlob = objPdfStatement.getContent();
                }
                
                Attachment objAttachment = new Attachment();
                objAttachment.Name ='EXP_'+listResolution[0].Name+'_'+ system.Datetime.now().format('MM-dd-yyyy HH:mm:ss')+'.pdf';
                objAttachment.Body = pdfStatementBlob;            
                objAttachment.IsPrivate = false;
                objAttachment.ParentId = resolutionId;
                attachmentToInsert.add(objAttachment); 
                
                insert attachmentToInsert;
            }
        }
        catch(Exception ex){}
    }
    
    @AuraEnabled
    public static void saveResolutionAndPdf(string resolutionId,resolutionExpensesWrapper objWrapper ){
        Savepoint sp;
        try{
            List<litify_pm__Resolution__c> listResolution =[select id,Name,litify_pm__Matter__c,litify_pm__Matter__r.Name,litify_pm__Total_Expenses__c from litify_pm__Resolution__c where id=:resolutionId];
            if(listResolution.size()>0){
                string matterId = listResolution[0].litify_pm__Matter__c;                
                decimal totalSoftCost=0,totalHardCost=0,totalVoidedSoftCost=0,totalVoidedHardCost=0;
                List<litify_pm__Expense__c> listExpenseToUpdate = new   List<litify_pm__Expense__c>();
                
                for(litify_pm__Expense__c  prebilledExpense : objWrapper.billedAndPreBilledExpenses){
                    system.debug('Billing_Status__c '+prebilledExpense.Billing_Status__c );
                    if(prebilledExpense.Billing_Status__c != 'Pre-Billed'){
                        prebilledExpense.Billing_Status__c = 'Pre-Billed';
                        prebilledExpense.Resolution__c = resolutionId;
                        listExpenseToUpdate.add(prebilledExpense);
                        
                    }
                    
                    if(prebilledExpense.Expense_Category__c=='Hard Cost'){
                        totalHardCost= totalHardCost+ prebilledExpense.Amount_after_Reductions__c;
                        if(prebilledExpense.Void__c){
                            totalVoidedHardCost  = totalVoidedHardCost+ prebilledExpense.Amount_after_Reductions__c;
                        }
                    }
                    else if(prebilledExpense.Expense_Category__c=='Soft Cost'){
                        totalSoftCost= totalSoftCost+ prebilledExpense.Amount_after_Reductions__c;
                        if(prebilledExpense.Void__c){
                            totalVoidedSoftCost = totalVoidedSoftCost+ prebilledExpense.Amount_after_Reductions__c;
                        }
                    }
                    
                }
                
                
                for(litify_pm__Expense__c  unbilledExpense : objWrapper.unbilledExpenses){
                    if( unbilledExpense.Billing_Status__c != 'Unbilled' && unbilledExpense.Billing_Status__c == 'Pre-Billed'){
                        unbilledExpense.Billing_Status__c = 'Unbilled';
                        unbilledExpense.Resolution__c = null;
                        listExpenseToUpdate.add(unbilledExpense);
                    }
                    
                }
                
                sp=database.setSavepoint();                
                if(listExpenseToUpdate.size()>0){
                    update listExpenseToUpdate;
                }
                
                if(objWrapper.totalPreBilledAmount!=null){
                    listResolution[0].litify_pm__Total_Expenses__c =objWrapper.totalPreBilledAmount;
                }
                listResolution[0].Soft_Costs__c= totalSoftCost;
                listResolution[0].Hard_Costs__c= totalHardCost;
                listResolution[0].Voided_Soft_Costs__c =totalVoidedSoftCost;
                listResolution[0].Voided_Hard_Costs__c =totalVoidedHardCost;
                //update listResolution[0];
                
                Database.SaveResult [] Srlist = database.update(listResolution);
                attchPdf(resolutionId);
                for(Database.SaveResult sr: Srlist){
                    if(sr.isSuccess()){
                        List<litify_pm__Resolution__c> listInsertedResolution =[select id,litify_pm__Matter__c,litify_pm__Matter__r.Name from litify_pm__Resolution__c where id=:resolutionId];
                        system.debug('listInsertedResolution '+listInsertedResolution);
                        
                        // List<Attachment>attachmentToInsert = new List<Attachment>();
                        
                    }
                }
                
                
                
            }
            
            
            
            
            
        }
        catch(Exception ex){
            if(sp!=null){
                database.rollback(sp);
            }
        }
        
    }
    
    @Future(callout=true)
    public static void attchPdf(string resolutionId){
        try{
            List<litify_pm__Resolution__c> listResolution =[select id,Name,litify_pm__Matter__c,litify_pm__Matter__r.Name,litify_pm__Total_Expenses__c from litify_pm__Resolution__c where id=:resolutionId];
            
            Attachment objAttachment = new Attachment();
            
            PageReference objPdfStatement =  page.clientStatementPDF;
            objPdfStatement.getParameters().put('Id',resolutionId);            
            Blob pdfStatementBlob;
            if(system.Test.isRunningTest()){
                pdfStatementBlob = blob.valueOf('test');
            }
            else{
                pdfStatementBlob = objPdfStatement.getContent();
            }
            
            objAttachment.Name ='EXP_'+listResolution[0].Name+'_'+ system.Datetime.now().format('MM-dd-yyyy HH:mm:ss')+'.pdf';
            objAttachment.Body = pdfStatementBlob;            
            objAttachment.IsPrivate = false;
            objAttachment.ParentId = resolutionId;
            //attachmentToInsert.add(objAttachment); 
            
            insert objAttachment;
        }
        catch(Exception ex){}
    }
    
}