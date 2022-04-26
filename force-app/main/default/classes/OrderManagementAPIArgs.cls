public inherited sharing class OrderManagementAPIArgs {
    private final String ORDER_PAYLOAD_IS_REQUIRED = 'Order payload or order cannot be null or empty';
    public List<Object> payload { private set; get; }
    public Order order { private set; get; }

    public OrderManagementAPIArgs(List<Object> orderPayload, Order order){
        if(orderPayload == null || orderPayload.isEmpty() || order == null){
            throw new OrderManagementAPIArgsException(ORDER_PAYLOAD_IS_REQUIRED);
        }
        this.payload = orderPayload;
        this.order = order;
    }

    private class OrderManagementAPIArgsException extends Exception{}
}
