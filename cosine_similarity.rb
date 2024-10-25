module CosineSimilarity
  def self.calculate(vec1, vec2)
    begin
      dot_product = vec1.zip(vec2).map { |x, y| x * y }.reduce(:+)
      magnitude1 = Math.sqrt(vec1.map { |x| x**2 }.reduce(:+))
      magnitude2 = Math.sqrt(vec2.map { |y| y**2 }.reduce(:+))
      dot_product / (magnitude1 * magnitude2)
    rescue StandardError => e
      # imposible de calcular
    end
  end
end