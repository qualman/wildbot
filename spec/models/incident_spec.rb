require_relative '../../app/models/incident'

describe Incident do
  let(:incident) { Incident.new }
  let(:status_1) { Status.new(description: "Status 1") }
  let(:status_2) { Status.new(description: "Status 2") }

  context 'starting a new incident' do
    it 'doesn\'t allow two concurrent incidents'
  end

  context 'resuming an incident' do
    it 'checks redis for a hanging incident'
    it 'starts a new incident if there was no incident in progress'
  end

  context 'updating status' do
    it 'should create a Status class object' do
      incident.add_status(description: "Test status")
      expect(incident.statuses.first).to be_kind_of(Status)
    end
  end

  context 'ending an incident' do
    it 'should not have ended_at instance variable until ended' do
      expect(incident.ended_at).to be_nil
      incident.update_incident(ended: true)
      expect(incident).to_not be_nil
    end
  end
end