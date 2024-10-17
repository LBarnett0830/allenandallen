/*
Author: Cmentor/ Sampath Suranji
Date :06/08/2020
Description : Send email to finance when resolution approved

Lamar B - 10/10/2024
Added Logic to Updated Total Damages, Escrow Damages, Total Liens, and Escrow Liens.
*/
public class resolutionTriggerHandler {
    public static List<litify_pm__Resolution__c>listApprovedResolutions{get;set;}
    
    //Trigger was used to send approval email to finance, since finance email Id store in custom label
    public static void afterUpdate(list<litify_pm__Resolution__c>newRecords,map<id,litify_pm__Resolution__c>oldMap){
        savepoint sp;
        //beforeUpdate(newRecords.deepClone());
        try
        {
            listApprovedResolutions = new list<litify_pm__Resolution__c>();
            set<id>approvedResolutionIds= new set<id>();
            set<id>resolutionIdsToUpdateReferalFee = new set<id>();
            map<id,litify_pm__Resolution__c>mapResolutionToUpdateReferals = new  map<id,litify_pm__Resolution__c>();
            list<Referral_Fee__c>listReferalFeeToUpdate = new list<Referral_Fee__c>();

            List<String> newRecordIds = new List<String>();//String to store new Record Id's for query used later

            for(litify_pm__Resolution__c objResolution:newRecords )
            {

                //Add New Record Ids to List for a Query
                newRecordIds.add(objResolution.Id);

                if(objResolution.Status__c=='Approved' && oldMap.get(objResolution.Id).Status__c=='Pending Approval')
                {
                    listApprovedResolutions.add(objResolution);
                    approvedResolutionIds.add(objResolution.id);
                }
                if(oldMap.get(objResolution.Id).Contingency_Fee__c !=objResolution.Contingency_Fee__c)
                {
                    resolutionIdsToUpdateReferalFee.add(objResolution.id);
                    mapResolutionToUpdateReferals.put(objResolution.id,objResolution);
                }
            }
            if(approvedResolutionIds.size()>0){
                //update related expenses as billed
                /*List<litify_pm__Expense__c> listExpenseToUpdate = new List<litify_pm__Expense__c>();
                
                for(litify_pm__Expense__c objExpense: [select id,name,litify_pm__Date__c,litify_pm__Matter__c,Billing_Status__c,Resolution__c   from litify_pm__Expense__c where Resolution__c in :approvedResolutionIds]){
                    
                    objExpense.Billing_Status__c='Billed';   
                    listExpenseToUpdate.add(objExpense);
                }
                
                if(listExpenseToUpdate.size()>0){
                    update listExpenseToUpdate;
                }*/
                
                //send email to finance for approved notification
                sendEmailToFinance(approvedResolutionIds);
            }
            
            //Update related referral fee effective amount
            if(resolutionIdsToUpdateReferalFee.size()>0)
            {
                for(Referral_Fee__c objReferral :[select id,name,Amount__c , Fee_Rate__c ,Account__c,Effective_Fee_Amount__c,Resolution__c from Referral_Fee__c where Resolution__c in :resolutionIdsToUpdateReferalFee])
                {
                    if(objReferral.Amount__c==null && objReferral.Fee_Rate__c>0)
                    {
                        objReferral.Effective_Fee_Amount__c = objReferral.Fee_Rate__c * mapResolutionToUpdateReferals.get(objReferral.Resolution__c).Contingency_Fee__c;
                        listReferalFeeToUpdate.add(objReferral);
                    }
                }
                if(listReferalFeeToUpdate.size()>0)
                {
                    update listReferalFeeToUpdate;
                }
            
            }
            
        }catch(Exception ex){}    
    }

