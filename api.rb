require 'sinatra'
require 'json'
require 'byebug'
require 'bundler/setup'
require 'webrick'
require 'webrick/https'
require 'openssl'
require 'rack/cors'

require_relative 'ticket_loader'
require_relative 'embedding_generator'
require_relative 'db_handler'
require_relative 'cosine_similarity'

use Rack::Cors do
  allow do
    origins '*'  # Permitir solicitudes de cualquier origen
    resource '*', headers: :any, methods: [:get, :post, :options]
  end
end

configure do

  # Configuración de CORS


  set :port, 4567 
  set :bind, '0.0.0.0'

  set :server, 'webrick'
  set :ssl_certificate, OpenSSL::X509::Certificate.new(File.read("server.crt"))
  set :ssl_key, OpenSSL::PKey::RSA.new(File.read("server.key"))
end


DBHandler.setup_database

get '/api/v1/consulta/:query' do
  begin
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
  rescue StandardError => e
    {error: "Lo siento, no tenemos esa informacion :("}
  end
end