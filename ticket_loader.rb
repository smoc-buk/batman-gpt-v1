require 'csv'

module TicketLoader
  def self.load_from_csv(file_path)
    tickets = []
    CSV.foreach(file_path, headers: true) do |row|
      tickets << row.to_h
    end
    tickets
  end
end