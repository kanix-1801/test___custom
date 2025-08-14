({
    doInit: function(component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.userId", userId);
        
        console.log('🔔 Urgent Notification Display loaded for user:', userId);
        
        helper.subscribeToUrgentSessions(component);
    },
    
    doDestroy: function(component, event, helper) {
        helper.unsubscribeFromEvents(component);
    },
    
    openSession: function(component, event, helper) {
        var sessionId = event.getSource().get("v.value");
        console.log('Opening session:', sessionId);
        
        var navService = component.find("navService");
        var pageReference = {
            "type": "standard__recordPage",
            "attributes": {
                "recordId": sessionId,
                "objectApiName": "MessagingSession",
                "actionName": "view"
            }
        };
        navService.navigate(pageReference);
    },
    
    dismissNotification: function(component, event, helper) {
        var index = parseInt(event.getSource().get("v.value"));
        var notifications = component.get("v.notifications");
        notifications.splice(index, 1);
        
        // Reindex notifications
        for(var i = 0; i < notifications.length; i++) {
            notifications[i].index = i;
        }
        
        component.set("v.notifications", notifications);
        component.set("v.hasNotifications", notifications.length > 0);
    },
    
    addUrgentNotification: function(component, sessionData) {
        console.log('🚨 Adding urgent notification to display');
        
        var notifications = component.get("v.notifications") || [];
        var timestamp = new Date().toLocaleTimeString();
        
        var newNotification = {
            sessionId: sessionData.Session_Id__c,
            customerName: sessionData.Customer_Name__c || 'Unknown Customer',
            message: sessionData.Message__c,
            timestamp: timestamp,
            index: notifications.length
        };
        
        notifications.unshift(newNotification); // Add to beginning
        component.set("v.notifications", notifications);
        component.set("v.hasNotifications", true);
        
        // Browser alert as backup
        alert("🚨 URGENT SESSION ASSIGNED!\nCustomer: " + newNotification.customerName + "\nTime: " + timestamp);
        
        // Auto-open after 3 seconds unless dismissed
        setTimeout(function() {
            var currentNotifications = component.get("v.notifications");
            if (currentNotifications.length > 0 && currentNotifications[0].sessionId === sessionData.Session_Id__c) {
                // Still there, auto-open
                var navService = component.find("navService");
                var pageReference = {
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId": sessionData.Session_Id__c,
                        "objectApiName": "MessagingSession",
                        "actionName": "view"
                    }
                };
                navService.navigate(pageReference);
            }
        }, 3000);
    }
})