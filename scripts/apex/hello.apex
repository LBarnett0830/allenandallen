// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

String recid = 'a0oRu000002We1BIAS';

List<litify_pm__Damage__c> damages = [SELECT Name, Resolution__c, Balance_Due__c FROM litify_pm__Damage__c WHERE Resolution__c =: recid AND Escrow__c = false];

Decimal totalDue = 0.0;

for(litify_pm__Damage__c damage: damages) {
    totalDue += damage.Balance_Due__c;
}

System.debug('Total Due ===> ' + totalDue);