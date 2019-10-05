module ProcessOutputWrapper
  class Command
    def initialize(command)
      @command = command
      @line = ""
      @print_normally = false
    end

    def execute
      if ENV['VERBOSE'] == 'true'
        execute_normally
      else
        execute_wrapped
      end
    end

    def whenever(&blk)
      Whenever.new(&blk).tap do |w|
        conditionals << w
      end
    end

    private

    attr_reader :command,
                :line

    def print_normally!
      @print_normally = true
    end

    def print_wrapped!
      @print_normally = false
    end

    def conditionals
      @conditionals ||= []
    end

    def check_conditionals
      return if @line.length == 0
      @line = without_color(@line)

      conditionals.each do |conditional|
        if instance_eval(&conditional.condition)
          instance_eval(&conditional.result)
        end
      end
    end

    def without_color(str)
      str.gsub(/\x1B\[([0-9]{1,3}((;[0-9]{1,3})*)?)?[m|K]/, "")
    end

    def execute_normally
      system(command)
    end

    def execute_wrapped
      @output = ""
      @line = ""
      input_thread = nil

      IO.console.raw!

      PTY.spawn(command) do |read, write, pid|
        write.winsize = STDOUT.winsize
        Signal.trap(:WINCH) { write.winsize = STDOUT.winsize }
        input_thread = Thread.new { IO.copy_stream(STDIN, write) }

        read.each_char do |char|
          @output.concat(char)
          print(char) if @print_normally

          case char
          when "\n", "\r"
            IO.console.cooked!
            check_conditionals
            IO.console.raw!
            @line = ""
          else
            @line.concat(char)
          end
        end

        Process.wait(pid)
      end
      input_thread.kill if input_thread

      IO.console.cooked!

      $?.exitstatus
    end
  end
end
