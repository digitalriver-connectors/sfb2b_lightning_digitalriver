/**
 * @description       : 
 * @author            : Girish Kalidindi
 * @group             : 
 * @last modified on  : 04-08-2021
 * @last modified by  : Girish Kalidindi
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   04-08-2021   Girish Kalidindi   Initial Version
**/
public with sharing class DRB2B_WebhookException extends DCM_Exception {

    public DRB2B_WebhookException(String methodName, String errorMessage) {
        super(methodName, errorMessage);
        this.stackTraceAsString = getStackTraceForCustomExceptions();
    }

    /*public DRB2B_WebhookException(String methodName, String customExceptionMessage, String parentExceptionMessage, String stackTrace) {
        super(methodName, customExceptionMessage, parentExceptionMessage, stackTrace);
    }*/

}