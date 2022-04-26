public inherited sharing class OrderSelector {
    private static final String ORDER_ID_IS_REQUIRED = 'Order id is required';

    public static Order getOrderByOrderId(Id orderId){
        if(orderId == null){
            throw new ORderSelectorException(ORDER_ID_IS_REQUIRED);
        }

        List<Order> orderList = [
            SELECT Id, AccountId, OrderNumber, Status, Type
            FROM Order
            WHERE Id = :orderId
        ];

        return orderList.size() > 0 ? orderList[0] : null;
    }

    private class OrderSelectorException extends Exception{}
}
