# Витрина RFM

## 1.1. Выясните требования к целевой витрине.

Постановка задачи выглядит достаточно абстрактно - постройте витрину. Первым делом вам необходимо выяснить у заказчика детали. Запросите недостающую информацию у заказчика в чате.

Зафиксируйте выясненные требования. Составьте документацию готовящейся витрины на основе заданных вами вопросов, добавив все необходимые детали.

-----------

Размытая задача: построить витрину для RFM-анализа.
- витрина должна располагаться в базе de в схеме analysis
- витрина должна состоять из полей:
  - user_id
  - recency
  - frequency
  - monetary_value
- глубина выборки: данные с начала 2022 года
- витрину назвать dm_rfm_segments
- обновление витрины не требуется
- успешно выполненный заказ - заказ со статусом "Closed"



## 1.2. Изучите структуру исходных данных.

Полключитесь к базе данных и изучите структуру таблиц.

Если появились вопросы по устройству источника, задайте их в чате.

Зафиксируйте, какие поля вы будете использовать для расчета витрины.

-----------

- Products - таблица с наименованием блюд
    - id - идентификатор блюда 
    - name - наименование блюда
    - price - цена блюда

- Users - информация о пользователях
    - id - идентификатор пользователя
    - name - ФИО пользователя
    - login - логин пользователя

- Orders - таблица заказов
    - order_id - идентификатор заказа
    - order_ts - дата и время заказа (timestamp)
    - user_id - id пользователя (FK)
    - bonus_payment - сумма оплаты бонусами
    - payment - сумма оплаты деньгами
    - cost - стоимость заказа
    - bonus_grant - начисленные бонусы 
    - status - статус заказа (FK)

- OrderItems - состав заказа
    - id - идентификатор позиции
    - product_id - идентификатор блюда (FK)
    - order_id - идентификатор заказа (FK)
    - name - наименование продукта
    - price - цена
    - discount - сумма скидки
    - quantity - количество позиций этого типа в заказе

- OrderStatuses - статус заказа
    - id - идентификатор статуса
    - key - ключ (открыт, готовится, доставляется, закрыт, отменен)

- OrderStatusLog - журнал статусов заказов
    - id - идентификатор позиции в журнале
    - order_id - идентификатор заказа (FK)
    - status_id - идентификатор статуса (FK)
    - dttm - дата и время


## 1.3. Проанализируйте качество данных

Изучите качество входных данных. Опишите, насколько качественные данные хранятся в источнике. Так же укажите, какие инструменты обеспечения качества данных были использованы в таблицах в схеме production.

-----------

В таблице Users названия столбцов name и login перепутаны местами. В остальных таблицах отсутствуют пропущенные данные и дубли, все типы данных полей корректны, форматы записей верны.

Схема production: 
| Таблицы | Объект | Инструмент | Предназначение инструмента |
| ------- | ------ | ---------- | -------------------------- |
| production.Products | id int NOT NULL PRIMARY KEY | Первичный ключ | Уникальность записей о продуктах |
| production.Products | CHECK ((price >= (0)::numeric)) | Ограничение | Добавление только положительных значений в price |
| production.Users | id int NOT NULL PRIMARY KEY | Первичный ключ | Уникальность записей о пользователях |
| production.Orders | order_id int NOT NULL PRIMARY KEY | Первичный ключ | Уникальность записей о заказах |
| production.Orders | CHECK ((cost = (payment + bonus_payment))) | Ограничение | Стоимость состоит из требуемой оплаты + наценки |
| production.OrderItems | id int NOT NULL PRIMARY KEY | Первичный ключ | Уникальность записей о составе заказов |
| production.OrderItems | UNIQUE(order_id, product_id) | Уникальность | Уникальное сочетание записей order_id и product_id |
| production.OrderItems | CHECK (((discount >= (0)::numeric) AND (discount <= price))) | Ограничение | Добавление только положительных значений в discount, но меньше цены заказа |
| production.OrderItems | CHECK ((price >= (0)::numeric)) | Ограничение | Добавление только положительных значений в price |
| production.OrderItems | CHECK ((quantity > 0)) | Ограничение | Добавление только положительных значений |
| production.OrderStatuses | id int NOT NULL PRIMARY KEY | Первичный ключ | Уникальность записей о статусе заказов |
| production.OrderStatusLog| UNIQUE(order_id, status_id) | Уникальность | Уникальное сочетание записей order_id и status_id |


## 1.4. Подготовьте витрину данных

Теперь, когда требования понятны, а исходные данные изучены, можно приступить к реализации.

### 1.4.1. Сделайте VIEW для таблиц из базы production.**

Вас просят при расчете витрины обращаться только к объектам из схемы analysis. Чтобы не дублировать данные (данные находятся в этой же базе), вы решаете сделать view. Таким образом, View будут находиться в схеме analysis и вычитывать данные из схемы production. 

Напишите SQL-запросы для создания пяти VIEW (по одному на каждую таблицу) и выполните их. Для проверки предоставьте код создания VIEW.

