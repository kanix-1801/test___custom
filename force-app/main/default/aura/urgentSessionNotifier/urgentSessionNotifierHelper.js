({
    subscribeToUrgentSessions: function(component) {
        var empApi = component.find("empApi");
        var channelName = component.get("v.channelName");
        var userId = component.get("v.userId");
        
        // Callback function for handling events
        var callback = function(response) {
            console.log("Platform event received: ", response);
            
            var payload = response.data.payload;
            
            // Check if this event is for the current user
            if (payload.Agent_Id__c === userId) {
                console.log("Urgent session assigned to current user");
                component.getEvent("c.handleUrgentSession").fire({
                    sessionData: payload
                });
                
                // Call controller method to handle the session
                var controller = component.getController();
                controller.handleUrgentSession(component, payload);
            }
        };
        
        // Error handler
        var errorHandler = function(message) {
            console.error("EMP API subscription error: ", message);
        };
        
        // Subscribe to the platform event
        empApi.subscribe(channelName, -1, callback).then(function(subscription) {
            console.log("Successfully subscribed to: ", channelName);
            console.log("Subscription: ", subscription);
            component.set("v.subscription", subscription);
        }).catch(function(error) {
            console.error("Subscription failed: ", error);
            errorHandler(error);
        });
    },
    
    unsubscribeFromEvents: function(component) {
        var empApi = component.find("empApi");
        var subscription = component.get("v.subscription");
        
        if (subscription) {
            empApi.unsubscribe(subscription, function(result) {
                console.log("Unsubscribed from platform events: ", result);
            });
        }
    }
})