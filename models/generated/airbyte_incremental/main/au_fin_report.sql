select date_time,
       settlement_id,
       type,
       order_id,
       sku,
       description,
       sum(quantity)            as quantity,
       marketplace,
       fulfillment,
       order_city,
       order_state,
       order_postal,
       sum(product_sales)       as product_sales,
       sum(shipping_credits)    as shipping_credits,
       sum(gift_wrap_credits)   as gift_wrap_credits,
       sum(promotional_rebates) as promotional_rebates,
       sum(sales_tax_collected) as sales_tax_collected,
       sum(low_value_goods)     as low_value_goods,
       sum(selling_fees)        as selling_fees,
       sum(fba_fees)            as fba_fees,
       sum(other_transaction_fees) as other_transaction_fees,
       sum(other)               as other,
       sum(total)               as total


from (
         select
               DATE_FORMAT(`posted-date`, '%Y-%m-%d %H:%i:%s.%f')  as date_time,
                `settlement-id`                                              as settlement_id,
                `transaction-type`                                           as type,
                `order-id`                                                   as order_id,
                ff.sku                                                       as sku,
                gn.`product-name`                                            as description,
                `quantity-purchased`                                         as quantity,
                `marketplace-name`                                           as marketplace,
                case when `fulfillment-id` = 'AFN' then 'Amazon' end         as fulfillment,
                gn.`ship-city`                                               as order_city,
                `ship-state`                                                 as order_state,
                gn.`ship-postal-code`                                        as order_postal,
                case when `price-type` = 'Principal' then `price-amount` end as product_sales,
                case when `price-type` = 'Shipping' then `price-amount` end  as shipping_credits,
                gn.`gift-wrap-price`                                         as gift_wrap_credits,
                `promotion-amount`                                           as promotional_rebates,
                `item-tax`                                                   as sales_tax_collected,
                0                                                            as low_value_goods,
                case
                    when `item-related-fee-type` = 'Commission'
                        then `item-related-fee-amount` end                   as selling_fees,
                case
                    when `item-related-fee-type` = 'FBAPerUnitFulfillmentFee'
                        then `item-related-fee-amount` end                   as fba_fees,
                case
                    when `transaction-type` = 'ServiceFee'
                        then `item-related-fee-amount` end                   as other_transaction_fees,
                `other-amount`                                               as other,
                `total-amount`                                               as total

         from main.au_get_v2_settlement_report_data_flat_file ff
                  left join main.au_get_flat_file_all___y_last_update_general gn
                            on gn.`amazon-order-id` = ff.`order-id`  and ff.sku=gn.sku
           where `posted-date`!=''

         group by
                  DATE_FORMAT(`posted-date`, '%Y-%m-%d %H:%i:%s.%f'),
                  `settlement-id`,
                  `transaction-type`,
                  `order-id`,
                  ff.sku,
                  gn.`product-name`,
                  `quantity-purchased`,
                  `marketplace-name`,
                  case when `fulfillment-id` = 'AFN' then 'Amazon' end,
                  gn.`ship-city`,
                  `ship-state`,
                  gn.`ship-postal-code`,
                  case when `price-type` = 'Principal' then `price-amount` end,
                  case when `price-type` = 'Shipping' then `price-amount` end,
                  gn.`gift-wrap-price`,
                  `promotion-amount`,
                  `item-tax`,

                  case
                      when `item-related-fee-type` = 'Commission'
                          then `item-related-fee-amount` end,
                  case
                      when `item-related-fee-type` = 'FBAPerUnitFulfillmentFee'
                          then `item-related-fee-amount` end,
                  case
                      when `transaction-type` = 'ServiceFee'
                          then `item-related-fee-amount` end,
                  `other-amount`,
                  `total-amount`

     ) fin

group by date_time,
         settlement_id,
         type,
         order_id,
         sku,
         description,
         marketplace,
         fulfillment,
         order_city,
         order_state,
         order_postal
