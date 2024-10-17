/*
Author: Cmentor/Sampath Suranji
Date  : 11/04/2020
Description : splitExpenseController for splitExpense lightning component

Updated by: Cmentor/Sampath Suranji
Date  : 12/11/2020
Description : prevent creation of JE for Soft costs

Updated by:Impak/Dave Williams
Date: 12/22/2021
Description:  Added invoice number to the new expenses created to stop tripping validation rule
*/
public class splitExpenseController {
    @AuraEnabled
    public static splitExpenseWrapper getExpenseWrapper(string expenseId){
        splitExpenseWrapper objWrapper = new splitExpenseWrapper();
        try{
            List<litify_pm__Expense__c> listExpense = [select id,Amount_after_Reductions__c,litify_pm__lit_Reductions__c,name,Split_Expense__c,Void__c,Split_Parent__c,origin__c,litify_pm__Date__c,vendor__c,vendor__r.Name,litify_pm__Matter__c,litify_pm__Matter__r.Name,litify_pm__Amount__c, Billing_Status__c,litify_pm__ExpenseType2__c,litify_pm__ExpenseType2__r.Name,litify_pm__lit_Invoice__c,Payment_Date__c,Payment_Reference__c,litify_pm__Note__c
                                                       ,Expense_Category__c ,Invoice__c,Stage__c,Split_Reduction__c from litify_pm__Expense__c  where id=:expenseId];
            if(listExpense.size()>0){
                Aggregateresult arTotalAmountSplit = [select sum(litify_pm__Amount__c)totalAmount From litify_pm__Expense__c where Split_Parent__c=:expenseId and litify_pm__Amount__c>0];
                
                objWrapper.objExpense  = listExpense[0]; 
                //objWrapper.totalAmountSplit = (decimal)(arTotalAmountSplit.get('totalAmount')==null?0:arTotalAmountSplit.get('totalAmount'));
                objWrapper.objInvoiceLine = new splitExpenseWrapper.splitExpenseLineWrapper();        
                objWrapper.listInvoiceLines = new  list<splitExpenseWrapper.splitExpenseLineWrapper>();
                //objWrapper.amountLeft = listExpense[0].Amount_after_Reductions__c - objWrapper.totalAmountSplit;
                //objWrapper.amountLeft = listExpense[0].litify_pm__Amount__c - (listExpense[0].litify_pm__lit_Reductions__c==null?0:listExpense[0].litify_pm__lit_Reductions__c)- objWrapper.totalAmountSplit;
                
                objWrapper.amountLeft = listExpense[0].Amount_after_Reductions__c;
                system.debug('objWrapper.amountLeft '+objWrapper.amountLeft);
                List<AcctSeed__Account_Payable_Line__c>listPayableLine = [select id, Split_Expense__c,expense__c,AcctSeed__Account_Payable__r.AcctSeed__Payment_Status__c,AcctSeed__Account_Payable__r.AcctSeed__Status__c from AcctSeed__Account_Payable_Line__c where expense__c=:expenseId];
                if(listPayableLine.size()>0){
                    objWrapper.objPayableLine =listPayableLine[0];
                }
                list<AcctSeed__Journal_Entry_Line__c>listJELine =[select id,Split_Expense__c,AcctSeed__Journal_Entry__r.AcctSeed__Status__c from AcctSeed__Journal_Entry_Line__c  where expense__c=:expenseId ];
                if(listJELine.size()>0){
                    objWrapper.objJELine =listJELine[0];
                }
            }
        }
        catch(Exception ex){}
        return objWrapper;
    }
    
