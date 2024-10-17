/*
Author: Cmentor/Sampath Suranji
Date   :06/12/2020
Description: closingStatementPdfController for closing statement pdf

Updated By: Cmentor/ Sampath Suranji
Date      : 10/12/2020
Description : Set vendor from AlternatePayee for payables for each Damages and Liens

Updated By : AllenLaw/Dave Williams
Date       : 9/28/2021
Description: Added a couple new fields to this controller for layout changes in Rough/Final

Updated By : AllenLaw/Dave Williams
Date       : 9/27/2022
Description: Revisions to header and all sections as per project notes from ELA/KBH from meeting with GDG/JSW

Updated by : 4Converge/Dave Williams
Date       : 10/5/2024
Description: Revisions for using Balance_Due__c on Damages instead of managed field Amount_Due__c
*/
public class closingStatementPdfController {

    public statementWrapper objWrapper {get;set;}
    public string currentDate{get;set;}
    public string statementType{get;set;}

    public closingStatementPdfController(){
        string recId= ApexPages.currentPage().getParameters().get('id');
        string stType= ApexPages.currentPage().getParameters().get('type');
        if(!string.isEmpty(stType)){
            statementType = stType;
        }
        if(!string.isEmpty(recId)){
            getDetails(recId);
        }
        String fileName = '';
        litify_pm__Resolution__c resolution = [SELECT Id, Name FROM litify_pm__Resolution__c WHERE Id =:recId ];
        if(statementType=='Rough'){
            fileName ='Rough_'+resolution.Name+'_'+ system.Datetime.now().format('MM-dd-yyyy HH:mm:ss')+'.pdf';
        }
        else{
            fileName ='Final_'+resolution.Name+'_'+ system.Datetime.now().format('MM-dd-yyyy HH:mm:ss')+'.pdf';
        }
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=AccountReport.pdf');
        Apexpages.currentPage().getHeaders().put( 'content-disposition', 'inline; filename=' + fileName );
    }

