public with sharing class DocusignTemplateMenuController {
    @AuraEnabled
    public static List<Map<String, String>> getTemplates(Id recordId) {
        List<Map<String, String>> l_results = new List<Map<String, String>>();
        if (recordId != null) {
            String objectName = recordId.getSobjectType().getDescribe().getName();
            List<dfsle__EnvelopeConfiguration__c> l_envelops = [SELECT Id, Name, dfsle__IsQuickSend__c FROM dfsle__EnvelopeConfiguration__c WHERE dfsle__SourceObject__c =:objectName AND dfsle__Active__c = true];
            if (l_envelops.size() > 0) {
                for (dfsle__EnvelopeConfiguration__c envelop : l_envelops) {
                    Map<String, String> m_temp = new Map<String, String>();
                    Pagereference pg = new PageReference('/apex/dfsle__sending');
                    pg.getParameters().put('sId', recordId);
                    pg.getParameters().put('templateId', envelop.Id);
                    pg.getParameters().put('quickSend', String.Valueof(envelop.dfsle__IsQuickSend__c));
                    pg.getParameters().put('title', envelop.Name);
                    pg.getParameters().put('recordId', recordId);
                    m_temp.put('value',  pg.getUrl());
                    m_temp.put('label', envelop.Name);
                    l_results.add(m_temp);
                } 
            }
        }
        return l_results;
    }
}