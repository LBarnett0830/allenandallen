({
	defineURL : function(cmp) {
		var action = cmp.get('c.getTemplates');
        let recId =  cmp.get('v.recordId');
        console.log(recId);
        action.setParams({ 
            recordId : recId
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let params = response.getReturnValue();
                console.log('params=='+params)
                if (params.length > 0) {
                    cmp.set('v.selectedValue', params[0].value);
                }
                cmp.set('v.options', params);
            } else if (state === "ERROR") {
            var errors = a.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        title : "Docusign Template Error",
                        type:"error",
                        message :" Error message: " + errors[0].message
                    });
                    resultsToast.fire();
                }
                else {
                    console.log("Unknown error");
                }
            } else {
                console.log("Unknown error");
            }
            }
        }));
        $A.enqueueAction(action);

	}
})