({
    doInit: function(component, event, helper) {
        // Get current user ID
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.userId", userId);
        
        console.log('UrgentSessionNotifier: Component loaded for user:', userId);
        
        // Test toast using $A.get instead of component.find
        setTimeout(function() {
            $A.get("e.force:showToast").setParams({
                "variant": "success",
                "title": "Urgent Notifier Loaded",
                "message": "Component is working for user: " + userId,
                "mode": "sticky"
            }).fire();
            console.log('Diagnostic toast should have appeared');
        }, 1000);
        
        // Subscribe to platform events
        helper.subscribeToUrgentSessions(component);
    },
    
    doDestroy: function(component, event, helper) {
        helper.unsubscribeFromEvents(component);
    },
    
    handleUrgentSession: function(component, sessionData) {
        console.log('🚨 Handling urgent session:', sessionData);
        
        // Method 1: Use force:showToast event
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "variant": "warning",
            "mode": "sticky",
            "title": "🚨 URGENT: Message Session Assigned",
            "message": sessionData.Message__c || "Customer: " + sessionData.Customer_Name__c,
            "type": "warning"
        });
        toastEvent.fire();
        console.log('🔥 Toast event fired');
        
        // Method 2: Browser alert as backup
        alert("🚨 URGENT SESSION ASSIGNED!\n" + 
              "Customer: " + sessionData.Customer_Name__c + "\n" +
              "Session ID: " + sessionData.Session_Id__c);
        
        // Method 3: Navigate to session
        setTimeout(function() {
            var navService = component.find("navService");
            if (navService) {
                var pageReference = {
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId": sessionData.Session_Id__c,
                        "objectApiName": "MessagingSession",
                        "actionName": "view"
                    }
                };
                navService.navigate(pageReference);
                console.log('🔄 Navigation triggered');
            } else {
                // Fallback navigation
                window.open('/lightning/r/MessagingSession/' + sessionData.Session_Id__c + '/view', '_blank');
            }
        }, 2000);
    }
})