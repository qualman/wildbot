require 'securerandom'
require 'time'
require 'json'
require_relative './status'
require_relative './redis_client'

class Incident
  attr_accessor :id, :started_at, :statuses, :recovered_at, :ended_at

  def initialize(resume: false)
    recovered = recover_incident if resume

    @id = recovered ? recovered[:id] : SecureRandom.hex(4)
    @started_at = recovered ? recovered[:started_at] : Time.now
    @statuses = recovered ? recovered[:statuses] : []
    @ended_at = nil
  end

  def update_incident(ended: false)
    @ended_at = Time.now if ended
    update_to_redis
  end

  def add_status(description)
    @statuses << Status.new(description: description)
    update_incident
  end

  def as_json(options={})
    {
      id: @id,
      started_at: @started_at,
      statuses: @statuses.map { |s| s.as_json },
      ended_at: @ended_at
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end

  private

  def update_to_redis
    return false unless redis_client.upsert(self)
    return true
  end

  def recover_incident
    return unless incident = redis_client.fetch
    incident[:statuses] = recover_statuses(incident)
    @recovered_at = Time.now
    incident
  end

  def recover_statuses(incident_or_statuses)
    statuses = incident_or_statuses[:statuses] || incident_or_statuses
    new_status_objects = []

    statuses.each do |status_hash|
      recovered_status_object = Status.new(recover_from: status_hash)
      new_status_objects.push(recovered_status_object)
    end
    new_status_objects.sort_by(&:posted_at)
  end

  def redis_client
    @redis_client ||= RedisClient.new
  end
end