    public static void beforeUpdate(List<litify_pm__Resolution__c> newRecords){
        Map<String, litify_pm__Resolution__c> resolutionByName = new Map<String, litify_pm__Resolution__c>();
        Map<String, List<litify_pm__Damage__c>> damageListByResolutionName = new Map<String, List<litify_pm__Damage__c>>();
        Map<String, List<litify_pm__Lien__c>> lienListByResolutionName = new Map<String, List<litify_pm__Lien__c>>();

        List<String> resolutionNames = new List<String>();


        for(litify_pm__Resolution__c resolution : newRecords){ 
            resolutionByName.put(resolution.Name, resolution);
            resolutionNames.add(resolution.Name);
        }
        List<litify_pm__Damage__c> damageList = getDamageByResolutionName(resolutionNames);
        List<litify_pm__Lien__c> lienList = getLienByResolutionName(resolutionNames);

        for(litify_pm__Resolution__c resolution : newRecords){
            damageListByResolutionName.put(resolution.Name, getDamagesByName(resolution.Name, damageList));
            lienListByResolutionName.put(resolution.Name, getLienByName(resolution.Name, lienList));
        }

        for(litify_pm__Resolution__c resolution : newRecords) {
            if(damageListByResolutionName.containsKey(resolution.Name)){
                if(damageListByResolutionName.get(resolution.Name) != null){
                    Double totalDamageNonEscrow = calculateTotalDamageNonEscrow(damageListByResolutionName.get(resolution.Name));
                    Double totalEscrowedDamages = calculateTotalEscrowDamage(damageListByResolutionName.get(resolution.Name));
                    
                    resolution.litify_pm__Total_Damages__c = resolution.litify_pm__Total_Damages__c != totalDamageNonEscrow 
                        ? totalDamageNonEscrow : resolution.litify_pm__Total_Damages__c;
                    resolution.Escrow_Damages__c = resolution.Escrow_Damages__c != totalEscrowedDamages 
                        ? totalEscrowedDamages : resolution.Escrow_Damages__c;
                }
            }

            if(lienListByResolutionName.containsKey(resolution.Name)){
                if(lienListByResolutionName.get(resolution.Name) != null){
                    Double totalLiens = calculateTotalLienNoneEscrow(lienListByResolutionName.get(resolution.Name));
                    Double totalEscrowLiens = calculateTotalEscrowLien(lienListByResolutionName.get(resolution.Name));

                    resolution.Total_Liens__c = resolution.Total_Liens__c != totalLiens ? totalLiens : resolution.Total_Liens__c;
                    resolution.Escrow_Liens__c = resolution.Escrow_Liens__c != totalEscrowLiens ? totalEscrowLiens : resolution.Escrow_Liens__c;
                }
            }
        }
        /*
        try {
            upsert newRecords litify_pm__Resolution__c.Name;
        }catch(Exception ex){
            System.debug(LoggingLevel.Error, ex.getMessage());
        }
         */

    }

