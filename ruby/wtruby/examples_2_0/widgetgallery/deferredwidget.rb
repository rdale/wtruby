#
# A utility container widget which defers creation of its single
# child widget until the container is loaded (which is done on-demand
# by a WMenu). The constructor takes the create function for the
# widget as a parameter.
#
# We use this to defer widget creation until needed, which also defers
# loading auxiliary javascript libraries.
#
class DeferredWidget < Wt::WContainerWidget
  def initialize(method, target)
    super()
    @method = method
    @target = target
  end

  def load
    addWidget(@target.send(@method))
    super
  end
end

# kate: space-indent on; indent-width 2; replace-tabs on; mixed-indent off;

