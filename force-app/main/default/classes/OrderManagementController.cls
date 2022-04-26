public with sharing class OrderManagementController {
    private final String ORDER_ARGUMENTS_ARE_REQUIRED = 'Arguments cannot be null';

    List<Object> orderItemsList;
    String orderId;

    public OrderManagementController(List<Object> orderItemsList, String orderId){
        if(orderItemsList == null || orderItemsList.size() == 0 || orderId == null || orderId == ''){
            throw new OrderManagementControllerException(ORDER_ARGUMENTS_ARE_REQUIRED);
        }

        this.orderItemsList = orderItemsList;
        this.orderId = orderId;
    }

    public Result executeCalloutToRestServiceAndReturnResponse(){
        Order order = OrderSelector.getOrderByOrderId(this.orderId);
        Result postCalloutResult = (new OrderManagementServiceAPI(new OrderManagementAPIArgs(orderItemsList, order))).executePostCalloutToValidateOrderDetails();

        if(postCalloutResult.IsSuccess){
            List<OrderItem> orderItemsListForInsert = new List<OrderItem>();
            for(Object orderItem : orderItemsList){
                Map<String, Object> orderItemParsed = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(orderItem));
                OrderItem oi = new OrderItem();
                oi.Quantity = (Integer) orderItemParsed.get('Quantity');
                oi.OrderId = this.orderId;
                oi.Product2Id = (String) orderItemParsed.get('Id');
                oi.PricebookEntryId = (String) orderItemParsed.get('Pricebook2Id');
                oi.UnitPrice = (Integer) orderItemParsed.get('UnitPrice');
                orderItemsListForInsert.add(oi);
            }
            System.debug(LoggingLevel.INFO, '[OrderManagementController.executeCalloutToRestServiceAndReturnResponse] - orderItemsListForInsert: ' + orderItemsListForInsert);

            if(orderItemsListForInsert.size() > 0){
                INSERT orderItemsListForInsert;
            }

            order.Status = 'Activated';
            UPDATE order;

            System.debug(LoggingLevel.INFO, '[OrderManagementController.executeCalloutToRestServiceAndReturnResponse] OK');
            return Result.OK();
        }
        else{
            System.debug(LoggingLevel.INFO, '[OrderManagementController.executeCalloutToRestServiceAndReturnResponse] Callout failed');
            return Result.Fail('Callout failed');
        }
    }

    private class OrderManagementControllerException extends Exception{}
}
