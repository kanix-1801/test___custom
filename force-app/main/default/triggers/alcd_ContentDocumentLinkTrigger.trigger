trigger alcd_ContentDocumentLinkTrigger on ContentDocumentLink
(after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    private alcd_ContentDocumentLinkHandler handler = new alcd_ContentDocumentLinkHandler();
    //before
    if (Trigger.isBefore && Trigger.isInsert){
    }
    if (Trigger.isBefore && Trigger.isUpdate){
    }
    if (Trigger.isBefore && Trigger.isDelete){
    }
    //after
    if (Trigger.isAfter && Trigger.isInsert){
        handler.callCDLFlow(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate){
    }
    if (Trigger.isAfter && Trigger.isDelete){
    }
    if (Trigger.isAfter && Trigger.isUndelete){
    }
    
}