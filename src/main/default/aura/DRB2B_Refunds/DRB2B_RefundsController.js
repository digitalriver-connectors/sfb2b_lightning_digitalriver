({  
    handleClick : function (cmp, event, helper) {
    var action = cmp.get("c.getDROrderDetails");
    action.setParams({ orderId : cmp.get("v.recordId") });
    action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            let result = JSON.parse(response.getReturnValue());
            if(typeof result.order.digitalriverv3__DR_Order_Id__c !== "undefined"){
                // Navigate to external url
                var linkToDashBoard = 'https://dashboard.digitalriver.com/orderdetails?id='+result.order.digitalriverv3__DR_Order_Id__c;
                var eUrl= $A.get("e.force:navigateToURL");
                    eUrl.setParams({
                    "url": linkToDashBoard 
                    });
                eUrl.fire();
                $A.get("e.force:closeQuickAction").fire()
            }else{
                $A.enqueueAction(cmp.get('c.showToast2'));
            }
        }
        else if (state === "ERROR") {
            $A.enqueueAction(cmp.get('c.showToast'));
        }
    });
    $A.enqueueAction(action);
    },
    showToast : function(cmp, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": $A.get("$Label.digitalriverv3.DR_Refund_Error"),
            "type": "Error"
        });
        toastEvent.fire();
        $A.get("e.force:closeQuickAction").fire()
    },
    showToast2 : function(cmp, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": $A.get("$Label.digitalriverv3.DR_Refund_DROrderId_Error"),
            "type": "Error"
        });
        toastEvent.fire();
        $A.get("e.force:closeQuickAction").fire()
    }
    
})
