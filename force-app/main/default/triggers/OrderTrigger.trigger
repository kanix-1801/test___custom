/**
 * Created by chana.landau on 16/03/2022.
 */

trigger OrderTrigger on Order (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    OrderHandler handler = new OrderHandler(); 
    //before
    if (Trigger.isBefore && Trigger.isInsert){
    }
    if (Trigger.isBefore && Trigger.isUpdate){
    }
    if (Trigger.isBefore && Trigger.isDelete){
    }
    //after
    if (Trigger.isAfter && Trigger.isInsert){
    }
    if (Trigger.isAfter && Trigger.isUpdate){
        handler.calloutWhenStatusChange( Trigger.newMap, Trigger.oldMap);

    }
    if (Trigger.isAfter && Trigger.isDelete){
    }
    if (Trigger.isAfter && Trigger.isUndelete){
    }

}