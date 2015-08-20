#!/usr/bin/env ruby
require 'pathname'
require 'csv'
require 'ap'
require 'ostruct'
require 'json'

SCRIPTDIR=Pathname.new(__FILE__).parent.realpath
DATAROOT=SCRIPTDIR.parent
LOGDIR=DATAROOT.join('logs')
CC_DIR=DATAROOT.join('CreditCardTransactions')

def find_cc_files
  files = []
  Dir.glob("#{CC_DIR}/**/*.csv").each do |dir|
    if block_given?
      next unless yield(dir)
    end
    files << dir
  end
  files
end

def read_cc_file path
  raise "Pass a block to process each row" unless block_given?
  past_header = false
  row_num = 0
  begin
    CSV.foreach(path) do |row|
      row_num += 1
      # require "pry"; binding.pry if row[0] == "ACCOUNT"
      if row[0] == 'ACCOUNT'
        past_header = true
        next
      end
      next unless past_header

      #     [1] pry(main)> ap row
      # [
      #     [ 0] "ACCOUNT",
      #     [ 1] "ACCOUNT NAME",
      #     [ 2] "AMOUNT",
      #     [ 3] "AUTH CODE",
      #     [ 4] "AVS",
      #     [ 5] "BRAND",
      #     [ 6] "CARD ENDING",
      #     [ 7] "CVD",
      #     [ 8] "FIRST NAME",
      #     [ 9] "LAST NAME",
      #     [10] "MERCHANT TRANS. ID",
      #     [11] "OPTION CODE",
      #     [12] "DATE",
      #     [13] "TXN ID",
      #     [14] "CONF. NO.",
      #     [15] "ERROR CODE",
      #     [16] "AUTH TYPE",
      #     [17] "TYPE",
      #     [18] "TXT_CITY%2CTXT_COUNTRY%2CTXT_EMAIL%2CTXT_PHONE%2CTXT_STATE%2CTXT_ADDR1%2CTXT_ADDR2%2CZIP%2CCONSUMER_IP",
      #     [18] "TXT_CITY
      #     [19] CTXT_COUNTRY
      #     [20] CTXT_EMAIL
      #     [21] CTXT_PHONE
      #     [22] CTXT_STATE
      #     [23] CTXT_ADDR1
      #     [24] CTXT_ADDR2
      #     [25] CZIP
      #     [26] CCONSUMER_IP",
      #     [19] nil
      # ]
      yield(row, row_num)
    end
  rescue Exception => e
    raise e if e.class == NameError
    raise e if e.class == Interrupt
    $stderr.puts "*** #{e.class} ERROR in file #{path}\n#{e}"
    # return
  end
end


def extractNames
  files = find_cc_files do |cand|
    # filename = File.basename(cand)
    # next true if filename =~ /^2015-/
    true
  end
  header_printed = false
  files.each do |path|
    read_cc_file(path) do |row,line_num|
      next unless row[19] =~ /us/i # Only US Customers
      # require "pry"; binding.pry
      file = File.basename(path)

      name_parts = split_name(row[9])
      data = {
        file: file,
        line_num: line_num,
        amount: row[2].to_f,
        name: row[9],
        date: row[12],
        addr1: row[23],
        addr2: row[24],
        city: row[18],
        state: row[22],
        zip: row[25],
        email: row[20],
      }.merge(name_parts)

      # Name debugging
      # next unless name_parts[:first].nil?
      # data = {
      #   file:data[:file],
      #   line_num:data[:line_num],
      # }.merge(name_parts.merge({name:data[:name]}))
      # puts data.to_json

      if !header_printed
        puts data.keys.to_csv
        header_printed = true
      end
      puts data.values.to_csv
    end
  end
end

def split_name fname
  name = {first:'', middle:'', last:''}

  # ALFRED COLE
  if fname =~ /^\s*([^ ]+)\s+([^ ]+)\s*$/
    name[:first] = $1
    name[:middle] = $2
    name[:last] = $3
    return name
  end

  # ALFRED BOB COLE
  if fname =~ /^\s*([^ ]+)\s+([^ ]+)\s+([^ ]+)\s*$/
    name[:first] = $1
    name[:middle] = $2
    name[:last] = $3
    return name
  end

  # ALFRED BOB COLE JR
  if fname =~ /^\s*([^ ]+)\s+([^ ]+)\s+([^ ]+)\s*([^ ]+)$/
    name[:first] = $1
    name[:middle] = $2
    name[:last] = $3
    name[:suffix] = $4
    return name
  end

  return {}
end

if $0 == __FILE__
  extractNames
end
