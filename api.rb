require 'sinatra'
require 'json'
require 'byebug'
require 'bundler/setup'
require_relative 'ticket_loader'
require_relative 'embedding_generator'
require_relative 'db_handler'
require_relative 'cosine_similarity'

DBHandler.setup_database

get '/api/v1/consulta/:query' do
  # params
  content_type :json
  query = params[:query]

  # params query
  consulta_embedding = EmbeddingGenerator.get_embedding(query)
  
  # result
  tickets_similares = DBHandler.find_similar_tickets(consulta_embedding)

  tickets_json = []
  tickets_similares.first(3).each do |ticket|
    solution = ticket[:analisis] if ticket[:analisis] rescue ''
    ticket_json = {
      ticket_id: ticket[:ticket_id],
      score: ticket[:similitud].round(2),
      title: ticket[:titulo],
      description: ticket[:descripcion],
      solution: solution
    }
    tickets_json << ticket_json
  end
  { tickets: tickets_json }.to_json
end