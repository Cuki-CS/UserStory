public inherited sharing class OrderManagementServiceAPI {
    private final String ARGUMENTS_ARE_REQUIRED = 'Arguments are required';
    OrderManagementAPIArgs args;

    public OrderManagementServiceAPI(OrderManagementAPIArgs args) {
        if(args == null){
            throw new OrderManagementServiceAPIException(ARGUMENTS_ARE_REQUIRED);
        }
        this.args = args;
    }

    public Result executePostCalloutToValidateOrderDetails(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://burek.requestcatcher.com/test');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');

        List<Object> orderProducts = new List<Object>();
        for(Object orderItem : args.payload){
            Map<String, Object> orderItemParsed = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(orderItem));
            orderProducts.add(new Map<String,Object>{
                'name' => (String) orderItemParsed.get('Name'),
                'code' => (String) orderItemParsed.get('ProductCode'),
                'unitPrice' => (Integer) orderItemParsed.get('UnitPrice'),
                'quantity' => (Integer) orderItemParsed.get('Quantity')
            });
        }

        Map<String, Object> servicePayload = new Map<String, Object>{
            'accountNumber' => args.order.AccountId,
            'orderNumber' => args.order.OrderNumber,
            'type' => args.order.Type,
            'status' =>  args.order.Status,
            'orderProducts' => orderProducts
        };

        request.setBody(JSON.serialize(servicePayload));
        HttpResponse response = http.send(request);
        System.debug(LoggingLevel.INFO, '[OrderManagementServiceAPI.executePostCalloutToValidateOrderDetails] - response: ' + response);
        Integer statusCode = response.getStatusCode();
        return StatusCode != 200 ? Result.Fail('Error occured during validation') : Result.OK();
    }

    private class OrderManagementServiceAPIException extends Exception{}
}
