// Determines the taxes for the cart
global with sharing class DRB2B_SyncTax {

    // This invocable method only expects one ID
    @InvocableMethod(callout=true label='Prepare the taxes' description='Runs a synchronous version of taxes' category='B2B Commerce')
    global static List<ResponseModel> syncTax(List<ID> cartIds) {
        // Validate the input
        if (cartIds == null || cartIds.size() != 1) {
            String errorMessage = 'A cart id must be included to B2BSyncTax'; // Get wording from doc!!!
            // Sync non-user errors skip saveCartValidationOutputError
            throw new CalloutException (errorMessage);
        }
        List<ResponseModel> resultList = new List<ResponseModel>();
        for(Id  cartId: cartIds){
           DRB2B_TaxCalculationService.ResponseModel response =  DRB2B_TaxCalculationService.startCartProcessAsync(cartId, null);
           if(response != null && response.status =='Error'){
                saveCartValidationOutputError(response.message, cartId);
                ResponseModel result = new ResponseModel();
                result.status=response.status;
                resultList.add(result);
           }
        }
        
        return resultList;
    }

// TODO clean this part of code
    private static void saveCartValidationOutputError(String errorMessage, Id cartId) {
            // For the error to be propagated to the user, we need to add a new CartValidationOutput record.
            // The following fields must be populated:
            // BackgroundOperationId: Foreign Key to the BackgroundOperation
            // CartId: Foreign key to the WebCart that this validation line is for
            // Level (required): One of the following - Info, Error, or Warning
            // Message (optional): Message displayed to the user (maximum 255 characters)
            // Name (required): The name of this CartValidationOutput record. For example CartId
            // RelatedEntityId (required): Foreign key to WebCart, CartItem, CartDeliveryGroup
            // Type (required): One of the following - SystemError, Inventory, Taxes, Pricing, Shipping, Entitlement, Other
            CartValidationOutput cartValidationError = new CartValidationOutput(
                CartId = cartId,
                Level = 'Error',
                Message = errorMessage.left(255),
                Name = (String)cartId,
                RelatedEntityId = cartId,
                Type = 'Taxes'
            );
            insert(cartValidationError);
    }


    global class ResponseModel{
        @InvocableVariable
        global String status;
    }
}
