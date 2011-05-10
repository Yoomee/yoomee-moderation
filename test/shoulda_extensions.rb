Shoulda::ActiveRecord::Matchers.module_eval do

  def have_attribute(attr)
    HaveAttributeMatcher.new(attr)
  end
  
  def have_timestamps
    have_db_column(:created_at) && have_db_column(:updated_at)
  end

end

Shoulda::ActionController::Matchers.module_eval do

  def have_action(action)
    HaveActionMatcher.new(action)
  end

  def set_waypoint
    SetWaypointMatcher.new
  end

  def should_delegate(delegate_method, options)
    delegate_object = options[:to]
    object_method = options[:object_method]
    klass = model_class
    if object_method
      should "delegate #{delegate_method} to #{delegate_object}.#{object_method}" do
        instance = klass.new
        instance.expects(delegate_object).at_least_once.returns mock(object_method => true)
        assert instance.send(delegate_method)
      end
      if options.key?(:nil_object_result)
        nil_object_result = options[:nil_object_result]
        nil_object_result_s =  case nil_object_result
           when nil
             'nil'
           when ''
             "''"
           else
             nil_object_result
         end
        should "return #{nil_object_result_s} for #{delegate_method} when #{delegate_object} is nil" do
          instance = klass.new
          instance.expects(delegate_object).at_least_once.returns nil
          assert_equal nil_object_result, instance.send(delegate_method)
        end
      end
    else
      should "delegate #{delegate_method} to #{delegate_object}" do
        instance = klass.new
        instance.expects(delegate_object).at_least_once.returns mock(delegate_method => true)
        assert instance.send(delegate_method)
      end
      if options.key?(:nil_object_result)
        nil_object_result = options[:nil_object_result]
        nil_object_result_s =  case nil_object_result
          when nil
            'nil'
          when ''
            "''"
          else
            nil_object_result
        end
        should "return #{nil_object_result_s} for #{delegate_method} when #{delegate_object} is nil" do
          instance = klass.new
          instance.expects(delegate_object).at_least_once.returns nil
          assert_equal nil_object_result, instance.send(delegate_method)
        end
      end
    end
  end

  class HaveAttributeMatcher
    
    attr_reader :failure_message, :negative_failure_message
    
    def description
      "have attribute #{@attr.to_s}"
    end
    
    def initialize(attr)
      @attr = attr
    end
    
    def matches?(subject)
      has_setter?(subject) && has_getter?(subject)
    end
    
    private
    def has_getter?(subject)
      if subject.respond_to?("#{@attr}")
        @negative_failure_message = "should not have method #{@attr}, but does"
        true
      else
        @failure_message = "should have method #{@attr}"
        false
      end
    end
    
    def has_setter?(subject)
      if subject.respond_to?("#{@attr}=")
        @negative_failure_message = "should not have method #{@attr}=, but does"
        true
      else
        @failure_message = "should have method #{@attr}="
        false
      end
    end
    
  end

  class HaveActionMatcher
    
    attr_reader :failure_message, :negative_failure_message
    
    def description
      returning @description = "have action '#{@action.to_s}'" do
        @description << " with default level '#{@default_level.to_s}'" if @default_level
        @description << " and" if @level && @default_level
        @description << " with level '#{@level.to_s}'" if @level
      end
    end

    def initialize(action)
      @action = action
    end
    
    def matches?(controller)
      @controller = controller
      has_action? && correct_level? && correct_default_level?
    end

    def with_level(level)
      @level = level
      self
    end
    
    def with_default_level(level)
      @default_level = level
      self
    end
    
    def without_level
      @no_level = true
      self
    end
    
    private
    def correct_level?
      return true unless @level
      return has_no_level? if @level.to_s == 'default'
      if @controller.send("#{@level}_action?", @action)
        @negative_failure_message = "Didn't expect #{@controller} to have action #{@action.to_s} of level #{@level}, but it did"
        true
      else
        @failure_message = "Expected #{@action.to_s} to be level #{@level}"
        false
      end
    end
    
    def correct_default_level?
      return true unless @default_level
      if @controller.send("default_#{@default_level}_action?", @action)
        @negative_failure_message = "Didn't expect #{@controller} to have action #{@action.to_s} of default level #{@level}, but it did"
        true
      else
        @failure_message = "Expected #{@action.to_s} to have default level #{@level}"
        false
      end
    end
    
    def has_action?
      if @controller.respond_to?(@action)
        @negative_failure_message = "Expected #{@controller} to not have action #{@action.to_s}"
        true
      else
        @failure_message = "Expected #{@controller} to have action #{@action.to_s}"
        false
      end
    end
    
    def has_no_level?
      @controller.permission_levels[@action.to_sym].nil?
    end
    
  end
  
  class SetWaypointMatcher
    
    attr_reader :failure_message, :negative_failure_message
  
    def description
      "set the waypoint"
    end
    
    def matches?(controller)
      @controller = controller
      has_set_waypoint?
    end
   
    private 
    def expected_waypoint
      returning out = HashWithIndifferentAccess.new(@controller.params) do
        out[:controller] = "/#{@controller.controller_name}"
      end
    end
      
    def has_set_waypoint?
      if expected_waypoint == session[:waypoint]
        @negative_failure_message = "Didn't expect #{@controller.controller_name.camelcase}##{@controller.action_name} to set the waypoint"
        true
      else
        @failure_message = "Expected #{@controller.controller_name.camelcase}##{@controller.action_name} to set the waypoint"
        false
      end
    end
    
    def session
      if @controller.request.respond_to?(:session)
        @controller.request.session.to_hash
      else
        @controller.reponse.session.data
      end
    end
    
  end

  private
  def model_class
    self.name.gsub(/Test$/, '').constantize
  end
  
end
