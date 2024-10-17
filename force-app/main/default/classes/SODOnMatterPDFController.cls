public class SODOnMatterPDFController {
    
    public string header{get;set;}
    public litify_pm__Matter__c objMatter{get;set;}
    public string dateOfIncident{get;set;}
    public list<damageWrapper> listTreatmentWrp{get;set;}
    public list<damageWrapper> listFutureTreatmentWrp{get;set;}
    public list<damageWrapper> listWageLossWrp{get;set;}
    public list<damageWrapper> listMiscWrp{get;set;}
    public decimal totalTreatementCharges{get;set;}
    public decimal totalFutureTreatementCharges{get;set;}
    public decimal totalWageLoss{get;set;}
    public decimal totalMisc{get;set;}
    public decimal totalDmgAmount{get;set;}
    
    public SODOnMatterPDFController(){
        string recId= ApexPages.currentPage().getParameters().get('id');
        if(!string.isEmpty(recId)){
            bindData(recId);
        }
        
    }
    
    public void bindData(string matterId){
        
        try{
            
            if(!string.isEmpty(matterId)){
                
                map<string, list<string>> mapDmgTypeWithCategory= new map<string, list<string>>();
                listTreatmentWrp= new list<damageWrapper>();
                listFutureTreatmentWrp= new list<damageWrapper>();
                listWageLossWrp= new list<damageWrapper>();
                listMiscWrp= new list<damageWrapper>();
                totalTreatementCharges=0;
                totalFutureTreatementCharges=0;
                totalWageLoss=0;
                totalMisc=0;
                totalDmgAmount=0;
                
                header='Statement of Damages for';
                 
                
                list<litify_pm__Matter__c> listMatter = [select id,name,litify_pm__Display_Name__c,litify_pm__Client__r.Name,
                                                         litify_pm__Principal_Attorney__r.Name,litify_pm__Incident_date__c,
                                                         litify_pm__Case_Type__c,litify_pm__Case_Type__r.Name,Legal_Assistant__r.Name
                                                         from litify_pm__Matter__c where id=:matterId];
                
                if(listMatter.size()>0){
                    header= header+ ' ' +listMatter[0].litify_pm__Client__r.Name;
                    
                    if(listMatter[0].litify_pm__Incident_date__c!=null){
                        time objTm= time.newInstance(0,0,0,0);
                        dateOfIncident = datetime.newInstance( listMatter[0].litify_pm__Incident_date__c,objTm).format('MM/dd/yyyy');
                    }
                    
                    /*for(SOD_Charge_Vs_Category__mdt objSetting:[select Category__c, Type__c from SOD_Charge_Vs_Category__mdt])
{
if(!mapDmgTypeWithCategory.containsKey(objSetting.Type__c)){
mapDmgTypeWithCategory.put(objSetting.Type__c,new list<string>{objSetting.Category__c});
}
else{
list<string> exists= mapDmgTypeWithCategory.get(objSetting.Category__c);
exists.add(objSetting.Category__c);
mapDmgTypeWithCategory.put(objSetting.Type__c,exists);

}
}*/
                    objMatter = listMatter[0];
                    
                    for(litify_pm__Damage__c objDmg:[select id,name,litify_pm__Amount_Billed__c,litify_pm__Type__c,
                                                     litify_pm__Service_Start_Date__c,litify_pm__Service_End_Date__c,
                                                     Category__c,litify_pm__Comments__c
                                                     from litify_pm__Damage__c
                                                     where litify_pm__Matter__c=:matterId
                                                     order by litify_pm__Service_Start_Date__c nulls first])
                    {
                        damageWrapper objWrp = new damageWrapper();
                        objWrp.damageName= objDmg.Name;
                        objWrp.serviceStartDate= objDmg.litify_pm__Service_Start_Date__c;
                        objWrp.serviceEndDate= objDmg.litify_pm__Service_End_Date__c;
                        objWrp.billedAmount= objDmg.litify_pm__Amount_Billed__c==null?0:objDmg.litify_pm__Amount_Billed__c;
                        objWrp.damageType= objDmg.litify_pm__Type__c;
                        objWrp.comments= objDmg.litify_pm__Comments__c;
                        objWrp.objDmg=objDmg;
                        
                        
                        if(objDmg.Category__c=='TREATMENT CHARGES'){                            
                            listTreatmentWrp.add(objWrp);
                            totalTreatementCharges= totalTreatementCharges+  objWrp.billedAmount;
                        }
                        else if(objDmg.Category__c=='FUTURE TREATMENT CHARGES'){                            
                            listFutureTreatmentWrp.add(objWrp);
                            totalFutureTreatementCharges= totalFutureTreatementCharges+  objWrp.billedAmount;
                        }
                        else if(objDmg.Category__c=='WAGE LOSS'){                            
                            listWageLossWrp.add(objWrp);
                            totalWageLoss=totalWageLoss+  objWrp.billedAmount;
                        }
                        else if(objDmg.Category__c=='MISC'){                            
                            listMiscWrp.add(objWrp);
                            totalMisc=totalMisc+  objWrp.billedAmount;
                        }
                    }
                    
                    totalTreatementCharges= totalTreatementCharges.setScale(2);
                    totalFutureTreatementCharges= totalFutureTreatementCharges.setScale(2);
                    totalWageLoss= totalWageLoss.setScale(2);
                    totalMisc= totalMisc.setScale(2);
                    totalDmgAmount= totalTreatementCharges+totalFutureTreatementCharges+totalWageLoss+totalMisc;
                    
                    Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=Statement of Damages_'+listMatter[0].name+'.pdf');
                    
                }
                
                
            }
        }
        catch(Exception ex){}
    }
    
    public class damageWrapper{
        
        public litify_pm__Damage__c objDmg{get;set;} 
        public string damageType{get;set;}
        public string damageName{get;set;}
        public string comments{get;set;}
        public date serviceStartDate{get;set;}
        public date serviceEndDate{get;set;}
        public decimal billedAmount{get;set;}
        
    }
    
}