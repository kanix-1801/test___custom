({
    subscribeToUrgentSessions: function(component) {
        var empApi = component.find("empApi");
        var channelName = component.get("v.channelName");
        var userId = component.get("v.userId");
        
        console.log("🔔 Subscribing to:", channelName);
        
        var callback = function(response) {
            // ADD THIS ALERT FIRST
            alert("DEBUG: Platform event callback triggered!");
            
            console.log("🚨 PLATFORM EVENT RECEIVED - URGENT NOTIFICATION");
            var payload = response.data.payload;
            
            if (payload.Agent_Id__c === userId) {
                console.log("✅ Event for current user - showing notification");
                
                // ADD THIS ALERT TOO
                alert("DEBUG: About to call addUrgentNotification");
                
                var controller = component.getController();
                controller.addUrgentNotification(component, payload);
            }
        };
        
        empApi.subscribe(channelName, -1, callback).then(function(subscription) {
            console.log("✅ Subscribed successfully");
            component.set("v.subscription", subscription);
        }).catch(function(error) {
            console.error("❌ Subscription failed:", error);
        });
    },
    
    unsubscribeFromEvents: function(component) {
        var empApi = component.find("empApi");
        var subscription = component.get("v.subscription");
        
        if (subscription) {
            empApi.unsubscribe(subscription, function(result) {
                console.log("Unsubscribed:", result);
            });
        }
    }
})