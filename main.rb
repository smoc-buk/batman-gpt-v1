require 'byebug'
require 'bundler/setup'
require_relative 'ticket_loader'
require_relative 'embedding_generator'
require_relative 'db_handler'
require_relative 'cosine_similarity'


#tickets = TicketLoader.load_from_csv('hackaton_tickets.csv')
#EmbeddingGenerator.generate_embeddings!(tickets)

DBHandler.setup_database
#DBHandler.save_tickets(tickets)

puts "Consulta batman-gpt:"
consulta = gets.chomp
consulta_embedding = EmbeddingGenerator.get_embedding(consulta)

tickets_similares = DBHandler.find_similar_tickets(consulta_embedding)

# salida consola
puts "Tickets más relevantes para tu consulta:"
tickets_similares.first(3).each do |ticket|
  puts "Ticket ID: #{ticket[:ticket_id]}, Score Similitud: #{ticket[:similitud]}"
  puts "Titulo: #{ticket[:titulo]}"
  puts "Descripción: #{ticket[:descripcion]}"
  if ticket[:analisis]
    puts "Posible Solucion: #{ticket[:analisis]}"
  end
end