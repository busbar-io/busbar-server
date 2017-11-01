module SettingService
  extend SingleForwardable

  def_delegator Settings::CollectionFinder, :call, :where
  def_delegator Settings::Finder,           :call, :find
  def_delegator Settings::Upserter,         :call, :upsert
  def_delegator Settings::BulkUpserter,     :call, :bulk_upsert
  def_delegator Settings::Destroyer,        :call, :destroy
end
