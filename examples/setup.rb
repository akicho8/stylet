require "bundler/setup"

$LOAD_PATH.unshift "#{__dir__}/../lib"
require "stylet"
require "observer"
require "stylet/contrib/menu"
require "active_support/core_ext/benchmark"

require "active_support/isolated_execution_state"
