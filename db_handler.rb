require 'sqlite3'
require 'json'

module DBHandler
  def self.setup_database
    @db = SQLite3::Database.new 'tickets.db'

    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS tickets (
        id INTEGER PRIMARY KEY,
        ticket_id TEXT,
        titulo TEXT,
        descripcion TEXT,
        analisis TEXT,
        embedding BLOB
      );
    SQL
  end

  def self.save_tickets(tickets)
    tickets.each do |ticket|

      puts "Ticket ID: #{ticket['ticket_id']}, Subject: #{ticket['subject']}, Description: #{ticket['parse_description']}, Analysis: #{ticket['analisis_del_ticket_y']}, Embedding: #{ticket['embedding']}"

      @db.execute("INSERT INTO tickets (ticket_id, titulo, descripcion, analisis, embedding)
                  VALUES (?, ?, ?, ?, ?)", [ticket['ticket_id'], ticket['subject'], ticket['parse_description'], ticket['analisis_del_ticket_y'], ticket['embedding'].to_json])
    end
  end

  def self.find_similar_tickets(consulta_embedding)
    tickets_similares = []
    @db.execute("SELECT ticket_id, titulo, descripcion, analisis, embedding FROM tickets") do |row|
      embedding = JSON.parse(row[4])
      similitud = CosineSimilarity.calculate(consulta_embedding, embedding)
      if similitud
        unless tickets_similares.any? { |ticket| ticket[:ticket_id] == row[0] }
          tickets_similares << { ticket_id: row[0], titulo: row[1], descripcion: row[2], similitud: similitud }
        end
      end
    end
    tickets_similares.sort_by { |ticket| -ticket[:similitud] }
  end
end