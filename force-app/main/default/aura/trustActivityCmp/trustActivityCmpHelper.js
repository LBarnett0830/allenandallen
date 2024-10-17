({
    getMatterWrapper : function(cmp) {
        cmp.set("v.showError",false);
        cmp.set("v.showSpinner",true);
        var recordId =cmp.get("v.recordId");
        var action = cmp.get('c.getMatterWrapper');
        
        action.setParams({
            'matterId':recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                cmp.set("v.showSpinner",false);
                
                console.log( response.getReturnValue());
                var objWrapper = response.getReturnValue();
                var trustActDetailList = objWrapper.trustActDetailList;
                trustActDetailList.sort(function(a,b){
                    return new Date(a.transactioDate) - new Date(b.transactioDate);
                });
                
                cmp.set("v.matterWrapper",objWrapper);
                
            }
        });
        $A.enqueueAction(action);
    }
})