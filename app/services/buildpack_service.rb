module BuildpackService
  extend SingleForwardable

  def_delegator Buildpacks::Resolver, :call, :resolve
  def_delegator Buildpacks::Detector, :call, :detect
end
