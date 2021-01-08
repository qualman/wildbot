require_relative './main_prompt'
require_relative '../helpers/prompt_helper'
require_relative '../models/incident'

module MainPrompt
  class IncidentPrompt
    include PromptHelper

    def initialize
      @incident ||= Incident.new(resume: true)
      @prompt = prompt
    end

    def run_incident
      MainPrompt.clear
      incident_header
      incident_prompt
    end

    private

    def incident_prompt
      input = @prompt.ask(">>") do |q|
        q.required true
      end
      handle_input(input)
    end

    def incident_header
      @prompt.say(incident_banner)
      @prompt.say("Wildbot - Incident #{@incident.id} - Started at #{@incident.started_at}")
      @prompt.say("RECOVERED at #{@incident.recovered_at}") if @incident.recovered_at
      @prompt.say(separator + "What's the latest update? ('list' to view previous updates, 'end' to resolve the incident.)")
    end

    def handle_input(input)
      case input
      when /^(end|exit)\s*$/i
        end_incident
      when /^list\s*$/i
        list_statuses
      else
        add_status(input)
      end

      incident_prompt
    end

    def add_status(input)
      result = @incident.add_status(input)
      @prompt.say("Done! Saved to current incident at #{@incident.statuses.last.posted_at}")
      @prompt.say("WARNING: Your redis instance is offline. Wildbot will keep trying to connect and store your data once it comes back online.") unless result
    end

    def list_statuses
      @prompt.say("Status history for incident #{@incident.id}")
      @incident.statuses.reverse_each do |status|
        @prompt.say("#{status.posted_at} - #{status.description}")
      end
      @prompt.say("#{@incident.started_at} - Incident #{@incident.id} started")
      incident_prompt
    end

    def end_incident
      @incident.update_incident(ended: true)
      @prompt.say("Whew! Incident resolved at #{@incident.ended_at}. It will be stored in the incident archive for export.")
      @prompt.say("\n\nReturning to main menu...")
      sleep(5)
      MainPrompt.welcome(clear_screen: true)
    end
  end
end