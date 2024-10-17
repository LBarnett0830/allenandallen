({
    cancelOrder: function (component, event, helper) {
        helper.cancelOrder(component);
    },
    switchOrderStatus: function (component, event, helper) {
        helper.orderRequest(component);
    },
    changeReceivedByLegalFirm: function (component, event, helper) {
        helper.setReceivedByLegalFirm(component);
    }
})