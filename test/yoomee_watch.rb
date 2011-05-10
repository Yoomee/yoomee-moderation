require 'active_support/core_ext'

RUBY19 = defined? Encoding
STATUS_ICONS = {
  :pass     => File.dirname(__FILE__) + "/icons/rails_ok.png",
  :fail     => File.dirname(__FILE__) + "/icons/rails_fail.png",
  :pending  => File.dirname(__FILE__) + "/icons/rails_pending.png"
}

class YoomeeWatch

  cattr_accessor :interrupted

  # Handle ctrl-c
  trap 'INT' do
    if self.interrupted
      exit
    else
      puts "Interrupt a second time to quit"
      self.interrupted = true
      Kernel.sleep 1.5
      self.interrupted = false
      self::run_all_tests
    end
  end

  class << self

    def all_tests
      (yoomee_tests("unit/*.rb") + yoomee_tests("functional/*.rb") + yoomee_tests("unit/helpers/*.rb")).uniq
    end

    def growl(title, msg, img, pri=0, stick="")
      system "growlnotify -n watchr --image #{img} -p #{pri} -m #{msg.inspect} #{title} #{stick}"
      sleep 1
    end

    def growl_results(results)
      output = get_tests_assertions_failures_and_errors(results)
      if !output.empty?
        tests, assertions, failures, errors = output
        # Test::Unit
        tests, assertions, failures, errors = output
        failed = failures.to_i > 0 || errors.to_i > 0
        if failed
          prefix, icon, priority, stick = "FAIL: ", :fail, 2, ""
        else
          prefix, icon, priority, stick = "PASS: ", :pass, 0, ""
        end

        info  = "Tests: #{tests}/#{assertions}"
        info += " Errors: #{errors}" if errors.to_i > 0
        info += " Failures: #{failures}" if failures.to_i > 0
        growl prefix, info, STATUS_ICONS[icon], priority, stick
      end
    end
    
    def get_tests_assertions_failures_and_errors(results)
      result = [results].flatten.join("\n")
      test_unit_regexp = /(\d+)\s+tests?,\s*(\d+)\s+assertions?,\s*(\d+)\s+failures?,\s*(\d+)\s+errors?/
      result.scan(test_unit_regexp).flatten
    end

    def loud_backquote(cmd)
      old_sync = $stdout.sync
      $stdout.sync = true
      results = []
      line = []
      begin
        open "| #{cmd}", "r" do |f|
          until f.eof? do
            c = f.getc or break
            char = c.chr
            print char
            line << c
            if c == ?\n then
              results << if RUBY19 then
                                line.join
                              else
                                line.pack "c*"
                              end
              line.clear
            end
          end
        end
      ensure
        $stdout.sync = old_sync
      end
      results
    end
    
    def run_all_tests(stop_on_failure = false)
      run_tests(all_tests, stop_on_failure)
    end
    
    def run_tests(test_paths, stop_on_failure = false)
      test_paths = [test_paths].flatten
      unless test_paths.empty?
        puts "Running #{test_paths.join(' ')}..."
        growl "Running #{test_paths.size} test files...", test_paths.first(5).join(', '), '', nil
        if stop_on_failure
          results = loud_backquote("ruby -e \"begin;require '#{File.dirname(__FILE__)}/failure_catcher';%w[#{test_paths.join(' ')}].each {|f| require f};rescue e; puts 'HELLO';end\"")
        else
          results = loud_backquote("ruby -e \"%w[#{test_paths.join(' ')}].each {|f| require Dir.pwd + '/' + f\"}")
        end
        growl_results(results)
      end
    end
    
    def yoomee_tests(test_suffix)
      Dir["test/#{test_suffix}"] + Dir["client/test/#{test_suffix}"] + Dir["vendor/plugins/yoomee_*/test/#{test_suffix}"]
    end

  end
  
end
