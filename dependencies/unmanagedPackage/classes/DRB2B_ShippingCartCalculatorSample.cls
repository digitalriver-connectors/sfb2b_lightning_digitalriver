// This sample is for the situations where Shipping Calculation needs to be extended or overridden
// via the extension point for the Shipping Calculator. The Custom Apex Class must be linked to the
// Shipping Calculator extension point and then the integration must be linked to the webstore via
// appropriate Setup

// NOTE: Prior to using this script you must create a Product with the name "Shipping Charge for this delivery method" that will be used as the Shipping product. 
// Alternatively you can modify the function getDefaultShippingChargeProduct2Id providing the name of the shipping product for your environment

// This class must extend the CartExtension.ShippingCartCalculator class to be processed.
public class DRB2B_ShippingCartCalculatorSample extends CartExtension.ShippingCartCalculator {
  // You MUST change this to be your service or you must launch your own Third Party Service
  // and add the host in Setup | Security | Remote site settings.
  private static String externalShippingServiceHost = 'https://example.com';

  // You MUST change this to be your service or your URL
  private static String externalShippingURL = externalShippingServiceHost + '/calculate-shipping-rates';

  // You MUST change the useExternalService to True if you want to use the Third Party Service.
  private static Boolean useExternalService = false;

  private static Boolean debugMode = true;

  public virtual override void calculate(CartExtension.CartCalculateCalculatorRequest request) {
    CartExtension.Cart cart = request.getCart();

    systemDebug('DRB2B_ShippingCartCalculatorSample: START');

    try 
    {
    
    //Get the cart type, Digital or Non-Digital
    String drCheckoutType = (String)cart.getCustomField('digitalriverv3__DR_Checkout_Type__c');
             
    // Clean up CVO based on Shipping
    CartExtension.CartValidationOutputList cartValidationOutputList = cart.getCartValidationOutputs();

    for (Integer i = (cartValidationOutputList.size() - 1); i >= 0; i--) {
      CartExtension.CartValidationOutput cvo = cartValidationOutputList.get(i);
      if (cvo.getType() == CartExtension.CartValidationOutputTypeEnum.SHIPPING) {
        cartValidationOutputList.remove(cvo);
      }
    }
    systemDebug('DRB2B_ShippingCartCalculatorSample: 1');

    // To create the Cart delivery group methods, we need to get the ID of the cart delivery group.
    CartExtension.CartDeliveryGroupList cartDeliveryGroups = cart.getCartDeliveryGroups();
    if (cartDeliveryGroups.size() == 0) {
      CartExtension.CartValidationOutput cvo = new CartExtension.CartValidationOutput(
        CartExtension.CartValidationOutputTypeEnum.SHIPPING,
        CartExtension.CartValidationOutputLevelEnum.ERROR
      );
      cvo.setMessage('No Cart Delivery Groups have been defined');
      cartValidationOutputList.add(cvo);
    } else {
      systemDebug('DRB2B_ShippingCartCalculatorSample: 2');
      CartExtension.CartItemList cartItems = cart.getCartItems();
      Integer numberOfUniqueItems = cartItems.size();
      CartExtension.CartDeliveryGroup cartDeliveryGroup = cartDeliveryGroups.get(0);
      CartExtension.CartDeliveryGroupMethodList cartDeliveryGroupMethods = cartDeliveryGroup.getCartDeliveryGroupMethods();
      
      systemDebug('DRB2B_ShippingCartCalculatorSample: 3');
      // Clean up the CartDeliveryGroupMethods
      for (Integer i = (cartDeliveryGroupMethods.size() - 1); i >= 0; i--) {
        CartExtension.CartDeliveryGroupMethod method = cartDeliveryGroupMethods.get(i);
        cartDeliveryGroupMethods.remove(method);
      }
      // To clear selected Cart Delivery Group Method
      cartDeliveryGroup.setSelectedCartDeliveryGroupMethod(null);

      systemDebug('DRB2B_ShippingCartCalculatorSample: 4');

      // Get the Shipping Product
      Id shippingProductId = getDefaultShippingChargeProduct2Id();        

      if(shippingProductId == null) {
        systemDebug('DRB2B_ShippingCartCalculatorSample: 5');
        CartExtension.CartValidationOutput cvo = new CartExtension.CartValidationOutput(CartExtension.CartValidationOutputTypeEnum.SHIPPING,
                CartExtension.CartValidationOutputLevelEnum.ERROR );
        cvo.setMessage('No Shipping Products have been defined');
        cartValidationOutputList.add(cvo);
      } else {
          systemDebug('DRB2B_ShippingCartCalculatorSample: 6');
          String shippingProduct = Id.valueOf(shippingProductId);
          // Create a CartDeliveryGroupMethod record for every shipping option returned from the external service
            if(useExternalService){
                // Get shipping options, including aspects like rates and carriers, from the external service.
                ShippingOptionsAndRatesFromExternalService[] shippingOptionsAndRatesFromExternalService = getShippingOptionsAndRatesFromExternalService(
                  numberOfUniqueItems, cartValidationOutputList
                  );

                  // Create a CartDeliveryGroupMethod record for every shipping option returned from the external
                  // service and every Order Delivery Method that matches
                 if(shippingOptionsAndRatesFromExternalService != null){
                  populateCartDeliveryGroupMethodWithShippingOptions(
                    shippingOptionsAndRatesFromExternalService,
                    cartDeliveryGroupMethods,shippingProduct,
                    cartValidationOutputList
                  );
                }
            } else {    
              systemDebug('DRB2B_ShippingCartCalculatorSample: 7');           
              //Add Free shipping for both Digital and Non-Digital Carts
              CartExtension.CartDeliveryGroupMethod cartDeliveryGroupMethod01 = new CartExtension.CartDeliveryGroupMethod('Delivery Method 1', 0.00, shippingProduct);
              cartDeliveryGroupMethod01.setCarrier('Test Carrier 1');
              cartDeliveryGroupMethod01.setClassOfService('SNC9600');
              cartDeliveryGroupMethods.add(cartDeliveryGroupMethod01);

              if(!drCheckoutType.equalsIgnoreCase('Digital')) {
                  //For Non-Digital Carts, add additional dellivery methods
                  CartExtension.CartDeliveryGroupMethod cartDeliveryGroupMethod02 = new CartExtension.CartDeliveryGroupMethod('Delivery Method 2', 11.99, shippingProduct);
                  cartDeliveryGroupMethod02.setCarrier('Test Carrier 2');
                  cartDeliveryGroupMethod02.setClassOfService('SNC9700');
                  cartDeliveryGroupMethods.add(cartDeliveryGroupMethod02);
                  CartExtension.CartDeliveryGroupMethod cartDeliveryGroupMethod03 = new CartExtension.CartDeliveryGroupMethod('Delivery Method 3', 15.99, shippingProduct);
                  cartDeliveryGroupMethod03.setCarrier('Test Carrier 3');
                  cartDeliveryGroupMethod03.setClassOfService('SNC9800');
                  cartDeliveryGroupMethods.add(cartDeliveryGroupMethod03);
              }
            }
            systemDebug('DRB2B_ShippingCartCalculatorSample: END'); 
         }
      }
    }
    catch (Exception e) {
      systemDebug('DRB2B_ShippingCartCalculatorSample: exception ' + e.getMessage()); 
    } 
  }

