-- добавьте код сюда
CREATE OR REPLACE VIEW analysis.Orders AS 
SELECT 
    orders.order_id AS order_id,
    orders.order_ts AS order_ts,
    orders.user_id AS user_id,
    orders.bonus_payment AS bonus_payment,
    orders.payment AS payment,
    orders.cost AS cost,
    orders.bonus_grant AS bonus_grant,
    final_statuses.status_id AS status
FROM production.Orders AS orders
    INNER JOIN (
        SELECT
            order_id,
            status_id
        FROM (
            SELECT
                order_id,
                status_id,
                ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY dttm DESC) AS rn
            FROM
                production.OrderStatusLog
        ) AS t
        WHERE rn = 1
    ) AS final_statuses
ON final_statuses.order_id = orders.order_id;