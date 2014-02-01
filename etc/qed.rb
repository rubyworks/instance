QED.configure 'coverage' do
  require 'simplecov'
  SimpleCov.command_name 'QED'
  SimpleCov.start do
    coverage_dir 'log/coverage'
  end
end

