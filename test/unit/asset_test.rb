require File.dirname(__FILE__) + '/../test_helper'

class AssetTest < ActiveSupport::TestCase

  should have_db_column(:name).of_type(:string)


end
