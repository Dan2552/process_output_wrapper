module ProcessOutputWrapper
  class Whenever
    attr_reader :condition,
                :result

    def initialize(&condition)
      @condition = condition
      @result = -> {}
    end

    def do(&result)
      @result = result
    end
  end
end
