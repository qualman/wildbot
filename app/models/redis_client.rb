require 'redis'
require 'dotenv'

Dotenv.load

INCIDENT_KEY =   ENV['REDIS_INCIDENT_KEY']        || "wildbot_active_incident"
ARCHIVE_KEY  =   ENV['REDIS_ARCHIVE_KEY']         || "wildbot_archived_incidents"
CONN_ATTEMPTS =  ENV['REDIS_CONN_ATTEMPTS'].to_i  || 5
CONN_DELAY =     ENV['REDIS_CONN_DELAY'].to_f     || 0.5
CONN_DELAY_MAX = ENV['REDIS_CONN_DELAY_MAX'].to_f || 2.0

class RedisClient
  def initialize
    @@redis_conn ||= Redis.new(
      :reconnect_attempts => CONN_ATTEMPTS,
      :reconnect_delay => CONN_DELAY,
      :reconnect_delay_max => CONN_DELAY_MAX,
    )
  end

  def upsert(object)
    return false unless connection_verified?

    if object.is_a?(Incident)
      return store_incident(object)
    end
  end

  def fetch(archive: false)
    return false unless connection_verified?

    archive ? get(ARCHIVE_KEY) : get(INCIDENT_KEY)
  end

  def connection_verified?
    begin
      @@redis_conn.ping && @@redis_conn.connected?
    rescue Errno::ECONNREFUSED, Redis::CannotConnectError
      return false
    end
  end

  def clear_archive
    store(ARCHIVE_KEY, [])
  end

  private

  def get(key)
    deserialize_data(@@redis_conn.get(key))
  end

  def store(key, value)
    @@redis_conn.set(key, serialize_data(value))
  end

  def store_incident(incident)
    if incident.ended_at
      result = move_incident_to_archive(incident)
    else
      result = store(INCIDENT_KEY, incident)
    end
    return result
  end

  def move_incident_to_archive(incident)
    archive = fetch(archive: true)
    updated_archive = archive ? archive.push(incident) : [incident]
    store(INCIDENT_KEY, nil)
    store(ARCHIVE_KEY, updated_archive)
  end

  def serialize_data(object)
    object.to_json
  end

  def deserialize_data(object)
    JSON.parse(object, symbolize_names: true) if object
  end

  def unfinished_incident_exists?
    fetch.ended_at ? true : false
  end
end