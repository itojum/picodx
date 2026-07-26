module PicoDX
  class Greeter
    def initialize(element_id)
      @element = JS.document.getElementById(element_id)
    end

    def greet(name)
      @element.innerText = "Hello, #{name}!"
    end
  end
end
