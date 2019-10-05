module ProcessOutputWrapper
  module DSL
    def run_this(command, &blk)
      command = Command.new(command)
      command.instance_eval(&blk)
      command.execute
    end
  end
end
