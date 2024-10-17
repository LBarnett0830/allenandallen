public class TreatmentTriggerHandler {
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public static Boolean dontInvokeTrigger = false;
    
    public TreatmentTriggerHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    public static Boolean isDisabled(){
        litify_pm__Public_Setup__c  setting = litify_pm__Public_Setup__c.getOrgDefaults();
        return (setting != null && (setting.Disable_Treatment_Trigger__c  || setting.litify_pm__Run_Triggers__c == false));
    }
    public void OnBeforeInsert(List<litify_pm__Treatment__c> l_new)  {
        Set<Id> s_injuryIds = new Set<Id>();
        for(litify_pm__Treatment__c item : l_new){
            if(item.litify_pm__Injury__c != null && item.litify_pm__Doctor_Facility__c  != null) {
                s_injuryIds.add(item.litify_pm__Injury__c);
            }
        }
        if (s_injuryIds.size() > 0) {
            Map<Id, litify_pm__Injury__c> m_injuries = new Map<Id, litify_pm__Injury__c>([SELECT ID, litify_pm__Matter__c FROM litify_pm__Injury__c WHERE ID IN :s_injuryIds]);
            Set<Id> s_matterIds = new Set<Id>();
            for (litify_pm__Injury__c injury : m_injuries.values()) {
                s_matterIds.add(injury.litify_pm__Matter__c);
            }
            Map<Id, litify_pm__Matter__c> m_matters = new Map<Id, litify_pm__Matter__c>([SELECT ID, (SELECT ID, Doctor_Facility__c  FROM Treatment_Summaries__r) FROM litify_pm__Matter__c WHERE Id IN:s_matterIds]);
            List<Treatment_Summary__c> l_newSummary = new List<Treatment_Summary__c>();
            for(litify_pm__Treatment__c item : l_new){
                if(item.litify_pm__Injury__c != null && item.litify_pm__Doctor_Facility__c  != null) {
                    litify_pm__Injury__c injury = m_injuries.get(item.litify_pm__Injury__c);
                    if (injury != null) {
                        litify_pm__Matter__c matter = m_matters.get(injury.litify_pm__Matter__c);
                        if (matter != null) {
                            Boolean isExist = false;
                            for(Treatment_Summary__c summary : matter.Treatment_Summaries__r) {
                                if (item.litify_pm__Doctor_Facility__c == summary.Doctor_Facility__c ) {
                                    isExist = true;
                                    item.Treatment_Summary__c = summary.Id;
                                    break;
                                }
                            }
                            for(Treatment_Summary__c summary : l_newSummary) {
                                if (item.litify_pm__Doctor_Facility__c == summary.Doctor_Facility__c  && summary.Matter__c == matter.Id) {
                                    isExist = true;
                                    //item.Treatment_Summary__c = summary.Id;
                                    break;
                                }
                            }
                            if (isExist == false) {
                                Treatment_Summary__c newSummary = new Treatment_Summary__c();
                                newSummary.Matter__c  = matter.Id;
                                newSummary.Doctor_Facility__c  = item.litify_pm__Doctor_Facility__c;
                                l_newSummary.add(newSummary);
                            }
                        }
                    }
                }
            }
            if (l_newSummary.size() > 0) {
                insert l_newSummary;
                for(litify_pm__Treatment__c item : l_new){
                    if(item.litify_pm__Injury__c != null && item.litify_pm__Doctor_Facility__c  != null && item.Treatment_Summary__c == null) {
                        litify_pm__Injury__c injury = m_injuries.get(item.litify_pm__Injury__c);
                        if (injury != null) {
                            litify_pm__Matter__c matter = m_matters.get(injury.litify_pm__Matter__c);
                            if (matter != null) {
                                for(Treatment_Summary__c summary : l_newSummary) {
                                    if (item.litify_pm__Doctor_Facility__c == summary.Doctor_Facility__c && summary.Matter__c == matter.Id) {
                                        item.Treatment_Summary__c = summary.Id;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }                
            }
        }
    }
    public void OnAfterInsert(List<litify_pm__Treatment__c> l_new)  {
        Set<Id> s_Ids = new Set<Id>();
        for(litify_pm__Treatment__c item : l_new){
            if(item.Treatment_Summary__c != null) {
                s_Ids.add(item.Treatment_Summary__c);
            }
        }
        if (s_Ids.size() > 0) {
            updateSummary(s_Ids);
        }
    }
    public void OnBeforeUpdate(List<litify_pm__Treatment__c > l_old, List<litify_pm__Treatment__c > l_new, Map<Id, litify_pm__Treatment__c > m_old,  Map<Id, litify_pm__Treatment__c > m_new)  {
    	Set<Id> s_injuryIds = new Set<Id>();
        for(litify_pm__Treatment__c item : l_new){
            if(item.litify_pm__Injury__c != null && item.litify_pm__Doctor_Facility__c  != null && item.litify_pm__Doctor_Facility__c != m_old.get(item.Id).litify_pm__Doctor_Facility__c) {
                s_injuryIds.add(item.litify_pm__Injury__c);
            }
        }
        if (s_injuryIds.size() > 0) {
            Map<Id, litify_pm__Injury__c> m_injuries = new Map<Id, litify_pm__Injury__c>([SELECT ID, litify_pm__Matter__c FROM litify_pm__Injury__c WHERE ID IN :s_injuryIds]);
            Set<Id> s_matterIds = new Set<Id>();
            for (litify_pm__Injury__c injury : m_injuries.values()) {
                s_matterIds.add(injury.litify_pm__Matter__c);
            }
            Map<Id, litify_pm__Matter__c> m_matters = new Map<Id, litify_pm__Matter__c>([SELECT ID, (SELECT ID, Doctor_Facility__c  FROM Treatment_Summaries__r) FROM litify_pm__Matter__c WHERE Id IN:s_matterIds]);
            List<Treatment_Summary__c> l_newSummary = new List<Treatment_Summary__c>();
            for(litify_pm__Treatment__c item : l_new){
                if(item.litify_pm__Injury__c != null && item.litify_pm__Doctor_Facility__c  != null && item.litify_pm__Doctor_Facility__c != m_old.get(item.Id).litify_pm__Doctor_Facility__c) {
                    litify_pm__Injury__c injury = m_injuries.get(item.litify_pm__Injury__c);
                    if (injury != null) {
                        litify_pm__Matter__c matter = m_matters.get(injury.litify_pm__Matter__c);
                        if (matter != null) {
                            Boolean isExist = false;
                            for(Treatment_Summary__c summary : matter.Treatment_Summaries__r) {
                                if (item.litify_pm__Doctor_Facility__c == summary.Doctor_Facility__c) {
                                    isExist = true;
                                    item.Treatment_Summary__c = summary.Id;
                                    break;
                                }
                            }
                            for(Treatment_Summary__c summary : l_newSummary) {
                                if (item.litify_pm__Doctor_Facility__c == summary.Doctor_Facility__c  && summary.Matter__c == matter.Id) {
                                    isExist = true;
                                    //item.Treatment_Summary__c = summary.Id;
                                    break;
                                }
                            }
                            if (isExist == false) {
                                Treatment_Summary__c newSummary = new Treatment_Summary__c();
                                newSummary.Matter__c  = matter.Id;
                                newSummary.Doctor_Facility__c  = item.litify_pm__Doctor_Facility__c;
                                l_newSummary.add(newSummary);
                            }
                        }
                    }
                }
            }
            if (l_newSummary.size() > 0) {
                insert l_newSummary;
                for(litify_pm__Treatment__c item : l_new){
                    if(item.litify_pm__Injury__c != null && item.litify_pm__Doctor_Facility__c  != null  && item.litify_pm__Doctor_Facility__c != m_old.get(item.Id).litify_pm__Doctor_Facility__c) {
                        litify_pm__Injury__c injury = m_injuries.get(item.litify_pm__Injury__c);
                        if (injury != null) {
                            litify_pm__Matter__c matter = m_matters.get(injury.litify_pm__Matter__c);
                            if (matter != null) {
                                for(Treatment_Summary__c summary : l_newSummary) {
                                    if (item.litify_pm__Doctor_Facility__c == summary.Doctor_Facility__c && summary.Matter__c == matter.Id) {
                                        item.Treatment_Summary__c = summary.Id;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }                
            }
        }
    }
    
    public void OnAfterUpdate(List<litify_pm__Treatment__c > l_old, List<litify_pm__Treatment__c > l_new, Map<Id, litify_pm__Treatment__c > m_old,  Map<Id, litify_pm__Treatment__c > m_new)  {
        Set<Id> s_Ids = new Set<Id>();
        for(litify_pm__Treatment__c item : l_new){
            if(item.Treatment_Summary__c != null && (item.litify_pm__Doctor_Facility__c != m_old.get(item.Id).litify_pm__Doctor_Facility__c ||
                                                     item.litify_pm__Injury__c != m_old.get(item.Id).litify_pm__Injury__c || 
                                                     item.litify_pm__Treatment_Date__c != m_old.get(item.Id).litify_pm__Treatment_Date__c|| 
                                                     item.litify_pm__Treatment__c   != m_old.get(item.Id).litify_pm__Treatment__c   || 
                                                     item.litify_pm__Treatment_Notes__c != m_old.get(item.Id).litify_pm__Treatment_Notes__c    || 
                                                     item.litify_pm__Treatment_Status__c != m_old.get(item.Id).litify_pm__Treatment_Status__c  || 
                                                     item.litify_pm__Treatment_Completed__c != m_old.get(item.Id).litify_pm__Treatment_Completed__c ||
                                                     item.Next_Treatment_Date__c != m_old.get(item.Id).Next_Treatment_Date__c
                                                       )) {
                                                           s_Ids.add(item.Treatment_Summary__c);
                                                           s_Ids.add(m_old.get(item.Id).Treatment_Summary__c);
                                                     }
        }
        if (s_Ids.size() > 0) {
            updateSummary(s_Ids);
        }
    }
    
    public void OnAfterDelete(List<litify_pm__Treatment__c > l_old, Map<ID, litify_pm__Treatment__c > m_old){ 
        Set<Id> s_Ids = new Set<Id>();
        for(litify_pm__Treatment__c item : l_old){
            if(item.Treatment_Summary__c != null) {
                s_Ids.add(item.Treatment_Summary__c);
            }
        }
        if (s_Ids.size() > 0) {
            updateSummary(s_Ids);
        }
    }
    
    public static void updateSummary(Set<Id> s_ids) {
        List<Treatment_Summary__c > l_summaries = [SELECT ID, 
                                                   of_Treatments__c , All_Treatments_Completed__c ,   
                                                   Body_Parts__c , Doctor_Facility__c , 
                                                   First_Treatment_Date__c , Last_Treatment_Date__c , 
                                                   Next_Treatment_Date__c , Summary__c , 
                                                   Treatments__c, 
                                                   (SELECT ID, litify_pm__Body_Part__c , Next_Treatment_Date__c ,
                                                    litify_pm__Treatment__c , litify_pm__Treatment_Completed__c ,
                                                    litify_pm__Treatment_Date__c , litify_pm__Treatment_Notes__c , litify_pm__Treatment_Status__c 
                                                    FROM Treatments__r ORDER BY litify_pm__Treatment_Date__c ASC) FROM Treatment_Summary__c  WHERE Id IN: s_ids];
        List<Treatment_Summary__c> l_delete = new List<Treatment_Summary__c>();
        List<Treatment_Summary__c> l_update = new List<Treatment_Summary__c>();
        for (Treatment_Summary__c summary : l_summaries) {
            if (summary.Treatments__r.size() > 0) {
                Set<String> s_treatments = new Set<String>();
                Set<String> s_parts = new Set<String>();
                List<String> l_summary = new List<String>();
                Boolean isAllCompleted = true;
                Date fisrtDate = null;
                Date lastDate = null;
                Date nextDate = null;
                for (litify_pm__Treatment__c treatment : summary.Treatments__r) {
                    if (isAllCompleted && treatment.litify_pm__Treatment_Completed__c == false) {
                        isAllCompleted = false;
                    }
                    if (treatment.litify_pm__Treatment__c != null) {
                        s_treatments.add(treatment.litify_pm__Treatment__c);
                    }
                    if (treatment.litify_pm__Treatment_Notes__c != null) {
                        l_summary.add(treatment.litify_pm__Treatment_Notes__c);
                    }
                    if (treatment.litify_pm__Body_Part__c != null) {
                        s_parts.add(treatment.litify_pm__Body_Part__c);
                    }
                    if (fisrtDate == null || fisrtDate > treatment.litify_pm__Treatment_Date__c) {
                        fisrtDate = treatment.litify_pm__Treatment_Date__c;
                    }
                    if (lastDate == null || lastDate < treatment.litify_pm__Treatment_Date__c) {
                        lastDate = treatment.litify_pm__Treatment_Date__c;
                    }
                    if (treatment.litify_pm__Treatment_Completed__c == false && (nextDate == null || nextDate > treatment.Next_Treatment_Date__c)) {
                        nextDate = treatment.Next_Treatment_Date__c;
                    }
                }     
                summary.of_Treatments__c = summary.Treatments__r.size();
                summary.All_Treatments_Completed__c = isAllCompleted;
                summary.Treatments__c = String.join(new List<String>(s_treatments),';');
                summary.Body_Parts__c = String.join(new List<String>(s_parts),';');
                summary.Summary__c = String.join(l_summary,'\n');
                summary.Next_Treatment_Date__c = nextDate;
                summary.Last_Treatment_Date__c = lastDate;
                summary.First_Treatment_Date__c = fisrtDate;
                l_update.add(summary);
                
            }
            else {
                l_delete.add(summary);
            }
            
            
        }
        if (l_delete.size() > 0) {
            delete l_delete;
        }
        if (l_update.size () > 0) {
            update l_update;
        }
    }
}