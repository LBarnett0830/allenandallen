({
	handleGenerateStatement : function(component, event, helper) {
         var statementType = component.get("v.statementType");
        if(statementType==undefined || statementType==''){
             var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please select Statement type.",
                        "type": 'error'
                    });
                    toastEvent.fire();
        }
        else{
            helper.generateStatement(component);
        }
		
	},
     handleCancel : function(component, event, helper) {
        var isClassic=  component.get("v.isClassic");
        var resolutionId =component.get("v.recordId");
        if(isClassic){
            window.location='/'+resolutionId;
        }
        else{
            $A.get("e.force:closeQuickAction").fire();
        }
        
        
        
    },
})