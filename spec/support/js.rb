module JS
  Element = Struct.new(:id) do
    attr_accessor :innerText
  end

  class Document
    def initialize
      @store = {}
    end

    def getElementById(id)
      @store[id] ||= Element.new(id)
    end
  end

  def self.document
    @document ||= Document.new
  end

  def self.reset!
    @document = nil
  end
end
