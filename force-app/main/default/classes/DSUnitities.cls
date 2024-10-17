public with sharing class DSUnitities {

    public static Boolean isDisabled(){
        litify_pm__Public_Setup__c  setting = litify_pm__Public_Setup__c.getOrgDefaults();
        return (setting != null && (setting.litify_pm__Run_Triggers__c == false));
    }

    public static void updateMatters (List<litify_pm__Matter__c> l_new,  Map<Id, litify_pm__Matter__c> m_old) {
        Map<Id, Id> m_accountContact = new Map<Id, Id>();
        for (litify_pm__Matter__c matter : l_new) {
            if (matter.litify_pm__Client__c != null && (
                m_old == null || (m_old != null && m_old.get(matter.Id).litify_pm__Client__c != matter.litify_pm__Client__c)
            )) {
                m_accountContact.put(matter.litify_pm__Client__c, null);
            }
        }
        if (m_accountContact.size() > 0) {
            for (Account acc : [SELECT Id, (SELECT ID FROM Contacts LIMIT 1) FROM  Account WHERE Id IN: m_accountContact.keySet()]) {
                if (acc.Contacts.size() > 0) {
                    m_accountContact.put(acc.Id, acc.Contacts[0].Id);
                }
            }
            for (litify_pm__Matter__c matter : l_new) {
                if (matter.litify_pm__Client__c != null && m_accountContact.get(matter.litify_pm__Client__c) != null) {
                    matter.Client_Contact_ds__c = m_accountContact.get(matter.litify_pm__Client__c);
                }
            }
        }
        
    }

    public static void updateIntakes (List<litify_pm__Intake__c> l_new,  Map<Id, litify_pm__Intake__c> m_old) {
        Map<Id, Id> m_accountContact = new Map<Id, Id>();
        for (litify_pm__Intake__c record : l_new) {
            if (record.litify_pm__Client__c != null && (
                m_old == null || (m_old != null && m_old.get(record.Id).litify_pm__Client__c != record.litify_pm__Client__c)
            )) {
                m_accountContact.put(record.litify_pm__Client__c, null);
            }
        }
        if (m_accountContact.size() > 0) {
            for (Account acc : [SELECT Id, (SELECT ID FROM Contacts LIMIT 1) FROM  Account WHERE Id IN: m_accountContact.keySet()]) {
                if (acc.Contacts.size() > 0) {
                    m_accountContact.put(acc.Id, acc.Contacts[0].Id);
                }
            }
            for (litify_pm__Intake__c record : l_new) {
                if (record.litify_pm__Client__c != null && m_accountContact.get(record.litify_pm__Client__c) != null) {
                    record.Client_Contact_ds__c = m_accountContact.get(record.litify_pm__Client__c);
                }
            }
        }
    }
        
}