    private static List<litify_pm__Damage__c> getDamageByResolutionName(List<String> resolutionName){
        List<litify_pm__Damage__c> damages = new List<litify_pm__Damage__c>();
        try{
            damages = [
                SELECT Id, Name, Balance_Due__c, Escrow__c, Resolution__r.Name 
                FROM litify_pm__Damage__c
                WHERE Resolution__r.Name IN: resolutionName
            ];
        }catch(Exception ex){
            System.debug(LoggingLevel.Error, 'Error retrieving damages for Resolution: ' + resolutionName);
            System.debug(LoggingLevel.Error, 'Error message: ' + ex.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack Trace: '+ex.getStackTraceString());
        }
        return damages;
    }

    private static List<litify_pm__Lien__c> getLienByResolutionName(List<String> resolutionName){
        List<litify_pm__Lien__c> liens  = new List<litify_pm__Lien__c>();
        try{
            liens = [
                SELECT Id, Name, litify_pm__lit_Amount_Due__c, Escrow__c, Resolution__r.Name 
                FROM litify_pm__Lien__c 
                WHERE Resolution__r.Name IN: resolutionName
            ];

        }catch(Exception ex){
            System.debug(LoggingLevel.Error, 'Error retrieving damages for Resolution: ' + resolutionName);
            System.debug(LoggingLevel.Error, 'Error message: ' + ex.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack Trace: '+ex.getStackTraceString());
        }
        return liens;
    }

    private static List<litify_pm__Damage__c> getDamagesByName(String resolutionName, List<litify_pm__Damage__c> damages){
        List<litify_pm__Damage__c> toReturn = new List<litify_pm__Damage__c>();
        for(litify_pm__Damage__c damage : damages){
            if(damage.Resolution__r.Name == resolutionName){
                toReturn.add(damage);
            }
        }
        return toReturn;
    }

    private static List<litify_pm__Lien__c> getLienByName(String resolutionName, List<litify_pm__Lien__c> liens){
        List<litify_pm__Lien__c> toReturn = new List<litify_pm__Lien__c>();
        for(litify_pm__Lien__c lien : liens) {
            if(lien.Resolution__r.Name == resolutionName) {
                toReturn.add(lien);
            }
        }
        return toReturn;
    }

    private static Double calculateTotalDamageNonEscrow(List<litify_pm__Damage__c> damages) {
        System.debug(LoggingLevel.Debug, 'Calculating Total Non Escrow Damage Start');
        Double toReturn = 0.0;
        for(litify_pm__Damage__c damage : damages) {
            if(damage.Escrow__c == false) {
                toReturn += damage.Balance_Due__c;
            }
        }
        System.Debug(LoggingLevel.Debug, 'Calculated Totaol Non Escrowed Damage Value: ' + toReturn);
        return toReturn;
    }

    private static Double calculateTotalEscrowDamage(List<litify_pm__Damage__c> damages){
        System.debug(LoggingLevel.Debug, 'Calculating Total Escrow Damage Start');
        Double toReturn = 0.0;
        for(litify_pm__Damage__c damage : damages) {
            if(damage.Escrow__c == true) {
                toReturn += damage.Balance_Due__c;
            }
        }
        System.Debug(LoggingLevel.Debug, 'Calculated Total Escrowed Damage Value: ' + toReturn);
        return toReturn;
    }

    private static Double calculateTotalLienNoneEscrow(List<litify_pm__Lien__c> liens){
        System.debug(LoggingLevel.Debug, 'Calculating Total Non Escrow lien Start');
        Double toReturn = 0.0;
        for(litify_pm__Lien__c lien : liens){
            if(lien.Escrow__c == false) {
                toReturn += lien.litify_pm__lit_Amount_Due__c;
            }
        }
        System.Debug(LoggingLevel.Debug, 'Calculated Total Non Escrowed lien Value: ' + toReturn);
        return toReturn;
    }
    
    private static Double calculateTotalEscrowLien(List<litify_pm__Lien__c> liens){
        System.debug(LoggingLevel.Debug, 'Calculating Total Escrow lien Start');
        Double toReturn = 0.0;
        for(litify_pm__Lien__c lien : liens){
            if(lien.Escrow__c == true) {
                toReturn += lien.litify_pm__lit_Amount_Due__c;
            }
        }
        System.Debug(LoggingLevel.Debug, 'Calculated Total Escrowed lien Value: ' + toReturn);
        return toReturn;
    }
    
    
    @future
    public static void sendEmailToFinance(set<id>approvedResolutionIds){
        try{
            list<litify_pm__Resolution__c> listApprovedResolutions = [select id from litify_pm__Resolution__c where id in:approvedResolutionIds];
            Messaging.SingleEmailMessage [] emails = new Messaging.SingleEmailMessage[]{};
                EmailTemplate template = [Select id,body,HTMLValue,subject from EmailTemplate where developername = 'Resolution_Approved_Notification_to_Finance' limit 1];
            if(listApprovedResolutions.size()>0){
                for(litify_pm__Resolution__c objResolution:listApprovedResolutions){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String> {label.Finance_Email_Address});
                    string body = template.HTMLValue;
                    
                    body = body.replace('{!litify_pm__Resolution__c.Link}','<br><br>'+'<a href="'+URL.getSalesforceBaseUrl().toExternalform()+'/one/one.app?#/sObject/'+objResolution.Id+'">View record</a>');
                    mail.setSubject(template.subject);
                    mail.htmlBody= body;
                    emails.add(mail);
                }
                
            }
            if(emails.size()>0){
                Messaging.sendEmail(emails);
            }
        }
        catch(Exception ex){}
    }
    
    
}