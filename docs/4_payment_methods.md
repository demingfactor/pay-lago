# Payment Methods

## Adding a Payment Method to a Customer

Lago uses the default method of payment for a given customer. As such, Payment Methods in this gem actually
store customer information of the given provider, rather than the payment method itself.

```ruby
# Adding a Stripe customer as a Payment Method
customer = Pay::Customer.find(1234)
customer.add_payment_method(:stripe, "cus_1234")
```

```ruby
# Adding a Stripe customer as a Payment Method, but make it not the default.
customer = Pay::Customer.find(1234)
customer.add_payment_method(:stripe, "cus_1234", default: false)
```

```ruby
# Adding a Stripe customer as a Payment Method, but make it not sync with Lago.
# NOTE: Syncing with Lago will only work anyways if default is true (which it is by default).
customer = Pay::Customer.find(1234)
customer.add_payment_method(:stripe, "cus_1234", sync: false)
```

## Retrieving a Payment Method

```ruby
# Retrieve a Payment Method with a given ID.
customer = Pay::Customer.find(1234)
customer.get_payment_method(:stripe, "cus_1234")
```

```ruby
# If no Payment Method ID is given, it will return either the first Payment Method
# for the customer with the given provider, or the default Payment Method (if provider matches).
customer = Pay::Customer.find(1234)
customer.get_payment_method(:stripe)
```