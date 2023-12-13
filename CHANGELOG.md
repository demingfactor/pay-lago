## [0.1.1] - 2023-12-11
### Added
- Scope for Lago payment methods with a given provider.
- Method to find a Lago payment method by provider, and provider id.
- Added `pull!` and `push!` methods to billable, and payment method, to better control syncing with Lago.
- Method to retrieve a payment method on billable.

### Changed
- Dependency `lago-ruby-client` was upgraded to version 0.52.2.pre.beta.
- Improved API for adding a payment method to billable.
- Method `subscription` on subscription can be passed `reload: true` to reload the subscription data.

## [0.1.0] - 2023-10-23
- Initial release