   private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
        Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
        randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }

    private Id getDefaultShippingChargeProduct2Id() {
      // In this example we will name the product representing shipping charges 'Shipping Charge for this delivery method'.
      // Check to see if a Product2 with that name already exists.
      // If it doesn't exist, create one.
      systemDebug('DRB2B_ShippingCartCalculatorSample:getDefaultShippingChargeProduct2Id START');
      String shippingChargeProduct2Name = 'Shipping Charge for this delivery method';
      List<Product2> shippingChargeProducts = [SELECT Id FROM Product2 WHERE Name = :shippingChargeProduct2Name WITH SECURITY_ENFORCED];
      if (shippingChargeProducts.isEmpty()) {
        /*
          Product2 shippingChargeProduct = new Product2(
              isActive = true,
              Name = shippingChargeProduct2Name
          );
          insert(shippingChargeProduct);
          return shippingChargeProduct.Id;
          */
          systemDebug('DRB2B_ShippingCartCalculatorSample:getDefaultShippingChargeProduct2Id END - No shipping products');
          return null;
      }
      else {
        systemDebug('DRB2B_ShippingCartCalculatorSample:getDefaultShippingChargeProduct2Id END - shipping product found');
          return shippingChargeProducts[0].Id;
      }
      
  }

  // Note: This sample method currently only takes in numberOfUniqueItems as an input parameter. For
  // real-world scenarios, expand the parameter list.
  private ShippingOptionsAndRatesFromExternalService[] getShippingOptionsAndRatesFromExternalService(
    Integer numberOfUniqueItems, CartExtension.CartValidationOutputList cartValidationOutputCollection) {
    final Integer SuccessfulHttpRequest = 200;
    ShippingOptionsAndRatesFromExternalService[] shippingOptions = new List<ShippingOptionsAndRatesFromExternalService>();
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint(externalShippingURL);
    request.setMethod('GET');
    HttpResponse response = http.send(request);

    // If the request is successful, parse the JSON response. The response looks like this:
    // [{"status":"calculated","rate":{"name":"Delivery Method 1","serviceName":"Test Carrier 1","serviceCode":"SNC9600","shipmentCost":11.99,"otherCost":5.99}}, undefined undefined
    // {"status":"calculated","rate":{"name":"Delivery Method 2","serviceName":"Test Carrier
    // 2","serviceCode":"SNC9600","shipmentCost":15.99,"otherCost":6.99}}]
    if (response.getStatusCode() == SuccessfulHttpRequest) {
      List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());
      for (Object result : results) {
        Map<String, Object> subresult = (Map<String, Object>) result;
        Map<String, Object> providerAndRate = (Map<String, Object>) subresult.get('rate');
        shippingOptions.add( new ShippingOptionsAndRatesFromExternalService(
                   (String) providerAndRate.get('name'),
                   (String) providerAndRate.get('serviceCode'),
                   (Decimal) providerAndRate.get('shipmentCost'),
                   (Decimal) providerAndRate.get('otherCost'),
                   (String) providerAndRate.get('serviceName'),
                   (String) providerAndRate.get('serviceName'),
                   (String) providerAndRate.get('serviceCode'),
                   generateRandomString(10),
                   true
               ));
      }
      return shippingOptions;
    } else {
       String errorMessage = 'We failed to calculate shipping options for your cart.';
       if(response.getStatusCode() == 404) {
              errorMessage = '404. You must create a sample application or add your own service which returns a valid response';
        }

        // Create a CVO with the Error
        CartExtension.CartValidationOutput cvo = new CartExtension.CartValidationOutput(
          CartExtension.CartValidationOutputTypeEnum.SHIPPING,
          CartExtension.CartValidationOutputLevelEnum.ERROR
        );
        cvo.setMessage(errorMessage);
        cartValidationOutputCollection.add(cvo);
        return null;
    }
  }

  // Structure to store the shipping options retrieved from external service.
  Class ShippingOptionsAndRatesFromExternalService {
       private String name;
       private String provider;
       private Decimal rate;
       private Decimal otherCost;
       private String serviceName;
       private String carrier;
       private String classOfService;
       private String referenceNumber;
       private Boolean isActive;

       public ShippingOptionsAndRatesFromExternalService() {
           name = '';
           provider = '';
           rate = 0.0;
           serviceName = '';
           otherCost = 0.0;
           carrier = '';
           classOfService = '';
           referenceNumber = '';
           isActive = true;
       }

       public ShippingOptionsAndRatesFromExternalService(String someName, String someProvider, Decimal someRate, Decimal someOtherCost, String someServiceName,
               String someCarrier, String someClassOfService, String someReferenceNumber, Boolean someIsActive) {
           name = someName;
           provider = someProvider;
           rate = someRate;
           otherCost = someOtherCost;
           serviceName = someServiceName;
           carrier = someCarrier;
           classOfService = someClassOfService;
           referenceNumber = someReferenceNumber;
           isActive = someIsActive;
       }

       public String getProvider() { return provider; }
       public Decimal getRate() { return rate; }
       public Decimal getOtherCost() { return otherCost; }
       public String getServiceName() { return serviceName; }
       public String getName() { return name; }
       public String getCarrier() { return carrier; }
       public String getClassOfService() { return classOfService; }
       public String getReferenceNumber() { return referenceNumber; }
       public Boolean isActive() { return isActive; }
   }


  private void populateCartDeliveryGroupMethodWithShippingOptions(
   List<DRB2B_ShippingCartCalculatorSample.ShippingOptionsAndRatesFromExternalService> shippingOptions,
   CartExtension.CartDeliveryGroupMethodList cartDeliveryGroupMethodCollection,
   String shippingProduct,
   CartExtension.CartValidationOutputList cartValidationOutputCollection
 ) {
     for (ShippingOptionsAndRatesFromExternalService shippingOption : shippingOptions) {
         String carrier = shippingOption.serviceName;
         String classOfService = shippingOption.provider;
           // Create a CartDeliveryGroupMethod for every shipping option returned from the external
           // service
           CartExtension.CartDeliveryGroupMethod cartDeliveryGroupMethod = new CartExtension.CartDeliveryGroupMethod(
             shippingOption.getName(),
             shippingOption.getRate(),
             shippingProduct
           );
           cartDeliveryGroupMethod.setExternalProvider(shippingOption.getProvider());
           cartDeliveryGroupMethod.setCarrier(shippingOption.getCarrier());
           cartDeliveryGroupMethod.setClassOfService(shippingOption.getClassOfService());
           cartDeliveryGroupMethod.setIsActive(shippingOption.isActive());
           cartDeliveryGroupMethod.setReferenceNumber(shippingOption.getReferenceNumber());
           cartDeliveryGroupMethodCollection.add(cartDeliveryGroupMethod);
       }
    }

    private void systemDebug(String message) 
    {
      if(debugMode) {
        system.debug(message);
      }
    }
}
