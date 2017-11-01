module ComponentService
  extend SingleForwardable

  def_delegator Components::Upserter,     :call, :upsert
  def_delegator Components::Destroyer,    :call, :destroy
  def_delegator Components::Installer,    :call, :install
  def_delegator Components::Uninstaller,  :call, :uninstall
  def_delegator Components::Scaler,       :call, :scale
  def_delegator Components::LogRetriever, :call, :retrieve_log
end