    public void getDetails(string resolutionId){
        try{
            currentDate = system.now().format('MM/dd/yyyy');
            decimal expenseTotal=0, totalCopying=0;
            map<string, list<litify_pm__Expense__c>> mapExpenses = new  map<string, list<litify_pm__Expense__c>>();
            map<string, string> mapExpCategory = new  map<string, string>();

            List<litify_pm__Resolution__c> listResolution =[select id,name,litify_pm__Resolution_Type__c,Escrow_Reason__c,litify_pm__Settlement_Verdict_Amount__c,litify_pm__Payor__r.name,litify_pm__Matter__c,litify_pm__Matter__r.Name,litify_pm__Matter__r.litify_pm__Client__r.Name,litify_pm__Matter__r.litify_pm__Display_Name__c, litify_pm__Matter__r.litify_pm__Case_Type__r.Name,createddate,litify_pm__Contingency_Fee_Rate__c,Effective_Contingency_Fee__c,Contingency_Fee__c,Fee_Reduction_Description__c,
                                                            Alternate_Payee_Reason__c,Alternate_Payee__c,Alternate_Payee__r.name,Referral_Fees__c,litify_pm__Resolution_Date__c,Net_Fees__c ,Escrow__c,Affirmation_Text__c,Affirmation_Text__r.Text__c,Statement_Signor__c,Statement_Signor__r.Name,Statement_Signor__r.BillingStreet,Statement_Signor__r.BillingCity,Statement_Signor__r.BillingState,Statement_Signor__r.BillingPostalCode,Statement_Signor__r.BillingCountry,
                                                            litify_pm__Matter__r.litify_pm__Client__c,litify_pm__Matter__r.Claims_User__r.name,litify_pm__Matter__r.litify_pm__Client__r.BillingStreet,litify_pm__Matter__r.litify_pm__Client__r.BillingCity,litify_pm__Matter__r.litify_pm__Client__r.BillingState,litify_pm__Matter__r.litify_pm__Client__r.BillingPostalCode,litify_pm__Matter__r.litify_pm__Client__r.BillingCountry,
                                                            Alternate_Payee__r.BillingStreet,Alternate_Payee__r.BillingCity,Alternate_Payee__r.BillingState,Alternate_Payee__r.BillingPostalCode,Alternate_Payee__r.BillingCountry,Status__c,Manual_Resolution__c,
                                                            AAAA_Fee_Rate__c,litify_pm__Matter__r.litify_pm__Client__r.litify_pm__Date_of_birth__c, Fees_Written_Off__c,litify_pm__Matter__r.litify_pm__Statute_Of_Limitations__c,  litify_pm__Matter__r.litify_pm__Incident_date__c,  litify_pm__Matter__r.Legal_Assistant__r.name, litify_pm__Matter__r.litify_pm__Principal_Attorney__r.Name,  litify_pm__Matter__r.Supervising_Attorney__r.Name
                                                            from litify_pm__Resolution__c where id=:resolutionId];

            if(listResolution.size()>0){

                list<litify_pm__Damage__c>listDamages=[select id,Alternate_Payee__c,Alternate_Payee__r.name,litify_pm__Provider__r.litify_pm__Party_Name__c,litify_pm__lit_Provider_Name_Text__c,litify_pm__Provider__r.litify_pm__Party__c,litify_pm__Provider__r.litify_pm__Role__c, litify_pm__Provider__r.name,litify_pm__Amount_Paid__c,litify_pm__Amount_Billed__c,Balance_Due__c,Accounting_Comments__c,litify_pm__Comments__c,Escrow__c from litify_pm__Damage__c where Resolution__c=:resolutionId];
                aggregateresult arDamagesPD = [select sum(Balance_Due__c)totalAmountPaid from litify_pm__Damage__c where Resolution__c=:resolutionId AND Escrow__c=false ];
                aggregateresult arDamagesES = [select sum(Balance_Due__c)totalAmountEscrow from litify_pm__Damage__c where Resolution__c=:resolutionId AND Escrow__c=true ];

                list<Distribution__c>listDistribution = [select id,Amount__c,Comments__c,Account__r.Name,createddate from Distribution__c where Resolution__c=:resolutionId order by createddate];
                aggregateresult arDistribution = [select sum(Amount__c)totalAmount from Distribution__c where Resolution__c=:resolutionId ];

                List<Referral_Fee__c>listReferral = [select id,Amount__c,Effective_Fee_Amount__c,Comments__c,Account__c,Account__r.Name from Referral_Fee__c where Resolution__c=:resolutionId ];

                List<litify_pm__Lien__c>listLienes = [select id,name,Alternate_Payee__c,Alternate_Payee__r.name,CreatedDate,litify_pm__lit_Comments__c,Payee_Party__c,Payee_Party__r.Name,litify_pm__lit_Amount__c,litify_pm__lit_Amount_Due__c,Date_Issued__c,Accounting_Comments__c,Escrow__c from litify_pm__Lien__c where Resolution__c=:resolutionId];

                objWrapper = new statementWrapper();
                objWrapper.objResolution = listResolution[0];
                if(statementType=='Rough'){
                    objWrapper.header='Resolution (ROUGH DRAFT)';
                    objWrapper.footer='Internal Allen & Allen Use Only';
                    objWrapper.zeroDollar = 0.00;
                }
                else{
                    objWrapper.header='Resolution';
                    objWrapper.footer='';
                    objWrapper.zeroDollar = 0.00;
                }
                if (objWrapper.objResolution.Status__c=='Approved' || objWrapper.objResolution.Status__c=='Closed' || objWrapper.objResolution.Status__c=='Rejected' ) {
                    objWrapper.watermark = 'no';
                } else {
                    objWrapper.watermark = 'yes';
                    //objWrapper.watermarkUrl = PageReference.forResource('unapprovedWatermark').getUrl();
                    //objWrapper.watermarkUrl = objWrapper.watermarkUrl.subString(0,objWrapper.watermarkUrl.indexOf('?'));
                }

                List<litify_pm__Role__c>listRoles = [select id,name,litify_pm__Role__c from litify_pm__Role__c where litify_pm__Matter__c=:listResolution[0].litify_pm__Matter__c];

                // Gross Receipts and Fees

                if(listResolution[0].litify_pm__Settlement_Verdict_Amount__c!=null){
                    objWrapper.AAAGrossAmount = listResolution[0].Effective_Contingency_Fee__c;//(listResolution[0].litify_pm__Settlement_Verdict_Amount__c/3).setscale(2);

                    if(statementType=='Rough'){
                        objWrapper.AAAGrossAmount = listResolution[0].Effective_Contingency_Fee__c- listResolution[0].Referral_Fees__c;
                    }
                    if(statementType=='Final'){
                        objWrapper.AAAGrossAmountAfterWriteOff = (listResolution[0].Net_Fees__c).setscale(2) ;//+ (listResolution[0].Fees_Written_Off__c==null?0:listResolution[0].Fees_Written_Off__c)).setscale(2);
                        objWrapper.AAAGrossAmountAfterDeduct = (listResolution[0].litify_pm__Settlement_Verdict_Amount__c - objWrapper.AAAGrossAmountAfterWriteOff).setscale(2);
                    }
                    else{
                        objWrapper.AAAGrossAmountAfterWriteOff = (objWrapper.AAAGrossAmount- (listResolution[0].Fees_Written_Off__c==null?0:listResolution[0].Fees_Written_Off__c)).setscale(2);
                        objWrapper.AAAGrossAmountAfterDeduct = (listResolution[0].litify_pm__Settlement_Verdict_Amount__c - objWrapper.AAAGrossAmountAfterWriteOff).setscale(2);
                    }
                    if (listResolution[0].litify_pm__Settlement_Verdict_Amount__c<=0) {
                        objWrapper.AAANetFirmFeePercentage = 0.00;
                    } else {
                        objWrapper.AAANetFirmFeePercentage = (objWrapper.AAAGrossAmountAfterWriteOff/listResolution[0].litify_pm__Settlement_Verdict_Amount__c)*100;
                    }
                }

                // Expenses

                set<string>setAggregateExpType = new set<string>();
                for(litify_pm__Expense__c objExp : [select id,name,litify_pm__Date__c,litify_pm__Matter__c,litify_pm__Matter__r.Name,litify_pm__Amount__c, Expense_Category__c,Billing_Status__c,Resolution__c,litify_pm__ExpenseType2__c,litify_pm__ExpenseType2__r.Name ,Void__c,Vendor__r.Name
                                                    ,Amount_after_Reductions__c ,Vendor__r.AccountNumber ,litify_pm__lit_Invoice__c,litify_pm__ExpenseType2__r.Category__c  ,litify_pm__ExpenseType2__r.Merge_on_Statement__c from litify_pm__Expense__c  where (Billing_Status__c='Pre-Billed' OR Billing_Status__c='Billed' )  and Resolution__c= :resolutionId and void__c=false order by litify_pm__ExpenseType2__r.Name,litify_pm__Date__c ASC]){
                                                        //if(objExp.Amount_after_Reductions__c>0){
                                                            if(!mapExpenses.containsKey(objExp.litify_pm__ExpenseType2__r.Name)){
                                                                mapExpenses.put(objExp.litify_pm__ExpenseType2__r.Name, new list<litify_pm__Expense__c>{objExp});
                                                            }
                                                            else{
                                                                list<litify_pm__Expense__c> exist= mapExpenses.get(objExp.litify_pm__ExpenseType2__r.Name);
                                                                exist.add(objExp);
                                                                mapExpenses.put(objExp.litify_pm__ExpenseType2__r.Name,exist);
                                                            }
                                                        //}

                                                        expenseTotal = expenseTotal+ objExp.Amount_after_Reductions__c;
                                                        if(objExp.Expense_Category__c=='Soft Cost'){// if(objExp.litify_pm__ExpenseType2__r.Merge_on_Statement__c){
                                                            setAggregateExpType.add(objExp.litify_pm__ExpenseType2__r.Name);
                                                            mapExpCategory.put(objExp.litify_pm__ExpenseType2__r.Name,'Soft Cost');
                                                        }else{
                                                            mapExpCategory.put(objExp.litify_pm__ExpenseType2__r.Name,'Hard Cost');
                                                        }
                                                    }

                aggregateresult arCopyingExp = [select sum(litify_pm__Amount__c)totalAmount from litify_pm__Expense__c  where (Billing_Status__c='Pre-Billed' OR Billing_Status__c='Billed' )  and Resolution__c= :resolutionId and litify_pm__ExpenseType2__r.Name='Copying'];
                totalCopying = (decimal) arCopyingExp.get('totalAmount')==null? 0 : ((decimal) arCopyingExp.get('totalAmount')).setScale(2) ;

                list<litify_pm__Expense__c>listCopyingExpense = [select id from litify_pm__Expense__c where (Billing_Status__c='Pre-Billed' OR Billing_Status__c='Billed' )  and Resolution__c= :resolutionId and litify_pm__ExpenseType2__r.Name='Copying' and litify_pm__ExpenseType2__r.Merge_on_Statement__c=true];
                expenseTotal = expenseTotal +totalCopying;
                objWrapper.totalCopying = totalCopying;

                List<expenseWrapper>listExpWrapper = new  List<expenseWrapper>();
                string expCatDisplayName='';
                for(string catName:mapExpenses.keySet()){
                    List<expenseFinalWrapper>listExpFinalWrapper = new  List<expenseFinalWrapper>();
                    expenseWrapper objExpWrapper = new expenseWrapper();
                    system.debug('catName '+catName);
                    expCatDisplayName = catName;
                    if(catName!=null && catName.contains('(')){
                        expCatDisplayName = catName.substringBefore('(');
                    }
                    objExpWrapper.expenseCatName = expCatDisplayName;
                    objExpWrapper.category = mapExpCategory.get(catName);
                    //if(statementType=='Rough'){
                    if(setAggregateExpType.contains(catName)){
                        decimal total=0;
                        for(litify_pm__Expense__c exp:mapExpenses.get(catName)){
                            total =total+ (exp.Amount_after_Reductions__c==null?0:exp.Amount_after_Reductions__c);
                        }
                        objExpWrapper.totalByExpenseCategory = total;
                    }

                    else{
                        if( objExpWrapper.category!='Soft Cost'){
                            objExpWrapper.listExpense = mapExpenses.get(catName);
                        }

                    }


                    // display expense total by vendor in final statement
                    if(statementType=='Final' && objExpWrapper.category!='Soft Cost'){
                        decimal totalByVendor=0;
                        map<string,decimal>mapVendorByAmount = new  map<string,decimal>();
                        map<string,string>mapVendors = new  map<string,string>();
                        for(litify_pm__Expense__c objExp:mapExpenses.get(catName)){
                            if(!mapVendorByAmount.containskey(objExp.Vendor__c)){
                                mapVendorByAmount.put(objExp.Vendor__c,objExp.Amount_after_Reductions__c);
                                mapVendors.put(objExp.Vendor__c,objExp.Vendor__r.name);
                            }
                            else{
                                decimal exist =  mapVendorByAmount.get(objExp.Vendor__c);
                                mapVendorByAmount.put(objExp.Vendor__c,objExp.Amount_after_Reductions__c+exist);
                            }
                        }
                        for(string vendor:mapVendorByAmount.keyset()){
                            expenseFinalWrapper objExpFinalWrp = new expenseFinalWrapper();
                            objExpFinalWrp.vendorName = mapVendors.get(vendor);
                            objExpFinalWrp.totalByVendor = mapVendorByAmount.get(vendor);
                            listExpFinalWrapper.add(objExpFinalWrp);
                        }
                        //totalByVendor  expenseFinalWrapper
                    }

                    objExpWrapper.listExpFinalWrapper = listExpFinalWrapper;

                    listExpWrapper.add(objExpWrapper);
                    //listExpFinalWrapper.clear();
                }

                objWrapper.listExpenseWrapper = listExpWrapper;

                // Referrals

                objWrapper.totalReferrals=0;
                if(listReferral.size()>0){
                    objWrapper.listReferral=listReferral;
                    decimal total=0;
                    for(Referral_Fee__c objRef:listReferral){
                        system.debug('Amount__c '+objRef.Effective_Fee_Amount__c);
                        total =total+ (objRef.Effective_Fee_Amount__c==null?0:objRef.Effective_Fee_Amount__c);
                    }
                    objWrapper.totalReferrals = total;
                }

                // Liens

                if(listLienes.size()>0){
                    objWrapper.listLienes=listLienes;
                    decimal totalPD=0;
                    decimal totalES=0;
                    for(litify_pm__Lien__c objRef:listLienes){
                        if (objRef.Escrow__c) {
                            totalES = totalES + (objRef.litify_pm__lit_Amount_Due__c == null ? 0 : objRef.litify_pm__lit_Amount_Due__c);
                        } else {
                            totalPD = totalPD + (objRef.litify_pm__lit_Amount_Due__c == null ? 0 : objRef.litify_pm__lit_Amount_Due__c);
                        }
                    }
                    objWrapper.totalLiens = totalPD;
                    objWrapper.totalLiensEscrow = totalES;
                    if(statementType=='Final'){
                        map<string,string>mapProviders = new map<string,string>();
                        map<string,decimal>mapProviderByAmount = new map<string,decimal>();
                        map<string,decimal>mapProviderByAmountDue = new map<string,decimal>();
                        for(litify_pm__Lien__c objLien:listLienes){
                            mapProviders.put(objLien.Payee_Party__c,objLien.Payee_Party__r.Name);
                            if(!mapProviderByAmount.containskey(objLien.Payee_Party__c)){
                                mapProviderByAmount.put(objLien.Payee_Party__c,objLien.litify_pm__lit_Amount__c);
                                mapProviderByAmountDue.put(objLien.Payee_Party__c,objLien.litify_pm__lit_Amount_Due__c);
                            }
                            else{
                                decimal exist =  mapProviderByAmount.get(objLien.Payee_Party__c)==null?0:mapProviderByAmount.get(objLien.Payee_Party__c);
                                exist= exist+ (objLien.litify_pm__lit_Amount__c==null?0:objLien.litify_pm__lit_Amount__c);
                                mapProviderByAmount.put(objLien.Payee_Party__c,exist);

                                decimal existDue =  mapProviderByAmountDue.get(objLien.Payee_Party__c)==null?0:mapProviderByAmountDue.get(objLien.Payee_Party__c);
                                existDue= existDue +(objLien.litify_pm__lit_Amount_Due__c==null?0:objLien.litify_pm__lit_Amount_Due__c);
                                mapProviderByAmountDue.put(objLien.Payee_Party__c,existDue);
                            }
                        }

                        List<lienFinalWrapper>listLienFinalWrapper = new List<lienFinalWrapper>();
                        for(string provider:mapProviders.keyset()){
                            lienFinalWrapper objDmgFinal = new lienFinalWrapper();
                            objDmgFinal.providerName = mapProviders.get(provider);
                            objDmgFinal.amountByProvider = mapProviderByAmount.get(provider);
                            objDmgFinal.amountDueByProvider = mapProviderByAmountDue.get(provider);
                            listLienFinalWrapper.add(objDmgFinal);

                        }
                        if(listLienFinalWrapper.size()>0){
                            objWrapper.listLienFinalWrapper = listLienFinalWrapper;
                        }



                    }
                }

                // Affirmation Text

                //objWrapper.objResolution.Affirmation_Text__ ==null then get standard
                objWrapper.affirmationText = objWrapper.objResolution.Affirmation_Text__r.Text__c;
                if(string.isEmpty(objWrapper.affirmationText)){
                    List<Affirmation_Paragraph__c>listAffirmation = [select id, text__c from Affirmation_Paragraph__c where name='Standard'];
                    if(listAffirmation.size()>0){
                        objWrapper.affirmationText = listAffirmation[0].text__c;
                    }
                }

                // Damages

                if(listDamages.size()>0){
                    objWrapper.listDamages=listDamages;
                    if(statementType=='Final'){
                        map<string,string>mapProviders = new map<string,string>();
                        map<string,decimal>mapProviderByAmount = new map<string,decimal>();
                        map<string,decimal>mapProviderByAmountDue = new map<string,decimal>();
                        for(litify_pm__Damage__c objDmg:listDamages){
                            mapProviders.put(objDmg.litify_pm__Provider__r.litify_pm__Party__c,objDmg.litify_pm__lit_Provider_Name_Text__c);
                            if(!mapProviderByAmount.containskey(objDmg.litify_pm__Provider__r.litify_pm__Party__c)){
                                mapProviderByAmount.put(objDmg.litify_pm__Provider__r.litify_pm__Party__c,objDmg.litify_pm__Amount_Billed__c);
                                mapProviderByAmountDue.put(objDmg.litify_pm__Provider__r.litify_pm__Party__c,objDmg.Balance_Due__c);
                            }
                            else{
                                decimal exist =  mapProviderByAmount.get(objDmg.litify_pm__Provider__r.litify_pm__Party__c)==null?0:mapProviderByAmount.get(objDmg.litify_pm__Provider__r.litify_pm__Party__c);
                                mapProviderByAmount.put(objDmg.litify_pm__Provider__r.litify_pm__Party__c,exist+(objDmg.litify_pm__Amount_Billed__c==null?0:objDmg.litify_pm__Amount_Billed__c));

                                decimal existDue =  mapProviderByAmountDue.get(objDmg.litify_pm__Provider__r.litify_pm__Party__c)==null?0:mapProviderByAmountDue.get(objDmg.litify_pm__Provider__r.litify_pm__Party__c);
                                mapProviderByAmountDue.put(objDmg.litify_pm__Provider__r.litify_pm__Party__c,existDue +objDmg.Balance_Due__c);
                            }
                        }

                        List<damageFinalWrapper>listDamageFinalWrapper = new List<damageFinalWrapper>();
                        for(string provider:mapProviders.keyset()){
                            damageFinalWrapper objDmgFinal = new damageFinalWrapper();
                            objDmgFinal.providerName = mapProviders.get(provider);
                            objDmgFinal.amountByProvider = mapProviderByAmount.get(provider);
                            objDmgFinal.amountDueByProvider = mapProviderByAmountDue.get(provider);
                            listDamageFinalWrapper.add(objDmgFinal);

                        }
                        if(listDamageFinalWrapper.size()>0){
                            objWrapper.listDamageFinalWrapper = listDamageFinalWrapper;
                        }


                    }
                }

                // Distributions

                if(listDistribution.size()>0){
                    objWrapper.listDistribution=listDistribution;
                    decimal total=0;
                    for(Distribution__c objDist:listDistribution){
                       system.debug('Amount__c '+objDist.Amount__c);
                       total =total+ (objDist.Amount__c==null?0:objDist.Amount__c);
                    }
                }

                //get Address
                List<Account>listAcc = [select id,name,billingStreet,billingCity,billingState,billingPostalCode,phone from Account where name=:label.Firm_Distribution_Account_AAA];
                if(listAcc.size()>0){
                    objWrapper.companyAccount =listAcc[0];
                }
                objWrapper.role= listRoles[0].litify_pm__Role__c;
                objWrapper.expenseTotal= expenseTotal.setScale(2);
                objWrapper.AAAGrossAmountAfterReferral = objWrapper.AAAGrossAmountAfterDeduct- objWrapper.totalReferrals;
                objWrapper.AAAGrossAmountAfterExpense =  objWrapper.AAAGrossAmountAfterReferral- objWrapper.expenseTotal;

                objWrapper.totalDamagesPaid =  (decimal) arDamagesPD.get('totalAmountPaid')==null ? 0 : ((decimal) arDamagesPD.get('totalAmountPaid')).setScale(2) ;
                objWrapper.totalDamagesEscrow =  (decimal) arDamagesES.get('totalAmountEscrow')==null ? 0 : ((decimal) arDamagesES.get('totalAmountEscrow')).setScale(2) ;
                objWrapper.totalDamages = objWrapper.totalDamagesPaid + objWrapper.totalDamagesEscrow ;

                objWrapper.AAAGrossAmountAfterDamage  =  objWrapper.AAAGrossAmountAfterExpense - objWrapper.totalDamagesPaid - objWrapper.totalDamagesEscrow;
                objWrapper.AAAGrossAmountAfterLiens  =  objWrapper.AAAGrossAmountAfterDamage - (objWrapper.totalLiens==null ? 0: objWrapper.totalLiens + objWrapper.totalLiensEscrow);
                objWrapper.AAAGrossAmountAfterEscrow =  objWrapper.AAAGrossAmountAfterLiens -  (objWrapper.objResolution.Escrow__c==null?0: objWrapper.objResolution.Escrow__c);

                objWrapper.totalDistribution =  (decimal) arDistribution.get('totalAmount')==null? 0 : ((decimal) arDistribution.get('totalAmount')).setScale(2) ;
                objWrapper.AAAGrossAmountAfterDistribution  =  objWrapper.AAAGrossAmountAfterEscrow - (objWrapper.totalDistribution==null?0:objWrapper.totalDistribution);

                system.debug( objWrapper.listLienFinalWrapper);
                system.debug( objWrapper.objResolution.Escrow__c);
                system.debug(objWrapper.listExpenseWrapper);
            }

        }
        catch(Exception ex){}

    }

