require_relative './incident_prompt'
require_relative '../models/redis_client'
require_relative '../helpers/prompt_helper'

module MainPrompt
  extend PromptHelper

  @incident_handler = MainPrompt::IncidentPrompt.new
  @redis_client = RedisClient.new

  def self.welcome(status_ok: true, clear_screen: false)
    if clear_screen
      header(status_ok: status_ok)
      prompt.say("Welcome to Wildbot, a chatbot for helping you manage incidents with ease!")
    end
    prompt.say(separator)
    prompt.select("What do you need help with?") do |menu|
      menu.choice "Start or resume an incident", -> {@incident_handler.run_incident}
      menu.choice "Export incident archive as JSON", -> {export}
      menu.choice "Clear incident archive", -> {clear_archives}
      menu.choice "Help", -> {help}
      menu.choice "Exit", -> {quit}
    end
  end

  def self.export
    prompt.say(separator)
    prompt.say(@redis_client.fetch(archive: true).to_json)
    return_prompt
  end

  def self.clear_archives
    return unless prompt.yes?("This will PERMANENTLY ERASE your archived incident data. Are you sure?")
    @redis_client.clear_archive
    prompt.say("Archived data cleared!")
    return_prompt
  end

  def self.help
    prompt.say(separator)
    prompt.say("Wildbot is a simple chatbot-like interface, offering an effortless, reliable way to manage incidents.\n")
    prompt.say("A quick description of its functions:\n\n")
    prompt.say("Start or resume an incident:")
    prompt.say(
      "The magic of Wildbot! Enter any text, and press return to store it safely for export later." +
      "You can also type 'list' to list all previous updates, or 'end' to resolve the incident!\n\n"
    )
    prompt.say("Export incident archive as JSON:")
    prompt.say("This will print all previous incidents to STDOUT as JSON, for you to share, reference, or manipulate later.\n\n")
    prompt.say("Clear incident archive:")
    prompt.say("This will wipe the incident data stored in Redis. This is NOT reversible, so use caution!.\n")
    return_prompt
  end

  private

  def self.header(status_ok: true)
    clear
    prompt.say("WARNING: Redis is offline! We'll continue trying to connect in the background.") unless status_ok
    prompt.say(main_banner)
  end

  def self.return_prompt
    prompt.keypress("\n\nPress enter to return to the main menu...", keys: [:return])
    welcome(clear_screen: true)
  end
end