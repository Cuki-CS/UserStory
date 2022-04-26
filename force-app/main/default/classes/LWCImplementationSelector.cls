public with sharing class LWCImplementationSelector {
    private final static String UNSUPPORTED_OPERATION = 'Operation is not supported';

    @AuraEnabled
    public static Object getImplementatationForParameters(Map<String, Object> inputParameters){
        try {
            System.debug('[LWCImplementationSelector.getImplementationForParameters] - inputParameters: ' + inputParameters);
            if(inputParameters.keySet().contains('getDistinctPriceBookEntries')){
                return PriceBookEntrySelector.getOrderableActivePriceBookEntryRecordsOrEmptyList().values();
            }
            else if(inputParameters.keySet().contains('callOrderActivationService')){
                OrderManagementController orderManagementController = new OrderManagementController((List<Object>)inputParameters.get('orderItems'), (String)inputParameters.get('orderId'));
                Object result = orderManagementController.executeCalloutToRestServiceAndReturnResponse();
                System.debug(LoggingLevel.INFO, '[LWCImplementationSelector.getImplementatationForParameters] - result: ' + result);
                return JSON.serialize(result);
            }
            else if(inputParameters.keySet().contains('selectOrderStatus')){
                return JSON.serialize(OrderSelector.getOrderByOrderId((Id)inputParameters.get('orderId')));
            }
            else{
                throw new LWCImplementationSelectorException(UNSUPPORTED_OPERATION);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '[LWCImplementationSelector.getImplementatationForParameters] - exc: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    private class LWCImplementationSelectorException extends Exception{}
}
