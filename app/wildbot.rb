require_relative 'prompts/main_prompt'

class Wildbot
  def self.preflight_check
    puts "Wildbot powering on..."
    puts "Running preflight check..."
    puts "Verifying Redis connection..."
    return false unless RedisClient.new.connection_verified?
    true
  end

  def self.run
    MainPrompt.welcome(status_ok: preflight_check, clear_screen: true)
  end
end

Wildbot.run