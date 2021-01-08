require 'tty-prompt'

module PromptHelper
  def prompt
    TTY::Prompt.new(interrupt: :noop)
  end

  def main_banner
    <<-'MAIN_BANNER'
    __        ___ _     _ _           _   
    \ \      / (_) | __| | |__   ___ | |_ 
     \ \ /\ / /| | |/ _` | '_ \ / _ \| __|
      \ V  V / | | | (_| | |_) | (_) | |_ 
       \_/\_/  |_|_|\__,_|_.__/ \___/ \__|
    MAIN_BANNER
  end

  def incident_banner
    <<-'INC_BANNER'
     ___            _     _            _   
    |_ _|_ __   ___(_) __| | ___ _ __ | |_ 
     | || '_ \ / __| |/ _` |/ _ \ '_ \| __|
     | || | | | (__| | (_| |  __/ | | | |_ 
    |___|_| |_|\___|_|\__,_|\___|_| |_|\__|
    INC_BANNER
  end

  def separator
    "=========================================================================\n"
  end

  def clear
    print "\e[2J\e[f"
  end

  private

  def quit
    abort("Until next time!")
  end
end