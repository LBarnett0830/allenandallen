({
	init: function (component, event, helper) {
        helper.defineURL(component);
    },
    handleClick: function (component, event, helper) {

        var urlParam = component.get("v.selectedValue");
        if (urlParam != undefined && urlParam != null) {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
            "url": urlParam
            });
            urlEvent.fire();
        }
        else {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                title : "Docusign Template ",
                type:"warning",
                message :"Please select Template"
            });
            resultsToast.fire();
        }
    },
})