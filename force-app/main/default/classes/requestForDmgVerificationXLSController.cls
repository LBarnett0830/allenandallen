public without sharing class requestForDmgVerificationXLSController {
    
    public string filename{get;set;}
    public string reportHeader{get;set;}
    public string xmlheader{get;set;}
    public string endfile{get;set;}
    public list<reportWrapper>listReqWrapper{get;set;}
    public string baseUrl{get;set;}
    public string userName{get;set;}
    
    public requestForDmgVerificationXLSController(){
        
        try{
            
            set<id> matterIds = new set<id>();
            map<string,list<litify_pm__Damage__c>>mapProviderClientWithDmgs =new map<string,list<litify_pm__Damage__c>>();
            map<string,list<clientWrapper>>mapProviderWithClientWrps =new map<string,list<clientWrapper>>();
            map<string,Account>mapProviders =new map<string,Account>();
            map<string,Account>mapClients =new map<string,Account>();
            
            listReqWrapper = new list<reportWrapper>();
            xmlheader ='<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
            endfile = '</Workbook>';
            baseUrl= System.Url.getSalesforceBaseUrl().toExternalForm();
            
            userName= userinfo.getName();
            
            string userId= userInfo.getUserId();//'0052K00000A8NJRQA3';// 
            
            for(litify_pm__Request__c objReq:[select id,litify_pm__Matter__c from litify_pm__Request__c 
                                              where Assigned_To__c=:userId and
                                              Submit_to_Accounting__c=true and All_Damages_Verified__c=null and
                                              litify_pm__Matter__c<>null ])
            {
                matterIds.add(objReq.litify_pm__Matter__c);
            }
            
            
            if(matterIds.size()>0){
                
                string key='';
                for(litify_pm__Damage__c objDmg:[select id,Name,Account__c,litify_pm__Amount_Billed__c,
                                                 litify_pm__Amount_Paid__c,litify_pm__Amount_Due__c,Balance_Due__c,Accounting_Comments__c,
                                                 litify_pm__Service_Start_Date__c,litify_pm__Service_End_Date__c,Damage_Verification_Request_Date__c,
                                                 litify_pm__Provider__r.litify_pm__Party__c,
                                                 litify_pm__Provider__r.litify_pm__Party__r.Name,
                                                 litify_pm__Provider__r.litify_pm__Party__r.Billing_Phone__c,
                                                 litify_pm__Provider__r.litify_pm__Party__r.Phone,
                                                 litify_pm__Matter__c,litify_pm__Matter__r.Name,
                                                 litify_pm__Matter__r.litify_pm__Client__c,
                                                 litify_pm__Matter__r.litify_pm__Client__r.BillingAddress,
                                                 litify_pm__Matter__r.litify_pm__Client__r.litify_pm__Date_of_birth__c,
                                                 litify_pm__Matter__r.litify_pm__Client__r.Social_Security_Number__c ,
                                                 litify_pm__Matter__r.litify_pm__Client__r.Name                                                 
                                                 from litify_pm__Damage__c
                                                 where litify_pm__Matter__c in:matterIds and
                                                 Damage_Verification_Request_Date__c<>null and
                                                 Damage_Verification_Completion_Time__c=null 
                                                 order by litify_pm__Provider__r.litify_pm__Party__c ASC NULLS FIRST
                                                 //litify_pm__Provider__r.litify_pm__Party__c<>null and 
                                                 // litify_pm__Matter__r.litify_pm__Client__c<>null 
                                                ])
                {
                    key = objDmg.litify_pm__Provider__r.litify_pm__Party__c + '##'+objDmg.litify_pm__Matter__r.litify_pm__Client__c;
                    system.debug(key);
                    system.debug(objDmg.litify_pm__Matter__c);
                    if(!mapProviderClientWithDmgs.containsKey(key)){
                        mapProviderClientWithDmgs.put(key,new list<litify_pm__Damage__c>{objDmg});
                    }
                    else{
                        list<litify_pm__Damage__c>exist = mapProviderClientWithDmgs.get(key);
                        exist.add(objDmg);
                        mapProviderClientWithDmgs.put(key,exist);
                    }
                    
                    if(!mapProviders.containsKey(objDmg.litify_pm__Provider__r.litify_pm__Party__c)){
                        mapProviders.put(objDmg.litify_pm__Provider__r.litify_pm__Party__c,objDmg.litify_pm__Provider__r.litify_pm__Party__r);
                    }
                    if(!mapClients.containsKey(objDmg.litify_pm__Matter__r.litify_pm__Client__c)){
                        mapClients.put(objDmg.litify_pm__Matter__r.litify_pm__Client__c,objDmg.litify_pm__Matter__r.litify_pm__Client__r);
                    }
                }
                
                system.debug(mapProviderClientWithDmgs.keyset());
                if(mapProviderClientWithDmgs.keyset().size()>0){
                    
                    string providerId='',clientId='',clientAddress='';
                    
                    
                    for(string providerClient:mapProviderClientWithDmgs.keySet()){
                        providerId = providerClient.split('##')[0];
                        clientId = providerClient.split('##')[1];
                        
                        providerId= providerId==null?'':providerId;
                        clientWrapper objClientWrapper = new clientWrapper();
                        clientAddress='';
                        
                        if( mapClients.containsKey(clientId)){
                            
                            objClientWrapper.clientName = mapClients.get(clientId).Name;
                            if(mapClients.get(clientId).BillingAddress!=null){
                                
                                objClientWrapper.clientStreet = mapClients.get(clientId).BillingAddress.getStreet();
                                objClientWrapper.clientCity = mapClients.get(clientId).BillingAddress.getCity();
                                objClientWrapper.clientState = mapClients.get(clientId).BillingAddress.getState();
                                objClientWrapper.clientZip = mapClients.get(clientId).BillingAddress.getPostalCode();
                                
                                if(!string.isempty( objClientWrapper.clientStreet)){
                                    clientAddress=   objClientWrapper.clientStreet;  
                                }
                                if(!string.isempty(clientAddress)){
                                    if(!string.isempty( objClientWrapper.clientCity)){
                                        clientAddress= clientAddress + ', '+objClientWrapper.clientCity;
                                    }
                                }
                                else{
                                    if(!string.isempty( objClientWrapper.clientCity)){
                                        clientAddress= objClientWrapper.clientCity;
                                    }
                                }
                                
                                if(!string.isempty(clientAddress)){
                                    if(!string.isempty( objClientWrapper.clientState)){
                                        clientAddress= clientAddress + ', '+objClientWrapper.clientState;
                                    }
                                }
                                else{
                                    if(!string.isempty( objClientWrapper.clientState)){
                                        clientAddress= objClientWrapper.clientState;
                                    }
                                }
                                if(!string.isempty( objClientWrapper.clientZip)){
                                    if(!string.isempty( objClientWrapper.clientState)){
                                        clientAddress=clientAddress+' '+ objClientWrapper.clientZip;
                                    }
                                    else{
                                        if(!string.isempty(clientAddress)){
                                            clientAddress=clientAddress+', '+ objClientWrapper.clientZip;
                                        }
                                        else{
                                            clientAddress=objClientWrapper.clientZip;
                                        }
                                    }
                                }
                                
                            }
                            
                            objClientWrapper.clientAddress = clientAddress;
                            objClientWrapper.clientDOB = mapClients.get(clientId).litify_pm__Date_of_birth__c;
                            objClientWrapper.clientSSN = mapClients.get(clientId).Social_Security_Number__c;
                             
                        }
                        
                        
                        objClientWrapper.listDamages = mapProviderClientWithDmgs.get(providerClient); 
                        system.debug( objClientWrapper.listDamages.size());
                        
                        if(!mapProviderWithClientWrps.containsKey(providerId)){
                            mapProviderWithClientWrps.put(providerId, new list<clientWrapper>{objClientWrapper});
                        }
                        else{
                            list<clientWrapper>exist = mapProviderWithClientWrps.get(providerId);
                            exist.add(objClientWrapper);
                            mapProviderWithClientWrps.put(providerId,exist);
                        }
                        
                    }                    
                    
                    if(mapProviderWithClientWrps.keyset().size()>0){                        
                        
                        
                        for(string provId :mapProviderWithClientWrps.keyset()){
                            
                            list<clientWrapper> listClientWrps = new list<clientWrapper>();
                            list<litify_pm__Damage__c>listDamages = new list<litify_pm__Damage__c>();
                            provId= provId==null?'':provId;
                            system.debug('provId= '+provId);
                            
                            reportWrapper objWrapper = new reportWrapper();
                            if( mapProviders.containsKey(provId)){
                                objWrapper.providerName = mapProviders.get(provId).Name;
                                objWrapper.providerBillingPhone = mapProviders.get(provId).Billing_Phone__c;
                                objWrapper.providerPhone = mapProviders.get(provId).Phone;
                            }
                                                       
                            for(integer i=0;i<mapProviderWithClientWrps.get(provId).size();i++){                                
                                
                                if(i==0){
                                    clientWrapper objFirstClientWrp = mapProviderWithClientWrps.get(provId)[0];
                                    for(integer j=0;j<objFirstClientWrp.listDamages.size();j++){
                                        
                                        if(j==0){
                                            objFirstClientWrp.objFirstDamage = objFirstClientWrp.listDamages[0];
                                        }
                                        else{
                                            listDamages.add(objFirstClientWrp.listDamages[j]);
                                        }
                                    }
                                    objFirstClientWrp.listDamages=listDamages;
                                    objWrapper.objFirstClientWrp = objFirstClientWrp; 
                                }
                                else{
                                    
                                    listDamages = new list<litify_pm__Damage__c>();
                                    clientWrapper objClientWrp = mapProviderWithClientWrps.get(provId)[i];
                                    for(integer j=0;j<objClientWrp.listDamages.size();j++){
                                        
                                        if(j==0){
                                            objClientWrp.objFirstDamage = objClientWrp.listDamages[0];
                                        }
                                        else{
                                            listDamages.add(objClientWrp.listDamages[j]);
                                        }
                                    }
                                    objClientWrp.listDamages=listDamages;
                                    listClientWrps.add(objClientWrp);
                                }
                            }
                            
                            
                            objWrapper.listClientWrapper = listClientWrps;
                            listReqWrapper.add(objWrapper);
                            
                            
                        }
                    }
                }
                
            }
            
            system.debug(listReqWrapper.size());
            
            reportHeader= 'My Requests for Damage Verification';
            filename='My_Requests_for_Damage_Verification';
        }
        catch(Exception ex){}
    }
    
    public class clientWrapper{       
        
        public string clientName{get;set;}
        public string clientStreet{get;set;}
        public string clientCity{get;set;}
        public string clientState{get;set;}
        public string clientZip{get;set;}
        public date clientDOB{get;set;}
        public string clientSSN{get;set;}
        public string clientAddress{get;set;}
        
        public string matterName{get;set;}
        public litify_pm__Damage__c objFirstDamage{get;set;}
        public list<litify_pm__Damage__c>listDamages{get;set;}
    }
    
    public class reportWrapper{
        
        public string providerName{get;set;}
        public string providerBillingPhone{get;set;}
        public string providerPhone{get;set;}
        public clientWrapper objFirstClientWrp{get;set;}
        public list<clientWrapper> listClientWrapper{get;set;}  
    }
}