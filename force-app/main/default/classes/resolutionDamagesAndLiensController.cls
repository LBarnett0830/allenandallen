/*
Author: Cmentor/ Sampath Suranji
Date   : 08/04/2020
Description : resolutionDamagesAndLiensController for Cost recovery Screen in Resolution

Updated by : 4Converge/Dave Williams
Date       : 10/5/2024
Description: Revisions for using Balance_Due__c on Damages instead of managed field Amount_Due__c

Updated by: Lamar Barnett
Date: 10/10/2024
Description: 
TODO: Update Total Damages Due Amount to reflect Total Damages for all non escrowed Damages
TODO: Updated Total Liens Due Amount to equal total Liens for all non escrowed Liens.
TODO: Add Whitespace for new tables
TODO: Ensure table names are accurate IAW original requirements
*/
public class resolutionDamagesAndLiensController {
    @AuraEnabled
    public static resolutionDamagesAndLiensWrapper getAllRecords(string resolutionId){
        try{
            
            string matterId='';
            List<litify_pm__Resolution__c> listResolution =[
                    SELECT
                            Id,Name,Status__c,litify_pm__Matter__c,litify_pm__Matter__r.Name,litify_pm__Matter__r.litify_pm__Display_Name__c,Firm_Distribution__c,litify_pm__Total_Damages__c,Third_Party_Distributions__c,Client_Distribution__c, litify_pm__Settlement_Verdict_Amount__c,litify_pm__Total_Expenses__c ,Contingency_Fee__c ,Voided_Hard_Costs__c,Voided_Soft_Costs__c , Fees_Written_Off__c, Total_Escrow__c, Total_Liens__c
                    FROM litify_pm__Resolution__c
                    WHERE id=:resolutionId];
            if(listResolution.size()>0){
                
                matterId = listResolution[0].litify_pm__Matter__c;
                List<litify_pm__Damage__c>listAvailableDamages = [select id,name,litify_pm__Provider__r.litify_pm__Party__c,litify_pm__Provider__r.litify_pm__Party__r.Name,Balance_Due__c,
                        Damage_Verification_Completion_Time__c,litify_pm__Type__c,Party_Name__c,Escrow__c
                    from litify_pm__Damage__c where Resolution__c=null and litify_pm__Matter__c=:listResolution[0].litify_pm__Matter__c];
                
                List<litify_pm__Damage__c>listSelectedDamages = [select id,name,litify_pm__Provider__r.litify_pm__Party__c,litify_pm__Provider__r.litify_pm__Party__r.Name,Balance_Due__c,Due_Date__c,
                        Damage_Verification_Completion_Time__c,litify_pm__Type__c,Party_Name__c,Escrow__c
                    from litify_pm__Damage__c where Resolution__c=:resolutionId];
                
                List<litify_pm__Damage__c>listResUsedDamages = [select id,name,litify_pm__Provider__r.litify_pm__Party__c,litify_pm__Provider__r.litify_pm__Party__r.Name,Balance_Due__c,Due_Date__c,
                        Damage_Verification_Completion_Time__c,litify_pm__Type__c,Party_Name__c,Escrow__c, Resolution__r.Name, Resolution__c
                    from litify_pm__Damage__c where Resolution__c!=:resolutionId and Resolution__c!=null and litify_pm__Matter__c=:listResolution[0].litify_pm__Matter__c];
                
                List<litify_pm__Lien__c>listAvailableLienes = [select id,name,Payee_Party__c,Payee_Party__r.Name,litify_pm__lit_Payee__r.litify_pm__Party__c,litify_pm__lit_Payee__r.litify_pm__Party__r.Name,
                    litify_pm__lit_Amount_Due__c,Date_Issued__c,Escrow__c
                    from litify_pm__Lien__c where Resolution__c=null and litify_pm__lit_Matter__c=:listResolution[0].litify_pm__Matter__c];
                
                List<litify_pm__Lien__c>listSelectedLienes = [select id,name,Payee_Party__c,Payee_Party__r.Name,litify_pm__lit_Payee__r.litify_pm__Party__c,litify_pm__lit_Payee__r.litify_pm__Party__r.Name,
                        litify_pm__lit_Amount_Due__c,Date_Issued__c,Escrow__c
                    from litify_pm__Lien__c where Resolution__c=:resolutionId];

                //Query to find Used Liens
                List<litify_pm__Lien__c> listUsedLiens = [
                    SELECT 
                        Id, 
                        name, 
                        Payee_Party__c, 
                        Payee_Party__r.Name, 
                        litify_pm__lit_Payee__r.litify_pm__Party__c, 
                        litify_pm__lit_Payee__r.litify_pm__Party__r.Name, 
                        litify_pm__lit_Amount_Due__c,
                        Date_Issued__c, 
                        Escrow__c,
                        Resolution__c,
                        Resolution__r.Name
                    FROM
                        litify_pm__Lien__c
                    WHERE  
                        Resolution__c !=: resolutionId
                        AND 
                    Resolution__c != null 
                        AND 
                        litify_pm__lit_Matter__c =: listResolution[0].litify_pm__Matter__c LIMIT 5000];

                
                
                resolutionDamagesAndLiensWrapper objWrapper = new resolutionDamagesAndLiensWrapper();//(listAvailableDamages,listSelectedDamages);
                objWrapper.currentResolution = listResolution[0];
                //objWrapper.totalDamagesAmount = listResolution[0].litify_pm__Total_Damages__c;
                //objWrapper.totalLienesAmount = listResolution[0].Total_Liens__c;
                objWrapper.availableDamages = listAvailableDamages;
                objWrapper.selectedDamages = listSelectedDamages;
                objWrapper.availableLienes = listAvailableLienes;
                objWrapper.selectedLienes = listSelectedLienes;
                objWrapper.usedDamages = listResUsedDamages;// Add used damages to declaration in wrapper
                objWrapper.usedLienes = listUsedLiens;
                objWrapper.emptyDamages = new List<litify_pm__Damage__c> ();
                objWrapper.emptyLienes = new List<litify_pm__Lien__c> ();
                
                if(listResolution.size()>0){
                    objWrapper.objResolution =listResolution[0];
                }
                objWrapper.totalDamagesAmount =  listResolution[0].litify_pm__Total_Damages__c != 0 || listResolution[0].litify_pm__Total_Damages__c != null
                        ? listResolution[0].litify_pm__Total_Damages__c
                        : 0;
                objWrapper.totalLienesAmount =  listResolution[0].Total_Liens__c != 0 || listResolution[0].Total_Liens__c != null
                        ? listResolution[0].Total_Liens__c
                        : 0;
                
                //Update totdal Damage Amount in resolution
               // listResolution[0].litify_pm__Total_Damages__c = objWrapper.totalDamagedAmount;
                //Update listResolution[0];
                
                return objWrapper;
            }
            
        }
        catch(Exception ex){
            system.debug('=======Line No========'+ex.getLineNumber()+'========Messag========'+ex.getMessage());
        }
        return null;
    }
    
    
    @AuraEnabled
    public static map<string,string> saveResolution(string resolutionId,resolutionDamagesAndLiensWrapper objWrapper ){
        Savepoint sp;
        map<string,string> msgMap = new map<string,string>();
        try{
            List<litify_pm__Resolution__c> listResolution =[
                    SELECT
                            Id,
                            litify_pm__Matter__c,
                            litify_pm__Matter__r.Name,
                            litify_pm__Matter__r.litify_pm__Display_Name__c,
                            litify_pm__Total_Expenses__c,
                            Name,
                            litify_pm__Total_Damages__c,
                            Escrow_Damages__c,
                            Escrow_Liens__c,
                            Total_Liens__c
                    FROM
                            litify_pm__Resolution__c
                    WHERE Id=:resolutionId
            ];
            if(listResolution.size()>0){
                string matterId = listResolution[0].litify_pm__Matter__c;
                decimal totalSoftCost=0,totalHardCost=0,totalVoidedSoftCost=0,totalVoidedHardCost=0;
                sp= database.setSavepoint();
                List<litify_pm__Damage__c> listDamagesToUpdate = new   List<litify_pm__Damage__c>();
                List<litify_pm__Lien__c> listLienesToUpdate = new   List<litify_pm__Lien__c>();
                map<id,litify_pm__Damage__c>mapSelectedDamages = new  map<id,litify_pm__Damage__c>([select id,name,litify_pm__Provider__r.litify_pm__Party__c,litify_pm__Provider__r.litify_pm__Party__r.Name,Balance_Due__c,Due_Date__c from litify_pm__Damage__c where Resolution__c=:resolutionId]);
                map<id,litify_pm__Lien__c>mapSelectedLienes = new   map<id,litify_pm__Lien__c>([select id,name,litify_pm__lit_Payee__r.litify_pm__Party__c,litify_pm__lit_Payee__r.litify_pm__Party__r.Name,litify_pm__lit_Amount_Due__c,Date_Issued__c from litify_pm__Lien__c where Resolution__c=:resolutionId]);
                
                // if Damage Resolution is not already in database, add it to list an update it.
                for(litify_pm__Damage__c  objDamage : objWrapper.selectedDamages){
                    if(!mapSelectedDamages.keyset().contains(objDamage.id)){
                        objDamage.Resolution__c = resolutionId;
                        listDamagesToUpdate.add(objDamage); 
                    }            
                }
                for(litify_pm__Damage__c  objDamage : objWrapper.availableDamages){
                    objDamage.Resolution__c = null;
                    listDamagesToUpdate.add(objDamage);                    
                } 
                
                for(litify_pm__Lien__c  objLien : objWrapper.selectedLienes){
                    if(!mapSelectedLienes.keyset().contains(objLien.id)){
                        objLien.Resolution__c = resolutionId;
                        listLienesToUpdate.add(objLien); 
                    }
                }              
                for(litify_pm__Lien__c  objLien : objWrapper.availableLienes){
                    objLien.Resolution__c = null;
                    listLienesToUpdate.add(objLien);                    
                }  
                sp =database.setSavepoint();
                if(listDamagesToUpdate.size()>0){
                    update listDamagesToUpdate;
                } 
                if(listLienesToUpdate.size()>0){
                    update listLienesToUpdate;
                }
                System.debug(LoggingLevel.INfo, 'damage '+objWrapper.totalDamagesAmount);
                Decimal totalDmgAmount = 0.0;
                if(objWrapper.totalDamagesAmount!=null){
                    //listResolution[0].litify_pm__Total_Damages__c = Decimal.valueOf( objWrapper.totalDamagesAmount);
                }
                if(objWrapper.totalLienesAmount!=null){
                    //listResolution[0].Total_Liens__c = Decimal.valueOf( objWrapper.totalLienesAmount);
                }
                resolutionTriggerHandler.beforeUpdate(listResolution);
               
                try{
                    update listResolution[0];
                }catch(Exception ex){
                    System.debug(LoggingLevel.ERROR, ex.getMessage());
                }
                msgMap.put('success','true');
            }
            
            
        }
        catch(Exception ex){
            msgMap.put('error','true');
            System.debug(LoggingLevel.Error, '=======Line No========'+ex.getLineNumber()+'========Messag========'+ex.getMessage());
            if(sp!=null){
                database.rollback(sp);
            }
        }
        return msgMap;
    }    
    
}