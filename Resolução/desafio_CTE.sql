WITH sellers as (
    SELECT 
        seller_id,
        seller_state
    FROM tb_sellers
),

pedidos as (
    SELECT
        seller_id,
        order_id,
        count(DISTINCT(order_id)) as qtd_pedidos,
        sum(price) as vendas_totais,
        sum(freight_value) as frete,
        sum(price) + sum(freight_value) as total_pedido
    FROM tb_order_items

    GROUP by 1,2
),

tipo_pagamento as (
    SELECT
        order_id,
        CASE WHEN payment_type = 'credit_card' THEN sum(payment_value) END AS cartao_credito,
        CASE WHEN payment_type = 'boleto' THEN sum(payment_value) END AS boleto,
        CASE WHEN payment_type = 'voucher' THEN sum(payment_value) END AS voucher,
        CASE WHEN payment_type = 'debit_card' THEN sum(payment_value) END AS debit_card 
    from tb_order_payments

    GROUP BY order_id
)


SELECT
    t1.seller_id,
    t1.seller_state,
    sum(t2.qtd_pedidos) as qtd_pedidos,
    sum(t2.vendas_totais) as vendas_totais,
    sum(t2.frete) as frete,
    sum(t2.total_pedido) as total_pedido,
    coalesce(sum(t3.cartao_credito),0) as cartao_credito,
    coalesce(sum(t3.boleto),0) as boleto,
    coalesce(sum(t3.voucher),0) as voucher,
    coalesce(sum(t3.debit_card),0) as debit_card
FROM sellers as t1

LEFT JOIN pedidos as t2
ON t1.seller_id = t2.seller_id

LEFT JOIN tipo_pagamento as t3
ON t2.order_id = t3.order_id

GROUP BY 1, 2
