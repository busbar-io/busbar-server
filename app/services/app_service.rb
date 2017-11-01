module AppService
  extend SingleForwardable

  def_delegator Apps::Processor,           :call, :process
  def_delegator Apps::Destroyer,           :call, :destroy
end
