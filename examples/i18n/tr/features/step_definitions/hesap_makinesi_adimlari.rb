begin
  require 'rspec/expectations'
rescue LoadError
  require 'spec/expectations'
end

require 'cucumber/formatter/unicode'
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../lib")
require 'hesap_makinesi'

Before do
  @calc = HesapMakinesi.new
end

After do
end

Diyelimki(/hesap makinesine (\d+) girdim/) do |n|
  @calc.push n.to_i
end

Eğerki(/(.*) tuşuna basarsam/) do |op|
  @result = @calc.send op
end

Ozaman(/ekrandaki sonuç (.*) olmalı/) do |result|
  expect(@result).to eq(result.to_f)
end
