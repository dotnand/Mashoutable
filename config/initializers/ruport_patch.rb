module Ruport
  module Data
    class Table
      def to_csv
        csv_string = CSV.generate(:headers => data.first.attributes) do |csv|
          data.each do |record|
            # Header Row
            if record == data.first
              csv << record.attributes
            end

            # Data
            csv << record.data if record.data
          end
        end
        return csv_string
      end
    end
  end
end