    @AuraEnabled
    public static map<string,string> saveExpenseDetails(string expenseId, splitExpenseWrapper objExpenseWrapper){
        savepoint sp;
        map<string,string> msgMap = new map<string,string>();  
        try{
            list<AcctSeed__Journal_Entry_Line__c>  listJELinesToInsert = new  list<AcctSeed__Journal_Entry_Line__c>();
            map<string,string> mapMatters = new map<string,string>();
            map<string,string> mapMatterWithProject = new map<string,string>(); 
            map<string,string> mapMatterIdWithLocName = new map<string,string>();
            map<string,string> mapMatterIdWithServiceLine = new map<string,string>();
            map<string,string> mapMatterIdWithAttorney = new map<string,string>();
            map<string,string> mapGLVarNameWithId = new map<string,string>();
            map<string,string> mapGLAccounts = new map<string,string>(); 
            boolean createJE =false;
            
            if(objExpenseWrapper.listInvoiceLines.size()>0){
                list<litify_pm__Expense__c>listExpenseToInsert = new   list<litify_pm__Expense__c>();
                decimal totalSplit=0;
                sp = database.setSavepoint();
                
                list<Split_Expenses_GL_Accounts__c> listGLSettings = [select Credit_GL_Account__c,Debit_GL_Account__c from Split_Expenses_GL_Accounts__c];
                if(listGLSettings.size()<1){
                    msgMap.put('invalidCustomSetting','true');
                    return msgMap;
                }
                List<AcctSeed__GL_Account__c>listGL = [select id,name from AcctSeed__GL_Account__c where name = :listGLSettings[0].Credit_GL_Account__c OR name = :listGLSettings[0].Debit_GL_Account__c];
                if(listGL.size()<2 && listGLSettings[0].Credit_GL_Account__c!= listGLSettings[0].Debit_GL_Account__c){
                    msgMap.put('invalidGLDefined','true');
                    return msgMap;
                } 
                if(listGL.size()<1 && listGLSettings[0].Credit_GL_Account__c== listGLSettings[0].Debit_GL_Account__c){
                    msgMap.put('invalidGLDefined','true');
                    return msgMap;
                } 
                for(AcctSeed__GL_Account__c objGl:listGL){
                    if(objGl.name==listGLSettings[0].Credit_GL_Account__c){
                        mapGLAccounts.put('creditGL',objGl.id);
                    }
                    if(objGl.name==listGLSettings[0].Debit_GL_Account__c){
                        mapGLAccounts.put('debitGL',objGl.id);
                    }
                }
                
                List<litify_pm__Expense__c> listParentExpense = [select id,name,origin__c,Expense_Category__c from litify_pm__Expense__c  where id=:expenseId];
                if(listParentExpense[0].Expense_Category__c=='Hard Cost'){
                    createJE=true;
                }
                set<id>setMatterIds = new set<id>();
                setMatterIds.add(objExpenseWrapper.objExpense.litify_pm__Matter__c);
                for(splitExpenseWrapper.splitExpenseLineWrapper invLine:objExpenseWrapper.listInvoiceLines ){
                    setMatterIds.add(invLine.matterId);
                }
                if(setMatterIds.size()>0){
                    for(litify_pm__Matter__c objMatter :[select id,litify_pm__Primary_Intake__r.Originating_Office__c,Name,litify_pm__Case_Type__r.Service_Line__c,litify_pm__Principal_Attorney__r.alias from litify_pm__Matter__c where id in:setMatterIds]){
                        mapMatterIdWithLocName.put(objMatter.Id,objMatter.litify_pm__Primary_Intake__r.Originating_Office__c);
                        mapMatterIdWithServiceLine.put(objMatter.Id,objMatter.litify_pm__Case_Type__r.Service_Line__c);
                        mapMatterIdWithAttorney.put(objMatter.Id,objMatter.litify_pm__Principal_Attorney__r.alias);
                        mapMatters.put(objMatter.Id,objMatter.Name);
                    }
                    for(AcctSeed__Project__c objProject : [select id,Matter__c from  AcctSeed__Project__c where Matter__c in:setMatterIds]){
                        mapMatterWithProject.put(objProject.Matter__c,objProject.id);
                    }
                }
                for(id matterId:setMatterIds){
                    if(!mapMatterWithProject.containskey(matterId)){
                        msgMap.put('invalidProject','true');
                        msgMap.put('invalidMatterWithProject',mapMatters.get(matterId));
                        return msgMap;
                    }
                }
                for(AcctSeed__Accounting_Variable__c variable :[select id,name,AcctSeed__Type__c from AcctSeed__Accounting_Variable__c where (AcctSeed__Type__c ='GL Account Variable 3' OR AcctSeed__Type__c ='GL Account Variable 2' OR AcctSeed__Type__c ='GL Account Variable 1'  OR AcctSeed__Type__c ='GL Account Variable 4')  
                                                                AND (name in:mapMatterIdWithLocName.values() OR name in:mapMatterIdWithAttorney.values() OR name in:mapMatterIdWithServiceLine.values())]){
                                                                    mapGLVarNameWithId.put(variable.name,variable.Id);
                                                                }
                
                AcctSeed__Journal_Entry__c objJE = new AcctSeed__Journal_Entry__c();
                if(createJE){
                    
                    objJE.name = 'Split Expenses /'+objExpenseWrapper.objExpense.Name+' /' +system.now().format('yyyy-MM-dd HH:mm');
                    
                    if(system.test.isRunningTest()){
                        List<AcctSeed__Ledger__c>listLeder = [select id from AcctSeed__Ledger__c where  AcctSeed__Type__c = 'Transactional'];
                        objJE.AcctSeed__Ledger__c = listLeder[0].id;
                    }
                    insert objJE;
                }
                for(splitExpenseWrapper.splitExpenseLineWrapper invLine:objExpenseWrapper.listInvoiceLines ){
                    totalSplit = totalSplit + invLine.amount;
                    litify_pm__Expense__c objExpense = new litify_pm__Expense__c();                    
                    objExpense.litify_pm__Amount__c = invLine.amount;
                    objExpense.litify_pm__Matter__c = invLine.matterId;
                    /*  DPW added these fields to the split expense object */
                    objExpense.litify_pm__lit_Invoice__c = objExpenseWrapper.objExpense.litify_pm__lit_Invoice__c;
                    objExpense.litify_pm__Note__c = 'Split from Expense: '+objExpenseWrapper.objExpense.Name;
                    objExpense.Payment_Date__c = objExpenseWrapper.objExpense.Payment_Date__c;
                    objExpense.Payment_Reference__c = objExpenseWrapper.objExpense.Payment_Reference__c;
                    /*  DPW end edits */
                    objExpense.Origin__c = objExpenseWrapper.objExpense.Origin__c; //'Litify-Split';
                    objExpense.Billing_Status__c ='Unbilled';
                    objExpense.Split_Parent__c = expenseId;
                    if(objExpenseWrapper.objExpense.litify_pm__ExpenseType2__c!=null){
                        objExpense.litify_pm__ExpenseType2__c= objExpenseWrapper.objExpense.litify_pm__ExpenseType2__c;
                    }
                    
                    objExpense.litify_pm__Date__c = system.Date.today(); 
                    if(objExpenseWrapper.objPayableLine!=null){
                        objExpense.Payable_Line__c= objExpenseWrapper.objPayableLine.Id;                        
                    }
                    else if(objExpenseWrapper.objJELine!=null){
                        // objExpense.Journal_Entry_Line__c= objExpenseWrapper.objJELine.Id;
                    }
                    objExpense.Vendor__c = objExpenseWrapper.objExpense.Vendor__c;
                    objExpense.Stage__c ='Approved';
                    
                    //Updated at 12/14/2020 Hard cost>> Approved Soft Cost>> NA
                    if(objExpenseWrapper.objExpense.Expense_Category__c=='Hard Cost'){
                        objExpense.Stage__c='Approved';
                    }
                    else if(objExpenseWrapper.objExpense.Expense_Category__c=='Soft Cost'){
                        objExpense.Stage__c='N/A';
                    }
                    objExpense.Invoice__c = objExpenseWrapper.objExpense.Invoice__c;
                    listExpenseToInsert.add(objExpense);
                    
                    if(createJE){
                        //Create Debit JE line for each
                        AcctSeed__Journal_Entry_Line__c objJEDebitLine= new AcctSeed__Journal_Entry_Line__c();
                        objJEDebitLine.AcctSeed__Debit__c = invLine.amount;
                        objJEDebitLine.AcctSeed__Date__c = system.Date.today();
                        objJEDebitLine.AcctSeed__GL_Account__c = mapGLAccounts.get('debitGL');
                        objJEDebitLine.AcctSeed__Journal_Entry__c = objJE.Id;
                        objJEDebitLine.Case_Cost__c =true;
                        if(mapMatterWithProject.containskey(invLine.matterId)){
                            objJEDebitLine.AcctSeed__Project__c =mapMatterWithProject.get(invLine.matterId);
                        }
                        if(mapMatterIdWithLocName.containskey(invLine.matterId)){
                            if(mapGLVarNameWithId.containskey(mapMatterIdWithLocName.get(invLine.matterId))){
                                objJEDebitLine.AcctSeed__GL_Account_Variable_2__c = mapGLVarNameWithId.get(mapMatterIdWithLocName.get(invLine.matterId));
                            }
                        }
                        if(mapMatterIdWithServiceLine.containskey(invLine.matterId)){
                            if(mapGLVarNameWithId.containskey(mapMatterIdWithServiceLine.get(invLine.matterId))){
                                objJEDebitLine.AcctSeed__GL_Account_Variable_1__c = mapGLVarNameWithId.get(mapMatterIdWithServiceLine.get(invLine.matterId));
                            }
                        }
                        if(mapMatterIdWithAttorney.containskey(invLine.matterId)){
                            if(mapGLVarNameWithId.containskey(mapMatterIdWithAttorney.get(invLine.matterId))){
                                objJEDebitLine.AcctSeed__GL_Account_Variable_4__c = mapGLVarNameWithId.get(mapMatterIdWithAttorney.get(invLine.matterId));
                            }
                        }
                        
                        listJELinesToInsert.add(objJEDebitLine);
                    }
                }
                
                if(objExpenseWrapper.objPayableLine!=null){
                    objExpenseWrapper.objPayableLine.Split_Expense__c=true;
                    update objExpenseWrapper.objPayableLine;
                }
                if(objExpenseWrapper.objJELine!=null){
                    objExpenseWrapper.objJELine.Split_Expense__c=true;
                    update objExpenseWrapper.objJELine;
                }
                
                
                if(totalSplit>0 &&  createJE){
                    
                    //one Credit line for total split
                    AcctSeed__Journal_Entry_Line__c objJECreditLine= new AcctSeed__Journal_Entry_Line__c();
                    objJECreditLine.AcctSeed__Credit__c = totalSplit;
                    objJECreditLine.AcctSeed__Date__c = system.Date.today();
                    objJECreditLine.AcctSeed__GL_Account__c = mapGLAccounts.get('creditGL');
                    //objJEDebitLine.AcctSeed__Reference__c = invLine.comments;
                    objJECreditLine.AcctSeed__Journal_Entry__c = objJE.Id;
                    objJECreditLine.Case_Cost__c =true;
                    if(mapMatterWithProject.containskey(objExpenseWrapper.objExpense.litify_pm__Matter__c)){
                        objJECreditLine.AcctSeed__Project__c =mapMatterWithProject.get(objExpenseWrapper.objExpense.litify_pm__Matter__c);
                    }
                    if(mapMatterIdWithAttorney.containskey(objExpenseWrapper.objExpense.litify_pm__Matter__c)){
                        if(mapGLVarNameWithId.containskey(mapMatterIdWithAttorney.get(objExpenseWrapper.objExpense.litify_pm__Matter__c))){
                            objJECreditLine.AcctSeed__GL_Account_Variable_4__c = mapGLVarNameWithId.get(mapMatterIdWithAttorney.get(objExpenseWrapper.objExpense.litify_pm__Matter__c));
                        }
                    }
                    if(mapMatterIdWithLocName.containskey(objExpenseWrapper.objExpense.litify_pm__Matter__c)){
                        if(mapGLVarNameWithId.containskey(mapMatterIdWithLocName.get(objExpenseWrapper.objExpense.litify_pm__Matter__c))){
                            objJECreditLine.AcctSeed__GL_Account_Variable_2__c = mapGLVarNameWithId.get(mapMatterIdWithLocName.get(objExpenseWrapper.objExpense.litify_pm__Matter__c));
                        }
                    }
                    if(mapMatterIdWithServiceLine.containskey(objExpenseWrapper.objExpense.litify_pm__Matter__c)){
                        if(mapGLVarNameWithId.containskey(mapMatterIdWithServiceLine.get(objExpenseWrapper.objExpense.litify_pm__Matter__c))){
                            objJECreditLine.AcctSeed__GL_Account_Variable_1__c = mapGLVarNameWithId.get(mapMatterIdWithServiceLine.get(objExpenseWrapper.objExpense.litify_pm__Matter__c));
                        }
                    }
                    
                    
                    listJELinesToInsert.add(objJECreditLine);
                    
                }
                
                insert listExpenseToInsert;
               // list<litify_pm__Expense__c>listInsertedExp = [select id,Journal_Entry_Line__c from litify_pm__Expense__c where id in:listExpenseToInsert ];
                
                integer JELinesTotal=0;
                if(createJE){
                    insert listJELinesToInsert;
                    JELinesTotal = listJELinesToInsert.size()-1;
                    for(integer i=0;i< JELinesTotal;i++){
                        listJELinesToInsert[i].Expense__c = listExpenseToInsert[i].Id;
                        listExpenseToInsert[i].Journal_Entry_Line__c  =listJELinesToInsert[i].Id;
                    }
                    update listJELinesToInsert;
                }
                
                
                //Create Exp Adjustment record
                Expense_Adjustment__c objAdjustment = new Expense_Adjustment__c();
                objAdjustment.Amount__c = totalSplit;
                objAdjustment.Expense__c = objExpenseWrapper.objExpense.Id;
                if(createJE){
                    objAdjustment.Journal_Entry_Line__c = listJELinesToInsert[JELinesTotal].Id;
                }
                objAdjustment.Adjustment_Type__c ='Split';
                insert objAdjustment;
                
                objExpenseWrapper.objExpense.Split_Expense__c=true;               
                objExpenseWrapper.objExpense.Split_Reduction__c =  (objExpenseWrapper.objExpense.Split_Reduction__c==null?0:objExpenseWrapper.objExpense.Split_Reduction__c) + totalSplit;
                
                listExpenseToInsert.add(objExpenseWrapper.objExpense);
                //listInsertedExp.add(objExpenseWrapper.objExpense);
                //below update will override the logic place in Expense before insert trigger
                update listExpenseToInsert;
                //update listInsertedExp;
                msgMap.put('success','true');
            }
        }
        catch(Exception ex){
            if(sp!=null){
                database.rollback(sp);
                msgMap.put('error','true');
            }
        }
        return msgMap;
    }
    
}