require 'spec_helper'

require 'spec_helper'
require_db 'db_layer'
require_db 'grid'
require_aggregator 'processor'
require_intelligence 'processor'

module RCS
module Intelligence

describe 'Intelligence::Processor (position aggregates)' do

  use_db
  enable_license
  silence_alerts

  before { Entity.any_instance.stub(:fetch_address) }

  let(:operation) { Item.create!(name: 'testoperation', _kind: :operation, path: [], stat: ::Stat.new) }

  let(:alor) do
    target = Item.create!(name: 'alor', _kind: :target, path: [operation.id], stat: ::Stat.new)
    Entity.any_in({path: [target.id]}).first
  end

  let(:zeno) do
    target = Item.create!(name: 'zeno', _kind: :target, path: [operation.id], stat: ::Stat.new)
    Entity.any_in({path: [target.id]}).first
  end

  let(:etnok) do
    target = Item.create!(name: 'etnok', _kind: :target, path: [operation.id], stat: ::Stat.new)
    Entity.any_in({path: [target.id]}).first
  end

  let(:alor_aggregates_data) do
    [
      {day: "20130114", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-14 19:06:11 UTC'), "end"=>Time.parse('2013-01-14 19:18:11 UTC')}], data: {"position"=>[9.5939346, 45.5353563], "radius"=>30}},
      {day: "20130115", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-15 18:56:43 UTC'), "end"=>Time.parse('2013-01-15 20:48:30 UTC')}], data: {"position"=>[9.5939346, 45.5353563], "radius"=>30}},
      {day: "20130115", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-15 12:58:18 UTC'), "end"=>Time.parse('2013-01-15 13:12:18 UTC')}], data: {"position"=>[9.1891592, 45.4792009], "radius"=>30}},
      {day: "20130115", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-15 20:56:30 UTC'), "end"=>Time.parse('2013-01-15 21:03:30 UTC')}], data: {"position"=>[9.5953488, 45.5215992], "radius"=>40}},
      {day: "20130115", type: :position, count: 3, size: 0, info: [{"start"=>Time.parse('2013-01-15 08:41:43 UTC'), "end"=>Time.parse('2013-01-15 09:22:18 UTC')}, {"start"=>Time.parse('2013-01-15 14:49:29 UTC'), "end"=>Time.parse('2013-01-15 15:22:29 UTC')}, {"start"=>Time.parse('2013-01-15 17:22:19 UTC'), "end"=>Time.parse('2013-01-15 17:41:23 UTC')}], data: {"position"=>[9.1919074, 45.4768394], "radius"=>30}},
      {day: "20130116", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-16 08:42:13 UTC'), "end"=>Time.parse('2013-01-16 09:12:19 UTC')}], data: {"position"=>[9.1919074, 45.4768394], "radius"=>30}},
      {day: "20130116", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-16 12:32:06 UTC'), "end"=>Time.parse('2013-01-16 12:42:55 UTC')}], data: {"position"=>[9.1919074, 45.4768394], "radius"=>30}},
      {day: "20130116", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-16 13:42:41 UTC'), "end"=>Time.parse('2013-01-16 14:35:41 UTC')}], data: {"position"=>[9.1919074, 45.4768394], "radius"=>30}},
      {day: "20130116", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-16 16:43:14 UTC'), "end"=>Time.parse('2013-01-16 16:58:14 UTC')}], data: {"position"=>[9.1919074, 45.4768394], "radius"=>30}},
      {day: "20130116", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-16 19:34:40 UTC'), "end"=>Time.parse('2013-01-16 20:06:40 UTC')}], data: {"position"=>[9.5939346, 45.5353563], "radius"=>30}}
    ]
  end

  let(:zeno_aggregates_data) do
    [
      {day: "20130114", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-14 15:05:37 UTC'), "end"=>Time.parse('2013-01-14 18:01:43 UTC')}], data: {"position"=>[9.1911135, 45.4761132], "radius"=>64}},
      {day: "20130115", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-15 09:04:12 UTC'), "end"=>Time.parse('2013-01-15 10:08:45 UTC')}], data: {"position"=>[9.1911135, 45.4761132], "radius"=>64}},
      {day: "20130115", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-15 12:32:44 UTC'), "end"=>Time.parse('2013-01-15 13:51:44 UTC')}], data: {"position"=>[9.1896133, 45.4793905], "radius"=>30}},
      {day: "20130115", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-15 13:51:54 UTC'), "end"=>Time.parse('2013-01-15 17:49:31 UTC')}], data: {"position"=>[9.1884792, 45.4769144], "radius"=>32}},
      {day: "20130115", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-15 18:08:31 UTC'), "end"=>Time.parse('2013-01-15 18:29:31 UTC')}], data: {"position"=>[9.2376064, 45.4361061], "radius"=>48}},
      {day: "20130115", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-15 18:40:30 UTC'), "end"=>Time.parse('2013-01-15 18:52:50 UTC')}], data: {"position"=>[9.4970635, 45.3099474], "radius"=>30}},
      {day: "20130116", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-16 00:00:14 UTC'), "end"=>Time.parse('2013-01-16 07:47:34 UTC')}], data: {"position"=>[9.4974186, 45.3090868], "radius"=>32}},
      {day: "20130116", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-16 07:59:34 UTC'), "end"=>Time.parse('2013-01-16 08:15:34 UTC')}], data: {"position"=>[9.238571, 45.4343889], "radius"=>30}},
      {day: "20130116", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-16 08:37:34 UTC'), "end"=>Time.parse('2013-01-16 18:21:38 UTC')}], data: {"position"=>[9.1911135, 45.4761132], "radius"=>64}},
      {day: "20130116", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-16 18:49:38 UTC'), "end"=>Time.parse('2013-01-16 19:13:38 UTC')}], data: {"position"=>[9.2391028, 45.4334439], "radius"=>30}},
      {day: "20130116", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-16 19:36:38 UTC'), "end"=>Time.parse('2013-01-16 21:14:08 UTC')}], data: {"position"=>[9.4887711, 45.3016618], "radius"=>30}},
      {day: "20130117", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-17 00:00:22 UTC'), "end"=>Time.parse('2013-01-17 07:34:37 UTC')}], data: {"position"=>[9.4797608, 45.3184223], "radius"=>30}},
      {day: "20130117", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-17 07:42:37 UTC'), "end"=>Time.parse('2013-01-17 08:06:37 UTC')}], data: {"position"=>[9.4974186, 45.3090868], "radius"=>32}},
      {day: "20130117", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-17 12:44:33 UTC'), "end"=>Time.parse('2013-01-17 13:22:58 UTC')}], data: {"position"=>[9.1896133, 45.4793905], "radius"=>30}},
      {day: "20130117", type: :position, count: 2, size: 0, info: [{"start"=>Time.parse('2013-01-17 08:58:18 UTC'), "end"=>Time.parse('2013-01-17 09:22:02 UTC')}, {"start"=>Time.parse('2013-01-17 12:20:34 UTC'), "end"=>Time.parse('2013-01-17 12:38:33 UTC')}], data: {"position"=>[9.1919785, 45.4771958], "radius"=>32}}
    ]
  end

  let(:etnok_aggregates_data) do
    [
      {day: "20130115", type: :position, count: 2, size: 0, info: [{"start"=>Time.parse('2013-01-15 16:09:14 UTC'), "end"=>Time.parse('2013-01-15 16:49:14 UTC')}, {"start"=>Time.parse('2013-01-15 16:52:14 UTC'), "end"=>Time.parse('2013-01-15 17:25:14 UTC')}], data: {"position"=>[9.19190163157895, 45.4766150877193], "radius"=>40}},
      {day: "20130116", type: :position, count: 3, size: 0, info: [{"start"=>Time.parse('2013-01-16 10:01:24 UTC'), "end"=>Time.parse('2013-01-16 10:39:58 UTC')}, {"start"=>Time.parse('2013-01-16 16:05:50 UTC'), "end"=>Time.parse('2013-01-16 16:30:50 UTC')}, {"start"=>Time.parse('2013-01-16 16:37:50 UTC'), "end"=>Time.parse('2013-01-16 16:50:48 UTC')}], data: {"position"=>[9.1912577, 45.4761685], "radius"=>30}},
      {day: "20130116", type: :position, count: 2, size: 0, info: [{"start"=>Time.parse('2013-01-16 09:23:24 UTC'), "end"=>Time.parse('2013-01-16 09:43:24 UTC')}, {"start"=>Time.parse('2013-01-16 11:00:58 UTC'), "end"=>Time.parse('2013-01-16 12:41:31 UTC')}], data: {"position"=>[9.19190163157895, 45.4766150877193], "radius"=>40}},
      {day: "20130116", type: :position, count: 2, size: 0, info: [{"start"=>Time.parse('2013-01-16 13:38:36 UTC'), "end"=>Time.parse('2013-01-16 15:37:50 UTC')}, {"start"=>Time.parse('2013-01-16 16:55:21 UTC'), "end"=>Time.parse('2013-01-16 17:17:21 UTC')}], data: {"position"=>[9.19190163157895, 45.4766150877193], "radius"=>40}},
      {day: "20130118", type: :position, count: 1, size: 0, info: [{"start"=>Time.parse('2013-01-18 15:15:55 UTC'), "end"=>Time.parse('2013-01-18 16:35:26 UTC')}], data: {"position"=>[9.19190163157895, 45.4766150877193], "radius"=>40}}
    ]
  end

  def create_aggregates_for target_entity, data
    agent_id = 'agent_id'

    data.each do |params|
      Aggregate.target(target_entity.target_id).create! params.merge(aid: agent_id)
    end
  end

  def process_all_aggregates
    Entity.create_indexes

    create_aggregates_for alor, alor_aggregates_data
    create_aggregates_for zeno, zeno_aggregates_data
    create_aggregates_for etnok, etnok_aggregates_data

    [alor, zeno, etnok].each do |target_entity|
      Aggregate.target(target_entity.target_id).each do |aggregate|
        queue_entry = IntelligenceQueue.new target_id: target_entity.target_id, ident: aggregate.id, type: :aggregate
        Processor.process queue_entry
      end
    end

    [alor, zeno, etnok].each { |target_entity| target_entity.reload }
  end

  context 'given 3 moving targets' do

    let(:la_chiusa) { Entity.positions.where(position: [9.1891592, 45.4792009]).first }

    let(:ufficio) { Entity.positions.where(position: [9.1919074, 45.4768394]).first }

    let(:via_moscova) { Entity.positions.where(position: [9.1912577, 45.4761685]).first }

    context 'when the user has created a position entity' do

      let!(:zona_ufficio) { Entity.create! type: :position, position: [9.191330, 45.476768], position_attr: {accuracy: 100}, path: [operation.id] }

      before do
        process_all_aggregates
        zona_ufficio.reload
      end

      it 'creates 2 valid position entities' do
        expect(Entity.positions.count).to eql 2

        expect(la_chiusa).not_to be_nil
        expect(zona_ufficio).not_to be_nil
      end

      it 'links the target entities to the new position entities' do
        expect(alor.links.size).to eql 2
        expect(alor.linked_to?(la_chiusa)).to be_true
        expect(alor.linked_to?(zona_ufficio)).to be_true

        expect(etnok.links.size).to eql 1
        expect(etnok.linked_to?(zona_ufficio)).to be_true

        expect(zeno.links.size).to eql 2
        expect(zeno.linked_to?(la_chiusa)).to be_true
        expect(zeno.linked_to?(zona_ufficio)).to be_true
      end

    end

    context 'when all the position aggregates are processed' do

      before { process_all_aggregates }

      it 'creates 3 valid position entities' do
        expect(Entity.positions.count).to eql 3

        expect(la_chiusa).not_to be_nil
        expect(ufficio).not_to be_nil
        expect(via_moscova).not_to be_nil
      end

      it 'links the target entities to the new position entities' do
        expect(alor.links.size).to eql 2
        expect(alor.linked_to?(ufficio)).to be_true
        expect(alor.linked_to?(la_chiusa)).to be_true

        expect(etnok.links.size).to eql 2
        expect(etnok.linked_to?(ufficio)).to be_true
        expect(etnok.linked_to?(via_moscova)).to be_true

        expect(zeno.links.size).to eql 3
        expect(zeno.linked_to?(ufficio)).to be_true
        expect(zeno.linked_to?(la_chiusa)).to be_true
        expect(zeno.linked_to?(via_moscova)).to be_true
      end
    end
  end
end

end
end
