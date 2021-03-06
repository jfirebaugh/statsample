module Statsample
  class CSV < SpreadsheetBase
    if RUBY_VERSION<"1.9"
      require 'fastercsv'
      CSV_klass=::FasterCSV  
    else
      require 'csv'
      CSV_klass=::CSV  
    end    
    class << self
      # Returns a Dataset  based on a csv file
      #
      # USE:
      #     ds=Statsample::CSV.read("test_csv.csv")
      def read(filename, empty=[''],ignore_lines=0,fs=nil,rs=nil)        
        first_row=true
        fields=[]
        fields_data={}
        ds=nil
        line_number=0
        opts={}
        opts[:col_sep]=fs unless fs.nil?
        opts[:row_sep]=rs unless rs.nil?
        csv=CSV_klass.open(filename,'r',opts)
        csv.each do |row|
          line_number+=1
          if(line_number<=ignore_lines)
            #puts "Skip line"
            next
          end
          row.collect!{|c| c.to_s }
          if first_row
            fields=extract_fields(row)
            ds=Statsample::Dataset.new(fields)
            first_row=false
          else
            rowa=process_row(row,empty)
            ds.add_case(rowa,false)
          end
        end
        convert_to_scale_and_date(ds,fields)
        ds.update_valid_data
        ds
      end
      # Save a Dataset on a csv file
      #
      # USE:
      #     Statsample::CSV.write(ds,"test_csv.csv")
      def write(dataset,filename, convert_comma=false,*opts)
        
        writer=CSV_klass.open(filename,'w',*opts)
        writer << dataset.fields
        dataset.each_array do|row|
          if(convert_comma)
            row.collect!{|v| v.to_s.gsub(".",",")}
          end
          writer << row
        end
        writer.close
      end
    end
  end
end