```SQL
CREATE OR REPLACE VIEW analysis.Users AS SELECT * FROM production.Users;
CREATE OR REPLACE VIEW analysis.OrderItems AS SELECT * FROM production.OrderItems;
CREATE OR REPLACE VIEW analysis.OrderStatuses AS SELECT * FROM production.OrderStatuses;
CREATE OR REPLACE VIEW analysis.Products AS SELECT * FROM production.Products;
CREATE OR REPLACE VIEW analysis.Orders AS SELECT * FROM production.Orders;
```

### 1.4.2. Напишите DDL-запрос для создания витрины.**

Далее вам необходимо создать витрину. Напишите CREATE TABLE запрос и выполните его на предоставленной базе данных в схеме analysis.

```SQL
CREATE TABLE analysis.dm_rfm_segments (
	user_id INT NOT NULL PRIMARY KEY,
  	recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5),
  	frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5),
  	monetary_value INT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);
```

### 1.4.3. Напишите SQL запрос для заполнения витрины

Наконец, реализуйте расчет витрины на языке SQL и заполните таблицу, созданную в предыдущем пункте.

Для решения предоставьте код запроса.

```SQL
WITH 
closed_orders AS (
    SELECT *
    FROM analysis.Orders AS o
    WHERE o.status = 4 --closed
),
recency AS (
    SELECT
        user_id,
        CASE
            WHEN user_order_ranks.last_order_rnk BETWEEN 1 AND 200 THEN 1
            WHEN user_order_ranks.last_order_rnk BETWEEN 201 AND 400 THEN 2
            WHEN user_order_ranks.last_order_rnk BETWEEN 401 AND 600 THEN 3
            WHEN user_order_ranks.last_order_rnk BETWEEN 601 AND 800 THEN 4
            WHEN user_order_ranks.last_order_rnk BETWEEN 801 AND 1000 THEN 5
            ELSE -1
        END AS recency_rank
    FROM (
        SELECT
            all_users.id AS user_id,
            ROW_NUMBER() OVER(ORDER BY COALESCE(user_last_orders.last_order_ts, '2000-01-01') ASC) AS last_order_rnk
        FROM
            analysis.Users AS all_users
            LEFT JOIN
            (
                SELECT
                    user_id,
                    order_ts AS last_order_ts
                FROM (
                    SELECT
                        user_id,
                        order_ts,
                        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_ts DESC) AS rnk
                    FROM closed_orders
                ) as order_rnk
                WHERE rnk = 1
            ) AS user_last_orders
            ON all_users.id = user_last_orders.user_id
    ) AS user_order_ranks
),
frequency AS (
    SELECT
        user_id,
        CASE
            WHEN user_order_ranks.order_cnt_rnk BETWEEN 1 AND 200 THEN 1
            WHEN user_order_ranks.order_cnt_rnk BETWEEN 201 AND 400 THEN 2
            WHEN user_order_ranks.order_cnt_rnk BETWEEN 401 AND 600 THEN 3
            WHEN user_order_ranks.order_cnt_rnk BETWEEN 601 AND 800 THEN 4
            WHEN user_order_ranks.order_cnt_rnk BETWEEN 801 AND 1000 THEN 5
            ELSE -1
        END AS frequency_rank
    FROM (
       SELECT
            all_users.id AS user_id,
            ROW_NUMBER() OVER(ORDER BY COUNT(orders.order_id) ASC NULLS FIRST) AS order_cnt_rnk
        FROM 
            analysis.Users AS all_users
                LEFT JOIN closed_orders AS orders
                    ON all_users.id = orders.user_id
        GROUP BY all_users.id 
    ) AS user_order_ranks
),
monetary_value AS (
    SELECT
        user_id,
            CASE
                WHEN user_order_ranks.order_sum_rnk BETWEEN 1 AND 200 THEN 1
                WHEN user_order_ranks.order_sum_rnk BETWEEN 201 AND 400 THEN 2
                WHEN user_order_ranks.order_sum_rnk BETWEEN 401 AND 600 THEN 3
                WHEN user_order_ranks.order_sum_rnk BETWEEN 601 AND 800 THEN 4
                WHEN user_order_ranks.order_sum_rnk BETWEEN 801 AND 1000 THEN 5
                ELSE -1
            END AS monetary_value_rank
    FROM (
        SELECT
            all_users.id AS user_id,
            ROW_NUMBER() OVER(ORDER BY SUM(orders.payment) ASC NULLS FIRST) AS order_sum_rnk
        FROM 
            analysis.Users AS all_users
                LEFT JOIN closed_orders AS orders
                    ON all_users.id = orders.user_id
        GROUP BY all_users.id 
    ) AS user_order_ranks
)
INSERT INTO analysis.dm_rfm_segments SELECT * from recency INNER JOIN frequency USING (user_id) INNER JOIN monetary_value USING (user_id)
--select *
--from recency
--	INNER join frequency USING (user_id)
--	INNER JOIN monetary_value USING (user_id)
```



