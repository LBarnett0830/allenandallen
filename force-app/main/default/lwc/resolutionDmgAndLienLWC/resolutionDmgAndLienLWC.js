import { LightningElement, wire, api } from 'lwc';
import { damageTableColumns, liensTableColumns } from './constants';
import getSelectedDamages from '@salesforce/apex/ResolutionDmgAndLienLWCController.getSelectedDamages'
import getAvailableDamages from '@salesforce/apex/ResolutionDmgAndLienLWCController.getAvailableDamages'
import getResolution from '@salesforce/apex/ResolutionDmgAndLienLWCController.getResolution';
import getSelectedLiens from '@salesforce/apex/ResolutionDmgAndLienLWCController.getSelectedLiens';

export default class ResolutionDmgAndLienLWC extends LightningElement {
    @api recordId;
    @api debugMode;
    damageColumns = damageTableColumns;
    lienColumns = liensTableColumns;
    selectedDamageData = [];
    availableDamageData = [];
    selectedLiensData = [];
    availableLiensData = [];

    @wire(getSelectedDamages)
    wiredDamages({ error, data }) {
        if (data) {
            this.selectedDamageData = this.mapDamagesData(data);
        } else if (error) {
            console.error('Error fetching damages:', error);
        }
    }

    @wire(getSelectedLiens)
    wiredLiens({ error, data }) {
        if (data) {
            this.selectedLiensData = this.mapLiensData(data);
        } else if (error) {
            console.error('Error fetching liens:', error);
        }
    }

    mapDamagesData(damages) {
        return damages.map(damage => ({
            name: damage.Name,  
            providerName: damage.litify_pm__Provider__r.litify_pm__Party__c, 
            payee: damage.Party_Name__c,  
            balanceDue: damage.Balance_Due__c,
            type: damage.litify_pm__Type__c, 
            verifyDate: damage.Damage_Verification_Completion_Time__c,  
            escrow: damage.Escrow__c  
        }));
    }
    
    mapLiensData(liens) {
        return liens.map(lien => ({
            name: lien.Name,  
            providerName: lien.litify_pm__Provider__r.litify_pm__Party__c,  
            payee: lien.Party_Name__c,  
            balanceDue: lien.Balance_Due__c,  
            type: lien.litify_pm__Type__c, 
            verifyDate: lien.Damage_Verification_Completion_Time__c, 
            escrow: lien.Escrow__c  
        }));
    }
    
}