    class expenseWrapper{
        public string expenseCatId{get;set;}
        public string expenseCatName{get;set;}
        public string category{get;set;}
        public list<litify_pm__Expense__c>listExpense{get;set;}
        public list<expenseFinalWrapper>listExpFinalWrapper{get;set;}
        public decimal totalByExpenseCategory{get;set;}
        public expenseWrapper(){}
    }

    class statementWrapper{
        public litify_pm__Resolution__c objResolution{get;set;}
        public list<expenseWrapper> listExpenseWrapper{get;set;}
        public list<litify_pm__Damage__c>listDamages{get;set;}
        public list<Distribution__c>listDistribution{get;set;}
        public List<Referral_Fee__c>listReferral{get;set;}
        public List<litify_pm__Lien__c>listLienes {get;set;}
        public List<damageFinalWrapper>listDamageFinalWrapper{get;set;}
        public List<lienFinalWrapper>listLienFinalWrapper{get;set;}
        public decimal AAAGrossAmount{get;set;}
        public decimal AAAGrossAmountAfterDeduct{get;set;}
        public decimal AAAGrossAmountAfterWriteOff{get;set;}
        public decimal AAANetFirmFeePercentage{get;set;}
        public decimal AAAGrossAmountAfterExpense{get;set;}
        public decimal expenseTotal{get;set;}
        public decimal totalDamages{get;set;}
        public decimal totalDamagesPaid{get;set;}
        public decimal totalDamagesEscrow{get;set;}
        public decimal totalDistribution{get;set;}
        public decimal totalReferrals{get;set;}
        public decimal totalLiens{get;set;}
        public decimal totalLiensEscrow{get;set;}
        public decimal AAAGrossAmountAfterDamage{get;set;}
        public decimal AAAGrossAmountAfterReferral{get;set;}
        public decimal AAAGrossAmountAfterLiens{get;set;}
        public decimal AAAGrossAmountAfterEscrow{get;set;}
        public decimal AAAGrossAmountAfterDistribution{get;set;}
        public decimal totalCopying{get;set;}
        public decimal zeroDollar{get;set;}
        public string header{get;set;}
        public string footer{get;set;}
        public string watermark{get;set;}
        public string role{get;set;}
        public string affirmationText{get;set;}
        public Account companyAccount{get;set;}
        public statementWrapper(){}
    }

    class expenseFinalWrapper{
        public string vendorName{get;set;}
        public decimal totalByVendor{get;set;}
        public expenseFinalWrapper(){}

    }
    class damageFinalWrapper{
        public string providerName{get;set;}
        public decimal amountByProvider{get;set;}
        public decimal amountDueByProvider{get;set;}
        public damageFinalWrapper(){}

    }
    class lienFinalWrapper{
        public string providerName{get;set;}
        public decimal amountByProvider{get;set;}
        public decimal amountDueByProvider{get;set;}
        public lienFinalWrapper(){}
    }

}