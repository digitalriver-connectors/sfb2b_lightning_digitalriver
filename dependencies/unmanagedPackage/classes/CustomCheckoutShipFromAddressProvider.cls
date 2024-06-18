global class CustomCheckoutShipFromAddressProvider implements digitalriverv3.DRB2B_CheckoutFromAddressProvider {
    global digitalriverv3.DRB2B_Address getAddress(digitalriverv3.DRB2B_CheckoutContext context) {
        Id cartId = context.cartId;
        WebCart cart = [SELECT id, digitalriverv3__DR_Customer_Type__c FROM WebCart WHERE Id = :cartId limit 1];

        digitalriverv3.DRB2B_Address address = new digitalriverv3.DRB2B_Address();
        if(cart.digitalriverv3__DR_Customer_Type__c.equals('individual')) {
            address.country = 'US';
            address.state = 'NY';
            address.postalCode = '31232';
            address.city = 'New York';
            address.line1 = '123 Main St.';
        }
        else {
          address.country = 'US';
            address.state = 'MN';
            address.postalCode = '55369';
            address.city = 'Minnetonka';
            address.line1 = '123 Main St.';     
        }
        return address;
    }
}