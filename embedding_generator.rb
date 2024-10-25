require 'ruby/openai'

module EmbeddingGenerator

  OpenAI.configure do |config|
    config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")
  end
  @client = OpenAI::Client.new


  def self.get_embedding(text)

    return nil if text.nil? || text.strip.empty?

    response = @client.embeddings(
      parameters: {
        model: "text-embedding-ada-002",
        input: text
      }
    )
    response['data'][0]['embedding']
  end

  def self.generate_embeddings!(tickets)
    cont = 0
    tickets.each do |ticket|
      if cont == 1000
        break
      end
      ticket['embedding'] = get_embedding(ticket['parse_description'])
      cont+=1
      puts cont
    end
  end
end


